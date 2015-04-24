#!/bin/bash
#
source $CIOM_HOME/ciom.util.sh

setMode 0

if [ $# -lt 2 ]; then
	echo "usage: $0 %cloudId %password"
	exit 0
fi 

cloudId=$1
password=$2
sha256Password=$(echo -n $(echo -n $password | sha256sum | awk {'print $1'}))

for host in $(cat "$cloudId.hosts"); do
	execRemoteCmd $host 22 "echo -n $sha256Password | passwd --stdin root"
done
