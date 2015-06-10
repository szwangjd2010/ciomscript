#!/bin/bash
#

ver=$1
env=$2
appName=$3
workspace=$4

src="$workspace/$appName"
dst="$CIOM_HOME/ci.slave.win/$ver/$env/$appName"


main() {
	rsync -az \
		--exclude .svn \
		--exclude packages/* \
		--delete \
		--force \
		$src/ $dst/
}

main