#!/bin/bash
# 
#
source $CIOM_HOME/ciom/ciom.util.sh
if [ "$JENKINS_HOME" == "" ]; then
	simulateJenkinsContainer
fi

version=$1
deployToEnv=$2
appName=$3


CnfLocation="$ENV{CIOM_HOME}/ciom/ciomvca/$version/pre/$deployToEnv"


enterWorkspace() {
	execCmd "echo"
}

leaveWorkspace() {
	execCmd "echo"
}

replaceEnvSpecialFiles() {
	execCmd "/bin/cp -rf $CnfLocation/$appName/* $WORKSPACE/$appName/"
}

execPrebuildExtraAction() {
	filePrebuildExtraAction="$CnfLocation/$appName.prebuild.extra.action"
	if [ ! -e $filePrebuildExtraAction ]; then
		return
	fi

	echo
	cat $filePrebuildExtraAction
	echo
	source $filePrebuildExtraAction
}

main() {
	enterWorkspace
	replaceEnvSpecialFiles
	execPrebuildExtraAction
	leaveWorkspace
}

main

unsimulateJenkinsContainer