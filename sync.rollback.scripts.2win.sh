#!/bin/bash
# 
#

source $CIOM_SCRIPT_HOME/ciom.util.sh

version=$1
deployToEnv=$2
appName=$3

SrcLocation="$CIOM_VCA_HOME/$version/pre/$deployToEnv"
DestLocation="$CIOM_SLAVE_WIN_WORKSPACE/$version/$deployToEnv"


replaceRollbackScripts() {
	
	if [ ! -d "$WORKSPACE/$appName" ]; then
		mkdir "$WORKSPACE/$appName"
	fi

	if [ -f "$SrcLocation/$appName/*.rollback.*" ]; then
		execCmd "/bin/cp -rf $SrcLocation/$appName/*.rollback.* $DestLocation/$appName/"
	fi
}

main() {
	replaceRollbackScripts
}

main
