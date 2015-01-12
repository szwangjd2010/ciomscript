#!/bin/bash
#

if [ $# -lt 5 ]; then
	echo "usage: ./change.xx.root.pwd.sh 192.168.0.9 3306 root 'OrangeP@ss!23' 111111"
	exit 0
fi 

host=$1
port=$2
user=$3
password=$4
xxrootPassword=$5

sha256Password=$(echo -n $(echo -n $xxrootPassword | sha256sum | awk {'print $1'}))

mysql -h $host -P $port -u$user -p$password -e "update t_org_user set s_password='$sha256Password' WHERE s_account='root';" "exiaoxin"
