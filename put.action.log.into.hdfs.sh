#!/bin/bash
#

dayAgo=${1:-1}
logFileYMD=$(date -d "$dayAgo days ago" +%04Y%02m%02d)
logRootLocation="/usr/share/nginx/html/ciompub/behavior"
logFileHdfsLocation="hdfs://hdc-54/raw/actionlog/"
hdfsBin="/opt/hadoop-2.7.1/bin/hdfs"
Products="lecai wangxiao qida mall"

putProductActionLog2Hdfs() {
	actionLogFile=$1
	hdfsFullActionLogFile=$2
	
	$hdfsBin dfs -put "$actionLogFile" "$logFileHdfsLocation/"
	$hdfsBin dfs -appendToFile "$actionLogFile" "$hdfsFullActionLogFile"	
}

cleanLogData() {
	logFile=$1
	$CIOM_SCRIPT_HOME/clean.data-action.log.sh "$logFile"
}

getProductActionLogLocalFile() {
	product=$1
	echo -n "$logRootLocation/$logFileYMD/${product}_action.$logFileYMD.all-instances.log"
}

getProductActionLogHdfsFullFile() {
	product=$1
	echo -n "$logFileHdfsLocation/${product}.action.log"	
}

main() {
	for product in $Products; do
		actionLogFile=$(getProductActionLogLocalFile $product)
		hdfsFullLogFile=$(getProductActionLogHdfsFullFile $product)

		cleanLogData "$actionLogFile"
		putProductActionLog2Hdfs "$actionLogFile" "$hdfsFullLogFile"
	done
}

main
