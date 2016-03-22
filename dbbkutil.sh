#!/bin/bash

dbs="mall component lecai2"
today=$(date +%04Y%02m%02d.%02k%02M%02S)
dumpoutFilesPackage="yxt.all-$today.tgz"

enterWorkspace() {
	cd /mysql/backup
}

getLecai2RptTables() {
	echo -n $(mysql -BNe "show tables" lecai2 | grep -P "^rpt_")
}

getLecai2IgnoreRptTablesString() {
	ignores=""
	for tb in $(getLecai2RptTables); do
		ignores="$ignores --ignore-table=lecai2.$tb"
	done
	echo -n "$ignores"
}

dump() {
	for db in $dbs; do
		dbDumpOutFile="yxt.$db-$today"
		ignoreTables=""
		if [ $db == "lecai2" ]; then
			ignoreTables=$(getLecai2IgnoreRptTablesString)
		fi
		
		mysqldump \
			--default-character-set=utf8 \
			--add-drop-database \
			--add-drop-table \
			--single-transaction \
			--set-gtid-purged=OFF \
			--flush-logs \
			--master-data=2 \
			$ignoreTables \
			--databases $db > $dbDumpOutFile
	done
}

schemaDump() {
	for db in $dbs; do
		mysqldump --no-data --databases $db > yxt.schema.$db-$today
	done

	mysqldump --no-data lecai2 $(getLecai2RptTables) > yxt.schema.lecai2.rpts-$today	
}

tarFiles() {
	tar -czvf $dumpoutFilesPackage yxt.*-$today
}

backupToStorage() {
	scp $dumpoutFilesPackage 10.10.73.166:/data/dbbackup/prod/	
}

clean() {
	rm -rf yxt.*-$today	
}

backupLecai2Rpts() {
	rptFile=yxt.lecai2.rpts-$today
	mysqldump \
		--default-character-set=utf8 \
		--add-drop-table \
		--single-transaction \
		--set-gtid-purged=OFF \
		--flush-logs \
		--master-data=2 \
		lecai2 $(getLecai2RptTables) > $rptFile

	tar -czvf $rptFile.tgz $rptFile
	scp $rptFile.tgz 10.10.73.166:/data/dbbackup/prod/
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

	if [ $(date +%u) -eq 7 ]; then
		backupLecai2Rpts
	fi
	
	clean
	leaveWorkspace
}

main
