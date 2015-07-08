#!/bin/bash
#
# example:
# cd /tech/user/micro/backup && $CIOM_SCRIPT_HOME/importdb.sh nest 222.92.116.85 3308 root 'Juziwl!@#' 20141206

dbName=$1
dbHost=$2
dbPort=$3
dbUser=$4
dbPwd=$5
dt=${6:-$(date +%04Y%02m%02d)}

logFile=import-$dbName-$dt.log
dumpSqlFile=$dbName-$dt
tar -xzvf $dumpSqlFile.tar.gz 
sed -i "s/\`$dbName\`/\`$dbName-$dt\`/g" $dumpSqlFile
mysql -v --tee=$logFile -h$dbHost -P $dbPort -u$dbUser -p"$dbPwd" -e "source $dumpSqlFile" 