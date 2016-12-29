#!/bin/bash
multiples=${1:-1}
for i in $(seq 1 $multiples); do
	tail -F /mnt/nfs/nginx-jmc/lecai.api.access.log | kafkacat -b 10.10.23.164 -t yxt.jinpai.api &
done

