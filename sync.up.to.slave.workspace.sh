#!/bin/bash
#

ver=$1
env=$2
appName=$3

src="$WORKSPACE/$appName"
dst="/opt/ciom/ci.slave.win/$ver/$env/$appName"


main() {
	if [ ! -d /opt/ciom/ci.slave.win/$ver/$env/$appName ]; then
		mkdir -p /opt/ciom/ci.slave.win/$ver/$env/$appName
	fi
	
	if [ ! -d /opt/ciom/ci.slave.win/$ver/$env/build ]; then
		mkdir -p /opt/ciom/ci.slave.win/$ver/$env/build
	fi	

	rsync -az \
		--exclude .svn \
		--exclude packages/* \
		--delete \
		--force \
		$src/ $dst/
}

main