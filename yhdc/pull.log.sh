#!/bin/bash
#
source $CIOM_SCRIPT_HOME/yhdc/log.common.sh "$@"

Flag_Force_Repull=0

pullLog() {
	hosts=$1
	localLogYmdLocation=$2
	reLogTypes=$LogTypes
	reLogTypes=${reLogTypes// /\|}
	for host in $hosts; do
		echo -n "pull $host logs ... "
		localHostLogLocation=$localLogYmdLocation/$host
		if [ -e $localHostLogLocation/$host.tomcat.logs.tgz ]; then
			echo "already exists"
			continue
		fi

		mkdir -p $localHostLogLocation

		ssh root@$host "\
			cd $LogRoot; \
			mkdir -p tmp; \
			find -regextype posix-extended -regex '.*/\w+_($reLogTypes).$ymd.log' > ./tmp/_pulllog; \
			tar -czvf ./tmp/$host.tomcat.logs.tgz --files-from ./tmp/_pulllog;\
		"
		scp root@$host:$LogRoot/tmp/$host.tomcat.logs.tgz $localHostLogLocation/
		(cd $localHostLogLocation; tar -xzvf $host.tomcat.logs.tgz --no-same-owner)
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
