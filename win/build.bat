@ echo off
@ echo.
@ echo begin build taurus...

SET rootPath=C:\ciom.workspace\yxtweb
SET webPath=%rootPath%\Web
SET appPath=%rootPath%\Web\Applications
SET webPublishPath=%rootPath%\build\YXT.Taurus
SET appPublishPath=%rootPath%\build\YXT.Taurus\Applications
SET publishLogPath=%rootPath%\build
SET dotNetFrameworkPath=C:\Program Files (x86)\MSBuild\12.0\Bin

cd /d %dotNetFrameworkPath%
@ echo.
msbuild %rootPath%\YXT.Taurus.sln /t:Rebuild /p:Configuration=Release /p:_ResolveReferenceDependencies=true
@ echo. 
@ echo.
msbuild %webPath%\Web.csproj /t:ResolveReferences;Compile /t:_WPPCopyWebApplication /p:Configuration=Release /p:_ResolveReferenceDependencies=true /p:_ResolveReferenceDependencies=true /p:WebProjectOutputDir=%webPublishPath%
@ echo.
@ echo.
msbuild %appPath%\YXT.Demo\YXT.Demo.csproj /t:ResolveReferences;Compile /t:_WPPCopyWebApplication /p:Configuration=Release /p:_ResolveReferenceDependencies=true /p:WebProjectOutputDir=%appPublishPath%\YXT.Demo
@ echo.
@ echo.
msbuild %appPath%\YXT.Group\YXT.Group.csproj /t:ResolveReferences;Compile /t:_WPPCopyWebApplication /p:Configuration=Release /p:_ResolveReferenceDependencies=true /p:WebProjectOutputDir=%appPublishPath%\YXT.Group
@ echo.
@ echo.
msbuild %appPath%\YXT.Home\YXT.Home.csproj /t:ResolveReferences;Compile /t:_WPPCopyWebApplication /p:Configuration=Release /p:_ResolveReferenceDependencies=true /p:WebProjectOutputDir=%appPublishPath%\YXT.Home
@ echo.
@ echo.
msbuild %appPath%\YXT.Kng\YXT.Kng.csproj /t:ResolveReferences;Compile /t:_WPPCopyWebApplication /p:Configuration=Release /p:_ResolveReferenceDependencies=true /p:WebProjectOutputDir=%appPublishPath%\YXT.Kng
@ echo.
@ echo.
@ echo build finished
@ echo.