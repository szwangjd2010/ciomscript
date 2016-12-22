#!/bin/bash
#

usage() {
	echo $0 %log.to.cat %multiples
}

if [ $# -lt 2 ]; then
	usage
	exit 0
fi

target=$1
multiples=$2

for i in $(seq 1 $multiples); do
	/data/ydata/kafkacat.${target}.sh
done
