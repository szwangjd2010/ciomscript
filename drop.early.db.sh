#!/bin/bash
#
# example:
# cd /tech/user/micro/backup && /home/tech/ciom/importdb.sh nest 222.92.116.85 3308 root 'Juziwl!@#' 20141206


dbs=$(mysql -h222.92.116.85 -P3308 -uroot -p'Juziwl!@#' -e "show databases;"  | grep -P "nest-\d+" | sort -r)

if [ "$dbs" == "" ]; then
	echo 'error: no "nest-\d+" database!'
	exit 1
fi
 
# let us do it
echo 'Begin drop all "nest-\d+" database ...'
i=0
for db in $dbs; do
	(( i++ ))
	if [ $i -gt 30 ]; then
		echo "drop database $db..."
		mysql -h222.92.116.85 -P3308 -uroot -p'Juziwl!@#' -e "drop database $db"
	fi
done