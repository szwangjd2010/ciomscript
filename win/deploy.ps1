param($appName)

$CiomPublish = "z:\ciom.win.publish"
$fileCiomJson = "$CiomPublish\$appName.ciom.json"
$jsonCiom = (get-content $fileCiomJson -raw) | convertfrom-json
$jsonCiom

$hosts = $jsonCiom.hosts
$username = $jsonCiom.username
$password = $jsonCiom.password
$appLocation = $jsonCiom.appLocation

$secPassword = 	ConvertTo-SecureString "$password" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -argumentlist $username,$secPassword
foreach ($hostIIS in $hosts) {
	invoke-command -comp $hostIIS -ScriptBlock {
		param($CiomPublish,$appName,$appLocation)
		
		function log($str) {
			echo  "$str" >> $logFile
		}
		
		function exec($cmd) {
			invoke-expression "$cmd"
			log($cmd)
		}
		
		function startSite() {
			exec("$iisAppcmd start site /site.name:$appName")
		}

		function stopSite() {
			exec("$iisAppcmd stop site /site.name:$appName")
		}

		function backup() {
			$appFullPath = "$appLocation\$appName"
			exec("ren $appFullPath ${appFullPath}_${timestamp}")
		}

		function extractAppPackage() {
			exec("copy $appPackageFile c:\")
			#exec("cd 'C:\Program Files\2345Soft\HaoZip'")
			#exec("HaoZipC x c:\$appName.zip -o$appLocation")
		}	


		$timestamp = Get-Date -Format 'yyyyMMdd-Hmmss'
		$iisAppcmd = "C:\Windows\system32\inetsrv\appcmd"
		$appPackageFile = "$CiomPublish\$appName.zip"
		$logFile = "c:\$appName.ciom.log"
		
		log("")
		log("")
		log("============================================")
		
		copy z:\1 z:\111
		
		log($timestamp)
		stopSite
		backup
		extractAppPackage
		startSite

	} -argumentlist $CiomPublish,$appName,$appLocation -Credential $cred

}