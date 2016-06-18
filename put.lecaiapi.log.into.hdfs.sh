#!/bin/bash
#

dayAgo=${1:-1}
logFileYMD=$(date -d "$dayAgo days ago" +%04Y%02m%02d)

logRootLocation="/sdc/ciompub/lecai.api"
logFileHdfsLocation="hdfs://hdc-54/raw/lecai"
hdfsBin="/opt/hadoop-2.7.1/bin/hdfs"

put() {
	logType=$1
	logFileName=${logType}.${logFileYMD}.all-instances.log
	localLogFile="$logRootLocation/$logFileYMD/$logFileName"
	hdfsFile=$logFileHdfsLocation/$logFileName
	hdfsFullFile="$logFileHdfsLocation/${logType}-full.log"
	$hdfsBin dfs -test -f $hdfsFile 
	if [ $? -eq 0 ]; then
		echo "already exists"
		return
	fi

	$hdfsBin dfs -put $localLogFile $hdfsFile
	$hdfsBin dfs -appendToFile $localLogFile $hdfsFullFile
}

main() {
	put "lecaiapi_event"
	put "lecaiapi_time"
}

main
