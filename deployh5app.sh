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
		#(cd ${appName}; zip -r ../html.zip *)
		#scp html.zip root@10.10.73.181:/data/
		#ssh root@10.10.73.181 "mkdir -p /data/$appName; cd /data/$appName; rm -rf *; cp ../html.zip ./; unzip ./html.zip"
		scp lecaih5mobile.zip root@10.10.73.181:/data/ciom/
		ssh root@10.10.73.181 "cd /data/ciom/;unzip ./lecaih5mobile.zip;mv ../lecaih5mobile lecaih5mobile_${timestamp}; mv lecaih5mobile/app ../lecaih5mobile;rm -rf lecaih5mobile"
	fi

	if [ "$appName" == "zhidah5mobile" ]; then
		#(cd ${appName}; zip -r ../html.zip *)
		#scp html.zip root@10.10.73.181:/data/
		#ssh root@10.10.73.181 "mkdir -p /data/$appName; cd /data/$appName; rm -rf *; cp ../html.zip ./; unzip ./html.zip"
		scp zhidah5mobile.zip root@10.10.73.181:/data/ciom/
		ssh root@10.10.73.181 "cd /data/ciom/;unzip ./zhidah5mobile.zip;mv ../zhidah5mobile lecaih5mobile_${timestamp}; mv zhidah5mobile/app ../zhidah5mobile;rm -rf zhidah5mobile"
	fi

	if [ "$appName" == "mallh5mobile" ]; then
		#(cd ${appName}; zip -r ../html.zip *)
		#scp html.zip root@10.10.73.181:/data/
		#ssh root@10.10.73.181 "mkdir -p /data/$appName; cd /data/$appName; rm -rf *; cp ../html.zip ./; unzip ./html.zip"
		scp mallh5mobile.zip root@10.10.73.181:/data/ciom/
		ssh root@10.10.73.181 "cd /data/ciom/;unzip ./mallh5mobile.zip;mv ../mallh5mobile mallh5mobile_${timestamp}; mv mallh5mobile/app ../mallh5mobile;rm -rf mallh5mobile"
	fi

	if [ "$appName" == "mallh5mobile2" ]; then
		scp mallh5mobile2.zip root@10.10.73.181:/data/ciom/
		ssh root@10.10.73.181 "cd /data/ciom/;unzip ./mallh5mobile2.zip;mv ../mallh5mobile2 mallh5mobile2_${timestamp}; mv mallh5mobile2/src ../mallh5mobile2;rm -rf mallh5mobile2"
	fi

	if [ "$appName" == "mall-gzh" ]; then
		#(cd ${appName}; zip -r ../html.zip *)
		#scp html.zip root@10.10.73.181:/data/
		#ssh root@10.10.73.181 "mkdir -p /data/$appName; cd /data/$appName; rm -rf *; cp ../html.zip ./; unzip ./html.zip"
		scp mall-gzh.zip root@10.10.73.181:/data/ciom/
		ssh root@10.10.73.181 "cd /data/ciom/;unzip ./mall-gzh.zip;mv ../mall-gzh mall-gzh_${timestamp}; mv mall-gzh/app ../mall-gzh;rm -rf mall-gzh"
	fi
	
	if [ "$appName" == "qidah5web" ]; then
		pwd
		scp ${appName}.zip root@10.10.197.36:/data/www/
		ssh root@10.10.197.36 "cd /data/www;mv app app_${timestamp};unzip ./${appName}.zip;mv ./${appName}/app/ ./;chown -R www:www app;rm -rf ${appName}"
	fi

	if [ "$appName" == "shequnh5web" ]; then
		pwd
		scp ${appName}.zip root@10.10.239.72:/usr/share/nginx/html/
		ssh root@10.10.239.72 "cd /usr/share/nginx/html/;mv app app_${timestamp};unzip ./${appName}.zip;mv ./${appName}/app/ ./;chown -R www:www app;rm -rf ${appName}"
	fi
	
	if [ "$appName" == "shequnh5web-dev" ]; then
		(cd shequnh5web; zip -r ../html.zip *)
		scp html.zip root@172.17.128.225:/usr/share/nginx/html/
		ssh root@172.17.128.225 "mkdir -p /usr/share/nginx/html/shequnh5web; cd /usr/share/nginx/html/shequnh5web; rm -rf *; cp ../html.zip ./; unzip ./html.zip"
	fi

	if [ "$appName" == "partnerh5web" ]; then
		scp ${appName}.zip root@10.10.73.181:/data/
		ssh root@10.10.73.181 "cd /data/; rm -rf ${appName}; unzip ./${appName}.zip"
	fi
	
	if [ "$appName" == "partnerh5web-dev" ]; then
		(cd partnerh5web; zip -r ../html.zip *)
		scp html.zip root@172.17.128.225:/usr/share/nginx/html/
		ssh root@172.17.128.225 "mkdir -p /usr/share/nginx/html/partnerh5web; cd /usr/share/nginx/html/partnerh5web; rm -rf *; cp ../html.zip ./; unzip ./html.zip"
	fi

	if [ "$appName" == "omsh5web" ]; then
		scp ${appName}.zip root@10.10.73.181:/data/
		ssh root@10.10.73.181 "cd /data/; rm -rf ${appName}; unzip ./${appName}.zip"
	fi

	if [ "$appName" == "omsh5web-dev" ]; then
		(cd omsh5web; zip -r ../html.zip *)
		scp html.zip root@172.17.128.225:/usr/share/nginx/html/
		ssh root@172.17.128.225 "mkdir -p /usr/share/nginx/html/omsh5web; cd /usr/share/nginx/html/omsh5web; rm -rf *; cp ../html.zip ./; unzip ./html.zip"
	fi

	if [ "$appName" == "lecaih5mobile-dev" ]; then
#		(cd lecaih5mobile; zip -r ../html.zip *)
#		scp html.zip root@172.17.128.225:/usr/share/nginx/html/
#		ssh root@172.17.128.225 "mkdir -p /usr/share/nginx/html/lecaih5mobile; cd /usr/share/nginx/html/lecaih5mobile; rm -rf *; cp ../html.zip ./; unzip ./html.zip"
		scp lecaih5mobile.zip root@172.17.128.225:/usr/share/nginx/html/ciom/
		ssh root@172.17.128.225 "cd /usr/share/nginx/html/ciom/;unzip ./lecaih5mobile.zip;mv ../lecaih5mobile lecaih5mobile_${timestamp}; mv lecaih5mobile/app ../lecaih5mobile;rm -rf lecaih5mobile"
	fi

	if [ "$appName" == "zhidah5mobile-dev" ]; then
		scp zhidah5mobile.zip root@172.17.128.225:/usr/share/nginx/html/ciom/
		ssh root@172.17.128.225 "cd /usr/share/nginx/html/ciom/;unzip ./zhidah5mobile.zip;mv ../zhidah5mobile lecaih5mobile_${timestamp}; mv zhidah5mobile/app ../zhidah5mobile;rm -rf zhidah5mobile"
	fi

	if [ "$appName" == "mallh5web-dev" ]; then
		(cd mallh5web; zip -r ../html.zip *)
		scp html.zip root@172.17.128.225:/usr/share/nginx/html/
		ssh root@172.17.128.225 "mkdir -p /usr/share/nginx/html/mallh5web; cd /usr/share/nginx/html/mallh5web; rm -rf *; cp ../html.zip ./; unzip ./html.zip"
	fi

}


main() {
	enterWorkspace
	doDeploy
	leaveWorkspace
}

main $@