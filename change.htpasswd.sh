#!/bin/bash
# 
#
if [ "$JENKINS_HOME" == "" ]; then
	source $CIOM_HOME/ciom.util.sh
	simulateJenkinsContainer
else 
	source $JENKINS_HOME/workspace/ciom/ciom.util.sh
fi

accountName=${AccountName:-$1}
oldPassword=${OldPassword:-$2}
newPassword=${NewPassword:-$3}

FileHtpasswd='/svnsvr.share/httpd.conf/passwd'
Salt='lle'

isUserExists() {
	echo -n $(execCmd "grep -c '$accountName:' $FileHtpasswd")
}

isValidPasswd() {
	accountEntry=$(getAccountEntry $accountName $oldPassword)
	echo -n $(execCmd "grep -c '$accountEntry' $FileHtpasswd")
}

updatePasswd() {
	accountEntry=$(getAccountEntry $accountName $oldPassword)
	accountNewEntry=$(getAccountEntry $accountName $newPassword)
	execCmd "sed -i 's/$accountEntry/$accountNewEntry/g' $FileHtpasswd"
}

getPasswd() {
	password=$1
	echo -n $(openssl passwd -apr1 -salt $Salt $password)
}

getAccountEntry() {
	name=$1
	password=$2
	echo -n "$name:$(getPasswd $password)"
}

main() {
	isUserExists
	#echo "% $bUserExists %"
	if [ "$bUserExists" == "0" ]; then
		echo "user does not exist!"
		exit 1
	fi

	isValidPasswd
	#echo $bValidPasswd
	if [ "$bValidPasswd" == "0" ]; then
		echo "user password is not correct!"
		exit 2
	fi

	updatePasswd
}

main

unsimulateJenkinsContainer