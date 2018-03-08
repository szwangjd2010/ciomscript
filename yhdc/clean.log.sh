#!/bin/bash
# 
source $CIOM_SCRIPT_HOME/yhdc/log.common.sh "$@"

logRoot=$LogLocalHome
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
	echo $1
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

binaryFilter() {
	goodFile=${1}.binaryFilter.good
	badFile=${1}.binaryFilter.bad.tsv
	cleanExec "awk -F'\t' '{if (NF == 32) print > \"$goodFile\"; else print > \"$badFile\"}' ${1}"
	
	mv $1 $1.pre.binaryFilter
	if [ -e $goodFile ]; then
		mv $goodFile $1
	else
		touch $1
	fi
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

cleanActionAccessLog() {
	fileOperated=$1
	truncateLog4jPrefix $fileOperated
	binaryFilter $fileOperated
}

cleanEventLog() {
	fileOperated=$1
	FieldSeparator_CommaToTab $fileOperated
	removeFieldClosureSignDoubleQuotes $fileOperated
}

clean() {
	ymdEnd=$(date -d "$end" +%04Y%02m%02d)

	for (( i=0; i<1000; i++ )); do
		ymd=$(date -d "$begin +$i days" +%04Y%02m%02d)

		if (( $ymd > $ymdEnd )); then
			break
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

		if [[ "$LogTypes" =~ .*event.* ]]; then
			cleanEventLog $fileOperated
		fi
		if [[ "$LogTypes" =~ .*action.* ]]; then
			cleanActionAccessLog $fileOperated
		fi
		if [[ "$LogTypes" =~ .*error.* ]]; then
			truncateLog4jPrefix $fileOperated
		fi
		
		touch $fileOperated.clean-done
		echo file total cost: $itemTotalCost secs
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