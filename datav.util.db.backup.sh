#!/bin/bash

username=$1
password=$2

# dbs can not multi database names separated by space
dbs="skyeye"
today=$(date +%04Y%02m%02d.%02k%02M%02S)
realm="yxt.datav"
dumpout="${realm}.all-$today.tgz"
MysqlDump="mysqldump -u$username -p$password"

enterWorkspace() {
	cd /data/backup
}

dump() {
	for db in $dbs; do
		$MysqlDump \
			--default-character-set=utf8 \
			--add-drop-database \
			--add-drop-table \
			--single-transaction \
			--set-gtid-purged=OFF \
			--flush-logs \
			--master-data=2 \
			--databases $db > ${realm}.${db}-${today}
	done
}

schemaDump() {
	for db in $dbs; do
		$MysqlDump --no-data --databases $db > ${realm}.schema.${db}-${today}
	done
}

tarFiles() {
	tar -czvf $dumpout ${realm}.*-$today
}

backupToStorage() {
	scp $dumpout bkup@172.17.128.240:/sdc/datav.db.archive/
}

clean() {
	rm -rf ${realm}.*-$today	
}

leaveWorkspace() {
	cd -
}

main() {
	enterWorkspace

	schemaDump
	dump
	tarFiles
	backupToStorage
	clean

	leaveWorkspace
}

main
