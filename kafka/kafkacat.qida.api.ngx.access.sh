#!/bin/bash
multiples=${1:-1}
for i in $(seq 1 $multiples); do
	tail -F /mnt/nfs/nginx-qida/access_apiqida.log | kafkacat -b 10.10.23.164 -t yxt.qida.api &
done

