#!/bin/bash
#

source $CIOM_SCRIPT_HOME/ciom.util.sh

timestamp=$(getTimestamp)
username="jenkins"
password="pwdasdwx"

svnparams="--username $username --password $password --non-interactive -m \"by jenkins\""

setMode 0
log 0

repoBranches="http://172.17.128.21:9000/svn/el/branches"

if [ "$PC" = "true" ]; then
    execCmd "svn cp $svnparams $repoBranches/laststable $repoBranches/laststable-v$timestamp"
    execCmd "svn del $svnparams $repoBranches/laststable/eLearning"
    execCmd "svn del $svnparams $repoBranches/laststable/Dlls"
    execCmd "svn cp $svnparams $repoBranches/laststable2/eLearning $repoBranches/laststable/"
    execCmd "svn cp $svnparams $repoBranches/laststable2/Dlls $repoBranches/laststable/"
fi

if [ "$H5" = "true" ]; then
    execCmd "svn cp $svnparams $repoBranches/laststable $repoBranches/laststable-v$timestamp"
    execCmd "svn del $svnparams $repoBranches/laststable/eLearningH5.01"
    execCmd "svn cp $svnparams $repoBranches/laststable2/eLearningH5.01 $repoBranches/laststable/"
fi

if [ "$JAVAAPI" = "true" ]; then
    repoBranches="http://172.17.127.72/hz/yxtv2/branches"
    execCmd "svn cp $svnparams $repoBranches/laststable-qida $repoBranches/laststable-qida-v$timestamp"
    execCmd "svn del $svnparams $repoBranches/laststable-qida/qidaapi"
    execCmd "svn del $svnparams $repoBranches/laststable-qida/waf-qida"
    execCmd "svn cp $svnparams $repoBranches/laststable-qida-test/qidaapi $repoBranches/laststable-qida/"
    execCmd "svn cp $svnparams $repoBranches/laststable-qida-test/waf-qida $repoBranches/laststable-qida/"
fi
