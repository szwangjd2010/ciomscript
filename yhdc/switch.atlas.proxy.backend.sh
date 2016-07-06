#!/bin/bash
#

ipId=${1:-172}
AtlasHome=/usr/local/mysql-proxy
perl -i -pE 's/(172\.17\.128\.)\d+/${1}'$ipId'/' $AtlasHome/conf/yhdc.cnf
$AtlasHome/bin/mysql-proxyd yhdc restart