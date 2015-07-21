#!/bin/bash
#

Ciom_Mysql_Log=/tmp/_ciom.mysql.log

Ciom_Mysql_User='ciom'
Ciom_Mysql_Password='pwdasdwx'
Ciom_Mysql_Master="10.10.71.10"
Ciom_Mysql_Slaves="10.10.77.235 10.10.66.88"
Ciom_Mysql_Workspace="/home/uciom/backup"
Ciom_Mysql_Timestamp=$(date +%04Y%02m%02d)
Ciom_Mysql_Error_Log="_ciom.mysql.util.error.log"

execSQLFile() {
	host=$1
	port=$2
	user=$3
	password=$4
	sqlFile=$5
	db="$6"

	mysql -h $host -u$user -p$password -e "source $sqlFile" $db 2>>$Ciom_Mysql_Error_Log
}

execSQL() {
	host=$1
	port=$2
	user=$3
	password=$4
	sql=$5
	db="$6"

	mysql -h $host -u$user -p$password -e "$sql" $db 2>>$Ciom_Mysql_Error_Log
}

execSQL_BN() {
	host=$1
	port=$2
	user=$3
	password=$4
	sql=$5
	db="$6"

	mysql -h $host -u$user -p$password -BNe "$sql" $db 2>>$Ciom_Mysql_Error_Log
}

stopSlaves() {
	for slave in $Ciom_Mysql_Slaves; do
		echo "stop slave on $slave"
		execSQL_BN $slave 3306 $Ciom_Mysql_User $Ciom_Mysql_Password 'stop slave'
	done
}

startSlaves() {
	for slave in $Ciom_Mysql_Slaves; do
		echo "start slave on $slave"
		execSQL_BN $slave 3306 $Ciom_Mysql_User $Ciom_Mysql_Password 'start slave'
	done
}

showSlavesStatus() {
	for slave in $Ciom_Mysql_Slaves; do
		echo "show slave status on $slave"
		execSQL $slave 3306 $Ciom_Mysql_User $Ciom_Mysql_Password 'show slave status\G'
	done
}

resetMaster() {
	echo "reset master on $Ciom_Mysql_Master"
	execSQL_BN $Ciom_Mysql_Master 3306 $Ciom_Mysql_User $Ciom_Mysql_Password 'reset master'
}

firstTimeSetSlavesMaster() {
	status=$(execSQL_BN $Ciom_Mysql_Master 3306 $Ciom_Mysql_User $Ciom_Mysql_Password 'show master status')
	statusArray=(${status// / })
	binlogFile=${statusArray[0]}
	binlogPos=${statusArray[1]}
	
	stopSlaves
	for slave in $Ciom_Mysql_Slaves; do
		query="change master to \
		master_host='$Ciom_Mysql_Master', \
		master_user='root', \
		master_password='$Ciom_Mysql_Password', \
		master_log_file='$binlogFile', \
		master_log_pos=$binlogPos;"
		
		echo "change master on $slave - $query"
		execSQL_BN $slave 3306 $Ciom_Mysql_User $Ciom_Mysql_Password "$query"
	done
}

setSlavesMaster() {
	stopSlaves
	for slave in $Ciom_Mysql_Slaves; do
		query="change master to \
		master_host='$Ciom_Mysql_Master', \
		master_user='root', \
		master_password='$Ciom_Mysql_Password';"
		
		echo "change master on $slave - $query"
		execSQL_BN $slave 3306 $Ciom_Mysql_User $Ciom_Mysql_Password "$query"
	done
}

getDumpoutFile() {
	dbName=$1
	echo $Ciom_Mysql_Workspace/$dbName.$Ciom_Mysql_Timestamp
}

import() {
	host=$1
	port=$2
	user=$3
	password=$4
	fileDumpout=$5
	
	echo "import $host $dbName from $fileDumpout..."
	execSQLFile $host $port $user $password "$fileDumpout"
}

dump() {
	host=$1
	port=$2
	user=$3
	password=$4
	dbName=$5
	fileDumpout=$(getDumpoutFile $dbName)
	
	echo "dump $host $dbName to $fileDumpout..."
	mysqldump -h $host -u$user -p$password \
		--default-character-set=utf8 \
		--add-drop-database \
		--add-drop-table \
		--lock-all-tables \
		--routines \
		--databases $dbName > $fileDumpout
}

dumpMaster() {
	db=$1
	dump $Ciom_Mysql_Master 3306 $Ciom_Mysql_User $Ciom_Mysql_Password $db
}

import2Slaves() {
	db=$1
	fileDumpout=$(getDumpoutFile $db)
	for slave in $Ciom_Mysql_Slaves; do
		import $slave 3306 $Ciom_Mysql_User $Ciom_Mysql_Password $fileDumpout
	done
}

getAllTablesInDB() {
	host=$1
	db=$2
	execSQL_BN $host 3306 $Ciom_Mysql_User $Ciom_Mysql_Password "show tables" $db | sort > _$host.$db.tables
}

getTableRows() {
	host=$1
	db=$2
	table=$3
	sql="select count(1) from $table"
	tableRow=$(execSQL_BN $host 3306 $Ciom_Mysql_User $Ciom_Mysql_Password "$sql" $db)

	echo "$tableRow"
}

getAllTablesRows() {
	host=$1
	db=$2

	getAllTablesInDB $host $db

	fileTablesRows=_$host.$db.tables.rows
	echo > $fileTablesRows
	cat _$host.$db.tables | while read table; do
		echo -n "$host.$db.$table: "
		rows=$(getTableRows $host $db $table)
		echo $rows
		line=$(printf "%-30s %8d" $table $rows)
		echo -e "$line" >> $fileTablesRows
	done	
}