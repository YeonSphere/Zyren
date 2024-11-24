@echo off
:: Build script for Windows bootstrap compiler

:: Compile bootstrap.c to seo-install.exe
cl.exe /nologo /O2 /Fe:seo-install.exe bootstrap.c

if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to compile bootstrap compiler
    exit /b 1
)

echo Build successful! Run seo-install.exe to install Seoggi.
