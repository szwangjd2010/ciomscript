#!/bin/bash
#

dayAgo=${1:-1}
logFileYMD=$(date -d "$dayAgo days ago" +%04Y%02m%02d)
Products="lecai wangxiao qida mall"
LogCatalogs="access action"
LogApiHosts="10.10.106.125"

pullLog() {
	hosts=$1
	svrTomcatParent=$2
	localLogLocation=$3
	reLogCatalogs=$LogCatalogs
	reLogCatalogs=${reLogCatalogs// /\|}
	for host in $hosts; do
		ssh root@$host "cd $svrTomcatParent; mkdir -p /data/tmp; find -regextype posix-extended -regex '.*/\w+_($reLogCatalogs).$logFileYMD.log' > /tmp/_pulllog; tar -cjvf /data/tmp/$host.tomcat.logs.bz2 --files-from /tmp/_pulllog"
		
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
			find "$localLogLocation" -name "${product}_${catalog}.${logFileYMD}.log" -exec cat {} >> "$localLogLocation/${product}_${catalog}.${logFileYMD}.all-instances.log" \;
		done
	done
}

getComponentLocalLogLocation() {
	componentName=$1
	echo -n "/usr/share/nginx/html/ciompub/$componentName/$logFileYMD"
}

handleComponentLog() {
	hosts=$1
	tomcatParent=$2
	componentName=$3

	localLogLocation=$(getComponentLocalLogLocation $componentName)

	mkdir -p $localLogLocation
	rm -rf $localLogLocation/*
	pullLog "$hosts" "$tomcatParent" "$localLogLocation"
	mergeLog "$hosts" "$localLogLocation"
}

main() {
	handleComponentLog "$LogApiHosts" 		/data 	behavior
}

main
