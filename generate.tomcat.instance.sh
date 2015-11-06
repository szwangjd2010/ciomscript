#!/bin/bash
# 
#
TomcatSeed=$1
instanceAmount=$2
basePortDelta=${3:-0}
shareWebapps=${4:-1}
noAjp=${5:-1}
protcolName=${6:-nio}
fileJavaOptsTpl=$CIOM_SCRIPT_HOME/tomcat/${7:-tomcat.catalina.java.opts.tpl}
fileHttpListenTpl=$CIOM_SCRIPT_HOME/tomcat/${8:-tomcat.server.xml.http.section.tpl}

declare -A Protcols=( [1.1]='HTTP/1.1' [nio]='org.apache.coyote.http11.Http11NioProtocol' [apr]='org.apache.coyote.http11.Http11AprProtocol' )
protcol=${Protcols[$protcolName]}
oldPwd=$(pwd)


enterWorkspace() {
	cd $CIOM_CLI_WORKSPACE
}

leaveWorkspace() {
	cd $oldPwd
}

clean() {
	rm -rf $TomcatSeed-*
	rm -rf tomcats.bz2
	rm -rf tomcat.users.section
	rm -rf webapps
	rm -rf $TomcatSeed
}

cloneSeed() {
	tar -xjvf $CIOM_REPOS_HOME/$TomcatSeed.seed.bz2
}

modifyTomcatUsersXml() {
	tomcatHome=$1
	
	fileUserSection="tomcat.users.section"
	fileUserSectionTpl="$CIOM_SCRIPT_HOME/tomcat/tomcat.users.section.tpl"
	/bin/cp -rf $fileUserSectionTpl $fileUserSection

	user="admin"
	userPwd=$(echo -n $(echo -n 'NotAdmin' | sha256sum | awk {'print $1'}))
	sed -i "s/#USER#/$user/" $fileUserSection
	sed -i "s/#PWD#/$userPwd/" $fileUserSection
	
	tomcatUsersXml="$tomcatHome/conf/tomcat-users.xml"
	
	lineNum=$(echo -n $(sed -n '/<\/tomcat-users>/=' $tomcatUsersXml))
	lineNum=$(( $lineNum - 1 ))
	sed -i "$lineNum r $fileUserSection" $tomcatUsersXml
}

modifyTomcatHttpConnector() {
	tomcatHome=$1
	serverXml="$tomcatHome/conf/server.xml"
	sed -i '/<Connector port="8080"/ i <!-- #CIOM_BEGIN#-8080' $serverXml
	sed -i '/A "Connector" using the shared thread pool/ i #CIOM_END#-8080 -->' $serverXml
	sed -i "/#CIOM_END#-8080 -->/ r $fileHttpListenTpl" $serverXml
	sed -i "s/#PROTCOL#/$protcol/"  $serverXml
}

commentAjp() {
	tomcatHome=$1
	serverXml="$tomcatHome/conf/server.xml"	
	sed -i '/<Connector port="8009"/i <!-- #CIOM_BEGIN#-AJP' $serverXml
	sed -i '/<Connector port="8009"/a #CIOM_END#-AJP -->' $serverXml
}

modifyTomcatListenPort() {
	tomcatIndex=$1
	tomcatHome=$2

	serverXml="$tomcatHome/conf/server.xml"
	portDelta=$(( $tomcatIndex - 1 + $basePortDelta ))
	httpPort=$(( 8080 + $portDelta ))
	shutdownPort=$(( 8005 + $portDelta ))
	ajpPort=$(( 8009 + 10 + $portDelta ))
	
	sed -i "s/8080/$httpPort/g" $serverXml
	sed -i "s/8005/$shutdownPort/g" $serverXml
	sed -i "s/8009/$ajpPort/g" $serverXml
}

createSharedWebapps() {
	cp -r $TomcatSeed/webapps webapps
}

modifyTomcatRealm() {
	tomcatHome=$1
	serverXml="$tomcatHome/conf/server.xml"
	fileHostRealm="$CIOM_SCRIPT_HOME/tomcat/tomcat.server.xml.realm.tpl"
	sed -i "/unpackWARs=\"true\" autoDeploy=\"true\"/ r $fileHostRealm" $serverXml
}

modifyTomcatCatalinaSh() {
	tomcatHome=$1
	catalinaSh="$tomcatHome/bin/catalina.sh"
	lineNum=$(echo -n $(sed -n '/# OS specific support/=' $catalinaSh))
	lineNum=$(( $lineNum - 1 ))
	sed -i "$lineNum r $fileJavaOptsTpl" $catalinaSh
	if [ $protcolName == 'apr' ]; then
		sed -i '/# OS specific support/i CATALINA_OPTS="-Djava.library.path=/usr/local/apr/lib"' $catalinaSh
	fi
}

removeWebappsUnusedApp() {
	webappsLocation=$TomcatSeed/webapps
	rm -rf $webappsLocation/examples
	rm -rf $webappsLocation/docs
	rm -rf $webappsLocation/host-manager
	rm -rf $webappsLocation/ROOT
}

packageTomcats() {
	if [ $shareWebapps -eq 1 ]; then
		tar -cjvf tomcats.bz2 webapps $TomcatSeed-* 
	else
		tar -cjvf tomcats.bz2 $TomcatSeed-* 
	fi
}

linkInstanceWebapps2SharedWebapps() {
	tomcatHome=$1
	rm -rf $tomcatHome/webapps
	(cd $tomcatHome; ln -s ../webapps webapps)
}

duplicateTomcat() {
	for tomcatIndex in `seq 1 $instanceAmount`;
	do
		tomcatHome="$TomcatSeed-$tomcatIndex"
		cp -r $TomcatSeed $tomcatHome
		
		if [ $noAjp -eq 1 ]; then
			commentAjp $tomcatHome
		fi

		modifyTomcatHttpConnector $tomcatHome
		modifyTomcatListenPort $tomcatIndex $tomcatHome
		modifyTomcatRealm $tomcatHome
		modifyTomcatUsersXml $tomcatHome
		modifyTomcatCatalinaSh $tomcatHome

		if [ $shareWebapps -eq 1 ]; then
			linkInstanceWebapps2SharedWebapps $tomcatHome
		fi
	done
}

usage() {
	cat <<EOF
usage:
$0 %tomcatSeed %instanceAmount [%basePortDelta %shareWebapps ...]

tomcatSeed: tomcat7 or tomcat8
instanceAmount: [1-10]
basePortDelta: >= 0
shareWebapps: 
  1 -> multi tomcat instance on same host share webapps
  0 -> do not share
  default is 1
noAjp: 
  1 -> comment ajp listen
  0 -> do not comment
  default is 1
protcolName: 1.1, nio, apr, default nio
fileJavaOptsTpl: default is tomcat.catalina.java.opts.tpl
fileHttpListenTpl: default is tomcat.server.xml.http.section.tpl


EOF
}

main() {
	if [ $1 -lt 2 ]; then
		usage
		return 0
	fi

	enterWorkspace
	clean
	cloneSeed

	removeWebappsUnusedApp
	if [ $shareWebapps -eq 1 ]; then
		createSharedWebapps
	fi

	duplicateTomcat
	packageTomcats
	leaveWorkspace
}

main $#
