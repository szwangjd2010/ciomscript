#!/bin/bash
#
#

confName=${1:-http_qida.xml}

TSUNG_HOME=/opt/tsung

cd $TSUNG_HOME
tsung -f conf/$confName -l log start | tee _out

logTimestamp=$(grep -o -P "\d{8}-\d{4}" _out)
cd $TSUNG_HOME/log/$logTimestamp
/usr/lib/tsung/bin/tsung_stats.pl
cd $TSUNG_HOME

echo
echo "report url:"
echo "http://log.devops.yxt.com/tsung/log/$logTimestamp/report.html"
echo 