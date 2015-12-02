#!/bin/bash
#

dayAgo=${1:-1}
logFileYMD=$(date -d "$dayAgo days ago" +%04Y%02m%02d)

logRootLocation="/usr/share/nginx/html/ciompub/behavior"
fullActionLogFile="qida.action.log"
actionLogFile="$logRootLocation/$logFileYMD/qida_action.$logFileYMD.all-instances.log"

logFileHdfsLocation="hdfs://yxtdfs/log.action/"
hdfsBin="/opt/hadoop-2.7.1/bin/hdfs"

$hdfsBin dfs -put "$actionLogFile" "$logFileHdfsLocation/"
$hdfsBin dfs -appendToFile "$actionLogFile" "$logFileHdfsLocation/$fullActionLogFile"

