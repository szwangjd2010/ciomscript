#!/bin/bash
#

dayAgo=${1:-1}
#logLevels=${2:-debug error info event time}
logLevels=${2:-event time}
logFileYMD=$(date -d "$dayAgo days ago" +%04Y%02m%02d)

LecaiApiHosts="10.10.73.235 10.10.76.73"
LecaiAdminapiHosts="10.10.74.158"
MallApiHosts="10.10.110.226"
MallAdminapiHosts="10.10.74.158"
ComponentapiHost="10.10.125.17"

pullLog() {
	hosts=$1
	svrTomcatParent=$2
	localLogLocation=$3
	reLogLevels=$logLevels
	reLogLevels=${reLogLevels// /\|}
	for host in $hosts; do
		ssh root@$host "cd $svrTomcatParent; mkdir -p /data/tmp; find -regextype posix-extended -regex '.*/lecaiapi_($reLogLevels).$logFileYMD.log' > /tmp/_pulllog; tar -cjvf /data/tmp/$host.tomcat.logs.bz2 --files-from /tmp/_pulllog"
		
		localHostLogLocation=$localLogLocation/$host
		mkdir -p $localHostLogLocation
		scp root@$host:/data/tmp/$host.tomcat.logs.bz2 $localHostLogLocation/

		(cd $localHostLogLocation; tar -xjvf $host.tomcat.logs.bz2 --no-same-owner)
	done	
}

mergeLog() {
	hosts=$1
	localLogLocation=$2	

	for level in $logLevels; do
		find "$localLogLocation" -name "lecaiapi_$level.$logFileYMD.log" -exec cat {} >> "$localLogLocation/lecaiapi_$level.$logFileYMD.all-instances.log" \;
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
	handleComponentLog "$LecaiApiHosts" 		/data/ws 	lecai.api
	#handleComponentLog "$LecaiAdminapiHosts" 	/data/ws-1 	lecai.adminapi

	#handleComponentLog "$MallApiHosts" 			/data 		mall.api
	#handleComponentLog "$MallAdminapiHosts" 	/data/ws-4 	mall.adminapi

	#handleComponentLog "$ComponentapiHost" 		/data 		component.api
}

main
