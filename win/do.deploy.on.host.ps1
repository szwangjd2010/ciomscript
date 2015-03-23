param($appURI,$appName,$appPublishLocation)

$timestamp = Get-Date -Format 'yyyyMMdd-Hmmss'
$iisappctl = "c:\Windows\system32\inetsrv\appcmd"
$logFile = "c:\$appName.ciom.log"

function log($str) {
	echo  "$str" >> $logFile
}

function exec($cmd) {
	invoke-expression "$cmd"
	log($cmd)
}

function startIIS() {
	iisreset /START
}

function stopIIS() {
	iisreset /STOP
}

function startSite() {
	exec("$iisappctl start site /site.name:$appName")
}

function stopSite() {
	exec("$iisappctl stop site /site.name:$appName")
}

function backup() {
	$appFullPath = "$appPublishLocation\$appName"
	exec("ren $appFullPath ${appFullPath}_${timestamp}")
}

function extractAppPackage() {
	exec("'C:\Program Files\2345Soft\HaoZip\HaoZipC' x c:\$appName.zip -o$appPublishLocation")
}

function downloadAppPackage() {
	exec("cd c:\")
	exec("c:\wget.exe $appURI")
}

function main() {
	log("")
	log("")
	log("============================================")

	log($timestamp)
	stopSite
	backup
	downloadAppPackage
	extractAppPackage
	startSite
}

main

