#!/bin/bash
#

ymd=$(date -d '1 days ago' +%04Y%02m%02d)
tplLocation="/data/ciomshare/ciom"

instanceLoadDataTpl() {
	tableName=$1
	tplInstance=load.data.$tableName
	/bin/cp -rf $tplLocation/load.data.tpl $tplInstance
	perl -i -pE "s|^--(.*$tableName)|\1|g" $tplInstance
	perl -i -pE "s|#ymd#|$ymd|g" $tplInstance
}

main() {
	re=".*/(rpt_all_data|rpt_channel_daily|rpt_channel_monthly|rpt_channel_weekly|rpt_daily|rpt_monthly|rpt_retention|rpt_weekly)\.$ymd\.log"
	for tableName in $(find /data/ws-1/tomcat7-1/logs/yxt/ -regextype posix-extended -regex "$re" | grep -o -P 'rpt_\w+'); do
		echo $tableName
		instanceLoadDataTpl $tableName
		cat load.data.$tableName
		#mysql -h 10.10.66.88 -uyxt -ppwdasdwx -e "source load.data.$tableName" lecaireport 2>>_err
	done
}

main
