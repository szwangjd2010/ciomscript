param($timestamp,$appURI,$appName,$app3wPath)

#import content form ciom.win.util.ps1
$IisAppCtl = "&'c:\Windows\system32\inetsrv\appcmd.exe'"
$logFile = "c:\ciom.log"

function log($str) {
	echo  "$str" >> $logFile
}

function exec($cmd) {
	Invoke-Expression "$cmd"
	log($cmd)
}

function startSite() {
	exec("$IisAppCtl start site /site.name:$appName")
}

function stopSite() {
	exec("$IisAppCtl stop site /site.name:$appName")
}
#end

function backup() {
	$appFullPath = "$app3wPath\$appName"
	exec("rename-item $appFullPath ${appFullPath}_${timestamp}")
}

function clean() {
	$appFullPath = "$app3wPath\$appName"
	exec("remove-item -recurse -force $appFullPath")
}

function extractAppPackage() {
	exec("&('C:\Program Files\2345Soft\HaoZip\HaoZipC') x c:\$appName.zip -o$app3wPath")
}

function downloadAppPackage() {
	exec("cd c:\")
	exec("remove-item -force ${appName}.zip")
	exec("c:\wget.exe $appURI")
}

function main() {
	log("============================================")
	log($timestamp)
	
	stopSite
	backup
	clean
	#downloadAppPackage
	extractAppPackage
	startSite
}

main

