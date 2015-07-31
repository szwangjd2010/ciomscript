#!/bin/bash
#
#
Today=$(date +%04Y%02m%02d)
DbsDumpoutFile="yxt.dbs-$Today"
DbsDumpoutBz2File="$DbsDumpoutFile.bz2"
BinlogLocation='/mysql/data/logbins'
BinlogIndex="$BinlogLocation/logbins.index"
Workspace='/mysql/backup'

enterWorkspace() {
	cd $Workspace
}

leaveWorkspace() {
	echo
}

compressDbsDumpout() {
	tar -cjvf $DbsDumpoutBz2File $DbsDumpoutFile
}