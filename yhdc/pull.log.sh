#!/bin/bash
#
source $CIOM_SCRIPT_HOME/yhdc/log.common.sh "$@"

Only_Pull_Defined_Products=${4:-'all'}
Flag_Force_Repull=0

pullLog() {
	hosts=$1
	localLogYmdLocation=$2

	reLogTypes=$LogTypes
	reLogTypes=${reLogTypes// /\|}
	joinedLogTypes=${LogTypes// /+}

	reProducts='\w+'
	if [ $Only_Pull_Defined_Products = 'OnlyPullDefinedProducts' ];then
		reProducts=$Products
		reProducts=${Products// /\|}
	fi

	for host in $hosts; do
		echo -n "pull $host logs ... "
		localHostLogLocation=$localLogYmdLocation/$host
		logTgzFile=${joinedLogTypes}.${host}.logs.tgz 
		if [ -e $localHostLogLocation/$logTgzFile ]; then
			echo "already exists"
			continue
		fi

		mkdir -p $localHostLogLocation

		ssh root@$host "\
			cd $LogRoot; \
			mkdir -p tmp; \
			rm -rf ./tmp/$logTgzFile; \
			find -regextype posix-extended -regex '.*/($reProducts)_($reLogTypes).$ymd.log' > ./tmp/_pulllog; \
			tar -czvf ./tmp/$logTgzFile --files-from ./tmp/_pulllog;\
		"
		scp root@$host:$LogRoot/tmp/$logTgzFile ${localHostLogLocation}/
		(cd $localHostLogLocation; tar -xzvf $logTgzFile --no-same-owner)
		echo "done"
	done	
}

mergeLog() {
	hosts=$1
	localLogYmdLocation=$2	

	for product in $Products; do
		for logType in $LogTypes; do
			toFile="$localLogYmdLocation/${product}_${logType}.${ymd}.all-instances.log"
			if [ -e $toFile ]; then
				continue
			fi

			find "$localLogYmdLocation" -name "${product}_${logType}.${ymd}.log" -exec cat {} >> ${toFile}.merging \;
			mv ${toFile}.merging $toFile
		done
	done
}

getLocalLogYmdLocation() {
	echo -n "$LogLocalHome/$ymd"
}

handleLog() {
	hosts=$1
	localLogYmdLocation=$(getLocalLogYmdLocation)

	mkdir -p $localLogYmdLocation
	if [ $Flag_Force_Repull -eq 1 ]; then
		rm -rf $localLogYmdLocation/*
	fi
	
	pullLog "$hosts" "$localLogYmdLocation"
	mergeLog "$hosts" "$localLogYmdLocation"
}

main() {
	ymdEnd=$(date -d "$end" +%04Y%02m%02d)

	for (( i=0; i<1000; i++ )); do
		ymd=$(date -d "$begin +$i days" +%04Y%02m%02d)

		if (( $ymd > $ymdEnd )); then
			break
		fi
		echo "pull $ymd logs ... "
		handleLog "$HostsLogPresentin"
		echo "done"
	done
}

main
