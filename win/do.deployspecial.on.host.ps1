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
	$toRestorePath = "$app3wPath\$appName\Upload"
	$backupUploadPath = "$app3wPath\${appName}_$timestamp\Upload"
	#exec("remove-item -recurse -force $toRestorePath")
	exec("copy-item -recurse -force $backupUploadPath\* $toRestorePath\")
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
	startIIS
}

main

