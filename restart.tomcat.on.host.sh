#!/bin/bash
# 
#
if [ "$JENKINS_HOME" == "" ]; then
	source $CIOM_HOME/ciom.util.sh
	simulateJenkinsContainer
else 
	source /opt/ciom/ciom.util.sh
fi

host=$1
port=$2
tomcatParent=$3

stopTomcats $host $port $tomcatParent
sleep 10
startTomcats $host $port $tomcatParent

unsimulateJenkinsContainer