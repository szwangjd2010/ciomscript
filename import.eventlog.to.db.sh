#!/bin/bash
#
source ./ciom.util.sh
source ./ciom.mysql.util.sh


logFileYMD=$(date -d '1 days ago' +%04Y%02m%02d)

getEventLogFile() {
	echo -n "/data/logs/yxt/event.log.$logFileYMD"
}

instanceSQLTpl() {
	eventlogFile=$(getEventLogFile)
	sed "s|#LogFile#|$eventlogFile|g" load.eventlog.to.db.tpl > load.eventlog.to.db.sql
}

logInfo() {
	logFile='/data/logs/yxt/eventlog.csv2db.log'
	eventlogFile=$(getEventLogFile)

	records=$(wc -l $eventlogFile | gawk '{print $1}')
	entry="$(getTimestamp) $eventlogFile $records imported"
	echo "$entry" >> $logFile
}


main() {
	instanceSQLTpl
	execSQLFile $Ciom_Mysql_Master 3306 root $Ciom_Mysql_Password load.eventlog.to.db.sql yxt
	logInfo
}

main
