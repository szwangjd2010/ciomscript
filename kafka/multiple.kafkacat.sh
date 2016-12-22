#!/bin/bash
#

target=${1:-qida.api.event}
multiples=${2:-3}

for i in $(seq 1 $multiples); do
	/data/ydata/kafkacat.${target}.sh
done
