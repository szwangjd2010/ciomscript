#!/bin/bash
#

dayAgo=${1:-1}
logType=${2:-action}

logFileYMD=$(date -d "$dayAgo days ago" +%04Y%02m%02d)
logRootLocation="/usr/share/nginx/html/ciompub/behavior"
logFileHdfsLocation="hdfs://hdc-54/raw/${logType}log/"
hdfsBin="/opt/hadoop-2.7.1/bin/hdfs"
Products="lecai wangxiao qida mall"

putProductLog2Hdfs() {
	logFile=$1
	hdfsFullLogFile=$2
	
	$hdfsBin dfs -put "$logFile" "$logFileHdfsLocation/"
	$hdfsBin dfs -appendToFile "$logFile" "$hdfsFullLogFile"	
}

cleanLogData() {
	logFile=$1
	$CIOM_SCRIPT_HOME/clean.data-action.log.sh "$logFile"
}

getProductLogLocalFile() {
	product=$1
	echo -n "$logRootLocation/$logFileYMD/${product}_${logType}.$logFileYMD.all-instances.log"
}

getProductLogHdfsFullFile() {
	product=$1
	echo -n "$logFileHdfsLocation/${product}.${logType}.log"	
}

main() {
	for product in $Products; do
		logFile=$(getProductLogLocalFile $product)
		hdfsFullLogFile=$(getProductLogHdfsFullFile $product)

		cleanLogData "$logFile"
		putProductLog2Hdfs "$logFile" "$hdfsFullLogFile"
	done
}

main
