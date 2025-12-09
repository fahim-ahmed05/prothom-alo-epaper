@echo off
setlocal

REM ================================
REM CONFIGURATION
REM ================================

REM Script's RAW GitHub URL
set "SCRIPT_URL=https://raw.githubusercontent.com/fahim-ahmed05/prothom-alo-epaper/main/prothom-alo-epaper.ps1"

REM Name to save the script as
set "SCRIPT_NAME=prothom-alo-epaper.ps1"

REM Download location in TEMP
set "TEMP_PS=%TEMP%\%SCRIPT_NAME%"

REM Delete script after running? (yes/no)
set "CLEANUP=no"


REM ================================
echo Downloading script from GitHub...
powershell -NoLogo -NoProfile -Command ^
    "try { Invoke-WebRequest -Uri '%SCRIPT_URL%' -OutFile '%TEMP_PS%' -UseBasicParsing } catch { exit 1 }"

if errorlevel 1 (
    echo.
    echo [ERROR] Failed to download from GitHub!
    echo URL: %SCRIPT_URL%
    exit /b 1
)

echo Download complete.


REM ================================
echo Running PowerShell script...
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%TEMP_PS%"

echo Script finished.


REM ================================
if /I "%CLEANUP%"=="yes" (
    echo Removing the PowerShell script...
    del "%TEMP_PS%" >nul 2>&1
)

echo.
echo Done.
endlocal
exit /b 0
