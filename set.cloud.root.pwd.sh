#!/bin/bash
#
source $CIOM_SCRIPT_HOME/ciom.util.sh

if [ $# -lt 2 ]; then
	echo "usage:"
	echo "$0 %cloudId %password %runMode"
	echo "if runMode is omit, default is 0"
	exit 0
fi

cloudId=$1
password=$2
hashPwd=${3:-1}
runMode=${4:-0}

setMode $runMode

if [ $hashPwd == "1" ]; then
	password=$(echo -n $(echo -n $password | sha256sum | awk {'print $1'}))	
fi

cmdSetRootPwd="echo -n $password | passwd --stdin root"

for host in $(cat "$cloudId.hosts"); do
	execRemoteCmd $host 22 "$cmdSetRootPwd"
done
