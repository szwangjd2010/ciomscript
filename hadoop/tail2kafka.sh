#!/bin/bash
#

products=${1:-qida lecai wangxiao mall}
types=${2:-action access}

brokers="10.10.23.164"
for product in $products; do
	for type in $types; do
		find /data -name ${product}_${type}.log -exec sh -c "tail -F {} | kafkacat -b $brokers -t ${product}.${type} &" \;
	done
done
