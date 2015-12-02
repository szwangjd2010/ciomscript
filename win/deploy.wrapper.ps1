$argus = "-ver $ENV:ciom_ver -env $ENV:ciom_env -appName $ENV:ciom_appname -type Normal"
Invoke-Expression "& $ENV:CIOM_SCRIPT_HOME\win\deploy.ps1 $argus"
exit $lastexitcode