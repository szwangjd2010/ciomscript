#!/bin/bash
# 
#
Products="qida lecai mall wangxiao"
LogTypes="action access"
Location=/sdc/ciompub/behavior/_clean

getFileNamePattern() {
	product=$1
	logType=$2
	echo -n "${product}_${logType}.*.all-instances.log"
}

getInspectedOutFile() {
	echo -n "$1.inspect-done"
}

getInspectingOutFile() {
	echo -n "$1.inspecting"
}

inspectFile() {
	awk -F'\t' 'BEGIN {out = "";} {out = out "" sprintf("%d,%d\n", NR, NF);} END {printf(out)}' $1 > $2
}

main () {
	for product in $Products; do
		for logType in $LogTypes; do
			fileNamePattern=$(getFileNamePattern $product $logType)
			for f in $(find $Location -name $fileNamePattern); do
				echo -n "inspecting $f ... "
				inspectingOutFile=$(getInspectingOutFile $f)
				inspectedOutFile=$(getInspectedOutFile $f)
				if [ -e $inspectedOutFile ]; then
					echo "already inpected"
					continue
				fi

				inspectFile $f $inspectingOutFile
				mv $inspectingOutFile $inspectedOutFile
				echo "done"
			done
		done
	done
}

main
