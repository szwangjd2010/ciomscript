#!/bin/bash
#
source $CIOM_HOME/ciom/ciom.util.sh

if [ $# -lt 2 ]; then
	echo "usage:"
	echo "$0 %cloudId %password %runMode"
	echo "if runMode is omit, default is 0"
	exit 0
fi

runMode=${3:-0}
setMode $runMode

cloudId=$1
password=$2
sha256Password=$(echo -n $(echo -n $password | sha256sum | awk {'print $1'}))
cmdSetRootPwd="echo -n $sha256Password | passwd --stdin root"

for host in $(cat "$cloudId.hosts"); do
	execRemoteCmd $host 22 "$cmdSetRootPwd"
done
