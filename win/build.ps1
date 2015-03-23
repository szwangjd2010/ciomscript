param($appName)

$fileAppCiomJson = "Z:\ciom.win.publish\$appName.ciom.json"
$jsonCiom = (get-content $fileAppCiomJson -raw) | convertfrom-json
$ciomWorkspace = $jsonCiom.ciomWorkspace

$siteRoot = "$ciomWorkspace\$appName"
$siteBuildoutPath = "$ciomWorkspace\build\$appName"

$MsBuild = "&('C:\Program Files (x86)\MSBuild\12.0\Bin\msbuild')"

$FlagCompile4Sln = "/t:Rebuild /p:Configuration=Release /p:_ResolveReferenceDependencies=true"
$FlagCompile4Proj = "/t:ResolveReferences;Compile /t:_WPPCopyWebApplication /p:Configuration=Release /p:_ResolveReferenceDependencies=true /p:_ResolveReferenceDependencies=true"
$FlagOutput = "/p:WebProjectOutputDir="

function log($str) {
	echo  "$str" >> c:\111.txt
}

function exec($cmd) {
	Invoke-Expression -Command:$cmd
	log($cmd)
}

function getOutputPath($str) {
	if ($str.indexof("\Applications\") -eq -1) {
		return $siteBuildoutPath
	}
	
	$firstIdx = "Web\".length;
	$pathSurfix = $str.substring($firstIdx, $str.LastIndexOf(".") - $firstIdx)
	return "$siteBuildoutPath\$pathSurfix"
}

function buildSolution($sln) {
	exec("$MsBuild $siteRoot\$sln $FlagCompile4Sln")
}

function buildProject($proj) {
	$outputPath = getOutputPath($proj)
	exec("$MsBuild $siteRoot\$proj $FlagCompile4Proj $FlagOutput=$outputPath")
}


buildSolution("YXT.Taurus.sln")
buildProject("Web\Web.csproj")
buildProject("Web\Applications\YXT.Demo.csproj")
buildProject("Web\Applications\YXT.Group.csproj")
buildProject("Web\Applications\YXT.Home.csproj")
buildProject("Web\Applications\YXT.Kng.csproj")





