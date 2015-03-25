#!/bin/bash
#

workspace=$1
appName=$2
src="$workspace/$appName"
dst="/home/jenkins/ciom.slave.win.workspace/$appName"


main() {
	rsync -az \
		--exclude .svn \
		--exclude packages/* \
		--delete \
		--force \
		$src/ $dst/
}

main