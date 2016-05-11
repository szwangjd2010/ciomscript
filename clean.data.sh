#!/bin/bash
# 
#
env=${1:-Local}
workspace=/sdc/ciompub/behavior/_clean

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



nullToEmpty() {
	$f=$1
	t0=$(date +%s)
	perl -pE 's/(?<=,)null(?=,)/""/g' $f > $f.nullToEmpty
	t1=$(date +%s)
	echo nullToEmpty: $(( $t1 - $t0 )) secs
}

tabToSpace() {
	$f=$1
	t0=$(date +%s)
	perl -pE 's/\t/ /g' $f
	t1=$(date +%s)
	echo tabToSpace: $(( $t1 - $t0 )) secs	
}

FieldSeparator_CommaToTab() {
	$f=$1
	t0=$(date +%s)
	perl -pE 's/","/"\t"/g' $f
	t1=$(date +%s)
	echo FieldSeparator_CommaToTab: $(( $t1 - $t0 )) secs	
}

removeFieldClosureSignDoubleQuotes() {
	$f=$1
	t0=$(date +%s)
	perl -pE 's/(^"|"$|(?<=\t)"|"(?=\t))//g' $f
	t1=$(date +%s)
	echo FieldSeparator_CommaToTab: $(( $t1 - $t0 )) secs	
}

main () {
	mkdir -p $workspace
	for (( i=1; i<180; i++)); do
		ymd=$(date -d "$i days ago" +%04Y%02m%02d)
		mkdir -p $workspace/$ymd

		f=$(getFile $ymd)
		if [ ! -e $f ]; then
			continue
		fi

		printf "%03d - %s - %s " $i $ymd $f


		if (( $ymd > 2016026 )); then 
			echo yes
		else 
			nullToEmpty $f

		fi
		showFieldsSeparatorInfo $f
	done
}

main
