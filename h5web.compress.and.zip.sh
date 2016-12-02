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
skipGrunt=${4:-noskip}
deployType=${5:-h5web}

AppPackageFile="$appName.zip"

enterWorkspace() {
	execCmd "cd $WORKSPACE/$appName"
}

leaveWorkspace() {
	execCmd "cd $WORKSPACE"
}

gruntCompress() {
	if [ "$skipGrunt" != "skipgrunt" ]; then
		if [ "$appName" == "mallh5mobile" ]; then
            execCmd "grunt release"
    	elif [ "$appName" == "mallh5mobile2" ]; then
    		execCmd "grunt release"
        else
            execCmd "grunt"
        fi
	fi
}

generateAppPackage() {
	if [ "$deployType" == "h5webnew" ]; then
		execCmd "cd ..;rm -rf $AppPackageFile; zip -r $AppPackageFile $appName/src/*"
	else
        execCmd "cd ..;rm -rf $AppPackageFile; zip -r $AppPackageFile $appName/app/*"
    fi
}


main() {
	enterWorkspace
	gruntCompress
	generateAppPackage
	leaveWorkspace
}

main $@
