#!/bin/bash
# 
prod=$1
if [ "$prod" == "" ]; then
	cat <<END
usage:
  $0 (qida|wangxiao|lecai|mall)

END
	exit 0
fi

transformShellFile=${prod}.event.log.trans.sh
find /data -name "event.*.log" | perl -pE 's|^(.*)/([^/\n]+)$|ln -sf $1/$2 $1/'$prod'_$2|g' > $transformShellFile
bash $transformShellFile
cat $transformShellFile