#!/bin/bash
#

source $CIOM_SCRIPT_HOME/ciom.util.sh
source $CIOM_SCRIPT_HOME/ciom.mysql.util.sh

SeparatorLine="---------------------------------------------------------------------------------------------------------------"
Log_DiffDetail=_mms.diff.details.log
Log_File=_mms.diff.log
DB_Name=yxt

getMaterAllTablesRows() {
	getAllTablesRows $Ciom_Mysql_Master $DB_Name
}

getSlavesAllTablesRows() {
	for slave in $Ciom_Mysql_Slaves; do
		getAllTablesRows $slave $DB_Name
	done	
}

diffMasterWithSlaves() {
	fileMasterTablesRows=_$Ciom_Mysql_Master.$DB_Name.tables.rows
	timestamp=$(getTimestamp)
	echo $timestamp | tee -a $Log_File $Log_DiffDetail
	echo $SeparatorLine | tee -a $Log_File $Log_DiffDetail

	for slave in $Ciom_Mysql_Slaves; do
		fileSlaveTablesRows=_$slave.$DB_Name.tables.rows
		echo "$DB_Name diff between $Ciom_Mysql_Master and $slave ..." | tee -a $Log_File $Log_DiffDetail
		diff -y $fileMasterTablesRows $fileSlaveTablesRows | tee -a $Log_DiffDetail | grep '|' | tee -a $Log_File
		echo | tee -a $Log_File $Log_DiffDetail
	done
	echo | tee -a $Log_File $Log_DiffDetail
}

main() {
	getMaterAllTablesRows
	getSlavesAllTablesRows
	echo
	echo
	echo "mms checking result"
	diffMasterWithSlaves
}

main
