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
gruntType=${4:-noskip}
deployType=${5:-h5web}

AppPackageFile="$appName.zip"

enterWorkspace() {
	execCmd "cd $WORKSPACE/$appName"
}

leaveWorkspace() {
	execCmd "cd $WORKSPACE"
}

gruntCompress() {
	if [ "$gruntType" != "skipgrunt" ]; then
		if [ "$gruntType" == "gruntRelease" ]; then
    		execCmd "grunt release"
        else
            execCmd "grunt"
        fi
	fi
}

generateAppPackage() {
	if [ "$deployType" == "h5webnew" ]; then
		execCmd "cd ..;rm -rf $AppPackageFile; mv $appName/version.txt $appName/src/; zip -r $AppPackageFile $appName/src/*"
	elif [ "$deployType" == "h5webWithTarget" ]; then
		folderTarget=$(grep "folderTarget" $CIOM_VCA_HOME/$version/pre/$deployToEnv/$appName.ciom| cut -d "'" -f 2)
		execCmd "cd ..;rm -rf $AppPackageFile; mv $appName/version.txt $appName/$folderTarget/; zip -r $AppPackageFile $appName/$folderTarget/*"
	else
        execCmd "cd ..;rm -rf $AppPackageFile; mv $appName/version.txt $appName/app/; zip -r $AppPackageFile $appName/app/*"
    fi
}


main() {
	enterWorkspace
	gruntCompress
	generateAppPackage
	leaveWorkspace
}

main $@
