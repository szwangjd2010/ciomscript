param($ver, $env, $appName, $type)
. $ENV:CIOM_SCRIPT_HOME\win\ciom.win.ver.env.util.ps1
. $ENV:CIOM_SCRIPT_HOME\win\ciom.win.util.ps1

$CIOM = getAppCiomJson
$siteName = $CIOM.siteName
$timestamp = getTimestamp
$maintainSiteName = $CIOM.maintainSiteName

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

function fillmSiteInfo($hostInfo) {
	nullset $hostInfo "username"
	nullset $hostInfo "password"
	nullset $hostInfo "port"
}

function enterMaintenance() {
	foreach ($mSiteInfo in $CIOM.uphosts) {
		fillmSiteInfo $mSiteInfo
		
		$mSiteName = $mSiteInfo.sitename
		$mIp = $mSiteInfo.ip
		$mPort = $mSiteInfo.port
		$mUsername = $mSiteInfo.username
		$mPassword = $mSiteInfo.password
		
		echo "Start maintenance site <$mSiteName> on $mIp"
		remoteStartSite $mIp $mPort $musername $mPassword $mSiteName 
	}
	
	foreach ($hostInfo in $CIOM.hosts) {
		fillHostInfo $hostInfo

		$ip = $hostInfo.ip
		$username = $hostInfo.username
		$password = $hostInfo.password
		$port = $hostInfo.port
		
		echo "Stop site <$siteName> on $ip"
		remoteStopSite $ip $port $username $password $siteName
	}
}

function exitMaintenance() {

	foreach ($mSiteInfo in $CIOM.uphosts) {
		fillmSiteInfo $mSiteInfo
		
		$mSiteName = $mSiteInfo.sitename
		$mIp = $mSiteInfo.ip
		$mPort = $mSiteInfo.port
		$mUsername = $mSiteInfo.username
		$mPassword = $mSiteInfo.password
		
		echo "Stop maintenance site <$mSiteName> on $mIp"
		remoteStopSite $mIp $mPort $musername $mPassword $mSiteName 
	}
	
	foreach ($hostInfo in $CIOM.hosts) {
		fillHostInfo $hostInfo

		$ip = $hostInfo.ip
		$username = $hostInfo.username
		$password = $hostInfo.password
		$app3wPath = $hostInfo.app3wPath
		$port = $hostInfo.port
		
		echo "Start site <$siteName> on $ip"
		remoteStartSite $ip $port $username $password $siteName
	}
}


function main(){
	if ( $type -eq "TurnOn") {
		enterMaintenance
	}
	if ( $type -eq "TurnOff") {
		exitMaintenance
	}
}

main
