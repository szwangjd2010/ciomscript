#!/bin/bash
#
source $CIOM_SCRIPT_HOME/ciom.util.sh
if [ "$JENKINS_HOME" == "" ]; then
	simulateJenkinsContainer
fi

host=$1
port=$2
tomcatParent=$3
appName=$4
backupTarget=$5
asRoot=${6:-NotAsRoot}

WebappsLocation="$tomcatParent/webapps"
RemoteWorkspace="$remoteWorkspace"
AppPackageFile="$appName.war"

appContextName=$appName

applyRollbackPackage() {
	execRemoteCmd $host $port "tar xvf $tomcatParent/$backupTarget -C $tomcatParent/;mv $tomcatParent/$appContextName $WebappsLocation/$appContextName"
}

clean() {
	execRemoteCmd $host $port "cd $WebappsLocation; rm -rf $appContextName $appName"
}

setAppContextName() {
	if [ $asRoot == "AsRoot" ]; then
		appContextName='ROOT'
	fi
}

preDeployApp() {
	stopTomcats $host $port $tomcatParent
	sleep 3
}

removeCatalinaLog() {
	execRemoteCmd $host $port "rm -rf $tomcatParent/tomcat*/logs/catalina.out"
}

postDeployApp() {
	removeCatalinaLog
	startTomcats $host $port $tomcatParent
}

backup() {
	execCmd "ssh -p $port root@$host \"test -e $WebappsLocation/$appContextName/WEB-INF/classes/version.txt\""
	if [ $? == 0 ]; then
		backupPostfix=$(ssh -p $port root@$host "head -1 $WebappsLocation/$appContextName/WEB-INF/classes/version.txt")
		execRemoteCmd $host $port "cd $WebappsLocation; tar -czvf $tomcatParent/$AppPackageFile-$backupPostfix.tgz $appContextName"
	else
		timestamp=$(date +%04Y%02m%02d.%02k%02M%02S)
		execRemoteCmd $host $port "cd $WebappsLocation; tar -czvf $tomcatParent/$AppPackageFile-$timestamp.tgz $appContextName"
	fi
}

main() {
	setAppContextName
	preDeployApp
	backup
	clean
	applyRollbackPackage
	postDeployApp

}

main

unsimulateJenkinsContainer