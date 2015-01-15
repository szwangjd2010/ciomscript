#!/bin/bash
# 
#

toGuoke() {
	host='122.193.22.133'
	declare -A ports=( \
		["ToBack1"]="50002" \
		["To52XiaoXin1"]="50003" \
		["ToXiaoXinApi1"]="50004" \
		["ToXiaoXinApi2"]="50005" \
		["ToLifeApi1"]="50006" \
	)

	for key in "${!ports[@]}"; do
		if [ "${!key}" == "YES" ]; then
			port=${ports["$key"]}
			$JENKINS_HOME/workspace/ciom/deploy.app.to.host.with.multi.tomcats.sh $appName $host $port /opt $asRoot
		fi
	done	
}

toAliyun_ws() {
	wsTomcatParent="/opt/ws"
	port=22
	declare -A ports=( \
		["Admin"]='121.41.62.20' \
		["Api1"]='121.40.200.186' \
		["Api2"]='121.41.37.12' \
		["Web"]='121.40.202.100' \
	)

	for key in "${!hosts[@]}"; do
		if [ "${!key}" == "YES" ]; then
			host=${hosts["$key"]}
			$JENKINS_HOME/workspace/ciom/deploy.app.to.host.with.multi.tomcats.sh $appName $host $port $wsTomcatParent $asRoot
		fi
	done	
}

toGuoke
toAliyun_ws 1
