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
bTarget=${4:-master}

if [ "$bTarget" == "master" ]; then
	AppPackageFile="$appName.war"
	AppDirectory="$WORKSPACE/$appName/target"
fi

if [ "$bTarget" == "win" ]; then
	AppPackageFile="$appName.zip"
	AppDirectory="$CIOM_SLAVE_WIN_WORKSPACE/$version/$deployToEnv/build/$appName"
fi

if [ "$bTarget" == "none" ]; then
	AppDirectory="$CIOM_SLAVE_WIN_WORKSPACE/$version/$deployToEnv/$appName"
fi

CnfLocation="$CIOM_VCA_HOME/$version/post/$deployToEnv"

enterWorkspace() {
	execCmd "cd $AppDirectory"
}

leaveWorkspace() {
	execCmd "cd $WORKSPACE"
}

generateAppPackage() {

	if [ "$bTarget" == "master" ]; then
		execCmd "cd $WORKSPACE/$appName; zip -r ../$AppPackageFile *"
	fi
	
	if [ "$bTarget" == "win" ]; then
		execCmd "cd ..;rm -rf ../$AppPackageFile; zip -r ../$AppPackageFile $appName/*"
	fi
}


replaceEnvSpecialFiles() {
	execCmd "/bin/cp -rf $CnfLocation/$appName/* $WORKSPACE/$appName/target/$appName/"
}

execPostbuildExtraAction() {
	filePostbuildExtraAction="$CnfLocation/$appName.postbuild.extra.action"
	if [ ! -e $filePostbuildExtraAction ]; then
		return
	fi

	echo
	cat $filePostbuildExtraAction
	echo
	source $filePostbuildExtraAction
}

main() {
	enterWorkspace
	replaceEnvSpecialFiles
	execPostbuildExtraAction
	generateAppPackage
	leaveWorkspace
}

main $@
