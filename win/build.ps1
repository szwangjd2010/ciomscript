param($ver, $env, $appName)
. $ENV:CIOM_SCRIPT_HOME\win\ciom.win.ver.env.util.ps1
. $ENV:CIOM_SCRIPT_HOME\win\ciom.win.util.ps1

function getWebProjectBuildOutputPath($str) {
	if ($str.indexof("\Applications\") -eq -1) {
		return $targetPath
	}
	
	$firstIdx = "Web\".length;
	$pathSurfix = $str.substring($firstIdx, $str.LastIndexOf("\") - $firstIdx)
	return "$targetPath\$pathSurfix"
}

function getPackages() {
	$packagesLocation = "$sourcePath\packages"
	mkdirIfNotExist "$packagesLocation"

	$arrayPackagesConfigSM = getPackagesConfigListBySolutionManifest
	$arrayPackagesConfig = validatePkgsConfList($arrayPackagesConfigSM)
	$arrayPackagesConfig += $CIOM.extraPackagesConfigList
	foreach ($item in $arrayPackagesConfig) {
		exec("NuGet install '$sourcePath\$item' -OutputDirectory '$packagesLocation'")
	}
}

function validatePkgsConfList($arrayPkgsConf){
	$newArrPkgsConf = @()
	
	foreach ($item in $arrayPkgsConf) {
		if(validatePath($item)){
			$newArrPkgsConf += $item
		}
	}
	
	return $newArrPkgsConf
}

function getPackagesConfigListBySolutionManifest() {
	$arrayPackagesConfig = @()
	foreach ($item in $CIOM.solutionManifest) {
		if ($item.endswith(".sln")) {
			continue
		}

		$packgesConfigFilePath = ""
		if ($item.indexOf("\") -ne -1) {
			$packgesConfigFilePath = $item.substring(0, $item.LastIndexOf("\") + 1)
		}
		$arrayPackagesConfig += $packgesConfigFilePath + "packages.config"
	}

	return $arrayPackagesConfig	
}

function buildSolution($sln) {
	exec("$MsBuild $sourcePath\$sln $SolutionCF $LogCF")
}

function buildProject($proj) {
	$outputPath = getWebProjectBuildOutputPath($proj)
	exec("$MsBuild $sourcePath\$proj $WebProjectCF $WebProjectOutputCF=$outputPath $LogCF")
}

function package() {
	$appBuildout = $targetPath
	compress $packageFile $appBuildout
}

function mkdirBuildout() {
	mkdirIfNotExist $(getVerEnvBuildPath)
}

function build() {
	mkdirBuildout
	
	foreach ($item in $CIOM.solutionManifest) {
		if ($item.endswith(".sln")) {
			buildSolution($item)
		}
		
		if ($item.endswith(".csproj")) {
			buildProject($item)
		}
	}	
}

function clean() {
	cleanDirectory "$targetPath"

	rmFile "$packageFile"

	rmFile "$CommonLogFile"
	rmFile "$ErrorLogFile"
	rmFile "$WarningLogFile"
}

function getBuildLogCF() {
	$logCF = "/flp1:errorsonly;logfile=$ErrorLogFile;Append /flp2:warningsonly;logfile=$WarningLogFile;Append /flp3:logfile=$CommonLogFile;Append"
	return $logCF
}

function isBuildError() {
	$errorLines = $(gc $ErrorLogFile | measure-object -line).lines
	return $errorLines -gt 0
}

function outputError() {
	write-output $(get-content "$ErrorLogFile")
}

function main() {
	clean
	getPackages
	build
	if (isBuildError) {
		outputError
		exit 1 #build error
	}
	
	package
}

$CIOM = getAppCiomJson
$sourcePath = getAppSourcePath
$targetPath = getAppTargetPath
$packageFile = getAppPackageFile

$MsBuild = "&'C:\Program Files (x86)\MSBuild\12.0\Bin\msbuild.exe' --%"
$SolutionCF = "/t:Clean;Build /p:Configuration=Release /p:_ResolveReferenceDependencies=true"
$CommonProjectCF = "/t:ResolveReferences;Compile /p:Configuration=Release /p:_ResolveReferenceDependencies=true"
$WebProjectCF = "/t:ResolveReferences;Compile /t:_WPPCopyWebApplication /p:Configuration=Release /p:_ResolveReferenceDependencies=true"
$WebProjectOutputCF = "/p:WebProjectOutputDir"

$CommonLogFile = getAppBuildLogFile("common")
$ErrorLogFile = getAppBuildLogFile("error")
$WarningLogFile = getAppBuildLogFile("warning")

$LogCF = getBuildLogCF

main