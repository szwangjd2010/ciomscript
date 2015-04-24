#!/bin/bash
# 

RUN_MODE=1
LOG=/tmp/_ciom.log

setMode() {
	RUN_MODE=$1
}

execCmd() {
	echo "$1" | tee -a $LOG
	if [ $RUN_MODE -eq 1 ]; then
		eval $1
	fi
}

#host, port, cmd
execRemoteCmd() {
	host=$1
	port=$2
	cmd=$3
	execCmd "ssh -p $port root@$host \"$cmd\""
}

#localFile host, port, remoteLocation
upload() {
	localFile=$1
	host=$2
	port=$3
	remoteLocation=$4
	
	execCmd "scp -P $port $localFile root@$host:$remoteLocation/"
}

#host, port, remoteFullPathFile, localPath
download() {
	host=$1
	port=$2
	remoteFullPathFile=$3
	localPath=$4
	execCmd "scp -P $port root@$host:$remoteFullPathFile $localPath/"
}

stopTomcats() {
	host=$1
	port=$2
	tomcatParent=$3
	execRemoteCmd $host $port "pkill -9 -f '$tomcatParent/tomcat7-'"
}

startTomcats() {
	host=$1
	port=$2
	tomcatParent=$3
	execRemoteCmd $host $port "find $tomcatParent -maxdepth 1 -type d -name 'tomcat7-*' | sort > /opt/_ciom_tomcats"
	download $host $port "/opt/_ciom_tomcats" "."
	for tomcat in $(cat _ciom_tomcats); do
		execRemoteCmd $host $port "export JRE_HOME='/usr/java/jdk1.7.0_76'; $tomcat/bin/startup.sh"
		sleep 30
	done
}

simulateJenkinsContainer() {
	if [ "$JENKINS_HOME" == "" ]; then
		export JENKINS_HOME=/var/lib/jenkins
		export BUILD_ID=20881212
		export WORKSPACE=/jenkins_workspace
		export CIOM_XXX=CIOM_XXX
	fi
}

unsimulateJenkinsContainer() {
	if [ "$CIOM_XXX" == "CIOM_XXX" ]; then
		unset JENKINS_HOME
		unset BUILD_ID
		unset WORKSPACE
		unset CIOM_XXX
	fi
}

getTimestamp() {
	echo -n $(date +%04Y%02m%02d.%02k%02M%02S)	
}

getDatestamp() {
	echo -n $(date +%04Y%02m%02d)	
}

