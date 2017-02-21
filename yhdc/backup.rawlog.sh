#/bin/bash

source $CIOM_SCRIPT_HOME/ciom.util.sh
setMode 1

yesterday=$(date -d '-1 day' +%Y%m%d)
begin=${1:-$yesterday}
end=${2:-$yesterday}

HDFS='/opt/hadoop-2.7.1/bin/hdfs'
Port='/cloud.storage.port/rawlog'
OldPwd=$(pwd)

enterWorkspace() {
	execCmd "cd $Port"
}

leaveWorkspace() {
	execCmd "cd $OldPwd"
}

backupLog() {
	logFileList=$1
	cat $logFileList | while read logFile; do
		logFileName=$(echo $logFile | grep -oP '(?<=/)[^/]+(?=$)')
		ym=$(echo $logFileName | grep -oP '(?<=\.)[\d]{6}(?=\.|\d)')
		if [ -f $ym/$logFileName ]; then
			echo "$ym/$logFileName already exist!"
			continue
		fi

		execCmd "$HDFS dfs -get $logFile $ym/"
		execCmd "tar -czvf compressed/$ym/$logFileName.tgz $ym/$logFileName"
	done		
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
		execCmd "mkdir -p compressed/$ym compressed/$ymOneMonthAgo"

		execCmd "$HDFS dfs -find /raw -name '*.$ymOneMonthAgo.log' > monthly.list" 1
		backupLog "monthly.list"
		
		execCmd "$HDFS dfs -find /raw -name '*.$ymd.all-instances.log' > daily.list" 1
		backupLog "daily.list"
	done

	leaveWorkspace
}

main
