$IisAppCtl = "&'c:\Windows\system32\inetsrv\appcmd.exe'"
$logFile = "c:\ciom.log"
$SSH = "&('C:\PuTTY\plink.exe') -ssh"
$SCP = "&('C:\PuTTY\pscp.exe') -scp"
$ZIP = "&('C:\Program Files\2345Soft\HaoZip\HaoZipC')"
# PsExec -i -2 means remoteExec with admin
$PsExec = "&('C:\PSTools\PsExec.exe') -d"
$invokeRsltFile = "c:\webrequest.log"
$appCmd = "C:\Windows\System32\inetsrv\appcmd.exe"

function log($str) {
	echo  "$str" >> $logFile
}

function exec($cmd) {
	log($cmd)
	Invoke-Expression "$cmd"
}

function remoteExec($ip, $port, $username, $password, $cmd) {
	exec("$SSH -P $port $ip -l $username -pw $password `"$cmd`"")
}

function remoteExecUsingKey($ip, $port, $username, $key, $cmd) {
	exec("$SSH -P $port $ip -l $username -i $key `"$cmd`"")
}

function remotePsExec($ip, $remoteSessionId, $admPwd, $programPath) {
	exec("$PsExec -i $remoteSessionId \\$ip -u administrator -p $admPwd $programPath")
}

function remoteStartSite($ip, $port, $username, $password, $siteName) {
	$startSiteCmd = $appCmd + " start site /site.name:" + $siteName
	#echo $startSiteCmd
	remoteExec $ip $port $username $password $startSiteCmd
}

function remoteStopSite($ip, $port, $username, $password, $siteName) {
	$stopSiteCmd = $appCmd + " stop site /site.name:" + $siteName
	#echo $stopSiteCmd
	remoteExec $ip $port $username $password $stopSiteCmd
}

function getRemoteSessionID($ip, $port, $username, $password){
	return Invoke-Expression "$SSH -P $port $ip -l $username -pw $password `"query session $username`" | ? { `$_ -match '\s+$username\s+(\d+)' } | % { `$matches[1] } "
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

function mkdirIfNotExist($directory) {
	if (!(Test-Path -Path $directory)) {
	    New-Item -ItemType directory -Path $directory
	}	
}

function cleanDirectory($path) {
	if (Test-Path $path) {
	    remove-item "$path\*" -recurse -force
	}	
}

function rmFile($path) {
	if (Test-Path $path) {
	    remove-item "$path" -recurse -force
	}	
}

function validatePath($path) {
	return Test-Path $path
}

function invokeWebRequest($url){
	log("visit $url")
	"Invoke-WebRequest $url" | Out-File -Append $invokeRsltFile
	Invoke-WebRequest $url -UseBasicParsin | Out-File -Append $invokeRsltFile
}

function cleanWebRequestResult(){
	if (Test-Path $invokeRsltFile) {
		echo "" > $invokeRsltFile
	}
}