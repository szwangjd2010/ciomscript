#!/bin/bash

source $CIOM_SCRIPT_HOME/ciom.util.sh
if [ "$JENKINS_HOME" == "" ]; then
	simulateJenkinsContainer
fi

appName=$1
timestamp=$(date +%04Y%02m%02d.%02k%02M%02S)

enterWorkspace() {
	execCmd "cd $WORKSPACE"
}

leaveWorkspace() {
	execCmd "cd $WORKSPACE"
}

doDeploy() {
	if [ "$appName" == "lecaih5mobile" ]; then
		(cd ${appName}; zip -r ../html.zip *)
		scp html.zip root@10.10.73.181:/data/
		ssh root@10.10.73.181 "mkdir -p /data/$appName; cd /data/$appName; rm -rf *; cp ../html.zip ./; unzip ./html.zip"
	fi

	if [ "$appName" == "qidah5web" ]; then
		pwd
		scp ${appName}.zip root@10.10.197.36:/data/www/
		ssh root@10.10.197.36 "cd /data/www;mv app app_${timestamp};unzip ./${appName}.zip;mv ./${appName}/app/ ./;chown -R www:www app;rm -rf ${appName}"
	fi
}


main() {
	enterWorkspace
	doDeploy
	leaveWorkspace
}

main $@