#!/bin/bash
#
#



timestamp=$(date +%04Y%02m%02d)
BackupLocation="/opt/data/ciom.workspace/dbdump"
EXiaoxinOutFile="exiaoxin-$timestamp"
TigaseOutFile="tigase-$timestamp"

CompressExtName="bz2"
RemoteBackupLocation="root@192.168.0.4:/data/bak/mysqlbak"

enterWorkspace() {
	cd $BackupLocation
}

dumpDb2File() {
	mysqldump -uroot -p'P@ss~!@321' \
		--default-character-set=utf8 \
		--add-drop-database \
		--add-drop-table \
		--routines \
		--databases $1 > $2
}
dump() {
	dumpDb2File exiaoxin $EXiaoxinOutFile
	dumpDb2File tigasedb $TigaseOutFile
}

compressFile() {
	tar -cjvf "$1.$CompressExtName" $1
}
compress() {
	compressFile $EXiaoxinOutFile
	compressFile $TigaseOutFile
}

uploadFile() {
	scp -P 22 $1 $RemoteBackupLocation
}

backup() {
	uploadFile "$EXiaoxinOutFile.$CompressExtName"
	uploadFile "$TigaseOutFile.$CompressExtName"
}

main() {
	enterWorkspace
	dump
	compress
#	backup
}

main
