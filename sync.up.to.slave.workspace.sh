#!/bin/bash
#

ver=$1
env=$2
appName=$3
workspace=$4

src="$workspace/$appName"
dst="/home/jenkins/ciom.slave.win.workspace/$ver/$env/$appName"


main() {
	rsync -az \
		--exclude .svn \
		--exclude packages/* \
		--delete \
		--force \
		$src/ $dst/
}

main