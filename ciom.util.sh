#!/bin/bash
# 

RUN_MODE=1
LOG=1
LOG_FILE=$CIOM_LOG_FILE

setMode() {
	RUN_MODE=$1
}

log() {
	LOG=$1
}

execCmd() {
	cmd=$1
	run=${2:-0}

	if [ $LOG -eq 1 ]; then
		echo "$1" | tee -a $LOG_FILE
	fi

	if [ $RUN_MODE -eq 1 ] || [ $run -eq 1 ]; then
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
	execRemoteCmd $host $port "pkill -9 -f '$tomcatParent/tomcat[678]-[1-9]'"
}

startTomcats() {
	host=$1
	port=$2
	tomcatParent=$3
	inteval=${4:-10}
	execRemoteCmd $host $port "find -L $tomcatParent -maxdepth 1 -type d -regextype posix-extended -regex '.*/tomcat[678]-[1-9]' | sort > /opt/_ciom_tomcats"
	download $host $port "/opt/_ciom_tomcats" "."
	for tomcat in $(cat _ciom_tomcats); do
		#execRemoteCmd $host $port "export JRE_HOME='/usr/java/jdk1.7.0_76'; $tomcat/bin/startup.sh"
		execRemoteCmd $host $port "$tomcat/bin/startup.sh"
		sleep $inteval
	done
}

stopTomcat() {
	host=$1
	port=$2
	tomcatHome=$3
	execRemoteCmd $host $port "pkill -9 -f '$tomcatHome'"
}

startTomcat() {
	host=$1
	port=$2
	tomcatHome=$3
	execRemoteCmd $host $port "$tomcatHome/bin/startup.sh"
	sleep 5
}

simulateJenkinsContainer() {
	if [ "$JENKINS_HOME" = "" ]; then
		export JENKINS_HOME=/var/lib/jenkins
		export BUILD_ID=20881212
		export WORKSPACE=/jenkins_workspace
		export CIOM_XXX=CIOM_XXX
	fi
}

unsimulateJenkinsContainer() {
	if [ "$CIOM_XXX" = "CIOM_XXX" ]; then
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

