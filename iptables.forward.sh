#!/bin/bash
#

iptables -F
iptables -F -t nat

if [ $# -lt 5 ]; then
	exit 0;
fi

outerIP=$1
innerIP=$2
outerPort=$3

targetIP=$4
targetPort=$5

iptables -t nat -A PREROUTING -d $outerIP -p tcp --dport $outerPort -j DNAT --to-destination $targetIP:$targetPort
iptables -t nat -A POSTROUTING -d $targetIP -p tcp --dport $targetPort -j SNAT --to-source $innerIP
iptables -A FORWARD -o eth0 -d $targetIP -p tcp --dport $targetPort -j ACCEPT
iptables -A FORWARD -i eth0 -s $targetIP -p tcp --sport $targetPort -j ACCEPT
service iptables save
service iptables restart