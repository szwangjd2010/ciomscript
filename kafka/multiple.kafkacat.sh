#!/bin/bash
#

multiples=${1:-3}

for i in $(seq 1 $multiples); do
	./cat.qidaapievent.to.kafka.sh
done
