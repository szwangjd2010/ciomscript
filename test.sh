#!/bin/bash
# 
#

source ./test.include.sh

showFieldsSeparatorInfo() {
	f=$1
	awk -F','  '{printf "     ,: %02d", NF; exit}' $f
	awk -F' '  '{printf "    \\s: %02d", NF; exit}' $f
	awk -F'\t' '{printf "    \\t: %02d", NF; exit}' $f
	echo
}

main () {
	echo $env
	for (( i=1; i<2; i++)); do
		ymd=$(date -d "$i days ago" +%04Y%02m%02d)

		f=$(getFile $ymd)
		printf "%03d - %s - %s \n" $i $ymd $f
		if [ ! -e $f ]; then
			continue
		fi

		
		#showFieldsSeparatorInfo $f
	done
}

test () {
	app="test"
	if [ "${app}" == "test" ]; then
		echo "app is test"
	fi
}

test
