@echo off
:: Seoggi Updater for Windows
:: Works in both CMD and PowerShell

echo Seoggi Updater
echo Checking administrator privileges...

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Error: Please run as administrator
    echo Right-click and select "Run as administrator"
    exit /b 1
)

:: Get current version
set "current_version="
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Seoggi" /v DisplayVersion 2^>nul ^| findstr /i "DisplayVersion"') do (
    set "current_version=%%b"
)

if "%current_version%"=="" (
    echo Error: Seoggi is not installed
    exit /b 1
)

echo Current version: %current_version%
echo Checking for updates...

:: Download latest version info
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://seoggi.org/version.txt', '%TEMP%\seoggi_version.txt')" >nul 2>&1
if %errorLevel% neq 0 (
    echo Error: Failed to check for updates
    exit /b 1
)

:: Compare versions
set /p latest_version=<%TEMP%\seoggi_version.txt
if "%current_version%"=="%latest_version%" (
    echo You are already running the latest version.
    exit /b 0
)

echo New version available: %latest_version%
echo Downloading update...

:: Download new version
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://seoggi.org/download/windows/seo-install.exe', '%TEMP%\seo-install.exe')" >nul 2>&1
if %errorLevel% neq 0 (
    echo Error: Failed to download update
    exit /b 1
)

:: Run new installer
echo Installing update...
"%TEMP%\seo-install.exe" /quiet

echo Update completed successfully!
echo Please restart your terminal to use the updated version.
pause
