#!/bin/bash
#

#type: Base, Channel, Other
#

type=$1
host=$2
username=$3
password=$4
logLocation=$5

ymd=$(date -d 'now' +%04Y%02m%02d)
scriptLocation="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tpl="${scriptLocation}/load.data.tpl"
tplInstance=""
logFile="ld.log"

reBase=".*/(rpt_all_data|rpt_daily|rpt_monthly|rpt_retention|rpt_weekly)\.log"
reChannel=".*/(rpt_channel_daily|rpt_channel_monthly|rpt_channel_weekly)\.log"
reOther=".*/(rpt_org_study_data)\.log"
reName=re${type}
re=${!reName}

instanceLoadDataTpl() {
	tableName=$1
	/bin/cp -rf $tpl $tplInstance
	perl -i -pE "s|^--(.*$tableName)|\1|g" $tplInstance
}

main() {
	echo $ymd >> $logFile
	for tableName in $(find $logLocation -regextype posix-extended -regex "$re" | grep -o -P 'rpt_\w+'); do
		echo $tableName >> $logFile
		tplInstance=load.data.$tableName
		instanceLoadDataTpl $tableName
		mysql -h $host -u $username -p$password -e "source $tplInstance" lecaireport 2>>$logFile
		#mysql -h 10.10.66.88 -uyxt -phzyxtDUANG2015 -e "show databases;" lecaireport 2>>$logFile
	done
	echo >> $logFile
}

main
