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
	foreach ($item in $CIOM.packageConfigManifest) {
		exec("NuGet install $sourcePath\$item -OutputDirectory $sourcePath\packages")
	}		
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

function build() {
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
}

function getBuildLogCF() {
	$commonLog = getAppBuildLogFile("common")
	$errorLog = getAppBuildLogFile("error")
	$warningLog = getAppBuildLogFile("warning")

	$logCF = "/flp1:errorsonly;logfile=$errorLog /flp2:warningsonly;logfile=$warningLog /flp3:logfile=$commonLog"
	
	return $logCF
}

function isBuildError() {
	$errorLog = getAppBuildLogFile("error")
	$errorLines = $(gc $errorLog | measure-object -line).lines
	
	return $errorLines -gt 0
}

function main() {
	clean
	getPackages
	build
	if (isBuildError) {
		exit 1 #build error
	}
	
	package
}

$CIOM = getAppCiomJson
$sourcePath = getAppSourcePath
$targetPath = getAppTargetPath
$packageFile = getAppPackageFile

$MsBuild = "&'C:\Program Files (x86)\MSBuild\12.0\Bin\msbuild.exe' --%"
$SolutionCF = "/t:Rebuild /p:Configuration=Release /p:_ResolveReferenceDependencies=true"
$ProjectCF = "/t:ResolveReferences;Compile /t:_WPPCopyWebApplication /p:Configuration=Release /p:_ResolveReferenceDependencies=true"
$OutputCF = "/p:WebProjectOutputDir"
$LogCF = getBuildLogCF

main