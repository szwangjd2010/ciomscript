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
asRoot=${5:-NotAsRoot}

AppPackageFile="$appName.war"
MyWorkspace="$WORKSPACE/$appName/target"
WebappsLocation="$tomcatParent/webapps"

appContextName=$appName

enterWorkspace() {
	execCmd "cd $MyWorkspace"
}

leaveWorkspace() {
	execCmd "cd $MyWorkspace"
}

uploadFiles() {
	upload $AppPackageFile $host $port $tomcatParent/
}

applyAppPackage() {
	execRemoteCmd $host $port "unzip -o $tomcatParent/$AppPackageFile -d $WebappsLocation/$appContextName"
}

backup() {
	timestamp=$(date +%04Y%02m%02d.%02k%02M%02S)
	execRemoteCmd $host $port "cd $WebappsLocation; tar -czvf $tomcatParent/$AppPackageFile-$timestamp.tgz $appContextName"
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

main() {
	setAppContextName
	enterWorkspace
	uploadFiles
	preDeployApp
	backup
	clean
	applyAppPackage
	postDeployApp
	leaveWorkspace
}

main

unsimulateJenkinsContainer