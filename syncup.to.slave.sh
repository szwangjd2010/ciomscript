#!/bin/bash
#

ver=$1
env=$2
appName=$3
os=$4

src="$WORKSPACE/$appName"
slaveWorkspaceEnvVarName="CIOM_SLAVE_${os^^}_WORKSPACE"
dst="${!slaveWorkspaceEnvVarName}/$ver/$env/$appName"

syncup_win() {
	rsync -az \
		--exclude .svn \
		--exclude packages/* \
		--delete \
		--force \
		$src/ $dst/
}

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
	if [ ! -d $dst ]; then
		mkdir -p $dst
	fi

	syncup_${os}
}

main