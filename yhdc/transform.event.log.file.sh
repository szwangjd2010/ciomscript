#!/bin/bash
# 
prod=$1

find /data -name "event.*.log" | perl -pE 's|^(.*)/([^/\n]+)$|ln -s $1/$2 $1/'$prod'_$2|g' > ${prod}.event.log.trans.sh
#find /data -name "event.*.log" | perl -pE 's|^(.*)/([^/\n]+)$|ln -s ${1}/${2} ${1}/'$prod'_${2}|g'