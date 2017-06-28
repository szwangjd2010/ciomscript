#!/bin/bash
#
# our case is: find out a job list, let another
# job to select one job from this joblist, 
# then get other useful info from the select job
# 

jobName=$1
version=$2
cloudId=$3
appName=$4

options=""
jobConfigFile="${JENKINS_HOME}/jobs/${jobName}/config.xml"

function getJobOptions() {
	arr=($(ssh root@172.17.128.234 "find /opt/ws-1/ -maxdepth 1 -name \"*lecaiadminapi*-*\" -printf \"%f\n\""))

	for i in "${arr[@]}";
	do 
		options=$options"<string>"$i"</string>\n"
	done 
}

function test() {
	testVar=$(/opt/ciom/ciomscript/generate.find.backup.cmd v0 dev lecaiapi);
	echo $testVar;
}

function updateJobOptionsInTargetJob() {
	#echo $options
	perl -i -0 -pE "s|(?<g1><a class=\"string-array\">\s+)(?<g2>.*)(?<g3>\s+</a>)|$+{g1}${options}$+{g3}|sg" $jobConfigFile
}

function checkJobConfigPath() {
	if [ ! -f "$jobConfigFile" ]; then
		echo "[Error] config.xml not exist for job, or the job is not exist at all."
		exit 1
	else
		echo $jobConfigFile
	fi
}

function reloadJenkinsConf() {
	java -jar $JENKINS_HOME/jenkins-cli.jar -s  http://localhost:8080/ reload-configuration
}

function main () {
	checkJobConfigPath
	getJobOptions
	updateJobOptionsInTargetJob
	reloadJenkinsConf
}



function main1 () {
	test
}
main1

