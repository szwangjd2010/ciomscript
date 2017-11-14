#!/bin/bash
#
#

# dbs can not multi database names separated by space
dbs="skyeye"
today=$(date +%04Y%02m%02d.%02k%02M%02S)
realm="yxt.datav"
dumpout="${realm}.all-$today.tgz"

enterWorkspace() {
	cd /data/backup
}

dump() {
	for db in $dbs; do
		mysqldump \
			--default-character-set=utf8 \
			--add-drop-database \
			--add-drop-table \
			--single-transaction \
			--set-gtid-purged=OFF \
			--flush-logs \
			--master-data=2 \
			--databases $db > ${realm}.${db}-${today}.sql
	done
}

schemaDump() {
	for db in $dbs; do
		mysqldump --no-data --databases $db > ${realm}.schema.${db}-${today}.sql
	done
}

tarFiles() {
	tar -czvf $dumpout ${realm}.*-${today}.sql
}

backupToStorage() {
	scp $dumpout bkup@172.17.128.240:/sdc/datav.db.archive/
}

clean() {
	rm -rf ${realm}.*-${today}.sql
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
