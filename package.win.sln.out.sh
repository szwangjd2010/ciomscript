#!/bin/bash
#

appName=$1
buildoutPath=/home/jenkins/ciom.slave.win.workspace/build
AppPackageFile='yxtweb.zip'

main() {
	cd $buildoutPath
	zip -r ../$AppPackageFile *
}

main