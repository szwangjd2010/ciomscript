#!/bin/bash
#
source $CIOM_SCRIPT_HOME/ciom.util.sh
source $CIOM_SCRIPT_HOME/yhdc/log.common.sh "$@"

setMode 1

hdfsBin="/opt/hadoop-2.7.1/bin/hdfs"

getSrcFile() {
	echo -n "hdfs://hdc-54/raw/${logType}log/${product}.${logType}.${year}${month}.log"	
}

getDstLocation() {
	echo -n "hdfs://hdc-54/user/hive/warehouse/yxt.db/${product}_${logType}log/year=${year}/month=${month}/"	
}

cp2016() {
	year=2016
	
	for (( i=1; i<=12; i++ )); do
		month=$(printf "%02d" $i)
		src=$(getSrcFile)
		dst=$(getDstLocation)

		echo "check if local exist ... "
		execCmd "$hdfsBin dfs -test -f $src"
		if [ $? -ne 0 ]; then
			echo "raw data $src not exists"
			continue
		fi

		execCmd "$hdfsBin dfs -cp -f $src $dst"
	done
}

cp2017() {
	year=2017
	
	for (( i=1; i<=1; i++ )); do
		month=$(printf "%02d" $i)
		src=$(getSrcFile)
		dst=$(getDstLocation)

		echo "check if local exist ... "
		execCmd "$hdfsBin dfs -test -f $src"
		if [ $? -ne 0 ]; then
			echo "raw data $src not exists"
			continue
		fi

		execCmd "$hdfsBin dfs -cp -f $src $dst"
	done
}


main() {
	for product in $Products; do
		for logType in $LogTypes; do
			cp2017
		done
	done
}

main
