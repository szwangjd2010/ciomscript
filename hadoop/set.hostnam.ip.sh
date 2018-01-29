#!/bin/bash
#

prefix=$1
nid=$2
nic=$3

if [ $# -lt 3 ]; then
    echo "usage:"
    echo "$0 %prefix $nid $nic"
    exit 0
fi

net='10.200.70.'
echo "${prefix}_${nid}" > /etc/hostname
perl -i -pE "s/(?<g1>IPADDR=).+/$+{g1}$net$nid/" /etc/sysconfig/network-scripts/ifcfg-${nic}
