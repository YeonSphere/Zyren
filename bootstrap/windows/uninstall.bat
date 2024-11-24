@echo off
:: Seoggi Uninstaller for Windows
:: Works in both CMD and PowerShell

echo Seoggi Uninstaller
echo Checking administrator privileges...

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Error: Please run as administrator
    echo Right-click and select "Run as administrator"
    exit /b 1
)

:: Remove registry entries
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Seoggi" /f >nul 2>&1

:: Remove from PATH
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path ^| findstr /i "path"') do (
    setx /M PATH "%%b" >nul 2>&1
)

:: Remove installation directory
echo Removing Seoggi installation...
rmdir /s /q "C:\Program Files\seoggi" >nul 2>&1

echo Seoggi has been uninstalled successfully.
echo Please restart your terminal to complete the uninstallation.
pause
