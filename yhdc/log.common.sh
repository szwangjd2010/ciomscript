#!/bin/bash
# 
logMetainfoFile=$CIOM_SCRIPT_HOME/yhdc/${1:-action.access.metainfo}
yesterday=$(date -d "1 days ago" +%04Y%02m%02d)
begin=${2:-$yesterday}
end=${3:-$yesterday}

getEnv() {
	echo -n $(grep -o -P '(?<=^env: )[\w]+' $logMetainfoFile)
}

getHostsLogPresentin() {
	echo -n $(grep -o -P '^[\d\.]+' $logMetainfoFile | sort -u |  perl -pE 's/\n/ /g' | perl -pE 's/ $//')
}

getProducts() {
	echo -n $(grep -o -P '(?<=^#)[\w]+' $logMetainfoFile | sort -u | perl -pE 's/\n/ /g' | perl -pE 's/ $//')
}

getLogTypes() {
	echo -n $(grep -o -P '(?<=^logs: )[\w ]+' $logMetainfoFile)
}

getLogRoot() {
	echo -n $(grep -o -P '(?<=^logroot: )[/\w]+' $logMetainfoFile)
}

getLogLocalRoot() {
	echo -n $(grep -o -P '(?<=^loglocalroot: )[/\w]+' $logMetainfoFile)
}

Env=$(getEnv)
HostsLogPresentin=$(getHostsLogPresentin)
Products=$(getProducts)
LogTypes=$(getLogTypes)
LogRoot=$(getLogRoot)
LogLocalRoot=$(getLogLocalRoot)

LogRoot=/data
LogLocalHome=$LogLocalRoot/$Env/${LogTypes// /+}

if [ ! -e $LogLocalHome ]; then
	mkdir -p $LogLocalHome
fi

echo $Env
echo $HostsLogPresentin
echo $Products
echo $LogTypes
echo $LogRoot
echo $LogLocalRoot
echo $LogLocalHome

product=''
logType=''
ymd=''
year=''
month=''
ym=''