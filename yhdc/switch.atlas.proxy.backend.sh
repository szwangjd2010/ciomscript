#!/bin/bash
#

AtlasHome=/usr/local/mysql-proxy
ipId=${1:-172}
perl -pE 's/(172\.17\.128\.)\d+/${1}'$ipId'/' $AtlasHome/conf/yhdc.cnf
$AtlasHome/bin/mysql-proxyd yhdc restart