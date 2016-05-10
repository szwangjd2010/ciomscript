#!/bin/bash
#

dayAgo=${1:-1}
logFileYMD=$(date -d "$dayAgo days ago" +%04Y%02m%02d)

logRootLocation="/usr/share/nginx/html/ciompub/lecai.api"
fullTimeLogFile="time-full.log"
fullEventLogFile="event-full.log"
timeLogFile="$logRootLocation/$logFileYMD/time.$logFileYMD.all-instances.log"
eventLogFile="$logRootLocation/$logFileYMD/event.$logFileYMD.all-instances.log"

logFileHdfsLocation="hdfs://yxtdfs/raw/lecai/"
hdfsBin="/opt/hadoop-2.7.1/bin/hdfs"

$hdfsBin dfs -put "$timeLogFile" "$logFileHdfsLocation"
$hdfsBin dfs -appendToFile "$timeLogFile" "$logFileHdfsLocation/$fullTimeLogFile"

$hdfsBin dfs -put "$eventLogFile" "$logFileHdfsLocation"
$hdfsBin dfs -appendToFile "$eventLogFile" "$logFileHdfsLocation/$fullEventLogFile"
