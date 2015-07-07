param($ver, $env, $appName)
. c:\ciom\win\ciom.win.ver.env.util.ps1
. c:\ciom\win\ciom.win.util.ps1


function getProjectBuildOutputPath($str) {
	if ($str.indexof("\Applications\") -eq -1) {
		return $targetPath
	}
	
	$firstIdx = "Web\".length;
	$pathSurfix = $str.substring($firstIdx, $str.LastIndexOf("\") - $firstIdx)
	return "$targetPath\$pathSurfix"
}

function getPackages() {
	mkdir "$sourcePath\packages"

	$arrayPackagesConfig = getPackageConfigList
	foreach ($item in $CIOM.packageConfigManifest) {
		exec("NuGet install '$sourcePath\$item' -OutputDirectory '$sourcePath\packages'")
	}		
}

function getPackageConfigList() {
	$arrayPackagesConfig = @()
	foreach ($item in $CIOM.solutionManifest) {
		if ($item.endswith(".sln")) {
			continue
		}

		$packgesConfigFile = $item.substring(0, ($item.length - ".csproj".length))
		$arrayPackagesConfig += $packgesConfigFile
	}

	return $arrayPackagesConfig	
}

function buildSolution($sln) {
	exec("$MsBuild $sourcePath\$sln $SolutionCF $LogCF")
}

function buildProject($proj) {
	$outputPath = getProjectBuildOutputPath($proj)
	exec("$MsBuild $sourcePath\$proj $ProjectCF $OutputCF=$outputPath $LogCF")
}

function package() {
	$appBuildout = $targetPath
	compress $packageFile $appBuildout
}

function mkdirBuildout() {
	$buildoutDir = getVerEnvBuildPath
	if (!(Test-Path -Path $buildoutDir )){
	    New-Item -ItemType directory -Path $buildoutDir
	}	
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
	exec("remove-item '$targetPath\*' -recurse -force")
	exec("remove-item '$packageFile' -force")

	exec("remove-item '$CommonLogFile' -force")
	exec("remove-item '$ErrorLogFile' -force")
	exec("remove-item '$WarningLogFile' -force")
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
$ProjectCF = "/t:ResolveReferences;Compile /t:_WPPCopyWebApplication /p:Configuration=Release /p:_ResolveReferenceDependencies=true"
$OutputCF = "/p:WebProjectOutputDir"

$CommonLogFile = getAppBuildLogFile("common")
$ErrorLogFile = getAppBuildLogFile("error")
$WarningLogFile = getAppBuildLogFile("warning")

$LogCF = getBuildLogCF

main