#!/bin/bash

tables="rpt_all_data rpt_channel_daily rpt_channel_monthly rpt_channel_weekly rpt_daily rpt_monthly rpt_retention rpt_weekly"
for table in $tables; do
	echo -n "--	/* $table */ ";mysql -BN lecaireport -e "desc $table" | awk '{print $1}' | perl -pE 's|\n|,|g' | perl -pE 's|,$|\n|'
done
