#!/bin/bash

db=$1

alterDbSQL="ALTER DATABASE #DB# CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci";
alterTbSQL="ALTER TABLE #TBL# CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
alterColSQL="ALTER TABLE #TBL# CHANGE column_name column_name VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

tables="$(mysql -BN -e 'mysql -BN -e 'use $db;show tables'')"
for table in $tables; do
	echo -n "--	/* $table */ ";mysql -BN lecaireport -e "desc $table" | awk '{print $1}' | perl -pE 's|\n|,|g' | perl -pE 's|,$|\n|'
done
