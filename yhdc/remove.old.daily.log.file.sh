#!/bin/bash
#

HDFS=/opt/hadoop-2.7.1/bin/hdfs
currentYM=$(date +%Y%m)
currentDay=$(date +%d)
allDailyLogList=all.instances.log.file
candidateToDeleteFileList=candidate.daily.log.file.list

echo > $candidateToDeleteFileList
$HDFS dfs -find /raw -name "*-instances.log" | sort > $allDailyLogList

cat $allDailyLogList | while read line; do 
	if (( $currentDay < 6 )); then
		continue
	fi

	fileYM=$(echo $line | grep -oP '(?<=\.)\d{6}(?=\d{2}\.)')
	if (( $fileYM < $currentYM )); then
		echo $line >> $candidateToDeleteFileList
	fi
done

if [ $(wc -l $candidateToDeleteFileList | awk '{print $1}') -gt 0 ]; then
	xargs -a $candidateToDeleteFileList $HDFS dfs -rm -f
fi

true
