#!/bin/bash

mount //10.10.71.137/data/ciomshare /data/ciomshare -o username=ciom,password=ciomYXT123

#change gateway to enable inertnet connection
perl -i -pE 's|(GATEWAY=)(.*)|${1}10.10.73.151|mg' /etc/sysconfig/network-scripts/ifcfg-eth0

#change max open file number permanently
echo "* soft nofile 102400" >> /etc/security/limits.conf
echo "* hard nofile 102400" >> /etc/security/limits.conf


