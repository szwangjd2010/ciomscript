#!/bin/bash
# 
#
if [ "$JENKINS_HOME" == "" ]; then
	source $CIOM_HOME/ciom.util.sh
	simulateJenkinsContainer
else 
	source $JENKINS_HOME/workspace/ciom/ciom.util.sh
fi

appName=$1
cloudId=${2:-guoke}
asRoot=${3:-NotAsRoot}

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

toTest() {
	$JENKINS_HOME/workspace/ciom/deploy.app.to.host.with.multi.tomcats.sh $appName 192.168.0.125 22 /opt $asRoot
}


main() {
	if [ "$cloudId" == "guoke" ]; then
		toGuoke
	fi
	
	if [ "$cloudId" == "test" ]; then
		toTest
	fi	
}

main

unsimulateJenkinsContainer