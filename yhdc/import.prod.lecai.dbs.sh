#!/bin/bash
#
#

cd /data/dbbackup

today=$(date +%04Y%02m%02d)
remoteHost="10.10.73.166"
remoteLocation="/data/dbbackup/prod"

fileDbDumpoutFullName=$(ssh ${remoteHost} "find ${remoteLocation} -name yxt.all-${today}.*.tgz")
fileDbDumpoutName=$(expr match "$fileDbDumpoutFullName" '.*/\(yxt\.all.*\.tgz\)')
dt=$(expr match "$fileDbDumpoutName" '.*-\(.*\)\.tgz')

fileURI=root@${remoteHost}:${fileDbDumpoutFullName}
echo "downloading $fileURI ... "
scp $fileURI .

echo "extracting $fileDbDumpoutName ..."
tar -xzvf $fileDbDumpoutName

echo "begin importing ... "
for name in mall component lecai2; do
	sqlFile=yxt.${name}-${dt}
	echo "importing $name ... "
	mysql -e "source ./${sqlFile}"
done
