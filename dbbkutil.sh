#!/bin/bash

today=$(date +%04Y%02m%02d.%02k%02M%02S)
dumpoutFileBz2="yxt.all-$today.bz2"

enterWorkspace() {
	cd /mysql/backup
}

getLecai2IgnoreTablesString() {
	ignores=""
	for tb in $(mysql -BNe "show tables" lecai2 | grep -P "^rpt_"); do
		ignores="$ignores --ignore-tables=lecai2.$tb"
	done
	echo -n "$ignores"
}

dump() {
	dbs="mall component lecai2"
	for db in $dbs; do
		dbDumpOutFile="yxt.$db-$today"
		ignoreTables=""
		if [ $db == "lecai2" ]; then
			ignoreTables=$(getLecai2IgnoreTablesString)
		fi
		
		mysqldump \
			--default-character-set=utf8 \
			--add-drop-database \
			--add-drop-table \
			--single-transaction \
			--flush-logs \
			--master-data=2 \
			$ignoreTables \
			--databases $db > $dbDumpOutFile
	done
}

tarFiles() {
	tar -cjvf $dumpoutFileBz2 yxt-*-$today
}

backupToStorage() {
	scp $dumpoutFileBz2 10.10.73.166:/data/dbbackup/prod/	
}

clean() {
	rm -rf yxt-*-$today	
}

leaveWorkspace() {
	cd -
}

main() {
	enterWorkspace
	dump
	tarFiles
	backupToStorage
	clean
	leaveWorkspace
}

main
