#!/bin/bash
# 
#

TomcatSeed=$1
instanceAmount=$2
basePortDelta=${3:-0}

fileJavaOptsTpl=$CIOM_HOME/${4:-tomcat.catalina.java.opts.tpl}
fileHttpListenTpl=$CIOM_HOME/${5:-tomcat.server.xml.http.section.tpl}

echo $fileJavaOptsTpl
echo $fileHttpListenTpl


clean() {
	rm -rf $TomcatSeed-*
	rm -rf tomcats.bz2
	rm -rf tomcat.users.section
	rm -rf webapps
}

modifyTomcatUsersXml() {
	tomcatHome=$1
	
	fileUserSection="tomcat.users.section"
	fileUserSectionTpl="$CIOM_HOME/tomcat.users.section.tpl"
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

createOrignalWebapps() {
	cp -r $TomcatSeed/webapps webapps
}

modifyTomcatRealm() {
	tomcatHome=$1
	serverXml="$tomcatHome/conf/server.xml"
	fileHostRealm="$CIOM_HOME/tomcat.server.xml.realm.tpl"
	sed -i "/unpackWARs=\"true\" autoDeploy=\"true\"/ r $fileHostRealm" $serverXml
}

modifyTomcatCatalinaSh() {
	tomcatHome=$1
	catalinaSh="$tomcatHome/bin/catalina.sh"
	lineNum=$(echo -n $(sed -n '/# OS specific support/=' $catalinaSh))
	lineNum=$(( $lineNum - 1 ))
	sed -i "$lineNum r $fileJavaOptsTpl" $catalinaSh
}

removeUnusedAppsInOrignalWebapps() {
	rm -rf webapps/examples
	rm -rf webapps/docs
	rm -rf webapps/host-manager
	rm -rf webapps/ROOT
}

packageTomcats() {
	tar -cjvf tomcats.bz2 webapps $TomcatSeed-* 
}

linkInstanceWebapps2OriginalWebapps() {
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
		linkInstanceWebapps2OriginalWebapps $tomcatHome
	done
}

main() {
	clean
	createOrignalWebapps
	removeUnusedAppsInOrignalWebapps
	duplicateTomcat
	packageTomcats
}

main
