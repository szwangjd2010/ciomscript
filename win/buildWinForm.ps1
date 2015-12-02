param($ver, $env, $appName)
. $ENV:CIOM_SCRIPT_HOME\win\ciom.win.ver.env.util.ps1
. $ENV:CIOM_SCRIPT_HOME\win\ciom.win.util.ps1

function buildSolution($sln) {
	$outputPath = $targetPath
	exec("$MsBuild $sourcePath\$sln $SolutionCF $WinFormProjectOutputCF=$outputPath $LogCF")
}

function buildProject($proj) {
	$outputPath = $targetPath
	exec("$MsBuild $sourcePath\$proj $WinFormProjectCF $WinFormProjectOutputCF=$outputPath $LogCF")
	#exec("$MsBuild $sourcePath\$proj $WinFormProjectCF $LogCF")
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
	if ($appName -eq "lecaiweb") {
		$dtNow = getTimestamp
		Copy-Item "$targetPath" "c:\lecaiweb.build.history\lecaiweb-$dtNow" -recurse
	}
	
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
	build
	if (isBuildError) {
		outputError
		exit 1 #build error
	}

}

$CIOM = getAppCiomJson
$sourcePath = getAppSourcePath
$targetPath = getAppTargetPath
$packageFile = getAppPackageFile

$MsBuild = "&'C:\Program Files (x86)\MSBuild\12.0\Bin\msbuild.exe' --%"
$SolutionCF = "/t:Clean;Build /p:Configuration=Release /p:_ResolveReferenceDependencies=true"
$WinFormProjectCF = "/t:ResolveReferences;Compile /p:Configuration=Release /p:Platform=AnyCPU /p:_ResolveReferenceDependencies=true"
$WinFormProjectOutputCF = "/p:OutDir"

$CommonLogFile = getAppBuildLogFile("common")
$ErrorLogFile = getAppBuildLogFile("error")
$WarningLogFile = getAppBuildLogFile("warning")

$LogCF = getBuildLogCF

main

