#!/bin/bash
#
logFileYMD=$(date -d '1 days ago' +%04Y%02m%02d)

AdminapiHosts="10.10.74.158"
ApiHosts="10.10.73.235 10.10.76.73 10.10.75.138"

pullLog() {
	hosts=$1
	svrTomcatParent=$2
	localLogLocation=$3
	
	for host in $hosts; do
		ssh root@$host "cd $svrTomcatParent; tar -cjvf /data/tmp/$host.tomcat.logs.bz2 "'$(find tomcat7-[1-4] -regextype posix-extended -regex '"'"'.*/(debug|error|info)\.'"$logFileYMD""\.log')"
		
		localHostLogLocation=$localLogLocation/$host
		mkdir -p $localHostLogLocation
		scp root@$host:/data/tmp/$host.tomcat.logs.bz2 $localHostLogLocation/

		(cd $localHostLogLocation; tar -xjvf $host.tomcat.logs.bz2 --no-same-owner)
	done	
}

mergeLog() {
	hosts=$1
	localLogLocation=$2	

	for level in debug error info; do
		find "$localLogLocation" -name "$level.$logFileYMD.log" -exec cat {} >> "$localLogLocation/$level.$logFileYMD.all-instances.log" \;
	done
}

main() {
	svrAdminTomcatParent="/opt/ws1/"
	svrApiTomcatParent="/opt/ws/"
	
	localAdminapiLogLocation=/usr/share/nginx/html/ciompub/leicai/adminapi/$logFileYMD
	localApiLogLocation=/usr/share/nginx/html/ciompub/leicai/api/$logFileYMD

	mkdir -p $localAdminapiLogLocation
	mkdir -p $localApiLogLocation

	pullLog "$AdminapiHosts" "$svrAdminTomcatParent" "$localAdminapiLogLocation"
	pullLog "$ApiHosts" "$svrApiTomcatParent" "$localApiLogLocation"
	
	mergeLog "$AdminapiHosts" "$localAdminapiLogLocation"
	mergeLog "$ApiHosts" "$localApiLogLocation"	
}

main
