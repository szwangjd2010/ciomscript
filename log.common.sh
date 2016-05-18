#!/bin/bash
# 
yesterday=$(date -d "1 days ago" +%04Y%02m%02d)
begin=${1:-$yesterday}
end=${2:-$yesterday}
Products="lecai wangxiao qida mall"
LogTypes="action access"

product=''
logType=''
ymd=''
year=''
month=''
ym=''
