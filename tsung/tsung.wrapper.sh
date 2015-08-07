#!/bin/bash
#
#

confName=$1

TSUNG_HOME=/opt/tsung

cd $TSUNG_HOME
tsung -f conf/$confName.xml -l log start | tee _out

logTimestamp=$(grep -o -P "\d{8}-\d{4}" _out)
cd $TSUNG_HOME/log/$logTimestamp
tsung_stats.pl
cd $TSUNG_HOME

echo
echo "report url:"
echo "http://172.17.128.236/tsung/log/$logTimestamp/report.html"
echo 