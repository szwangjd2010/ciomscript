#!/bin/bash
#

dayAgo=${1:-1}
logFileYMD=$(date -d "$dayAgo days ago" +%04Y%02m%02d)

logFile="/usr/share/nginx/html/ciompub/lecai.api/$logFileYMD/time.$logFileYMD.all-instances.log"
logFileHdfsLocation="hdfs://yxtdfs/log.api.lecai/"
hdfsBin="/opt/hadoop-2.7.1/bin/hdfs"

$hdfsBin dfs -put $logFile $logFileHdfsLocation
