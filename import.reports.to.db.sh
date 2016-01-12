#!/bin/bash
#

#type: Base, Channel
#
type=${1:-Base}

ymd=$(date -d 'now' +%04Y%02m%02d)
tpl="/data/ciomshare/ciom/load.data.tpl"
tplInstance=""
logFile="ld.log"

reBase=".*/(rpt_all_data|rpt_daily|rpt_monthly|rpt_retention|rpt_weekly)\.log"
reChannel=".*/(rpt_channel_daily|rpt_channel_monthly|rpt_channel_weekly)\.log"
reName=re${type}
re=${!reName}

instanceLoadDataTpl() {
	tableName=$1
	/bin/cp -rf $tpl $tplInstance
	perl -i -pE "s|^--(.*$tableName)|\1|g" $tplInstance
}

main() {
	echo $ymd >> $logFile
	for tableName in $(find /data/ws-1/tomcat7-1/logs/yxt/ -regextype posix-extended -regex "$re" | grep -o -P 'rpt_\w+'); do
		echo $tableName >> $logFile
		tplInstance=load.data.$tableName
		instanceLoadDataTpl $tableName
		mysql -h 10.10.66.88 -uyxt -phzyxtDUANG2015 -e "source $tplInstance" lecaireport 2>>$logFile
		#mysql -h 10.10.66.88 -uyxt -phzyxtDUANG2015 -e "show databases;" lecaireport 2>>$logFile
	done
	echo >> $logFile
}

main
