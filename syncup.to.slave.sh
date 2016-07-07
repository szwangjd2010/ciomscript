#!/bin/bash
#

ver=$1
env=$2
appName=$3
os=$4
excludePackagesDir=${5-:1}

src="$WORKSPACE/$appName"
slaveWorkspaceEnvVarName="CIOM_SLAVE_${os^^}_WORKSPACE"
dst_win="${!slaveWorkspaceEnvVarName}/$ver/$env/$appName"
dst_osx="${!slaveWorkspaceEnvVarName}/ws/$ver/$env/$appName"

syncup_win() {
	if [ ! -d $dst_win ]; then
		mkdir -p $dst_win
	fi

	excludeItem=""
	if [ "excludePackagesDir" == "1" ]; then
		excludeItem="--exclude packages/*"
	fi

	rsync -az \
		--exclude .svn \
		$excludeItem \
		--delete \
		--force \
		$src/ $dst_win/
}

syncup_osx() {
	if [ ! -d $dst_osx ]; then
		mkdir -p $dst_osx
	fi
	#-a -> -rlptgoD, with group preserver, will cause chgrp error - can not chgrp at NFS
	# so surpress option g
	rsync -rlptoDz \
		--exclude .svn \
		--delete \
		--force \
		$src/ $dst_osx/	
}

main() {
	syncup_${os}
}

main