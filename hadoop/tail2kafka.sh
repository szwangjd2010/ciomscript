#!/bin/bash
#


#products="qida lecai wangxiao mall"
#types="action access"
products="qida"
types="action"
brokers="10.10.23.164"

for product in $products; do
	for type in $types; do
		find /data -name ${product}_${type}.log -exec tail -F {} \; | nohup kafkacat -b $brokers -t ${product}.${type} & 
	done
done
