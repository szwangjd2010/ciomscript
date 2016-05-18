#!/bin/bash
#
source $CIOM_SCRIPT_HOME/yhdc/log.common.sh "$@"

Flag_Force_Repull=0
LogApiHosts="10.10.125.17"

pullLog() {
	hosts=$1
	svrTomcatParent=$2
	localLogLocation=$3
	reLogTypes=$LogTypes
	reLogTypes=${reLogTypes// /\|}
	for host in $hosts; do
		localHostLogLocation=$localLogLocation/$host
		if [ -e $localHostLogLocation/$host.tomcat.logs.tgz ]; then
			continue
		fi

		mkdir -p $localHostLogLocation

		ssh root@$host "\
			cd $svrTomcatParent; \
			mkdir -p /data/tmp; \
			find -regextype posix-extended -regex '.*/\w+_($reLogTypes).$ymd.log' > /tmp/_pulllog; \
			tar -czvf /data/tmp/$host.tomcat.logs.tgz --files-from /tmp/_pulllog;\
		"
		scp root@$host:/data/tmp/$host.tomcat.logs.tgz $localHostLogLocation/
		(cd $localHostLogLocation; tar -xzvf $host.tomcat.logs.tgz --no-same-owner)
	done	
}

mergeLog() {
	hosts=$1
	localLogLocation=$2	

	for product in $Products; do
		for logType in $LogTypes; do
			toFile="$localLogLocation/${product}_${logType}.${ymd}.all-instances.log"
			if [ -e $toFile ]; then
				continue
			fi

			find "$localLogLocation" -name "${product}_${logType}.${ymd}.log" -exec cat {} >> ${toFile}.merging \;
			mv ${toFile}.merging $toFile
		done
	done
}

getComponentLocalLogLocation() {
	componentName=$1
	echo -n "/usr/share/nginx/html/ciompub/$componentName/$ymd"
}

handleComponentLog() {
	hosts=$1
	tomcatParent=$2
	componentName=$3

	localLogLocation=$(getComponentLocalLogLocation $componentName)

	mkdir -p $localLogLocation
	if [ $Flag_Force_Repull -eq 1 ]; then
		rm -rf $localLogLocation/*
	fi
	
	pullLog "$hosts" "$tomcatParent" "$localLogLocation"
	mergeLog "$hosts" "$localLogLocation"
}

main() {
	ymdEnd=$(date -d "$end" +%04Y%02m%02d)

	for (( i=0; i<1000; i++ )); do
		ymd=$(date -d "$begin +$i days" +%04Y%02m%02d)

		if (( $ymd > $ymdEnd )); then
			break
		fi
		echo "pull $ymd logs ... "
		handleComponentLog "$LogApiHosts" /data behavior
		echo "done"
	done
}

main
