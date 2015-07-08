#!/bin/bash
#
source $CIOM_SCRIPT_HOME/ciom.util.sh
source $CIOM_SCRIPT_HOME/ciom.mysql.util.sh


logFileYMD=$(date -d '1 days ago' +%04Y%02m%02d)
eventlogFile=""

instanceSQLTpl() {
	sed "s|#LogFile#|$eventlogFile|g" load.eventlog.to.db.tpl > load.eventlog.to.db.sql
}

logInfo() {
	logFile='/data/logs/yxt/eventlog.csv2db.log'
	records=$(wc -l $eventlogFile | gawk '{print $1}')
	entry="$(getTimestamp) $eventlogFile $records imported"

	cat load.eventlog.to.db.sql >> $logFile
	echo >> $logFile
	echo "$entry" >> $logFile
	echo >> $logFile
}

main() {
	for eventlogFile in $(find /opt/ws/tomcat[678]-[1-9]/logs -name event.$logFileYMD.log); do
		instanceSQLTpl
		execSQLFile 10.10.73.166 3306 yxt pwdasdwx load.eventlog.to.db.sql yxtlog
		logInfo
	done
}

main
