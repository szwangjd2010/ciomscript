#!/bin/bash

source $CIOM_SCRIPT_HOME/ciom.util.sh
setMode 1

yesterday=$(date -d '-1 day' +%Y%m%d)
begin=${1:-$yesterday}
end=${2:-$yesterday}

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
		execCmd "rm -rf $localLogFile  ${localLogFile}.tgz"
	done		
}

clearDailyLog() {
	 ym=$1
	 execCmd "find $Port/$ym/ -name '*.all-instances.log.tgz' -delete"
}

main() {
	enterWorkspace

	ymdEnd=$(date -d "$end" +%Y%m%d)
	for (( i=0; i<1000; i++ )); do
		iday="$begin +$i day"
		ymd=$(date -d "$iday" +%Y%m%d)
		if (( $ymd > $ymdEnd )); then
			break
		fi

		ym=$(date -d "$iday" +%Y%m)
		ymOneMonthAgo=$(date -d "$iday -1 month" +%Y%m)
		execCmd "mkdir -p $ym $ymOneMonthAgo"

		execCmd "$HDFS dfs -find /raw -name '*.$ymOneMonthAgo.log' > monthly.list" 1
		backupLog "monthly.list"

		execCmd "$HDFS dfs -find /raw -name '*.$ymd.all-instances.log' > daily.list" 1
		backupLog "daily.list"
		
		clearDailyLog $ymOneMonthAgo
	done

	leaveWorkspace
}

main
