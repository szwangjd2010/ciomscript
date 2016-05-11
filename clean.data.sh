#!/bin/bash
# 
#
product=${1:-qida}
logRoot=/sdc/ciompub/behavior
workspace=$logRoot/_clean

getFileName() {
	ymd=$1
	echo -n "${product}_action.${ymd}.all-instances.log"
}

getFileOriginalFullPath() {
	ymd=$1
	echo -n $logRoot/$ymd/$(getFileName $ymd)
}

getFileOperatedFullPath() {
	ymd=$1
	echo -n $workspace/$ymd/$(getFileName $ymd)
}

createYmdWorkspace() {
	ymd=$1
	fileOriginal=$2
	fileOperated=$3
	ymdLocation=$workspace/$ymd

	mkdir -p $ymdLocation
	/bin/cp -rf $fileOriginal $fileOperated
}

truncateLog4jPrefix() {
	f=$1
	t0=$(date +%s)
	perl -i.origin -pE 's/^.+ \[\w+\.java:\d+\] - //g' $f
	t1=$(date +%s)
	echo truncateLog4jPrefix: $(( $t1 - $t0 )) secs	
}

nullToEmpty() {
	f=$1
	t0=$(date +%s)
	perl -i.truncateLog4jPrefix -pE 's/(?<=,)null(?=,)/""/g' $f
	t1=$(date +%s)
	echo nullToEmpty: $(( $t1 - $t0 )) secs
}

filedValueTabToSpace() {
	f=$1
	t0=$(date +%s)
	perl -i.nullToEmpty -pE 's/\t/ /g' $f
	t1=$(date +%s)
	echo filedValueTabToSpace: $(( $t1 - $t0 )) secs	
}

FieldSeparator_CommaToTab() {
	f=$1
	t0=$(date +%s)
	perl -i.filedValueTabToSpace -pE 's/","/"\t"/g' $f
	t1=$(date +%s)
	echo FieldSeparator_CommaToTab: $(( $t1 - $t0 )) secs	
}

removeFieldClosureSignDoubleQuotes() {
	f=$1
	t0=$(date +%s)
	perl -i.FieldSeparator_CommaToTab -pE 's/(^"|"$|(?<=\t)"|"(?=\t))//g' $f
	t1=$(date +%s)
	echo removeFieldClosureSignDoubleQuotes: $(( $t1 - $t0 )) secs	
}

showFieldsSeparatorInfo() {
	f=$1
	echo -n "FS info - "
	awk -F','  '{printf ",: %02d", NF; exit}' $f
	awk -F' '  '{printf "  \\s: %02d", NF; exit}' $f
	awk -F'\t' '{printf "  \\t: %02d", NF; exit}' $f
	echo
}

# first: 			FS->','		null value -> null 		field clouser sign -> '"'
# after 20160226, 	FS->'\t'	null value -> ""		field clouser sign -> '"'
# after 20160510, 	FS->'\t'	null value -> ""		field clouser sign -> no clouser sign
main () {
	begin="2015-12-30" # end date: 20160510
	for (( i=0; i<=132; i++)); do
		ymd=$(date -d "$begin +$i days" +%04Y%02m%02d)
		fileOriginal=$(getFileOriginalFullPath $ymd)
		if [ ! -e $fileOriginal ]; then
			continue
		fi

		if [ "$ymd" = "20160226" ]; then
			continue
		fi

		fileOperated=$(getFileOperatedFullPath $ymd)
		createYmdWorkspace $ymd $fileOriginal $fileOperated

		echo ------------------------------------------------------------
		printf "%03d - %s - %s\n" $i $ymd $fileOperated

		if (( $ymd < 20160226 )); then
			truncateLog4jPrefix $fileOperated
			nullToEmpty $fileOperated
			filedValueTabToSpace $fileOperated
			FieldSeparator_CommaToTab $fileOperated
		fi
		removeFieldClosureSignDoubleQuotes $fileOperated
		
		showFieldsSeparatorInfo $fileOperated

		echo
	done
}

main
