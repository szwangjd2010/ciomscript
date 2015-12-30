param($ver, $env, $appName, $type)
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
	nullset $hostInfo "adminPwd"
}

function getDeployScript() {
	if ($type -eq "withReplace") {
		return "do.deployspecial.on.host.ps1"
	}
	
	if ($type -eq "forMQ") {
		return "do.deploy4mq.on.host.ps1"
	}
	
	return "do.deploy.on.host.ps1"
}

function deployUsingWinRM($ip, $username, $password, $app3wPath) {
	$secPassword = 	ConvertTo-SecureString "$password" -AsPlainText -Force
	$cred = New-Object System.Management.Automation.PSCredential -argumentlist $username,$secPassword
	
	invoke-command `
	-comp $ip `
	-FilePath "$ENV:CIOM_SCRIPT_HOME\win\${deployScript}" `
	-argumentlist $timestamp, $appName, $siteName, $app3wPath `
	-Credential $cred
}

function deployUsingSSH($ip, $port, $username, $password, $app3wPath) {
	upload $port "$ENV:CIOM_SCRIPT_HOME\win\${deployScript}" "${ip}:/c:/" $username "$password"
	
	$argus = "-timestamp $timestamp -appName $appName -siteName $siteName -app3wPath $app3wPath"
	remoteExec $ip $port $username "$password" "powershell.exe -file c:\${deployScript} $argus"
}

function visitUrls($ip){
	if ( $CIOM.visitUrls -ne $null) {
		foreach ($item in $CIOM.visitUrls) {
			$vUrl= "http://" + $ip + $item
			echo "visit $vUrl"
			invokeWebRequest $vUrl
		}
	}
}

function main(){
	cleanWebRequestResult
	foreach ($hostInfo in $CIOM.hosts) {
		fillHostInfo $hostInfo

		$ip = $hostInfo.ip;
		$username = $hostInfo.username
		$password = $hostInfo.password
		$app3wPath = $hostInfo.app3wPath
		$port = $hostInfo.port
		$deployScript = getDeployScript
		#upload $port $packageFile "${ip}:/c:/" $username "$password"
		write-output "deploy to $ip ... "
		
		if ($hostInfo.typeRM -eq "winrm") {
			deployUsingWinRM $ip $username "$password" $app3wPath
		} else {
			deployUsingSSH $ip $port $username "$password" $app3wPath
		}
		
		if ($LASTEXITCODE -eq 1) {
			break
		}
		
		visitUrls $ip
		
		if ($appName -like "*mq") {
			$mqProgramPath = "$app3wPath\OceanSoft.ServiceMgmt.exe"
			$executorName = $hostInfo.activeAccName
			$executorPwd = $hostInfo.activeAccPwd
			$hostAdminPwd = $hostInfo.adminPwd
			echo "Executor is : $executorName"
			$executorSessionId = getRemoteSessionID $ip $port $executorName $executorPwd
			echo "Executor's session id: $executorSessionId" 
			remotePsExec $ip $executorSessionId $hostAdminPwd $mqProgramPath
			$LASTEXITCODE = 0
		}
	}
	
	if ($LASTEXITCODE -eq 0) {
		exit 0
	}
	else{
		exit 1
	}
	
}

main
