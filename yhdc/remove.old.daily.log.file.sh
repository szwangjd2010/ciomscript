#!/bin/bash
#

lastYM=$(date -d '-1 month' +%Y%m)
targetYM=${1:-$lastYM}

dayOfMonth=$(date +%e)
if (( $dayOfMonth < 10 )); then
    echo "day of month is less than 10, exit 0."
    exit 0
fi

HDFS=/opt/hadoop-2.7.1/bin/hdfs
candidateToDeleteFileList=candidate.daily.log.file.list
$HDFS dfs -find /raw -name "*.${targetYM}??.all-instances.log" | sort > $candidateToDeleteFileList
cat $candidateToDeleteFileList | xargs -i $HDFS dfs -rm -f {}
