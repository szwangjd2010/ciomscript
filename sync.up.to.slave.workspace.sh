#!/bin/bash
#

appName=$1
src=$WORKSPACE/$appName
dst=/home/jenkins/ciom.slave.win.workspace/$appName


main() {
	rsync -az \
		--exclude .svn \
		--exclude packages/* \
		--delete \
		--force \
		$src/ $dst/
}

main