#!/bin/bash
# 
logMetainfoFile=$CIOM_SCRIPT_HOME/yhdc/${1:-action.access.metainfo}
yesterday=$(date -d "1 days ago" +%04Y%02m%02d)
begin=${2:-$yesterday}
end=${3:-$yesterday}

getValue() {
	key=$1
	echo -n $(grep -o -P '(?<=^'$key': )[/\w]+' $logMetainfoFile)
}

getEnv() {
	echo -n $(getValue 'env')
}

getLogTypes() {
	echo -n $(getValue 'logs')
}

getLogRoot() {
	echo -n $(getValue 'logroot')
}

getLogLocalRoot() {
	echo -n $(getValue 'loglocalroot')
}

getHostsLogPresentin() {
	echo -n $(grep -o -P '^[\d\.]+' $logMetainfoFile | sort -u |  perl -pE 's/\n/ /g' | perl -pE 's/ $//')
}

getProducts() {
	echo -n $(grep -o -P '(?<=^#)[\w]+' $logMetainfoFile | sort -u | perl -pE 's/\n/ /g' | perl -pE 's/ $//')
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
