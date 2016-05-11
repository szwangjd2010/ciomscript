$argus = "-ver $ENV:ciom_ver -env $ENV:ciom_env -appName $ENV:ciom_appname -type $ENV:ciom_maintaintype"
Invoke-Expression "& $ENV:CIOM_SCRIPT_HOME\win\maintain.ps1 $argus"
exit $lastexitcode