param($timestamp, $appName, $siteName, $app3wPath)

$logFile = "c:\ciom.log"

function log($str) {
	echo  "$str" >> $logFile
}

function exec($cmd) {
	Invoke-Expression "$cmd"
	log($cmd)
}

function mkdirIfNotExist($directory) {
	if (!(Test-Path -Path $directory)) {
	    New-Item -ItemType directory -Path $directory
	}	
}
#end

function closeExplorer() {
	(New-Object -comObject Shell.Application).Windows() | ? { $_.FullName -ne $null } | ? { $_.FullName.toLower().Endswith('\explorer.exe') } | % { $_.Quit() }
}

function backup() {
	$mqBackupPath = "$app3wPath\..\${appName}_bak_$timestamp"
	if (!$(test-path $app3wPath)) {
		return
	}
	#backup as zipfile
	exec("&('C:\Program Files\2345Soft\HaoZip\HaoZipC') a -tzip $mqBackupPath.zip -r $app3wPath\OceanSoft.*.exe $app3wPath\OceanSoft.*.dll")
}

function extract() {
	if ($(test-path "c:\$appName\")) {
		exec("dir c:\")
		exec("remove-item -recurse -force c:\$appName\")
	}
	exec("&('C:\Program Files\2345Soft\HaoZip\HaoZipC') x -y c:\$appName.zip -oc:\")
}

function copyAndReplace() {
	exec("copy-item -recurse -force c:\$appName\* $app3wPath\")
	exec("remove-item -recurse -force c:\$appName\")
}

function logActionHeader() {
	log("===============================================")
	log($timestamp)
}

function clearCompleteStatus() {
	$completeStatusFile = "$app3wPath\config\AllCompleted.ini"
	#if ($(test-path $completeStatusFile)) {
	#	exec("remove-item -force ${completeStatusFile}")
	#}
	exec("echo 2 > ${completeStatusFile}")
}

function informDeployStart() {
	$runtimeModelFile = "$app3wPath\config\RuntimeModel.ini"
	exec("echo 1 > ${runtimeModelFile}")
}

function informDeployFinish() {
	$runtimeModelFile = "$app3wPath\config\RuntimeModel.ini"
	exec("echo 2 > ${runtimeModelFile}")
}

function waitDeployStartSignal(){
	$completeStatusFile = "$app3wPath\config\AllCompleted.ini"
	
	if ($(Get-Process|Where-Object{$_.ProcessName.Contains("OceanSoft.ServiceMgmt")}) -eq $null){
		write-host "No OceanSoft.ServiceMgmt process"
		return 1
	}
	
	for ($i=1;$i -le 120;$i++)
	{
		Start-Sleep -Seconds 60
		write-host "$i minute passed"
		if ($(test-path $completeStatusFile)) {
			$content = Get-Content $completeStatusFile
			write-host "completeStatus: $content"
			if($content -eq "1"){
				write-host "Got from AllCompleted.ini"
				return 1
			}
		}
	}
	
	write-host "Timeout, can not start the deploayment"
	
	return 0
}

function main() {
	logActionHeader
	closeExplorer #to aviod rename-item failed when execute backup
	sleep 5
	#clearCompleteStatus
	informDeployStart
	$canStartDeploy = waitDeployStartSignal
	if ($canStartDeploy -eq 0) {
		informDeployFinish
		exit 1
	}
	#deploy start
	write-host "deploy start ...."
	backup
	extract
	copyAndReplace
	informDeployFinish
	#deploy end
	write-host "deploy finish, will start ServiceMgmt.exe ...."
}

main

