#!/bin/bash
# Define log
MYSQLHOST=
if [ "$1" == "uclouddb_ssd_master" ]; then
	MYSQLHOST=10.10.71.10
fi

if [ "$1" == "uclouddb_ssd_slave" ]; then
	MYSQLHOST=10.10.77.235
fi

if [ "$1" == "uclouddb_slave" ]; then
	MYSQLHOST=10.10.66.88
fi

TIMESTAMP=`date  +%Y%m%d -d '-1 days'`
OUTFILE_NAME=slowsql@${MYSQLHOST}.csv
LOCAL_ROOT=/sdb/ciompub/mysql.slowsql/${TIMESTAMP}
REMOTE_ROOT=/tmp
REMOTE_FILE=${REMOTE_ROOT}/${OUTFILE_NAME}
LOCAL_FILE=${LOCAL_ROOT}/${OUTFILE_NAME}
EXEC_SQL="SELECT * FROM ((SELECT 'start_time' AS start_time,'user_host' AS user_host,'query_time' AS query_time,'lock_time' AS lock_time,'rows_sent' AS rows_sent,'sql_text' AS sql_text) UNION ALL (SELECT start_time,user_host,query_time,lock_time,rows_sent,sql_text FROM slow_log WHERE TO_DAYS(start_time) = TO_DAYS(NOW()) - 1) ORDER BY query_time DESC) temp into outfile '${REMOTE_FILE}' fields terminated by ',' optionally enclosed by '\"' escaped by '\"' lines terminated by '\n'"

if [ ! -d "${LOCAL_ROOT}" ]; then
  mkdir ${LOCAL_ROOT}
fi

chmod 777 ${LOCAL_ROOT}
rm -rf ${LOCAL_ROOT}/${OUTFILE_NAME}
ssh root@${MYSQLHOST} "rm -rf ${REMOTE_ROOT}/slowsql*.csv"

# execute sql stat
mysql -h ${MYSQLHOST} -uciom -ppwdasdwx -P 3306 -D mysql -e "${EXEC_SQL}"

scp root@${MYSQLHOST}:${REMOTE_FILE} ${LOCAL_FILE}


