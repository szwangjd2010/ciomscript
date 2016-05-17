#!/bin/bash
#
yesterday=$(date -d "1 days ago" +%04Y%02m%02d)
begin=${1:-$yesterday}
end=${2:-$yesterday}

Products="lecai wangxiao qida mall"
LogCatalogs="access action"
LogApiHosts="10.10.125.17"
ymd=''

pullLog() {
	hosts=$1
	svrTomcatParent=$2
	localLogLocation=$3
	reLogCatalogs=$LogCatalogs
	reLogCatalogs=${reLogCatalogs// /\|}
	for host in $hosts; do
		ssh root@$host "cd $svrTomcatParent; mkdir -p /data/tmp; find -regextype posix-extended -regex '.*/\w+_($reLogCatalogs).$ymd.log' > /tmp/_pulllog; tar -cjvf /data/tmp/$host.tomcat.logs.bz2 --files-from /tmp/_pulllog"
		
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
		for catalog in $LogCatalogs; do
			find "$localLogLocation" -name "${product}_${catalog}.${ymd}.log" -exec cat {} >> "$localLogLocation/${product}_${catalog}.${ymd}.all-instances.log" \;
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
