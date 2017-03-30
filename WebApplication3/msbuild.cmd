@echo off
setlocal enabledelayedexpansion


if not defined MSBUILDLOGPATH (
    set MSBUILDLOGPATH="D:\MSBuildLogs"
)

if not defined MSBUILDCUSTOMPATH (
    set MSBUILDCUSTOMPATH="MSBuild.exe"
)

if not defined MSBUILD_ARGS (
    set MSBUILD_ARGS="%~dp0WebApplication3.sln" /m /verbosity:minimal %*
)

if not defined BASEOUTPUT_PATH (
	set BASEOUTPUT_PATH="%~dp0BuildOutPut"
	call MKDIR "%~dp0BuildOutPut" 
)

if not defined NUGETRESTORECMD (
	set NUGETRESTORECMD=nuget.exe restore WebApplication3.sln
)

echo.
echo ** Restoring nuget packages
call %NUGETRESTORECMD%
echo.

echo %MSBUILD_ARGS%

:: Add a the file logger with diagnostic verbosity to the msbuild args
set MSBUILD_ARGS=%MSBUILD_ARGS% /fileloggerparameters:Verbosity=diag;LogFile="%MSBUILDLOGPATH%/build.log; /p:OutDir=%BASEOUTPUT_PATH%

set BUILD_COMMAND="%MSBUILDCUSTOMPATH%" /nodeReuse:false %MSBUILD_ARGS%

echo.
echo ** Using the MSBuild in path: %MSBUILDCUSTOMPATH%
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

if not defined FXCOPPATH (
    set FXCOPPATH="C:\Program Files (x86)\Microsoft Visual Studio 14.0\Team Tools\Static Analysis Tools\FxCop\FxCopCmd.exe"
)

if not defined FXCOPFILEPATH(
	set FXCOPFILEPATH=""
)

set FXCOP_RUN_COMMAND ="%FXCOPPATH%" 

exit /b %BUILDERRORLEVEL%
