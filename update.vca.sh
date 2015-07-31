#!/bin/bash
# 

version=$1
cloudId=$2
appName=$3

appVcaHome="$CIOM_VCA_HOME/$version/pre/$cloudId/$appName"
cd $appVcaHome
eval "svn --no-auth-cache $(cat $CIOM_SCRIPT_HOME/mobile.vca.repo.credential) update"
