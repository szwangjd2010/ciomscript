param($appName)
. c:\ciom\win\ciom.win.util.ps1

function getOutputPath($str) {
	if ($str.indexof("\Applications\") -eq -1) {
		return $targetPath
	}
	
	$firstIdx = "Web\".length;
	$pathSurfix = $str.substring($firstIdx, $str.LastIndexOf("\") - $firstIdx)
	return "$targetPath\$pathSurfix"
}

function buildSolution($sln) {
	exec("$MsBuild $srcPath\$sln $solutionCF")
}

function buildProject($proj) {
	$outputPath = getOutputPath($proj)
	exec("$MsBuild $srcPath\$proj $projectCF $outputCF=$outputPath")
}

function main() {
	foreach ($item in $CIOM.solutionManifest) {
		if ($item.endswith(".sln")) {
			buildSolution($item)
		}
		
		if ($item.endswith(".csproj")) {
			buildProject($item)
		}
	}
}

$CIOM = getAppCiomJson($appName)
$workspace = $CIOM.workspace
$srcPath = "$workspace\$appName"
$targetPath = "$workspace\build\$appName"

$MsBuild = "&'C:\Program Files (x86)\MSBuild\12.0\Bin\msbuild.exe' --%"
$solutionCF = "/t:Rebuild /p:Configuration=Release /p:_ResolveReferenceDependencies=true"
$projectCF = "/t:ResolveReferences;Compile /t:_WPPCopyWebApplication /p:Configuration=Release /p:_ResolveReferenceDependencies=true"
$outputCF = "/p:WebProjectOutputDir"

main