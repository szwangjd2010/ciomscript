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

function backup() {
	$appFullPath = "$app3wPath\$appName"
	if (!$(test-path $appFullPath)) {
		return
	}
	
	exec("rename-item $appFullPath ${appFullPath}_${timestamp}")
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
	stopIIS
	sleep 5
	backup
	clean
	extract
	startIIS
}

main

