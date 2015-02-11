#!/bin/bash
# 
#
if [ "$JENKINS_HOME" == "" ]; then
	source $CIOM_HOME/ciom.util.sh
else 
	source $JENKINS_HOME/workspace/ciom/ciom.util.sh
fi

accountName=${AccountName:-$1}
oldPassword=${OldPassword:-$2}
newPassword=${NewPassword:-$3}

FileHtpasswd='/var/www/svn/passwd'
Salt='lle'

checkUser() {
	execCmd "grep -c '$accountName:' $FileHtpasswd > /tmp/_tmp.ciom"
}

checkUserEntry() {
	accountEntry=$(getAccountEntry $accountName $oldPassword)
	execCmd "grep -c '$accountEntry' $FileHtpasswd > /tmp/_tmp.ciom"
}

updatePasswd() {
	accountEntry=$(getAccountEntry $accountName $oldPassword)
	accountNewEntry=$(getAccountEntry $accountName $newPassword)
	execCmd "sed -i 's|$accountEntry|$accountNewEntry|g' $FileHtpasswd"
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

getCheckResult() {
	echo -n $(cat /tmp/_tmp.ciom)
}

main() {
	checkUser
	bUserExists=$(getCheckResult)
	if [ "$bUserExists" == "0" ]; then
		echo "user does not exist!"
		exit 1
	fi

	checkUserEntry
	bValidPasswd=$(getCheckResult)
	if [ "$bValidPasswd" == "0" ]; then
		echo "user password is not correct!"
		exit 2
	fi

	updatePasswd
	echo "password updated successfully!"
	
}

main