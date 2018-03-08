#!/bin/bash
#
source $CIOM_SCRIPT_HOME/yhdc/log.common.sh "$@"

oldPwd=$(pwd)
logRootLocation="$LogLocalHome/_clean"
Domain="yxt.com"

getViolateLogSetFile() {
	echo -n "${ymd}.${logType}.bad.log.tar.gz"
}

mailViolateSetFile() {
	violateSetFile=$1
	echo "yxt ${logType} bad logs" | \
	mailx -v \
		-r "jenkins@yxt.com" \
		-b "lile@yxt.com" \
		-s "yxt ${logType} bad logs" \
		-a "${violateSetFile}" \
		-S smtp="mail.yxt.com:587" \
		-S smtp-use-starttls \
		-S smtp-auth=login \
		-S smtp-auth-user="jenkins" \
		-S smtp-auth-password="pwdasdwx" \
		-S ssl-verify=ignore \
		-S nss-config-dir=/etc/pki/nssdb/ \
		kfjl@yxt.com
}

main() {
	cd $logRootLocation

	ymdEnd=$(date -d "$end" +%04Y%02m%02d)

	for (( i=0; i<1000; i++ )); do
		ymd=$(date -d "$begin +$i days" +%04Y%02m%02d)
		if (( $ymd > $ymdEnd )); then
			break
		fi

		cd $ymd
		for logType in $LogTypes; do
			setFile=$(getViolateLogSetFile)
			find -name "*_${logType}.${ymd}.all-instances.log.binaryFilter.bad.tsv" | xargs -i tar -rvf $setFile {}
			if [  -e $setFile ]; then
				mailViolateSetFile $setFile
			fi
		done
		cd ..
	done	

	cd $oldPwd
}

main
