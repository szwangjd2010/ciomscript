#!/bin/bash
#
# our case is: find out a job list, let another
# job to select one job from this joblist, 
# then get other useful info from the select job
# 

source /etc/profile

jobConfigFile="${JENKINS_HOME}/jobs/${jobName}/config.xml"
backupRoot="/home/jenkins/jenkins.backup/"$(date +%04Y%02m%02d.%02k%02M%02S)

function createBackupRoot() {
	#echo $backupRoot
	mkdir -p $backupRoot
}

function backupJobConfigs() {
	#arr=($(find ${JENKINS_HOME}/jobs/ -maxdepth 1 -xtype d -name "*${saerchCondition}*" -printf "%f\n" | sort))
	arr=($(find ${JENKINS_HOME}/jobs/ -maxdepth 1 -xtype d  -printf "%f\n"))
	for item in "${arr[@]}";
	do 
		configFile="${JENKINS_HOME}/jobs/$item/config.xml"
		jobFolder="$backupRoot/jobs/$item/"
		if [ -f $configFile ]; then
			mkdir -p $jobFolder
			cp $configFile $jobFolder
		fi
	done 
}

function backupMainConfig() {
	configFile="${JENKINS_HOME}/config.xml"
	cp $configFile $backupRoot/
}

function main () {
	createBackupRoot
	backupMainConfig
	backupJobConfigs
}

main

