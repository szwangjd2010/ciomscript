#!/bin/bash
#

dayAgo=${1:-1}
logFileYMD=$(date -d "$dayAgo days ago" +%04Y%02m%02d)

logRootLocation="/sdc/ciompub/lecai.api"
logFileHdfsLocation="hdfs://hdc-54/raw/lecai/"
hdfsBin="/opt/hadoop-2.7.1/bin/hdfs"

put() {
	logType=$1
	localLogFile="$logRootLocation/$logFileYMD/${logType}.$logFileYMD.all-instances.log"
	$hdfsBin dfs -put $localLogFile $logFileHdfsLocation
	$hdfsBin dfs -appendToFile $localLogFile $logFileHdfsLocation/${logType}-full.log
}

main() {
	put "event"
	put "time"
}

main
