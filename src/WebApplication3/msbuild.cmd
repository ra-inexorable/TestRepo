@echo off
setlocal enabledelayedexpansion

if not defined MSBUILDLOGPATH (
    set MSBUILDLOGPATH="D:\MSBuildLogs"
)

if not defined MSBUILD_CUSTOM_PATH (
    set MSBUILD_CUSTOM_PATH="C:\MSBuild\14.0\Bin\MSBuild.exe"
)

if not defined MSBUILD_ARGS (
    set MSBUILD_ARGS="WebApplication3.xproj" /m /verbosity:minimal %*
)

if not defined BASEOUTPUT_PATH (
	set BASEOUTPUT_PATH="%~dp0BuildOutPut"
	call DEL BASEOUTPUT_PATH
	call MKDIR %BASEOUTPUT_PATH%
)

echo %MSBUILD_ARGS%

:: Add a the file logger with diagnostic verbosity to the msbuild args
set MSBUILD_ARGS=%MSBUILD_ARGS% /fileloggerparameters:Verbosity=diag;LogFile="%MSBUILDLOGPATH%/build.log;" 

set BUILD_COMMAND="%MSBUILD_CUSTOM_PATH%" /nodeReuse:false %MSBUILD_ARGS% /p:OutputPath=%BASEOUTPUT_PATH%

echo.
echo ** Using the MSBuild in path: %MSBUILD_CUSTOM_PATH%
echo ** Using runtime host in path: %RUNTIME_HOST%

:: Call MSBuild
echo ** %BUILD_COMMAND%
call %BUILD_COMMAND%
set BUILDERRORLEVEL=%ERRORLEVEL%
echo.

:: Pull the build summary from the log file
findstr /ir /c:".*Warning(s)" /c:".*Error(s)" /c:"Time Elapsed.*" "%MSBUILDLOGPATH%"
echo.
echo ** Build completed. Exit code: %BUILDERRORLEVEL%

echo ** FxCop Analysis Started

if not defined FXCOPFILEPATH (
	set FXCOPFILEPATH = "%BASEOUTPUT_PATH%\src\WebApplication3\bin\Debug\netcoreapp1.0\WebApplication3.dll"
}

if not defined FXCOPPATH (
    set FXCOPPATH="C:\Program Files (x86)\Microsoft Visual Studio 14.0\Team Tools\Static Analysis Tools\FxCop\FxCopCmd.exe"
)

if not defined FXCOP_RULES_PATH (
	set FXCOP_RULES_PATH="C:\Program Files (x86)\Microsoft Visual Studio 14.0\Team Tools\Static Analysis Tools\FxCop\Rules"
)

set FXCOP_RUN_COMMAND ="%FXCOPPATH%" /f:"%FXCOPFILEPATH%" /r:"%FXCOP_RULES_PATH%\DesignRules.dll" /o:OutputFile.xml

echo FXCOP_RUN_COMMAND

call %FXCOP_RUN_COMMAND%

exit /b %BUILDERRORLEVEL%
