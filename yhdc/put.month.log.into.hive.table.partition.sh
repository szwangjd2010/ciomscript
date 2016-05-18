#!/bin/bash
#
source $CIOM_SCRIPT_HOME/ciom.util.sh
setMode ${1:-0}

Products="lecai wangxiao qida mall"
LogTypes="action access"

year=''
month=''
product=''
logType=''

getSrcFile() {
	echo -n "/raw/${logType}log/${product}.${logType}.${year}${month}.log"	
}

getDstLocation() {
	echo -n "/user/hive/warehouse/yxt.db/${product}_${logType}log/year=${year}/month=${month}/"	
}

cp2015() {
	year=2015
	month=12

	execCmd "hdfs dfs -cp $(getSrcFile) $(getDstLocation)"
}

cp2016() {
	year=2016
	
	for (( i=1; i<=12; i++ )); do
		month=$(printf "%02d" $i)
		execCmd "hdfs dfs -cp $(getSrcFile) $(getDstLocation)"
	done
}


main() {
	for product in $Products; do
		for logType in $LogTypes; do
			cp2015
			cp2016
		done
	done
}

main
