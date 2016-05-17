#!/bin/bash
#
source $CIOM_SCRIPT_HOME/log.common.sh

LogApiHosts="10.10.125.17"

pullLog() {
	hosts=$1
	svrTomcatParent=$2
	localLogLocation=$3
	reLogTypes=$LogTypes
	reLogTypes=${reLogTypes// /\|}
	for host in $hosts; do
		ssh root@$host "cd $svrTomcatParent; mkdir -p /data/tmp; find -regextype posix-extended -regex '.*/\w+_($reLogTypes).$ymd.log' > /tmp/_pulllog; tar -cjvf /data/tmp/$host.tomcat.logs.bz2 --files-from /tmp/_pulllog"
		
		localHostLogLocation=$localLogLocation/$host
		mkdir -p $localHostLogLocation
		scp root@$host:/data/tmp/$host.tomcat.logs.bz2 $localHostLogLocation/

		(cd $localHostLogLocation; tar -xjvf $host.tomcat.logs.bz2 --no-same-owner)
	done	
}

mergeLog() {
	hosts=$1
	localLogLocation=$2	

	for product in $Products; do
		for logType in $LogTypes; do
			find "$localLogLocation" -name "${product}_${logType}.${ymd}.log" -exec cat {} >> "$localLogLocation/${product}_${logType}.${ymd}.all-instances.log" \;
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
echo $localLogLocation

return

	mkdir -p $localLogLocation
	rm -rf $localLogLocation/*
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


		handleComponentLog "$LogApiHosts" /data behavior
	done
}

main
