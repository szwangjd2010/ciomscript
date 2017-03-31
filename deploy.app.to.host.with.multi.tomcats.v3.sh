#!/bin/bash
#
source $CIOM_SCRIPT_HOME/ciom.util.sh
if [ "$JENKINS_HOME" == "" ]; then
	simulateJenkinsContainer
fi

host=$1
port=$2
tomcatParent=$3
appName=$4
appRepoURI=$5
appRepoScpURI=$6
remoteWorkspace=$7
asRoot=${8:-NotAsRoot}

AppPackageFile="$appName.war"
LocalMd5Sum=$(md5sum $AppPackageFile|cut -d ' ' -f1)
MyWorkspace="$WORKSPACE/$appName/target"
WebappsLocation="$tomcatParent/webapps"
RemoteWorkspace="$remoteWorkspace"

appContextName=$appName

RepoHost=${appRepoScpURI%%:*}
RepoLocation4Job="${appRepoScpURI##*:}/${JOB_NAME}"


enterWorkspace() {
	execCmd "cd $MyWorkspace"
}

leaveWorkspace() {
	execCmd "cd $MyWorkspace"
}

uploadPackageToWorkspace() {
	if [ "$appRepoURI" == "" ]; then
		echo "[CIOM] Upload $AppPackageFile from local"
		upload $AppPackageFile $host $port $RemoteWorkspace/
	else
		echo "[CIOM] Upload $AppPackageFile from Repo"
		execRemoteCmd $host $port "wget -nH -N -P $RemoteWorkspace/ $appRepoURI/${JOB_NAME}/$AppPackageFile 2>/dev/null"
	fi
}

uploadToWorkspaceWithMd5Check() {
	remoteMd5Sum=$(ssh -p $port root@$host "md5sum $RemoteWorkspace/$AppPackageFile|cut -d ' ' -f1")
	if [ "$LocalMd5Sum" == "$remoteMd5Sum" ]; then
		echo "[CIOM] local and remote package file are same, no need to upload again"
	else
		echo "[CIOM] local and remote package file are different, will upload ..."
		uploadPackageToWorkspace
	fi
}


uploadPackageToRepo() {
	execCmd "ssh -p $port $RepoHost \"mkdir -p $RepoLocation4Job\""
	execCmd "scp -r $AppPackageFile $appRepoScpURI/$JOB_NAME/$AppPackageFile" 
}

uploadAppPackgeToRepoIfNeeded() {
	
	execCmd "ssh -p $port $RepoHost \"test -e $RepoLocation4Job/$AppPackageFile\""
	if [ $? == 0 ]; then
		repoMd5Sum=$(ssh -p $port $RepoHost "md5sum $RepoLocation4Job/$AppPackageFile|cut -d ' ' -f1")
		if [ "$LocalMd5Sum" != "$repoMd5Sum" ]; then
			echo "[CIOM] In app repo, $AppPackageFile is not the lasted one, upload ..."
			uploadPackageToRepo
		fi
	else
		echo "[CIOM] $AppPackageFile not exists in app repo, upload ..."
		uploadPackageToRepo
	fi
}

uploadAppPackgeToWorkspace() {
	execRemoteCmd $host $port "test -e $RemoteWorkspace/$AppPackageFile"
	if [ $? == 0 ]; then
		uploadToWorkspaceWithMd5Check
	else
		uploadPackageToWorkspace
	fi
}

uploadAppPackage() {
	if [ "$appRepoURI" != "" ]; then
		uploadAppPackgeToRepoIfNeeded
	fi
	uploadAppPackgeToWorkspace
}

applyAppPackage() {
	execRemoteCmd $host $port "unzip -o $RemoteWorkspace/$AppPackageFile -d $WebappsLocation/$appContextName"
}

backup() {
	execCmd "ssh -p $port root@$host \"test -e $WebappsLocation/$appContextName/WEB-INF/classes/version.txt\""
	if [ $? == 0 ]; then
		backupPostfix=$(ssh -p $port root@$host "head -1 $WebappsLocation/$appContextName/WEB-INF/classes/version.txt")
		execRemoteCmd $host $port "cd $WebappsLocation; tar -czvf $tomcatParent/$AppPackageFile-$backupPostfix.tgz $appContextName"
	else
		timestamp=$(date +%04Y%02m%02d.%02k%02M%02S)
		execRemoteCmd $host $port "cd $WebappsLocation; tar -czvf $tomcatParent/$AppPackageFile-$timestamp.tgz $appContextName"
	fi
}

clean() {
	execRemoteCmd $host $port "cd $WebappsLocation; rm -rf $appContextName $appName"	
}

setAppContextName() {
	if [ $asRoot == "AsRoot" ]; then
		appContextName='ROOT'
	fi
}

preDeployApp() {
	stopTomcats $host $port $tomcatParent
	sleep 3
}

removeCatalinaLog() {
	execRemoteCmd $host $port "rm -rf $tomcatParent/tomcat*/logs/catalina.out"
}

postDeployApp() {
	removeCatalinaLog
	startTomcats $host $port $tomcatParent
}

main() {
	setAppContextName
	enterWorkspace
	uploadAppPackage
	preDeployApp
	backup
	clean
	applyAppPackage
	postDeployApp
	leaveWorkspace
}

main

unsimulateJenkinsContainer