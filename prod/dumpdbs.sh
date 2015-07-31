#!/bin/bash
#
#
$dbNames=$1
source ./common.sh

dump() {
	mysqldump --default-character-set=utf8 \
		--set-gtid-purged=OFF \
		--add-drop-database \
		--add-drop-table \
		--lock-all-tables \
		--routines \
		--databases $dbNames > $DbsDumpoutFile
}


main() {
	enterWorkspace
	dump
	leaveWorkspace
}

main