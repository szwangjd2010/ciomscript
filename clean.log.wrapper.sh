#!/bin/bash
# 
#

Products="qida lecai mall wangxiao"
Types="action access"

for product in $Products; do
	for logType in $LogTypes; do
		echo =====================================================================
		echo "$product - $logType"
		./clean.log.sh $product $logType
		echo
		echo
	done
done