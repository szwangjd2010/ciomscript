#!/bin/bash
# 
#
source $CIOM_SCRIPT_HOME/ciom.util.sh
if [ "$JENKINS_HOME" == "" ]; then
	simulateJenkinsContainer
fi

version=${1:-v1}
deployToEnv=$2
appName=$3

AppPackageFile="$appName.zip"

enterWorkspace() {
	execCmd "cd $WORKSPACE/$appName"
}

leaveWorkspace() {
	execCmd "cd $WORKSPACE"
}

gruntCompress() {
	execCmd "grunt"
}

generateAppPackage() {
	execCmd "cd ..;rm -rf $AppPackageFile; zip -r $AppPackageFile $appName/app/*"
}


main() {
	enterWorkspace
	#gruntCompress
	generateAppPackage
	leaveWorkspace
}

main $@
