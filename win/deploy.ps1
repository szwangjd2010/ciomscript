param($appName)

$fileAppCiomJson = "Z:\ciom.win.publish\$appName.ciom.json"
$jsonCiom = (get-content $fileAppCiomJson -raw) | convertfrom-json
$appURI = $jsonCiom.appURI

foreach ($hostInfo in $jsonCiom.hosts) {
	$ip = $hostInfo.ip;
	$username = $hostInfo.username
	$password = $hostInfo.password
	$appPublishLocation = $hostInfo.appPublishLocation	

	$secPassword = 	ConvertTo-SecureString "$password" -AsPlainText -Force
	$cred = New-Object System.Management.Automation.PSCredential -argumentlist $username,$secPassword
	
	invoke-command `
	-comp $ip `
	-FilePath "c:\do.deploy.on.host.ps1" `
	-argumentlist $appURI,$appName,$appPublishLocation `
	-Credential $cred
}