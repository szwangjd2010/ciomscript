#!/bin/bash 
#
source $CIOM_SCRIPT_HOME/ciom.util.sh

lastDays=$1
fileMergedLog="qidaapi.evt.log"
fileHZMergedLog="hz.qidaapi.evt.log"

main() {
	execRemoteCmd 10.4.3.237 22 'rm -rf /tmp/$fileMergedLog; find /data/ -mtime -$lastDays -name event.*.log -exec cat {} >> /tmp/$fileMergedLog \;'
	execRemoteCmd 10.4.3.237 22 "grep -P '/v1/figures.*71028353-7246-463f-ab12-995144fb4cb2.$' /tmp/$fileMergedLog > /tmp/$fileHZMergedLog"
	execRemoteCmd 10.4.3.237 22 "grep -P '/v1/orgs/71028353-7246-463f-ab12-995144fb4cb2/todo' /tmp/$fileMergedLog >> /tmp/$fileHZMergedLog"

	rm -rf ./$fileHZMergedLog
	scp root@10.4.3.237:/tmp/$fileHZMergedLog .

	#grep -P -o '[\w-]+(?=","[\w-]+"$)' $fileHZMergedLog | sort | uniq -c | sort -nr > hz.imapi.todo.userid.times.result

	perl $CIOM_SCRIPT_HOME/stat.imapi.usage.pl

	fileDatedUsage=usage-$(getDatestamp).csv
	/bin/cp -rf ./usage.csv /sdb/ciompub/starfish/$fileDatedUsage


	echo 
	echo
	echo "------------------------------------------------------------------------------------------------"	
	cat ./usage.csv
	echo "------------------------------------------------------------------------------------------------"
	echo
	echo
	echo "click to download excel report:"
	echo "http://172.17.128.240/ciompub/starfish/$fileDatedUsage"
	echo 
	echo

}

main
