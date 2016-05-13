#!/bin/bash
# 
#
begin=${1:-2015-12-30}
end=${1:-2016-05-10}

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