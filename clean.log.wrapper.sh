#!/bin/bash
# 
#

Products="qida lecai mall wangxiao"
#Types="action access"
LogTypes="action"

for product in $Products; do
	for logType in $LogTypes; do
		./clean.log.sh $product $logType
	done
done