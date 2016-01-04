#!/bin/bash
#


#products="qida lecai wangxiao mall"
#types="action access"
products="qida"
types="action"
brokers="10.10.23.164"

for i in $products; do
	for type in $types; do
		find /data -name $i_$type.log -exec tail -F {} | kafkacat -b $brokers -t $i.$type & \;
	done
done
