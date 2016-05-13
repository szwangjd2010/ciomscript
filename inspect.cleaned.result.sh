#!/bin/bash
# 
#
Products="qida lecai mall wangxiao"
LogTypes="action access"
Location=/sdc/ciompub/behavior/_clean

declare -A LogFN=( ["action"]="32" ["access"]="20" )

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
	f=$1
	echo -n "inspecting $f ... "
	inspectingOutFile=$(getInspectingOutFile $f)
	inspectedOutFile=$(getInspectedOutFile $f)
	if [ -e $inspectedOutFile ]; then
		echo "already inpected"
		return
	fi

	awk -F'\t' 'BEGIN {out = "";} {out = out "" sprintf("%d,%d\n", NR, NF);} END {printf(out)}' $f > $inspectingOutFile
	mv $inspectingOutFile $inspectedOutFile
	echo "done"	
}

filterDirtyLine() {
	logType=$1
	f=$2

	inspectedOutFile=$(getInspectedOutFile $f)
	dirtyFilteringFile=$inspectedOutFile.dirtyline-filtering
	dirtyFilteredFile=$inspectedOutFile.dirtyline-filtered

	echo -n "filtering dirty line ... "
	if [ -e $dirtyFilteredFile ]; then
		echo "already filtered"
		return
	fi

	logFN=${LogFN[$logType]}
	grep -v ",$logFN"  $inspectedOutFile > $dirtyFilteringFile
	mv $dirtyFilteringFile $dirtyFilteredFile
	echo "done"
}

main () {
	for product in $Products; do
		for logType in $LogTypes; do
			fileNamePattern=$(getFileNamePattern $product $logType)
			for f in $(find $Location -name $fileNamePattern | sort); do
				inspectFile $f
				filterDirtyLine $logType $f
			done
		done
	done
}

main
