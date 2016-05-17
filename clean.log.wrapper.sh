#!/bin/bash
# 
#
yesterday=$(date -d "1 days ago" +%04Y%02m%02d)
begin=${1:-$yesterday}
end=${2:-$yesterday}

Products="qida lecai mall wangxiao"
LogTypes="action access"

for product in $Products; do
	for logType in $LogTypes; do
		echo =====================================================================
		echo "$product - $logType"
		./clean.log.sh $begin $end $product $logType
		echo
		echo
	done
done