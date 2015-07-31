#!/bin/bash
#
#

source ./common.sh

flushBinlog() {
	echo "flush logs" | mysql
}

getBinlogFollowDbsDumpout() {
	echo -n $(tail -n 1 $BinlogIndex)
}

touchNextBinlogFlagFile() {
	touch $(getNextBinlogAccording2DbsDumpout)
}

main() {
	enterWorkspace
	flushBinlog
	leaveWorkspace
}

main