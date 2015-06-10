#!/bin/bash
#

ver=$1
env=$2
appName=$3

src="$WORKSPACE/$appName"
dst="/opt/ciom/ci.slave.win/$ver/$env/$appName"


main() {
	rsync -az \
		--exclude .svn \
		--exclude packages/* \
		--delete \
		--force \
		$src/ $dst/
}

main