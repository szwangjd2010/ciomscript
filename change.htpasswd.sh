#!/bin/bash
# 
#
source $CIOM_HOME/ciom/ciom.util.sh

accountName=${AccountName:-$1}
oldPassword=${OldPassword:-$2}
newPassword=${NewPassword:-$3}

#FileHtpasswd='/var/www/svn/passwd'
FileHtpasswd='/tech/72htpasswd'
SolidSalt='lle'

checkUser() {
	execCmd "grep -c '$accountName:' $FileHtpasswd > /tmp/_tmp.ciom"
}

checkUserEntry() {
	userSalt=$(grep "$accountName" $FileHtpasswd |  awk -F\$ '{print $3}')
	accountEntry=$(getAccountEntry $accountName $oldPassword $userSalt)
	execCmd "grep -c '$accountEntry' $FileHtpasswd > /tmp/_tmp.ciom"
}

updatePasswd() {
	accountNewEntry=$(getAccountEntry $accountName $newPassword $SolidSalt)
	execCmd "sed -i 's|^$accountName:.*|$accountNewEntry|g' $FileHtpasswd"
}

getPasswd() {
	password=$1
	salt=$2
	echo -n $(openssl passwd -apr1 -salt $salt $password)
}

getAccountEntry() {
	name=$1
	password=$2
	salt=$3
	echo -n "$name:$(getPasswd $password $salt)"
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