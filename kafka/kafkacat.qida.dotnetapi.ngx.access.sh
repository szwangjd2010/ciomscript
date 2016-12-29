#!/bin/bash
multiples=${1:-1}
broker=10.10.23.164
topic="yxt.qida.dotnet.api"
for i in $(seq 1 $multiples); do
	tail -F /mnt/nfs/nginx-qida/access_el_api.log | kafkacat -b $broker -t $topic &
	tail -F /mnt/nfs/nginx-qida/access_el_api_ssl.log | kafkacat -b $broker -t $topic & 
done

