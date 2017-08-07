#!/bin/bash

source $CIOM_SCRIPT_HOME/ciom.util.sh
source $CIOM_SCRIPT_HOME/yhdc/backup.rawlog.base.sh

setMode 1

yesterday=$(date -d '-1 day' +%Y%m%d)
begin=${1:-$yesterday}
end=${2:-$yesterday}

main() {
	enterWorkspace

	ymdEnd=$(date -d "$end" +%Y%m%d)
	for (( i=0; i<1000; i++ )); do
		iday="$begin +$i day"
		ymd=$(date -d "$iday" +%Y%m%d)
		if (( $ymd > $ymdEnd )); then
			break
		fi

		execCmd "mkdir -p $ymd"
		dailyList="${ymd}.list"
		execCmd "$HDFS dfs -find /raw -name '*.$ymd.all-instances.log' | grep -v '_error.' > $dailyList"
		backupLog "$ymd" "$dailyList"
	done

	leaveWorkspace
}

main
