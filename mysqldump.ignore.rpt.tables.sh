#!/bin/bash

timestamp=$(date +%04Y%02m%02d.%02k%02M%02S)	

ignoretbs=""
for tb in $(mysql -BN -e "use lecai2; show tables" | grep -P "^rpt_"); do
	ignoretbs+=" --ignore-table=lecai2.$tb"
done

mysqldump \
--default-character-set=utf8 \
--add-drop-table \
--single-transaction \
--master-data=2 \
$ignoretbs \
--databases lecai2 > lecai2.$timestamp
