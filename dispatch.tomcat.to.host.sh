#!/bin/bash
#

source $CIOM_SCRIPT_HOME/ciom.util.sh
if [ "$JENKINS_HOME" == "" ]; then
	simulateJenkinsContainer
fi

host=$1
port=$2
tomcatParent=$3

oldPwd=$(pwd)
enterWorkspace() {
	cd $CIOM_CLI_WORKSPACE
}

leaveWorkspace() {
	cd $oldPwd
}

createTomcatParent() {
	execRemoteCmd $host $port "mkdir -p $tomcatParent"
}

uploadTomcats() {
	upload tomcats.bz2 $host $port $tomcatParent/
}

extractTomcats(){
	execRemoteCmd $host $port "tar -xjvf $tomcatParent/tomcats.bz2 -C $tomcatParent"
}

cleanTomcats(){
	execRemoteCmd $host $port "rm -rf $tomcatParent/tomcat[678]-[1-9] $tomcatParent/webapps $tomcatParent/tomcats.bz2"
}

main() {
	enterWorkspace
	createTomcatParent
	stopTomcats $host $port $tomcatParent
	cleanTomcats
	uploadTomcats
	extractTomcats
#	startTomcats $host $port $tomcatParent 3
	leaveWorkspace
}

main

unsimulateJenkinsContainer
