#!/bin/bash
# 
#

Products="qida lecai mall wangxiao"
LogTypes="action access"

for product in $Products; do
	for logType in $LogTypes; do
		echo =====================================================================
		echo "$product - $logType"
		./clean.log.sh $product $logType
		echo
		echo
	done
done