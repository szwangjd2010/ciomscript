#!/bin/bash
#
#

timestamp=$(date +%04Y%02m%02d)
Backup2Host="192.168.0.4"
BackupLocation="/data/bak/mysqlbak"
NestOutFile="nest-$timestamp"
TigaseOutFile="tigase-$timestamp"
CompressExtName="tar.gz"

enterWorkspace() {
	cd /root/utils/backup/workspace
}

dumpDb2File() {
	mysqldump -uroot -p'OrangeP@ss!23' \
		--default-character-set=utf8 \
		--add-drop-database \
		--add-drop-table \
		--routines \
		--databases $1 > $2
}
dump() {
	dumpDb2File nest $NestOutFile
	dumpDb2File tigasedb $TigaseOutFile
}

compressFile() {
	tar -czvf "$1.$CompressExtName" $1
}
compress() {
	compressFile $NestOutFile
	compressFile $TigaseOutFile
}

uploadFile() {
	scp -P 22 $1 root@$Backup2Host:$BackupLocation
}
backup() {
	uploadFile "$NestOutFile.$CompressExtName"
	uploadFile "$TigaseOutFile.$CompressExtName"
}

main() {
	enterWorkspace
	dump
	compress
	backup
}

main
