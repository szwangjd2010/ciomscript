#!/bin/bash
# 
#
appName=$1
runMode=$2
cloudProvider=${3:-guoke}
ADLog="/tmp/_ciom.log"
interval=10

execCmd() {
	echo "$1" | tee -a $ADLog
	eval $1
}

deployTo() {
	host=$1
	port=$2
	tomcatHome=$3
	
	if [ "$runMode" == "0" ]; then
		host="192.168.0.125"
		port="22"
		interval=1
	fi
	
	execCmd "/opt/ciom/deploy.app.to.sh $appName $host $port $tomcatHome"
}

toGuoke() {
	if [ "$DeployTo50000" == "YES" ]; then
		deployTo "222.92.116.85" "50000" "/usr/local/tomcat7-production"
	fi

	if [ "$DeployTo50005" == "YES" ]; then
		deployTo "222.92.116.85" "50005" "/usr/local/tomcat7"
	fi

	if [ "$DeployTo50012" == "YES" ]; then
		deployTo "222.92.116.85" "50012" "/usr/local/tomcat8080"
		sleep $interval
		
		deployTo "222.92.116.85" "50012" "/usr/local/tomcat8081"
		sleep $interval
		
		deployTo "222.92.116.85" "50012" "/usr/local/tomcat8082"
	fi
}

toTest() {
	deployTo "192.168.0.125" "22" "/opt/tomcat7-1"
	deployTo "192.168.0.125" "22" "/opt/tomcat7-2"
	deployTo "192.168.0.125" "22" "/opt/tomcat7-3"
	deployTo "192.168.0.125" "22" "/opt/tomcat7-4"
}

#xiaoxin_back1=121.41.62.20=10.168.195.33
#xiaoxin_api1=121.40.200.186=10.168.49.72
#xiaoxin_api2=121.41.37.12=10.168.215.219
#xiaoxin_web1=121.40.202.100=10.168.90.165
toAli() {
	if [ "$DeployToAliBack1" == "YES" ]; then
		deployTo "121.41.62.20" "22" "/opt/tomcat7-1"
		sleep $interval
		deployTo "121.41.62.20" "22" "/opt/tomcat7-2"
		sleep $interval
		deployTo "121.41.62.20" "22" "/opt/tomcat7-3"
		sleep $interval
		deployTo "121.41.62.20" "22" "/opt/tomcat7-4"
	fi

	if [ "$DeployToAliApi1" == "YES" ]; then
		deployTo "121.40.200.186" "22" "/opt/tomcat7-1"
		sleep $interval
		deployTo "121.40.200.186" "22" "/opt/tomcat7-2"
		sleep $interval
		deployTo "121.40.200.186" "22" "/opt/tomcat7-3"
		sleep $interval
		deployTo "121.40.200.186" "22" "/opt/tomcat7-4"
	fi

	if [ "$DeployToAliApi2" == "YES" ]; then
		deployTo "121.41.37.12" "22" "/opt/tomcat7-1"
		sleep $interval
		deployTo "121.41.37.12" "22" "/opt/tomcat7-2"
		sleep $interval
		deployTo "121.41.37.12" "22" "/opt/tomcat7-3"
		sleep $interval
		deployTo "121.41.37.12" "22" "/opt/tomcat7-4"
	fi
	
	if [ "$DeployToAliWeb1" == "YES" ]; then
		deployTo "121.40.202.100" "22" "/opt/tomcat7-1"
		sleep $interval
		deployTo "121.40.202.100" "22" "/opt/tomcat7-2"
		sleep $interval
		deployTo "121.40.202.100" "22" "/opt/tomcat7-3"
		#sleep $interval
		#deployTo "121.40.202.100" "22" "/opt/tomcat7-4"
	fi	
}

main() {
	if [ "$cloudProvider" == "guoke" ]; then
		toGuoke
	fi
	
	if [ "$cloudProvider" == "ali" ]; then
		toAli
	fi
	
	if [ "$cloudProvider" == "test" ]; then
		toTest
	fi	
}

main

