param($ver, $env, $appName)
. $ENV:CIOM_SCRIPT_HOME\win\ciom.win.ver.env.util.ps1
. $ENV:CIOM_SCRIPT_HOME\win\ciom.win.util.ps1

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
	nullset $hostInfo "typeRM"
	nullset $hostInfo "port"
}

function deployUsingWinRM($ip, $username, $password, $app3wPath) {
	$secPassword = 	ConvertTo-SecureString "$password" -AsPlainText -Force
	$cred = New-Object System.Management.Automation.PSCredential -argumentlist $username,$secPassword
	
	invoke-command `
	-comp $ip `
	-FilePath "$ENV:CIOM_SCRIPT_HOME\win\do.deployspecial.on.host.ps1" `
	-argumentlist $timestamp, $appName, $siteName, $app3wPath `
	-Credential $cred
}

function deployUsingSSH($ip, $port, $username, $password, $app3wPath) {
	upload $port "$ENV:CIOM_SCRIPT_HOME\win\do.deployspecial.on.host.ps1" "${ip}:/c:/" $username "$password"
	
	$argus = "-timestamp $timestamp -appName $appName -siteName $siteName -app3wPath $app3wPath"
	remoteExec $ip $port $username "$password" "powershell.exe -file c:\do.deployspecial.on.host.ps1 $argus"
}

foreach ($hostInfo in $CIOM.hosts) {
	fillHostInfo $hostInfo

	$ip = $hostInfo.ip;
	$username = $hostInfo.username
	$password = $hostInfo.password
	$app3wPath = $hostInfo.app3wPath
	$port = $hostInfo.port
	
	#upload $port $packageFile "${ip}:/c:/" $username "$password"
	write-output "deploy to $ip ... "
	
	if ($hostInfo.typeRM -eq "winrm") {
		deployUsingWinRM $ip $username "$password" $app3wPath
	} else {
		deployUsingSSH $ip $port $username "$password" $app3wPath
	}
}