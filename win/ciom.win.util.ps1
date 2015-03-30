$IisAppCtl = "&'c:\Windows\system32\inetsrv\appcmd.exe'"
$logFile = "c:\ciom.log"
$SSH = "&('C:\PuTTY\plink.exe') -ssh"
$SCP = "&('C:\PuTTY\pscp.exe') -scp"
$ZIP = "&('C:\Program Files\2345Soft\HaoZip\HaoZipC')"

function log($str) {
	echo  "$str" >> $logFile
}

function exec($cmd) {
	Invoke-Expression "$cmd"
	log($cmd)
}

function remoteExec($ip, $username, $password, $cmd) {
	exec("$SSH $ip -l $username -pw $password `"$cmd`"")
}
function remoteExecUsingKey($ip, $username, $key, $cmd) {
	exec("$SSH $ip -l $username -i $key `"$cmd`"")
}

function upload($localURI, $remoteURI, $user, $password) {
	exec("$SCP -r -l $user -pw `"$password`" `"$localURI`" `"$remoteURI`"")
}
function uploadUsingKey($localURI, $remoteURI, $user, $key) {
	exec("$SCP -l $user -i $key `"$localURI`" `"$remoteURI`"")
}

function download($remoteURI, $localURI, $user, $password) {
	exec("$SCP -l $user -pw `"$password`" `"$remoteURI`" `"$localURI`"")
}
function downloadUsingKey($remoteURI, $localURI, $user, $key) {
	exec("$SCP -l $user -i $key `"$remoteURI`" `"$localURI`"")
}

function extract($zipFile, $extract2Path) {
	exec("$ZIP x $zipFile -o$extract2Path")
}

function compress($zipFile, $path) {
	exec("$ZIP a -tzip $zipFile $path")
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