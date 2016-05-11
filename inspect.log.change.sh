#!/bin/bash
# 
#
env=${1:-Local}

getProdFile() {
	echo -n "/data/ws-1/tomcat7-1/logs/yxt/qida_action.$1.log"
}

getLocalFile() {
	echo -n "/sdc/ciompub/behavior/$1/qida_action.$1.all-instances.log"
}

getFile() {
	echo -n $(get${env}File $1)
}

showFieldsSeparatorInfo() {
	f=$1
	awk -F','  '{printf "     ,: %02d", NF; exit}' $f
	awk -F' '  '{printf "    \\s: %02d", NF; exit}' $f
	awk -F'\t' '{printf "    \\t: %02d", NF; exit}' $f
	echo
}

main () {
	for (( i=1; i<180; i++)); do
		ymd=$(date -d "$i days ago" +%04Y%02m%02d)

		f=$(getFile $ymd)
		if [ ! -e $f ]; then
			continue
		fi

		printf "%03d - %s - %s " $i $ymd $f
		showFieldsSeparatorInfo $f
	done
}

main
