#!/bin/bash
# 
#
source $CIOM_SCRIPT_HOME/ciom.util.sh
if [ "$JENKINS_HOME" == "" ]; then
	simulateJenkinsContainer
fi

host=$1
port=$2
tomcatParent=$3

stopTomcats $host $port $tomcatParent
sleep 10
startTomcats $host $port $tomcatParent

unsimulateJenkinsContainer