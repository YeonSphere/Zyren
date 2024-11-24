@echo off
:: Seoggi Management Tool for Windows
:: Works in both CMD and PowerShell

setlocal enabledelayedexpansion

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Attempting to elevate privileges...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

:: Set paths
set "SEO_HOME=C:\Program Files\seoggi"
set "SEO_BIN=%SEO_HOME%\bin"
set "SEO_LIB=%SEO_HOME%\lib"
set "SEO_CACHE=%SEO_HOME%\cache"
set "SEO_TEMP=%SEO_HOME%\temp"
set "SEO_BACKUP=%SEO_HOME%\backup"

:: Function to log errors
:log_error
echo [%date% %time%] ERROR: %* >> "%SEO_HOME%\error.log"
exit /b

:: Function to log info
:log_info
echo [%date% %time%] INFO: %* >> "%SEO_HOME%\info.log"
exit /b

:: Parse command
if "%1"=="" goto :help
if "%1"=="clean" goto :clean
if "%1"=="repair" goto :repair
if "%1"=="optimize" goto :optimize
if "%1"=="backup" goto :backup
if "%1"=="restore" goto :restore
if "%1"=="status" goto :status
if "%1"=="diagnose" goto :diagnose
goto :help

:diagnose
echo Running system diagnostics...
call :log_info "Starting system diagnostics"

:: Check system requirements
echo Checking system requirements...
wmic os get Caption,OSArchitecture | findstr /i "64-bit" >nul
if errorlevel 1 (
    echo WARNING: 32-bit OS detected. Some features may not work.
    call :log_error "32-bit OS detected"
)

:: Check disk space
for /f "tokens=2" %%a in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value ^| find "="') do set free=%%a
set /a "free_gb=%free:~0,-9%"
if %free_gb% lss 5 (
    echo WARNING: Low disk space ^(less than 5GB^)
    call :log_error "Low disk space: %free_gb%GB"
)

:: Check for corrupted files
echo Checking for corrupted files...
for %%f in ("%SEO_BIN%\*.exe" "%SEO_BIN%\*.dll") do (
    sigcheck "%%f" >nul 2>&1
    if errorlevel 1 (
        echo WARNING: Corrupted file detected: %%f
        call :log_error "Corrupted file: %%f"
        echo Attempting to repair...
        call :repair_file "%%f"
    )
)

:: Check for common runtime dependencies
echo Checking runtime dependencies...
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" >nul 2>&1
if errorlevel 1 (
    echo Installing Visual C++ Runtime...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://aka.ms/vs/17/release/vc_redist.x64.exe', '%TEMP%\vc_redist.x64.exe')"
    %TEMP%\vc_redist.x64.exe /quiet /norestart
)

echo Diagnostics completed. Check error.log for details.
goto :eof

:clean
echo Cleaning Seoggi environment...
call :log_info "Starting cleanup"

:: Clean temp files
if exist "%SEO_CACHE%" (
    rd /s /q "%SEO_CACHE%" 2>nul || (
        echo Retrying with system permissions...
        takeown /f "%SEO_CACHE%" /r /d y >nul
        icacls "%SEO_CACHE%" /grant administrators:F /t >nul
        rd /s /q "%SEO_CACHE%"
    )
)
if exist "%SEO_TEMP%" rd /s /q "%SEO_TEMP%" 2>nul

:: Create fresh directories
mkdir "%SEO_CACHE%" 2>nul
mkdir "%SEO_TEMP%" 2>nul

:: Clean old logs (keep last 5)
for /f "skip=5 delims=" %%F in ('dir /b /o-d "%SEO_HOME%\*.log"') do del "%SEO_HOME%\%%F"

echo Environment cleaned successfully.
goto :eof

:repair
echo Repairing Seoggi installation...
call :log_info "Starting repair"

:: Verify and repair registry
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Seoggi" >nul 2>&1
if errorlevel 1 (
    echo Fixing registry entries...
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Seoggi" /v DisplayName /t REG_SZ /d "Seoggi Programming Language" /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Seoggi" /v InstallLocation /t REG_SZ /d "%SEO_HOME%" /f
)

:: Verify and repair PATH
echo Verifying PATH...
set "PATH_FIXED="
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path ^| findstr /i "path"') do (
    set "CURRENT_PATH=%%b"
    echo !CURRENT_PATH! | findstr /i /c:"%SEO_BIN%" >nul
    if errorlevel 1 (
        set "NEW_PATH=!CURRENT_PATH!;%SEO_BIN%"
        setx /M PATH "!NEW_PATH!" >nul
        set "PATH_FIXED=1"
    )
)

:: Verify and repair directories
for %%D in ("%SEO_HOME%" "%SEO_BIN%" "%SEO_LIB%" "%SEO_CACHE%" "%SEO_TEMP%" "%SEO_BACKUP%") do (
    if not exist "%%D" (
        mkdir "%%D" 2>nul || (
            echo Retrying with system permissions...
            takeown /f "%%D" /r /d y >nul
            icacls "%%D" /grant administrators:F /t >nul
            mkdir "%%D"
        )
    )
)

:: Verify and repair file permissions
for /r "%SEO_HOME%" %%F in (*) do (
    icacls "%%F" /grant administrators:F >nul
)

:: Verify binary integrity
echo Verifying binary integrity...
for %%f in ("%SEO_BIN%\*.exe" "%SEO_BIN%\*.dll") do (
    call :verify_binary "%%f"
)

echo Repair completed successfully.
goto :eof

:verify_binary
echo Verifying %~1...
sigcheck "%~1" >nul 2>&1
if errorlevel 1 (
    echo Binary verification failed for %~1
    call :repair_file "%~1"
)
goto :eof

:repair_file
echo Attempting to repair %~1...
:: Try to download a fresh copy
set "filename=%~nx1"
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://seoggi.org/binaries/%filename%', '%~1')" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Could not repair %filename%. Manual intervention required.
    call :log_error "Failed to repair %filename%"
) else (
    echo Successfully repaired %filename%
    call :log_info "Repaired %filename%"
)
goto :eof

:optimize
echo Optimizing Seoggi installation...
call :log_info "Starting optimization"

:: Clean first
call :clean

:: Optimize binary cache
echo Optimizing binary cache...
if exist "%SEO_BIN%\*.pdb" del /f /q "%SEO_BIN%\*.pdb"
if exist "%SEO_BIN%\*.ilk" del /f /q "%SEO_BIN%\*.ilk"

:: Compact installation directory
echo Compacting installation directory...
compact /c /s:"%SEO_HOME%" >nul

:: Optimize PATH
echo Optimizing PATH...
powershell -Command "$path = [Environment]::GetEnvironmentVariable('PATH', 'Machine'); $parts = $path -split ';' | Select-Object -Unique; [Environment]::SetEnvironmentVariable('PATH', ($parts -join ';'), 'Machine')"

:: Clear system file cache
echo Clearing system file cache...
powershell -Command "Write-VolumeCache C"

echo Optimization completed successfully.
goto :eof

:backup
if "%2"=="" (
    set "BACKUP_PATH=%SEO_BACKUP%\auto_%date:~-4,4%%date:~-10,2%%date:~-7,2%"
) else (
    set "BACKUP_PATH=%2"
)

echo Creating backup at !BACKUP_PATH!...
call :log_info "Starting backup to !BACKUP_PATH!"

if not exist "!BACKUP_PATH!" mkdir "!BACKUP_PATH!"

:: Create versioned backup
set "BACKUP_FILE=!BACKUP_PATH!\seoggi_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.zip"
powershell -Command "Compress-Archive -Path '%SEO_HOME%\*' -DestinationPath '!BACKUP_FILE!' -Force"

:: Verify backup
powershell -Command "Test-Path '!BACKUP_FILE!'" | findstr /i "true" >nul
if errorlevel 1 (
    echo ERROR: Backup failed
    call :log_error "Backup failed to !BACKUP_FILE!"
) else (
    echo Backup completed successfully.
    call :log_info "Backup completed to !BACKUP_FILE!"
)
goto :eof

:restore
if "%2"=="" (
    echo Searching for latest auto-backup...
    for /f "delims=" %%F in ('dir /b /o-d "%SEO_BACKUP%\auto_*\seoggi_backup_*.zip" 2^>nul') do (
        set "RESTORE_FILE=%%F"
        goto :do_restore
    )
    echo No auto-backup found.
    goto :eof
) else (
    set "RESTORE_FILE=%2"
)

:do_restore
echo Restoring from !RESTORE_FILE!...
call :log_info "Starting restore from !RESTORE_FILE!"

:: Stop running processes
taskkill /f /im seo.exe >nul 2>&1

:: Backup current installation
call :backup "%SEO_BACKUP%\pre_restore_%date:~-4,4%%date:~-10,2%%date:~-7,2%"

:: Restore files
powershell -Command "Expand-Archive -Path '!RESTORE_FILE!' -DestinationPath '%SEO_HOME%' -Force"

:: Verify restoration
if errorlevel 1 (
    echo ERROR: Restore failed
    call :log_error "Restore failed from !RESTORE_FILE!"
) else (
    echo Restore completed successfully.
    call :repair
    call :log_info "Restore completed from !RESTORE_FILE!"
)
goto :eof

:status
echo Seoggi Installation Status
echo -------------------------
call :log_info "Checking status"

:: Installation paths
echo Installation Paths:
echo   Home: %SEO_HOME%
echo   Binary: %SEO_BIN%
echo   Library: %SEO_LIB%
echo   Cache: %SEO_CACHE%
echo   Temp: %SEO_TEMP%
echo   Backup: %SEO_BACKUP%

:: Version info
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Seoggi" /v DisplayVersion 2^>nul ^| findstr /i "DisplayVersion"') do (
    echo Version: %%b
)

:: System info
echo.
echo System Information:
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"

:: PATH status
echo.
echo PATH Status:
echo !PATH! | findstr /i /c:"%SEO_BIN%" >nul
if !errorLevel! equ 0 (
    echo PATH is correctly configured
) else (
    echo WARNING: PATH is not correctly configured
    call :log_error "PATH misconfiguration detected"
)

:: Storage status
echo.
echo Storage Status:
for /f "tokens=3" %%a in ('dir /-c "%SEO_HOME%\*.*" 2^>nul ^| findstr "bytes"') do set "TOTAL_SIZE=%%a"
echo Installation size: !TOTAL_SIZE! bytes

:: Check available disk space
for /f "tokens=2" %%a in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value ^| find "="') do set free=%%a
set /a "free_gb=%free:~0,-9%"
echo Available disk space: %free_gb%GB

:: Process status
echo.
echo Process Status:
tasklist | findstr /i "seo" || echo No Seoggi processes running

goto :eof

:help
echo Seoggi Management Tool
echo Usage: manage.bat [command] [options]
echo.
echo Commands:
echo   clean     - Clean temporary files and cache
echo   repair    - Repair installation and environment
echo   optimize  - Optimize installation and performance
echo   backup    - Create backup (optional: specify path)
echo   restore   - Restore from backup (optional: specify path)
echo   status    - Show installation status
echo   diagnose  - Run system diagnostics
echo.
echo Examples:
echo   manage.bat clean
echo   manage.bat backup C:\backups\seoggi
echo   manage.bat restore C:\backups\seoggi
echo   manage.bat diagnose
goto :eof
