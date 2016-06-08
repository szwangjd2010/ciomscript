#!/bin/bash
# 
yesterday=$(date -d "1 days ago" +%04Y%02m%02d)
begin=${1:-$yesterday}
end=${2:-$yesterday}
HostsLogPresentin=${3:-"10.10.125.17"}
Products=${4:-"lecai wangxiao qida mall"}
LogTypes=${5:-"action access"}

product=''
logType=''
ymd=''
year=''
month=''
ym=''
