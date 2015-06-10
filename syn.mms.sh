#!/bin/bash

source $CIOM_HOME/ciom/ciom.mysql.util.sh

isSyncDbData=${1:-0}
isFirstTime=${2:-0}

main() {
	stopSlaves
	
	if [ $isSyncDbData -eq 1 ]; then
		dumpMaster
		import2Slaves
		resetMaster
		firstTimeSetSlavesMaster
	else
		setSlavesMaster
	fi

	startSlaves
	showSlavesStatus
}

main
