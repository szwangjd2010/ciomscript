$argus = "-ver $ENV:ciom_ver -env $ENV:ciom_env -appName $ENV:ciom_appname"
Invoke-Expression "& c:\ciom\win\deploy.ps1 $argus"
exit $lastexitcode