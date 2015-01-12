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
	execRemoteCmd $host $port "rm -rf $tomcatParent/tomcat7-* $tomcatParent/webapps tomcats.bz2"
}

main() {
	createTomcatParent
	stopTomcats $host $port $tomcatParent
	cleanTomcats
	uploadTomcats
	extractTomcats
	startTomcats $host $port $tomcatParent
}

main

unsimulateJenkinsContainer
