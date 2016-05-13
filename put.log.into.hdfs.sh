#!/bin/bash
#

ymd=${1:-$(date -d "1 days ago" +%04Y%02m%02d)}
logType=${2:-action}

logRootLocation="/sdc/ciompub/behavior/_clean"
logFileHdfsLocation="hdfs://hdc-54/raw/${logType}log/"
hdfsBin="/opt/hadoop-2.7.1/bin/hdfs"
Products="lecai wangxiao qida mall"

putProductLog2Hdfs() {
	logFile=$1
	hdfsFullLogFile=$2
	
	$hdfsBin dfs -put "$logFile" "$logFileHdfsLocation/"
	$hdfsBin dfs -appendToFile "$logFile" "$hdfsFullLogFile"	
}

getProductLogLocalFile() {
	product=$1
	echo -n "$logRootLocation/$ymd/${product}_${logType}.$ymd.all-instances.log"
}

getProductLogHdfsFullFile() {
	product=$1
	echo -n "$logFileHdfsLocation/${product}.${logType}.log"	
}

main() {
	for product in $Products; do
		logFile=$(getProductLogLocalFile $product)
		hdfsFullLogFile=$(getProductLogHdfsFullFile $product)
		putProductLog2Hdfs "$logFile" "$hdfsFullLogFile"
	done
}

main
