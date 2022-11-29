@echo off
setlocal EnableDelayedExpansion

rem Add path to MSBuild Binaries
set MSBUILD=()
set "_programfiles_86_vs=%ProgramFiles(x86)%\Microsoft Visual Studio"
set "_programfiles_vs=%ProgramFiles%\Microsoft Visual Studio"

set "_MSB_CAND=msbuild"
set "_MSB_CAND=%_MSB_CAND%;%_programfiles_vs%\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
set "_MSB_CAND=%_MSB_CAND%;%_programfiles_86_vs%\2019\Preview\MSBuild\Current\Bin\MSBuild.exe"
set "_MSB_CAND=%_MSB_CAND%;%_programfiles_86_vs%\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
set "_MSB_CAND=%_MSB_CAND%;%_programfiles_vs%\2017\Community\MSBuild\15.0\Bin\msbuild.exe"
set "_MSB_CAND=%_MSB_CAND%;%_programfiles_vs%\2017\Professional\MSBuild\15.0\Bin\msbuild.exe"
set "_MSB_CAND=%_MSB_CAND%;%_programfiles_vs%\2017\Enterprise\MSBuild\15.0\Bin\msbuild.exe"
set "_MSB_CAND=%_MSB_CAND%;%_programfiles_86_vs%\2017\Community\MSBuild\15.0\Bin\msbuild.exe"
set "_MSB_CAND=%_MSB_CAND%;%_programfiles_86_vs%\2017\Professional\MSBuild\15.0\Bin\msbuild.exe"
set "_MSB_CAND=%_MSB_CAND%;%_programfiles_86_vs%\2017\Enterprise\MSBuild\15.0\Bin\msbuild.exe"
set "_MSB_CAND=%_MSB_CAND%;%ProgramFiles(x86)%\MSBuild\14.0\bin"
set "_MSB_CAND=%_MSB_CAND%;%ProgramFiles%\MSBuild\14.0\bin"
set "_MSB_CAND=%_MSB_CAND%;dotnet"

set _MSB_CAND="%_MSB_CAND:;=";"%"

for %%i in (%_MSB_CAND%) do (
    set "found=()"

	set "build_cand=%%~i"
	where /q "!build_cand!" 2>nul
    if "!ERRORLEVEL!" == "0" (
		set "found=true" 
    ) else (
		set "build_cand=%%~$PATH:i"
		if exist "!build_cand!" (
			set "found=true" 
        )
    )

    if "!found!" == "true" (
        set MSBUILD="!build_cand!"
		echo %%i | find "dotnet" >nul
		if "!ERRORLEVEL!" == "0" (
            set "MSBUILD=!MSBUILD! msbuild"
		)
		goto :FOUND_MSBUILD
    )
)

if %MSBUILD%==() (
    echo "I couldn't find MSBuild on your PC. Make sure it's installed somewhere, and if it's not in the above list (in build.bat), add it."
    goto :EXIT
) 
:FOUND_MSBUILD
set _MSBUILD_TARGET=Build
set _MSBUILD_CONFIG=Debug
set _MSBUILD_PLATFORM=x64

:ARGS_LOOP
if (%1) == () goto :POST_ARGS_LOOP
if (%1) == (clean) (
    set _MSBUILD_TARGET=Clean,Build
)
if (%1) == (rel) (
    set _MSBUILD_CONFIG=Release
)
if (%1) == (arm) (
    set _MSBUILD_PLATFORM=ARM64
)
if (%1) == (x64) (
    set _MSBUILD_PLATFORM=x64
)
shift
goto :ARGS_LOOP

:POST_ARGS_LOOP
%MSBUILD% %~dp0\DistroLauncher.sln /t:%_MSBUILD_TARGET% /m /nr:true /p:Configuration=%_MSBUILD_CONFIG%;Platform=%_MSBUILD_PLATFORM%

if (%ERRORLEVEL%) == (0) (
    echo.
    echo Created appx in %~dp0x64\%_MSBUILD_CONFIG%\DistroLauncher-Appx\
    echo.
)

:EXIT
