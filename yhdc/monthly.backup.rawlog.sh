#!/bin/bash
#

source $CIOM_SCRIPT_HOME/ciom.util.sh
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
	logFileList=$1
	cnt=$(wc -l $logFileList | awk '{print $1}')
	counter=1
	cat $logFileList | while read logFile; do
		logFileName=$(echo $logFile | grep -oP '(?<=/)[^/]+(?=$)')
		ym=$(echo $logFileName | grep -oP '(?<=\.)[\d]{6}(?=\.|\d)')
		localLogFile="$ym/$logFileName"
		portLogFile=" $Port/$localLogFile"
		if [ -f $portLogFile ] || [ -f ${portLogFile}.tgz ]; then
			echo "$portLogFile already exist!"
			continue
		fi

		execCmd "$HDFS dfs -get $logFile $ym/"
		execCmd "tar -czvf ${localLogFile}.tgz $localLogFile"
		execCmd "cp --parents ${localLogFile}.tgz $Port/"
		execCmd "rm -rf $localLogFile ${localLogFile}.tgz"
		execCmd "touch ${localLogFile}.${counter}..${cnt}.done"
		(( counter++ ))
	done		
}

main() {
	enterWorkspace

	listFile="${month}.list"
	execCmd "mkdir -p $month"
	execCmd "$HDFS dfs -find /raw -name '*.$month.log' > $listFile" 
	backupLog "$listFile"

	leaveWorkspace
}

main
