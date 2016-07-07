#!/bin/bash
#
fromHost=$1
toHost=$2

vip=172.17.128.174
ssh root@$fromHost "ip addr del $vip dev ens32:1"
ssh root@$toHost   "ip addr del $vip dev ens32:1"
ssh root@$toHost   "ip addr add $vip dev ens32:1"
