param($timestamp, $appName, $siteName, $app3wPath)

$logFile = "c:\ciom.log"

function log($str) {
	echo  "$str" >> $logFile
}

function exec($cmd) {
	Invoke-Expression "$cmd"
	log($cmd)
}

function startIIS() {
	iisreset /START
}

function stopIIS() {
	iisreset /STOP
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
	$appFullPath = "$app3wPath\$appName"
	$appBackupPath = "${appFullPath}_$timestamp"
	if (!$(test-path $appFullPath)) {
		return
	}
	exec("rename-item $appFullPath $appBackupPath")
}

function restoreFromBackup() {
	$appRoot = $app3wPath + "\" + $appName
	$backupRoot = $app3wPath + "\" + ${appName} + "_" + $timestamp
	$folder1 = "Upload"
	$folder2 = "Config\ApiCount"
	$convertMgrBakFolder = "App_Data"
	$file1 = "ping.htm"
	$file2 = "CountSta.db"
	
	if ($appName -like "*api"){
		mkdirIfNotExist("$appRoot\$folder2")
		exec("move-item -force $backupRoot\$folder2\$file2 $appRoot\$folder2\")
	}
	
	if (($appName -like "*web") -or ($appName -eq "eschool") -or ($appName -eq "elearning")){
		exec("move-item -force $backupRoot\$folder1\* $appRoot\$folder1\")
	}
	
	#exec("remove-item -recurse -force $backupRoot\$folder1")
	if ($(test-path "$backupRoot\$file1")) {
		exec("copy-item -recurse -force $backupRoot\$file1 $appRoot\")
	}
	
	if ($appName -eq "convertmgmt"){
		mkdirIfNotExist("$appRoot\$convertMgrBakFolder")
		exec("copy-item -recurse -force $backupRoot\$convertMgrBakFolder\* $appRoot\$convertMgrBakFolder\")
	}
}

function clean() {
	$appFullPath = "$app3wPath\$appName"
	if (!$(test-path $appFullPath)) {
		return
	}
	
	exec("remove-item -recurse -force $appFullPath")
}

function extract() {
	exec("&('C:\Program Files\2345Soft\HaoZip\HaoZipC') x c:\$appName.zip -o$app3wPath")
}

function updatePriv() {
	$appRoot = $app3wPath + "\" + $appName
	$folder1 = "Upload"
	if (($appName -like "*web") -or ($appName -eq "eschool") -or ($appName -eq "elearning")){
		exec("cacls $appRoot\$folder1 /E /P NETWORKSERVICE:f")
	}
	#for eschool unionpay
	if (($appName -eq "eschweb") -or ($appName -eq "eschool")) {
		exec("cacls $appRoot\Config\Unionpay.config /E /P everyone:f")
	}
}

function logActionHeader() {
	log("===============================================")
	log($timestamp)
}

function main() {
	logActionHeader
	closeExplorer #to aviod rename-item failed when execute backup
	stopIIS
	sleep 5
	backup
	clean
	extract
	restoreFromBackup
	updatePriv
	startIIS
}

main

