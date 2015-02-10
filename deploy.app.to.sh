#!/bin/bash
# 
#
appName=$1
targetIP=$2
targetPort=$3
targetTomcatHome=$4


# 0: DONOT do actual deploy on target, for debug only
# 1: DO actual deploy on target
RUN_MODE=1

ADLog="/tmp/_ciom.log"

AppPackageFile="$appName.$BUILD_ID.tgz"
TargetADWorkspace="/root"
Adworkspace="$WORKSPACE/$appName/target"
WebappsLocation="$targetTomcatHome/webapps"
TomcatPattern="$targetTomcatHome/"

outHelp() {
	cat <<HELP
"usage: 
  $0 %appName %targetIP %targetPort %targetTomcatHome"

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

upload() {
	execCmd "scp -P $targetPort $1 root@$targetIP:$TargetADWorkspace/"
}

execRemoteCmd() {
	execCmd "ssh -p $targetPort root@$targetIP \"$1\""
}

uploadFiles() {
	upload $AppPackageFile
}

applyAppPackage() {
	execRemoteCmd "tar --overwrite -xzpvf $TargetADWorkspace/$AppPackageFile -C $WebappsLocation"
}

backup() {
	timestamp=$(date +%04Y%02m%02d.%02k%02M%02S)
	execRemoteCmd "cd $WebappsLocation; tar -czvf $targetTomcatHome/$appName-$timestamp.tgz $appName; rm -rf $appName; "
}

stopTargetService() {
	execRemoteCmd "pkill -9 -f '$TomcatPattern'"
}

startTargetService() {
	execRemoteCmd "export JRE_HOME='/usr/java/jdk1.7.0_76'; $targetTomcatHome/bin/startup.sh"
}

checkArgus() {
	if [ $# -lt 4 ]; then
		outHelp
		exit 1
	fi
}

main() {
	checkArgus $@
	enterWorkspace
	uploadFiles
	stopTargetService
	backup
	applyAppPackage
	startTargetService
	leaveWorkspace
}

main $@
