#!/bin/bash
# 
source $CIOM_SCRIPT_HOME/yhdc/log.common.sh "$@"

logRoot=/sdc/ciompub/behavior
workspace=$logRoot/_clean
itemTotalCost=0

getFileName() {
	ymd=$1
	echo -n "${product}_${logType}.${ymd}.all-instances.log"
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
	if [ -e $fileOperated ]; then
		return
	fi

	ymdLocation=$workspace/$ymd
	mkdir -p $ymdLocation
	/bin/cp -rf $fileOriginal $fileOperated
}

cleanExec() {
	t0=$(date +%s)
	eval $1
	t1=$(date +%s)
	cost=$(( $t1 - $t0 ))
	itemTotalCost=$(( $itemTotalCost + $cost ))
	echo ${FUNCNAME[1]}: $cost secs	
}

truncateLog4jPrefix() {
	cleanExec "perl -i.origin -pE '"'s/^.+ \[\w+\.java:\d+\] - //g'"' $1"
}

nullToEmpty() {
	cleanExec "perl -i.truncateLog4jPrefix -pE '"'s/(?<=,)null(?=,)/""/g'"' $1"
}

filedValueTabToSpace() {
	cleanExec "perl -i.nullToEmpty -pE '"'s/\t/ /g'"' $1"
}

FieldSeparator_CommaToTab() {
	cleanExec "perl -i.FieldSeparator_CommaToTab -pE '"'s/","/"\t"/g'"' $1"
}

removeFieldClosureSignDoubleQuotes() {
	cleanExec "perl -i.FieldSeparator_CommaToTab -pE '"'s/(^"|"$|(?<=\t)"|"(?=\t))//g'"' $1"
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
clean() {
	ymdEnd=$(date -d "$end" +%04Y%02m%02d)

	for (( i=0; i<1000; i++ )); do
		ymd=$(date -d "$begin +$i days" +%04Y%02m%02d)

		if (( $ymd > $ymdEnd )); then
			break
		fi
		
		if [ "$ymd" = "20160226" ]; then
			continue
		fi

		fileOriginal=$(getFileOriginalFullPath $ymd)
		fileOperated=$(getFileOperatedFullPath $ymd)
		if [ ! -e $fileOriginal ]; then
			continue
		fi
		createYmdWorkspace $ymd $fileOriginal $fileOperated

		printf "%s - %s ... \n" $ymd $fileOperated
		if [ -e "$fileOperated.clean-done" ]; then
			echo "already cleaned"
			continue
		fi

		itemTotalCost=0
		truncateLog4jPrefix $fileOperated
		if (( $ymd < 20160226 )); then
			nullToEmpty $fileOperated
			filedValueTabToSpace $fileOperated
			FieldSeparator_CommaToTab $fileOperated
		fi
		if (( $ymd < 20160510 )); then
			removeFieldClosureSignDoubleQuotes $fileOperated
		fi
		
		touch $fileOperated.clean-done
		echo file total cost: $itemTotalCost secs

		showFieldsSeparatorInfo $fileOperated
	done
}

main() {
	for product in $Products; do
		for logType in $LogTypes; do
			clean
		done
	done
}

main
