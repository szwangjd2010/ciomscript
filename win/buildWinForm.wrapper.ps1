$argus = "-ver $ENV:ciom_ver -env $ENV:ciom_env -appName $ENV:ciom_appname"
Invoke-Expression "& $ENV:CIOM_SCRIPT_HOME\win\buildWinForm.ps1 $argus"
exit $lastexitcode
