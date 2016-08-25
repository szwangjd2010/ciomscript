#!/bin/bash
#
#

dt=$1

echo "begin importing ... "
for name in mall component lecai2; do
	sqlFile=yxt.${name}-${dt}
	echo "importing $name ... "
	mysql -e "source ./${sqlFile}"
done
