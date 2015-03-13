#!/bin/bash
# 
#
if [ "$JENKINS_HOME" == "" ]; then
	source $CIOM_HOME/ciom.util.sh
	simulateJenkinsContainer
else 
	source $JENKINS_HOME/workspace/ciom/ciom.util.sh
fi

version=$1
deployToEnv=$2
appName=$3


CnfLocation="$JENKINS_HOME/workspace/ver.env.specific/$version/pre/$deployToEnv"


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