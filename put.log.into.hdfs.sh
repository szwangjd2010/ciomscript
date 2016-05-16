#!/bin/bash
#

ymd=${1:-$(date -d "1 days ago" +%04Y%02m%02d)}

logRootLocation="/sdc/ciompub/behavior/_clean"
hdfsBin="/opt/hadoop-2.7.1/bin/hdfs"
Products="lecai wangxiao qida mall"
LogTypes="action access"

product=''
logType=''

ym=${ymd:0:6}

getLogFileHdfsLocation() {
	echo -n "hdfs://hdc-54/raw/${logType}log"
}

getProductLogLocalFile() {
	echo -n "$logRootLocation/$ymd/${product}_${logType}.$ymd.all-instances.log"
}

getProductLogHdfsMonthlyFile() {
	echo -n "$(getLogFileHdfsLocation)/${product}.${logType}.${ym}.log"	
}

getProductLogHdfsFullFile() {
	echo -n "$(getLogFileHdfsLocation)/${product}.${logType}.log"	
}

main() {
	for product in $Products; do
		for logType in $LogTypes; do
			logFile=$(getProductLogLocalFile)
			$hdfsBin dfs -put $logFile $(getLogFileHdfsLocation)/
			$hdfsBin dfs -appendToFile $logFile $(getProductLogHdfsMonthlyFile)
			$hdfsBin dfs -appendToFile $logFile $(getProductLogHdfsFullFile)
			#echo $hdfsBin dfs -put $logFile $(getLogFileHdfsLocation)/
			#echo $hdfsBin dfs -appendToFile $logFile $(getProductLogHdfsFullFile)
		done
	done
}

main
