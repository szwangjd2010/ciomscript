#!/bin/bash
#
if [ "$JENKINS_HOME" == "" ]; then
	source $CIOM_HOME/ciom.util.sh
	simulateJenkinsContainer
else 
	source $JENKINS_HOME/workspace/ciom/ciom.util.sh
fi

appName=$1
host=$2
port=$3
tomcatParent=$4
asRoot=${5:-NotAsRoot}

AppPackageFile="$appName.$BUILD_ID.tgz"
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
	execRemoteCmd $host $port "tar --overwrite -xzpvf $tomcatParent/$AppPackageFile -C $WebappsLocation"
}

backup() {
	timestamp=$(date +%04Y%02m%02d.%02k%02M%02S)
	execRemoteCmd $host $port "cd $WebappsLocation; tar -czvf $tomcatParent/$appName-$timestamp.tgz $appContextName;"
}

makeAppAsRoot() {
	execRemoteCmd $host $port "rm -rf $WebappsLocation/ROOT; mv $WebappsLocation/$appName $WebappsLocation/ROOT"
}

preDeployApp() {
	stopTomcats $host $port $tomcatParent
	
	if [ $asRoot == "AsRoot" ]; then
		appContextName=ROOT
	fi
}

postDeployApp() {
	if [ $asRoot == "AsRoot" ]; then
		makeAppAsRoot #must be before start tomcats
	fi
	
	startTomcats $host $port $tomcatParent
}

main() {
	enterWorkspace
	preDeployApp
	uploadFiles
	backup
	applyAppPackage
	postDeployApp
	leaveWorkspace
}

main

unsimulateJenkinsContainer