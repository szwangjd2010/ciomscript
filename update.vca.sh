#!/bin/bash
# 

version=$1
cloudId=${2:-""}
appName=${3:-""}

if [ "$appName" == "" ]; then
	echo "[CIOM] SVN update for $version->$cloudId"
else
	echo "[CIOM] SVN update for $version->$cloudId->$appName"
fi

appVcaHome="$CIOM_VCA_HOME/$version/pre/$cloudId/$appName"
cd $appVcaHome
eval "svn --no-auth-cache $(cat $CIOM_SCRIPT_HOME/svn/jenkins.credential) update"
