#!/bin/bash
#

source $CIOM_SCRIPT_HOME/ciom.util.sh
source $CIOM_SCRIPT_HOME/yhdc/backup.rawlog.base.sh

setMode 1

lastMonth=$(date -d '-1 month' +%Y%m)
month=${1:-$lastMonth}

main() {
	enterWorkspace

	monthlyList="${month}.list"
	execCmd "mkdir -p $month"
	execCmd "$HDFS dfs -find /raw -name '*.$month.log' > $monthlyList" 
	backupLog "$month" "$monthlyList"

	leaveWorkspace
}

main
