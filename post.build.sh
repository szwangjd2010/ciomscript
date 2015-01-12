#!/bin/bash
# 
#

deployToEnv=$1
appName=$2
version=${3:-v1}

# 0: DONOT do actual deploy on target, for debug only
# 1: DO actual deploy on target
RUN_MODE=1

ADLog="/tmp/_ciom.log"
AppPackageFile="$appName.$BUILD_ID.tgz"
Adworkspace="$WORKSPACE/$appName/target"
CnfLocation="$JENKINS_HOME/workspace/ver.env.specific/$version/post/$deployToEnv"

outHelp() {
	cat <<HELP
"Usage: 
  $0 %deployToEnv %appName"
  %deployToEnv: 'test' or 'production'
  %appName: 'api' or 'back'
  
example:
  $0 "test" "api"
  $0 "test" "back"
  $0 "production" "api"
  
HELP
}


execCmd() {
	echo "$1" | tee -a $ADLog
	if [ $RUN_MODE -eq 1 ]; then
		eval $1
	fi	
}

enterWorkspace() {
	execCmd "cd $Adworkspace"
}

leaveWorkspace() {
	execCmd "cd $Adworkspace"
}

checkArgus() {
	if [ $# -lt 2 ]; then
		outHelp
		exit 1
	fi
}

generateAppPackage() {
	#execCmd "find $appName -print0 | xargs -0 -I {} touch '{}'; tar -czhvf $AppPackageFile $appName"
	execCmd "tar -czhvf $AppPackageFile $appName"
}

replaceEnvSpecialFiles() {
	execCmd "/bin/cp -rf $CnfLocation/$appName/* $WORKSPACE/$appName/target/$appName/"
}

unzipWar() {
	execCmd "rm -rf $appName; unzip $appName.war -d $appName"
}

main() {
	checkArgus $@
	
	enterWorkspace
	if [ "$version" == "v2" ]; then
		unzipWar
	fi
	
	replaceEnvSpecialFiles
	generateAppPackage
	leaveWorkspace
}

main $@
