#!/bin/bash
#
if [ "$JENKINS_HOME" == "" ]; then
	source $CIOM_HOME/ciom.util.sh
	simulateJenkinsContainer
else 
	source $JENKINS_HOME/workspace/ciom/ciom.util.sh
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
	execRemoteCmd $host $port "cd $WebappsLocation; rm -rf $appContextName"	
}

makeAppAsRoot() {
	execRemoteCmd $host $port "rm -rf $WebappsLocation/ROOT; mv $WebappsLocation/$appContextName $WebappsLocation/ROOT"
}

preDeployApp() {
	stopTomcats $host $port $tomcatParent
}

postDeployApp() {
	if [ $asRoot == "AsRoot" ]; then
		makeAppAsRoot
	fi
	
	startTomcats $host $port $tomcatParent
}

main() {
	enterWorkspace
	preDeployApp
	backup
	clean
	uploadFiles
	applyAppPackage
	postDeployApp
	leaveWorkspace
}

main

unsimulateJenkinsContainer