#!/bin/bash

from=$1
to=$2

mysql -e "CREATE DATABASE IF NOT EXISTS $to DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

tables="$(mysql -BN -e 'show tables' $from;)"
for table in $tables; do
	echo rename ${from}.${table} ... 
    mysql -e "rename table ${from}.${table} to ${to}.${table};"
done
