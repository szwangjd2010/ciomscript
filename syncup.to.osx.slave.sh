#!/bin/bash
#


slaveIdx=$1
wsIdx=$2
ver=$3
env=$4
appName=$5
slaveId=$6

src="$WORKSPACE/slave${slaveIdx}ws${wsIdx}/$appName"

if [ "$slaveId" == 0 ]; then
	slaveWorkspaceEnvVarName="CIOM_SLAVE_OSX_WORKSPACE"
else
	slaveWorkspaceEnvVarName="CIOM_SLAVE_OSX${slaveId}_WORKSPACE"
fi

#echo $slaveWorkspaceEnvVarName
dst="${!slaveWorkspaceEnvVarName}/ws${wsIdx}/$ver/$env/$appName"


syncup_osx() {
	#-a -> -rlptgoD, with group preserver, will cause chgrp error - can not chgrp at NFS
	# so surpress option g
	rsync -rlptoDz \
		--exclude .svn \
		--delete \
		--force \
		$src/ $dst/	
}

main() {
#	echo $dst
	if [ ! -d $dst ]; then
		mkdir -p $dst
	fi

	syncup_osx
	
}

main