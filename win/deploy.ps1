param($appName)
. c:\ciom.win\ciom.win.util.ps1

$CIOM = getAppCiomJson($appName)
$appURI = $CIOM.appURIBase + "${appName}.zip"
$timestamp = getLongTimestamp

foreach ($hostInfo in $CIOM.hosts) {
	$ip = $hostInfo.ip;
	$username = $hostInfo.username
	$password = $hostInfo.password
	$app3wPath = $hostInfo.app3wPath	

	$secPassword = 	ConvertTo-SecureString "$password" -AsPlainText -Force
	$cred = New-Object System.Management.Automation.PSCredential -argumentlist $username,$secPassword
	
	invoke-command `
	-comp $ip `
	-FilePath "c:\ciom.win\do.deploy.on.host.ps1" `
	-argumentlist $timestamp, $appURI, $appName, $app3wPath `
	-Credential $cred
}