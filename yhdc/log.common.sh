#!/bin/bash
# 
yesterday=$(date -d "1 days ago" +%04Y%02m%02d)
begin=${1:-$yesterday}
end=${2:-$yesterday}
logMetainfoFile=$CIOM_SCRIPT_HOME/yhdc/${3:-action.access.metainfo}

getHostsLogPresentin() {
	echo -n $(grep -o -P '^[\d\.]+' $logMetainfoFile | sort -u |  perl -pE 's/\n/ /g' | perl -pE 's/ $//')
}

getProducts() {
	echo -n $(grep -o -P '(?<=^#)[\w]+' $logMetainfoFile | sort -u | perl -pE 's/\n/ /g' | perl -pE 's/ $//')
}

getLogTypes() {
	echo -n $(grep -o -P '(?<=^logs: )[\w ]+' $logMetainfoFile)
}

HostsLogPresentin=$(getHostsLogPresentin)
Products=$(getProducts)
LogTypes=$(getLogTypes)

echo $HostsLogPresentin
echo $Products
echo $LogTypes

product=''
logType=''
ymd=''
year=''
month=''
ym=''
