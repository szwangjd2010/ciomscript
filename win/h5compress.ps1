param($ver, $env, $appName)
. $ENV:CIOM_SCRIPT_HOME\win\ciom.win.ver.env.util.ps1
. $ENV:CIOM_SCRIPT_HOME\win\ciom.win.util.ps1

function execGrunt(){
	cd $sourcePath
	dir
	cmd /c $grunt
}

function main() {
	execGrunt
}

$CIOM = getAppCiomJson
$sourcePath = getAppSourcePath
$targetPath = getAppTargetPath
$packageFile = getAppPackageFile

$grunt = "C:\Users\Administrator\AppData\Roaming\npm\grunt.cmd"

main