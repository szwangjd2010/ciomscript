#!/bin/bash

logLocation=/opt/tengine/logs
datestamp=$(date +%04Y%02m%02d)

mv $logLocation/access.log $logLocation/access.log-$datestamp
mv $logLocation/error.log $logLocation/error.log-$datestamp

pkill -USR1 -f nginx
