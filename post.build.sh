#!/bin/bash
# 
#
if [ "$JENKINS_HOME" == "" ]; then
	source $CIOM_HOME/ciom.util.sh
	simulateJenkinsContainer
else 
	source /opt/ciom/ciom.util.sh
fi

deployToEnv=$1
appName=$2
version=${3:-v1}

AppPackageFile="$appName.war"
Adworkspace="$WORKSPACE/$appName/target"
CnfLocation="$ENV{CIOM_HOME}/ciom/ciomvca/$version/post/$deployToEnv"

enterWorkspace() {
	execCmd "cd $Adworkspace"
}

leaveWorkspace() {
	execCmd "cd $Adworkspace"
}

generateAppPackage() {
	execCmd "cd $appName; zip -r ../$AppPackageFile *"
}

replaceEnvSpecialFiles() {
	execCmd "/bin/cp -rf $CnfLocation/$appName/* $WORKSPACE/$appName/target/$appName/"
}

main() {
	enterWorkspace
	replaceEnvSpecialFiles
	generateAppPackage
	leaveWorkspace
}

main $@
