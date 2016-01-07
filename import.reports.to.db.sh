#!/bin/bash
#

ymd=$(date -d '1 days ago' +%04Y%02m%02d)
tpl="/data/ciomshare/ciom/load.data.tpl"
tplInstance=""
logFile="ld.log"

instanceLoadDataTpl() {
	tableName=$1
	/bin/cp -rf $tpl $tplInstance
	perl -i -pE "s|^--(.*$tableName)|\1|g" $tplInstance
}

main() {
	echo $ymd >> $logFile
	re=".*/(rpt_all_data|rpt_channel_daily|rpt_channel_monthly|rpt_channel_weekly|rpt_daily|rpt_monthly|rpt_retention|rpt_weekly)\.log"
	for tableName in $(find /data/ws-1/tomcat7-1/logs/yxt/ -regextype posix-extended -regex "$re" | grep -o -P 'rpt_\w+'); do
		echo $tableName >> $logFile
		tplInstance=load.data.$tableName
		instanceLoadDataTpl $tableName
		mysql -h 10.10.66.88 -uyxt -ppwdasdwx -e "source $tplInstance" lecaireport 2>>$logFile
		#mysql -h 10.10.66.88 -uyxt -ppwdasdwx -e "show databases;" lecaireport 2>>$logFile
	done
	echo >> $logFile
}

main
