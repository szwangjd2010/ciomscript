#!/bin/bash
#
#



timestamp=$(date +%04Y%02m%02d)
BackupLocation="/opt/data/ciom.workspace/dbdump"
EXiaoxinOutFile="exiaoxin-$timestamp"
TigaseOutFile="tigase-$timestamp"

CompressExtName="bz2"

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

deletePlainDumpout() {
	rm -rf $EXiaoxinOutFile
	rm -rf $TigaseOutFile
}


main() {
	enterWorkspace
	dump
	compress
	deletePlainDumpout
}

main
