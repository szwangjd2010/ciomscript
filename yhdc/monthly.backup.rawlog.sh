#!/bin/bash
#

source $CIOM_SCRIPT_HOME/ciom.util.sh
source $CIOM_SCRIPT_HOME/yhdc/backup.rawlog.base.sh

setMode 1

lastMonth=$(date -d '-1 month' +%Y%m)
month=${1:-$lastMonth}

HDFS='/opt/hadoop-2.7.1/bin/hdfs'
Port='/cloud.storage.port/rawlog'
Workspace='/sdc/rawlog.backup.ws'

OldPwd=$(pwd)

enterWorkspace() {
	execCmd "cd $Workspace"
}

leaveWorkspace() {
	execCmd "cd $OldPwd"
}

backupLog() {
	to=$1
	logFileList=$2
	cnt=$(wc -l $logFileList | awk '{print $1}')
	counter=1
	cat $logFileList | while read logFile; do
		logFileName=$(echo $logFile | grep -oP '(?<=/)[^/]+(?=$)')
		localLogFile="$to/$logFileName"
		portLogFile=" $Port/$localLogFile"
		if [ -f $portLogFile ] || [ -f ${portLogFile}.tgz ]; then
			echo "$portLogFile already exist!"
			continue
		fi

		execCmd "$HDFS dfs -get $logFile $to/"
		execCmd "tar -czvf ${localLogFile}.tgz $localLogFile"
		execCmd "cp --parents ${localLogFile}.tgz $Port/"
		execCmd "rm -rf $localLogFile ${localLogFile}.tgz"
		execCmd "touch ${localLogFile}.${counter}..${cnt}.done"
		(( counter++ ))
	done		
}

main() {
	enterWorkspace

	monthlyList="${month}.list"
	execCmd "mkdir -p $month"
	execCmd "$HDFS dfs -find /raw -name '*.$month.log' > $monthlyList" 
	backupLog "$month" "$monthlyList"

	leaveWorkspace
}

main
