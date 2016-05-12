#!/bin/bash
# 
#
product=${1:-qida}
logType=${2:-action}
logRoot=/sdc/ciompub/behavior
workspace=$logRoot/_clean
itemTotalCost=0

getFileName() {
	ymd=$1
	echo -n "${product}_action.${ymd}.all-instances.log"
}

getFileOriginalFullPath() {
	ymd=$1
	echo -n $logRoot/$ymd/$(getFileName $ymd)
}

getFileOperatedFullPath() {
	ymd=$1
	echo -n $workspace/$ymd/$(getFileName $ymd)
}

createYmdWorkspace() {
	ymd=$1
	fileOriginal=$2
	fileOperated=$3
	ymdLocation=$workspace/$ymd

	mkdir -p $ymdLocation
	/bin/cp -rf $fileOriginal $fileOperated
}

doClean() {
	t0=$(date +%s)
	eval $1
	t1=$(date +%s)
	cost=$(( $t1 - $t0 ))
	itemTotalCost=$(( $itemTotalCost + $cost ))
	echo ${FUNCNAME[1]}: $cost secs	
}

truncateLog4jPrefix() {
	doClean "perl -i.origin -pE '"'s/^.+ \[\w+\.java:\d+\] - //g'"' $1"
}

nullToEmpty() {
	doClean "perl -i.truncateLog4jPrefix -pE '"'s/(?<=,)null(?=,)/""/g'"' $1"
}

filedValueTabToSpace() {
	doClean "perl -i.nullToEmpty -pE '"'s/\t/ /g'"' $1"
}

FieldSeparator_CommaToTab() {
	doClean "perl -i.FieldSeparator_CommaToTab -pE '"'s/","/"\t"/g'"' $1"
}

removeFieldClosureSignDoubleQuotes() {
	doClean "perl -i.FieldSeparator_CommaToTab -pE '"'s/(^"|"$|(?<=\t)"|"(?=\t))//g'"' $1"
}

showFieldsSeparatorInfo() {
	f=$1
	echo -n "FS info - "
	awk -F','  '{printf ",: %02d", NF; exit}' $f
	awk -F' '  '{printf "  \\s: %02d", NF; exit}' $f
	awk -F'\t' '{printf "  \\t: %02d", NF; exit}' $f
	echo
}

# first: 			FS->','		null value -> null 		field clouser sign -> '"'
# after 20160226, 	FS->'\t'	null value -> ""		field clouser sign -> '"'
# after 20160510, 	FS->'\t'	null value -> ""		field clouser sign -> no clouser sign
main () {
	begin="2015-12-30" # end date: 20160510
	for (( i=0; i<=132; i++ )); do
	#for (( i=0; i<1; i++ )); do
		ymd=$(date -d "$begin +$i days" +%04Y%02m%02d)
		fileOriginal=$(getFileOriginalFullPath $ymd)
		if [ ! -e $fileOriginal ]; then
			continue
		fi

		if [ "$ymd" = "20160226" ]; then
			continue
		fi

		fileOperated=$(getFileOperatedFullPath $ymd)
		createYmdWorkspace $ymd $fileOriginal $fileOperated
		itemTotalCost=0

		echo ------------------------------------------------------------
		printf "%03d - %s - %s\n" $i $ymd $fileOperated

		if (( $ymd < 20160226 )); then
			truncateLog4jPrefix $fileOperated
			nullToEmpty $fileOperated
			filedValueTabToSpace $fileOperated
			FieldSeparator_CommaToTab $fileOperated
		fi
		removeFieldClosureSignDoubleQuotes $fileOperated
		echo file total cost: $itemTotalCost secs

		showFieldsSeparatorInfo $fileOperated
	done
}

main
