param($ver, $env, $appName)
. c:\ciom\win\ciom.win.ver.env.util.ps1
. c:\ciom\win\ciom.win.util.ps1

$CIOM = getAppCiomJson
$siteName = $CIOM.siteName
$packageFile = getAppPackageFile
$timestamp = getTimestamp

function nullset($hostInfo, $name) {
	if ($hostInfo.$name -eq $null) {
		$hostInfo | add-member $name $CIOM.$name
	}
}

function fillHostInfo($hostInfo) {
	nullset $hostInfo "username"
	nullset $hostInfo "password"
	nullset $hostInfo "app3wPath"
}

foreach ($hostInfo in $CIOM.hosts) {
	fillHostInfo $hostInfo

	$ip = $hostInfo.ip;
	$username = $hostInfo.username
	$password = $hostInfo.password
	$app3wPath = $hostInfo.app3wPath
	
	upload $packageFile "${ip}:/c:/" $username "$password"
	
	$secPassword = 	ConvertTo-SecureString "$password" -AsPlainText -Force
	$cred = New-Object System.Management.Automation.PSCredential -argumentlist $username,$secPassword
	
	invoke-command `
	-comp $ip `
	-FilePath "c:\ciom\win\do.deploy.on.host.ps1" `
	-argumentlist $timestamp, $appName, $siteName, $app3wPath `
	-Credential $cred
}