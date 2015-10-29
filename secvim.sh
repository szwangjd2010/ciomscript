#!/bin/bash

file=$1
passphase=$2

tmpFile="__$file.tmp"
aesPrefix="openssl enc -aes-256-cbc -salt -a -pass pass:$passphase"

getMd5sum() {
	echo -n $(md5sum $1 | gawk '{print $1}')
}

getTimestamp() {
	echo -n $(date +%04Y%02m%02d.%02k%02M%02S)
}

snapshortFile() {
	timestamp=$(getTimestamp)
	cp $file $file.$timestamp
}

clean() {
	rm -rf $tmpFile
}

if [ $# -lt 2 ]; then
	echo "usage: $0 %file %passphase"
	exit 1
fi

if [ ! -f $file ]; then
	echo "file not exist!"
	exit 2
fi

$aesPrefix -d -in $file -out $tmpFile
if [ $? -ne 0 ]; then
	echo "incorrect password!"
	clean
	exit 3
fi

md5sum0=$(getMd5sum $tmpFile)
vim $tmpFile
md5sum1=$(getMd5sum $tmpFile)

if [ "$md5sum0" == "$md5sum1" ]; then
	echo "no changes!"
	clean
	exit 0
fi

snapshortFile
$aesPrefix -e -in $tmpFile -out $file

clean
cat $file

