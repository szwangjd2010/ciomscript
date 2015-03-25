$IisAppCtl = "&'c:\Windows\system32\inetsrv\appcmd.exe'"
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

function startSite() {
	exec("$IisAppCtl start site /site.name:$appName")
}

function stopSite() {
	exec("$IisAppCtl stop site /site.name:$appName")
}

function getLongTimestamp() {
	return Get-Date -Format 'yyyyMMdd-Hmmss'
}

function getTimestamp() {
	return Get-Date -Format 'yyyyMMdd'
}

function getAppCiomJsonFile($appName) {
	return "C:\ciom.workspace\$appName.ciom.json"
}

function getAppCiomJson($appName) {
	return (get-content (getAppCiomJsonFile($appName)) -raw) | convertfrom-json
}

function upload($localURI, $remoteURI, $user, $password) {
	exec("&('C:\PuTTY\pscp.exe') -scp -l $user -pw `"$password`" `"$localURI`" `"$remoteURI`"")
}

function download($remoteURI, $localURI, $user, $password) {
	exec("&('C:\PuTTY\pscp.exe') -scp -l $user -pw `"$password`" `"$remoteURI`" `"$localURI`"")
}

function extract($zipFile, $extract2Path) {
	exec("&('C:\Program Files\2345Soft\HaoZip\HaoZipC') x $zipFile -o$extract2Path")
}

function compress($zipFile, $path) {
	exec("&('C:\Program Files\2345Soft\HaoZip\HaoZipC') a -tzip $zipFile $path")
}