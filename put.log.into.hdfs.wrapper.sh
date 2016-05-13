#!/bin/bash
# 
#

begin=${1:-2015-12-30}
end=${1:-2016-05-10}
#end=${1:-2015-12-30}
main () {
	ymdEnd=$(date -d "$end" +%04Y%02m%02d)

	for (( i=0; i<1000; i++ )); do
		ymd=$(date -d "$begin +$i days" +%04Y%02m%02d)
		if (( $ymd > $ymdEnd )); then
			break
		fi
		
		if [ "$ymd" = "20160226" ]; then
			continue
		fi

		echo -n "put $ymd ... "
		./put.log.into.hdfs.sh $ymd
		echo "done"
	done
}

main