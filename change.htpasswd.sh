#!/bin/bash
# 
#
source $CIOM_HOME/ciom/ciom.util.sh

accountName=${AccountName:-$1}
oldPassword=${OldPassword:-$2}
newPassword=${NewPassword:-$3}

FileHtpasswd='/var/www/svn/passwd'
#FileHtpasswd='/opt/ciom/72htpasswd'
SolidSalt='lle'

getUserCnt() {
	echo -n $(grep -c "$accountName:" $FileHtpasswd)
}

getNameAndPasswdMatchedUserCnt() {
	userSalt=$(grep "$accountName:" $FileHtpasswd | awk -F\$ '{print $3}')
	accountEntry=$(getAccountEntry $accountName $oldPassword $userSalt)
	echo -n $(grep -c "$accountEntry" $FileHtpasswd)
}

updatePasswd() {
	accountNewEntry=$(getAccountEntry $accountName $newPassword $SolidSalt)
	sed -i "s|^$accountName:.*|$accountNewEntry|g" $FileHtpasswd
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

main() {
	if [ "$(getUserCnt)" == "0" ]; then
		echo "user does not exist!"
		exit 1
	fi

	if [ "$(getNameAndPasswdMatchedUserCnt)" == "0" ]; then
		echo "user password is not correct!"
		exit 2
	fi

	updatePasswd
	echo "password updated successfully!"
}

main