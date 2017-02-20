#!/bin/bash
#
source $CIOM_SCRIPT_HOME/ciom.util.sh
if [ "$JENKINS_HOME" == "" ]; then
	simulateJenkinsContainer
fi

host=$1
port=$2
webappsParent=$3
appName=$4
asRoot=${5:-NotAsRoot}

AppPackageFile="$appName.war"
MyWorkspace="$WORKSPACE/$appName/target"
WebappsLocation="$webappsParent/webapps"

appContextName=$appName


enterWorkspace() {
	execCmd "cd $MyWorkspace"
	execRemoteCmd $host $port "mkdir -p $WebappsLocation"
}

leaveWorkspace() {
	execCmd "cd $MyWorkspace"
}

uploadFiles() {
	upload $AppPackageFile $host $port $webappsParent/
}

applyAppPackage() {
	execRemoteCmd $host $port "unzip -o $webappsParent/$AppPackageFile -d $WebappsLocation/$appContextName"
}

backup() {
	timestamp=$(date +%04Y%02m%02d.%02k%02M%02S)
	execRemoteCmd $host $port "cd $WebappsLocation; tar -czvf $webappsParent/$AppPackageFile-$timestamp.tgz $appContextName"
}

clean() {
	execRemoteCmd $host $port "cd $WebappsLocation; rm -rf *"	
}

setAppContextName() {
	if [ $asRoot == "AsRoot" ]; then
		appContextName='ROOT'
	fi
}

preDeployApp() {
	
}

removeCatalinaLog() {
	execRemoteCmd $host $port "rm -rf $tomcatParent/tomcat*/logs/catalina.out"
}

postDeployApp() {
	
}

main() {
	setAppContextName
	enterWorkspace
	backup
	uploadFiles
	clean
	applyAppPackage
	leaveWorkspace
}

main

unsimulateJenkinsContainer
