#!/bin/bash

source $CIOM_SCRIPT_HOME/ciom.util.sh
if [ "$JENKINS_HOME" == "" ]; then
	simulateJenkinsContainer
fi

#platform=$1
host=$1
path=$2
#svcport=$3
svcjarname=$3
logfullpath=$4

source /etc/profile
timestamp=$(date +%04Y%02m%02d.%02k%02M%02S)
#targetJarName="tools_html5_service-0.1.1"
port=22
backupRoot="/data/ciom/backup"
targetJarWithFullPath=$(find $M2_REPO_HOME -name "$svcjarname.jar")

enterWorkspace() {
	execCmd "cd $WORKSPACE"
}

leaveWorkspace() {
	execCmd "cd $WORKSPACE"
}

backupOldJar() {
	execRemoteCmd $host $port "mkdir -p $backupRoot;cp -r $path/$svcjarname.jar $backupRoot/$svcjarname.$timestamp.jar"
}

copyJarToTarget() {
	execRemoteCmd $host $port "mkdir -p $path"
	execCmd "scp -r $targetJarWithFullPath root@$host:$path"
}

#killSvcProcess() {
	#echo "function killSvcProcess() called"
	#netstat -nlp | grep 18086 | awk '{print $7}' | awk -F"/" '{print $1} | xargs kill -9'
#	execRemoteCmd $host $port "netstat -nlp| grep $svcport| awk '{print \\\$7}'| awk -F\\\"/\\\" '{print \\\$1}'| xargs kill -9"
#}

#startSvc() {
	#echo "function startSvc() called"
#	execRemoteCmd $host $port "nohup java -jar $path/$svcjarname.jar --server.port=$svcport >/dev/null 2>&1 &"
#}

printLog() {
	execRemoteCmd $host $port "sleep 2; tail -n 50 $logfullpath"
}

main() {
	enterWorkspace
	#killSvcProcess
	backupOldJar
	copyJarToTarget
	#startSvc
	#printLog
	leaveWorkspace
}

main $@
