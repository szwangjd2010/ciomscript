#!/bin/bash
# 

Products="qida lecai mall wangxiao"
LogTypes="action access"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
YHDC_SCHEMA_TPL=yhdc.schema.tpl
YHDC_SCHEMA=yhdc.sql

cd $DIR
rm -rf $YHDC_SCHEMA

for product in $Products; do
	for logType in $LogTypes; do
		tableName=${product}_${logType}log
		fieldsFile=${logType}.log.fields
		/bin/cp -f $YHDC_SCHEMA_TPL _tmp

		echo -n "generating $tableName ... "
		perl -i -pE "s/#TABLE_NAME#/$tableName/g" _tmp
		perl -i -pE "s/#FIELDS#/$(cat $fieldsFile)/g" _tmp
		cat _tmp >> $YHDC_SCHEMA
		rm -rf _tmp
		echo "done"
	done
done
