#!/bin/bash
#

logFileYMD=$(date -d '1 days ago' +%04Y%02m%02d)

AdminapiHosts="10.10.74.158"
ApiHosts="10.10.73.235 10.10.76.73 10.10.75.138"

pullLog() {
	hosts=$1
	localLogLocation=$2

	svrlogLocation=/data/logs/yxt
	for host in $hosts; do
		hostLogLocation=$localLogLocation/$host
		mkdir -p $hostLogLocation
		scp root@$host:$svrlogLocation/*.$logFileYMD.log $hostLogLocation/
	done	
}

main() {
	localAdminapiLogLocation=/tech/ucloud.logs/adminapi/$logFileYMD
	localApiLogLocation=/tech/ucloud.logs/api/$logFileYMD

	pullLog "$AdminapiHosts" "$localAdminapiLogLocation"
	pullLog "$ApiHosts" "$localApiLogLocation"
}

main
