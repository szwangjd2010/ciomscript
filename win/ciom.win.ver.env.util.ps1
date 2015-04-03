$CiomWorkspace = "C:\ciom.workspace"

function getVerEnvPath() {
	return "$CiomWorkspace\$ver\$env"
}

function getVerEnvBuildPath() {
	return "$CiomWorkspace\$ver\$env\build"
}

function getAppSourcePath() {
	return $(getVerEnvPath) + "\$appName"
}

function getAppTargetPath() {
	return $(getVerEnvPath) + "\build\$appName"
}

function getAppBuildLogFile($level) {
	return $(getVerEnvBuildPath) + "\$appName.$level.log"
}

function getAppCiomJsonFile() {
	return $(getAppSourcePath) + "\ciom.json"
}

function getAppCiomJson() {
	return (get-content (getAppCiomJsonFile) -raw) | convertfrom-json
}

function getAppPackageFile() {
	return $(getVerEnvPath) + "\${appName}.zip" 
}
