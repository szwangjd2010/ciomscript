#!/bin/bash
#
source ./ciom.util.sh
source ./ciom.mysql.util.sh


logFileYMD=$(date -d '1 days ago' +%04Y%02m%02d)

getEventLogFile() {
	echo -n "/data/logs/yxt/event.$logFileYMD.log"
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
	execSQLFile 10.10.73.166 3306 yxt pwdasdwx load.eventlog.to.db.sql yxtlog
	logInfo
}

main
