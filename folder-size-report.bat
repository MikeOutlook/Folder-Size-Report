@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Folder Size Report

set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%folder-size-report.ps1"

if not exist "%PS_SCRIPT%" (
    echo.
    echo [Error] Missing PowerShell script:
    echo %PS_SCRIPT%
    echo.
    pause
    exit /b 1
)

set "TARGET_PATH=%~1"

if "%~1"=="" (
    cls
    echo ============================================================
    echo Folder Size Report
    echo ============================================================
    echo Enter an absolute folder path to scan.
    echo Example: E:\
    echo.
    set /p "TARGET_PATH=Path: "
) else (
    echo Using dropped / passed path:
    echo %TARGET_PATH%
    echo.
)

if not defined TARGET_PATH (
    echo No path was entered.
    echo.
    pause
    exit /b 1
)

set "TARGET_PATH=%TARGET_PATH:"=%"

echo.
echo Scanning, please wait...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%PS_SCRIPT%' -Path $env:TARGET_PATH"
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if not "%EXIT_CODE%"=="0" (
    echo The report did not finish successfully. Exit code: %EXIT_CODE%
) else (
    echo Report finished.
)
echo.
pause
exit /b %EXIT_CODE%
