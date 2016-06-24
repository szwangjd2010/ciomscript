#!/bin/bash
# 
location=$1
prod=$2
if [ "$location" == "" ] || [ "$prod" == "" ]; then
	cat <<END
usage:
  $0 /data lecaiapi
  $0 /data/ws-1/ mallapi

END
	exit 0
fi

transformShellFile=${prod}.event.log.trans.sh
find $location -name "event.*.log" | perl -pE 's|^(.*)/([^/\n]+)$|mv $1/$2 $1/'$prod'_$2|g' > $transformShellFile
bash $transformShellFile
cat $transformShellFile