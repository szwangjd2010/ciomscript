#!/bin/bash
#
source $CIOM_SCRIPT_HOME/log.common.sh "$@"

logRootLocation="/sdc/ciompub/behavior/_clean"
hdfsBin="/opt/hadoop-2.7.1/bin/hdfs"

getLogFileHdfsLocation() {
	echo -n "hdfs://hdc-54/raw/${logType}log"
}

getHiveDbHdfsRoot() {
	echo -n "hdfs://hdc-54/user/hive/warehouse/yxt.db"
}

getLogLocalFile() {
	echo -n "$logRootLocation/$ymd/${product}_${logType}.$ymd.all-instances.log"
}

getLogMonthlyFileName() {
	echo -n "${product}.${logType}.${ym}.log"	
}

getLogHdfsMonthlyFile() {
	echo -n "$(getLogFileHdfsLocation)/$(getLogMonthlyFileName)"	
}

getLogHdfsFullFile() {
	echo -n "$(getLogFileHdfsLocation)/${product}.${logType}.log"	
}

getHiveTablePartitionHdfsFile() {
	echo -n "$(getHiveDbHdfsRoot)/${product}_${logType}log/year=${year}/month=${month}/$(getLogMonthlyFileName)"
}

main() {
	ymdEnd=$(date -d "$end" +%04Y%02m%02d)

	for (( i=0; i<1000; i++ )); do
		ymd=$(date -d "$begin +$i days" +%04Y%02m%02d)
		ym=${ymd:0:6}
		year=${ymd:0:4}
		month=${ymd:4:2}

		if (( $ymd > $ymdEnd )); then
			break
		fi

		for product in $Products; do
			for logType in $LogTypes; do
				logFile=$(getLogLocalFile)
				$hdfsBin dfs -put $logFile $(getLogFileHdfsLocation)/
				$hdfsBin dfs -appendToFile $logFile $(getLogHdfsMonthlyFile)
				$hdfsBin dfs -appendToFile $logFile $(getLogHdfsFullFile)
				$hdfsBin dfs -appendToFile $logFile $(getHiveTablePartitionHdfsFile)
			done
		done
	done	
}

main
