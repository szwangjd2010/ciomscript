#!/bin/bash
# 
#
TomcatSeed=$1
instanceAmount=$2
basePortDelta=$3
shareWebapps=${4:-1}

fileJavaOptsTpl=$CIOM_SCRIPT_HOME/${5:-tomcat.catalina.java.opts.tpl}
fileHttpListenTpl=$CIOM_SCRIPT_HOME/${6:-tomcat.server.xml.http.section.tpl}
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
	cp -r $CIOM_REPOS_HOME/$TomcatSeed.seed $TomcatSeed
}

modifyTomcatUsersXml() {
	tomcatHome=$1
	
	fileUserSection="tomcat.users.section"
	fileUserSectionTpl="$CIOM_SCRIPT_HOME/tomcat.users.section.tpl"
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
	sed -i '/<Connector port="8080"/ i <!-- #CIOM_BEGIN#' $serverXml
	sed -i '/A "Connector" using the shared thread pool/ i #CIOM_END# -->' $serverXml
	sed -i "/#CIOM_END# -->/ r $fileHttpListenTpl" $serverXml
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
	fileHostRealm="$CIOM_SCRIPT_HOME/tomcat.server.xml.realm.tpl"
	sed -i "/unpackWARs=\"true\" autoDeploy=\"true\"/ r $fileHostRealm" $serverXml
}

modifyTomcatCatalinaSh() {
	tomcatHome=$1
	catalinaSh="$tomcatHome/bin/catalina.sh"
	lineNum=$(echo -n $(sed -n '/# OS specific support/=' $catalinaSh))
	lineNum=$(( $lineNum - 1 ))
	sed -i "$lineNum r $fileJavaOptsTpl" $catalinaSh
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

main() {
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

main
