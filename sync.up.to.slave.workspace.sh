#!/bin/bash
#

WORKSPACE=${WORKSPACE:-$1}
appName=$2
src=$WORKSPACE/$appName
dst=/home/jenkins/ciom.slave.win.workspace


main() {
	rm -rf $dst/$appName
	/bin/cp -rf $src $dst/
}

main