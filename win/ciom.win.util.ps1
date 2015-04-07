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

function remoteExec($ip, $port, $username, $password, $cmd) {
	exec("$SSH -P $port $ip -l $username -pw $password `"$cmd`"")
}
function remoteExecUsingKey($ip, $port, $username, $key, $cmd) {
	exec("$SSH -P $port $ip -l $username -i $key `"$cmd`"")
}

function upload($port, $localURI, $remoteURI, $user, $password) {
	exec("$SCP -P $port -r -l $user -pw `"$password`" `"$localURI`" `"$remoteURI`"")
}
function uploadUsingKey($port, $localURI, $remoteURI, $user, $key) {
	exec("$SCP -P $port -l $user -i $key `"$localURI`" `"$remoteURI`"")
}

function download($port, $remoteURI, $localURI, $user, $password) {
	exec("$SCP -P $port -l $user -pw `"$password`" `"$remoteURI`" `"$localURI`"")
}
function downloadUsingKey($port, $remoteURI, $localURI, $user, $key) {
	exec("$SCP -P $port -l $user -i $key `"$remoteURI`" `"$localURI`"")
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

function getTimestamp() {
	return Get-Date -Format 'yyyyMMdd-HHmmss'
}

function getDatestamp() {
	return Get-Date -Format 'yyyyMMdd'
}