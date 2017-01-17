#!/bin/bash
# 
#

source $CIOM_SCRIPT_HOME/ciom.util.sh
if [ "$JENKINS_HOME" == "" ]; then
	simulateJenkinsContainer
fi

version=$1
deployToEnv=$2
appName=$3


CnfLocation="$CIOM_VCA_HOME/$version/pre/$deployToEnv"


enterWorkspace() {
	execCmd "echo"
}

leaveWorkspace() {
	execCmd "echo"
}

replaceEnvSpecialFiles() {
	
	if [ ! -d "$WORKSPACE/$appName" ]; then
		mkdir "$WORKSPACE/$appName"
	fi

	execCmd "/bin/cp -rf $CnfLocation/$appName/* $WORKSPACE/$appName/"
}

replaceReplaceCustomizedVcaFiles() {
	
	if [ -d "$WORKSPACE/ciomcvca" ]; then
		execCmd "/bin/cp -rf $WORKSPACE/ciomcvca/* $WORKSPACE/$appName/"
		execCmd "rm -rf $WORKSPACE/ciomcvca"
	fi

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
	replaceReplaceCustomizedVcaFiles
	execPrebuildExtraAction
	leaveWorkspace
}

main

unsimulateJenkinsContainer