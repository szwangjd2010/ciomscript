#!/bin/bash

source $CIOM_SCRIPT_HOME/ciom.util.sh
setMode 0

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
	cat $logFileList | while read logFile; do
		logFileName=$(echo $logFile | grep -oP '(?<=/)[^/]+(?=$)')
		ym=$(echo $logFileName | grep -oP '(?<=\.)[\d]{6}(?=\.|\d)')
		localLogFile="$ym/$logFileName"
		localLogFileInPort=" $Port/$localLogFile"
		if [ -f $localLogFileInPort ] || [ -f ${localLogFileInPort}.tgz ]; then
			echo "$localLogFileInPort already exist!"
			continue
		fi

		execCmd "$HDFS dfs -get $logFile $ym/"
		execCmd "tar -czvf ${localLogFile}.tgz $localLogFile"
		execCmd "cp --parents ${localLogFile}.tgz $Port/"
		execCmd "rm -rf $localLogFile ${localLogFile}.tgz"
	done		
}

main() {
	enterWorkspace

	execCmd "mkdir -p $month"
	execCmd "$HDFS dfs -find /raw -name '*.$month.log' > monthly.list" 1
	backupLog "monthly.list"

	leaveWorkspace
}

main
