#!/bin/bash
#
# our case is: find out a job list, let another
# job to select one job from this joblist, 
# then get other useful info from the select job
# 

jobName=$1
saerchCondition=$2
options=""
jobConfigFile="${JENKINS_HOME}/jobs/${jobName}/config.xml"

function getJobOptions() {
	arr=($(find ${JENKINS_HOME}/jobs/ -maxdepth 1 -xtype d -name "*${saerchCondition}*" -printf "%f\n" | sort))

	for i in "${arr[@]}";
	do 
		options=$options"<string>"$i"</string>\n"
	done 
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
	java -jar $JENKINS_HOME/jenkins-cli.jar -s http://localhost:8080/ reload-configuration
}

function main () {
	checkJobConfigPath
	getJobOptions
	updateJobOptionsInTargetJob
	reloadJenkinsConf
}

main

