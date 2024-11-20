# Seoggi Windows-specific installer
# This script is a wrapper around the main installer with Windows-specific optimizations

# Ensure we're running with admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator"
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Source the main installer functions
. "$PSScriptRoot\install.ps1"

# Additional Windows-specific setup
function Setup-WindowsSpecific {
    Write-Host "Setting up Windows-specific features..." -ForegroundColor Blue
    
    # Install Chocolatey if not present
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Chocolatey package manager..." -ForegroundColor Blue
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    
    # Install MSYS2 if not present
    if (-not (Test-Path "$env:SystemDrive\msys64")) {
        Write-Host "Installing MSYS2..." -ForegroundColor Blue
        choco install msys2 -y
    }
    
    # Setup kernel development environment
    Write-Host "Setting up kernel development environment..." -ForegroundColor Blue
    choco install windows-sdk-10-version-2004-all `
        windows-driver-kit visualstudio2022-workload-nativedesktop -y
    
    # Setup GPU development environment
    Write-Host "Detecting GPU and setting up development environment..." -ForegroundColor Blue
    $gpu = Get-WmiObject Win32_VideoController
    if ($gpu.Name -match "NVIDIA") {
        Write-Host "NVIDIA GPU detected, setting up CUDA development environment..." -ForegroundColor Blue
        choco install cuda nvidia-display-driver -y
    }
    elseif ($gpu.Name -match "AMD") {
        Write-Host "AMD GPU detected, setting up ROCm development environment..." -ForegroundColor Blue
        choco install rocm-dev -y
    }
    
    # Setup DirectX development
    Write-Host "Setting up DirectX development environment..." -ForegroundColor Blue
    choco install directx-sdk -y
    
    # Setup Android development
    Write-Host "Setting up Android development environment..." -ForegroundColor Blue
    choco install android-sdk androidstudio -y
    
    # Setup game development environment
    Write-Host "Setting up game development environment..." -ForegroundColor Blue
    choco install cmake.install ninja git python3 `
        vulkan-sdk openal glew glfw freetype harfbuzz -y
    
    # Setup AI/ML development environment
    Write-Host "Setting up AI/ML development environment..." -ForegroundColor Blue
    choco install python3 anaconda3 -y
    
    # Install Python ML packages
    Write-Host "Installing Python ML packages..." -ForegroundColor Blue
    pip install numpy pandas scikit-learn torch tensorflow
    
    # Setup browser development environment
    Write-Host "Setting up browser development environment..." -ForegroundColor Blue
    choco install qt-sdk webkit2gtk -y
}

# Setup IDE integration
function Setup-IDEIntegration {
    # Setup VSCode integration
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Write-Host "Setting up VSCode integration..." -ForegroundColor Blue
        code --install-extension seoggi.seoggi-lang
        code --install-extension seoggi.seoggi-debug
    }
    
    # Setup Visual Studio integration
    Write-Host "Setting up Visual Studio integration..." -ForegroundColor Blue
    $vsixInstaller = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\VSIXInstaller.exe"
    if (Test-Path $vsixInstaller) {
        & $vsixInstaller /quiet "$env:SEOGGI_HOME\share\visualstudio\Seoggi.vsix"
    }
}

# Configure Windows environment
function Configure-WindowsEnvironment {
    Write-Host "Configuring Windows environment..." -ForegroundColor Blue
    
    # Add Seoggi to system PATH
    $seoggiPath = "$env:SEOGGI_HOME\bin"
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($currentPath -notlike "*$seoggiPath*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$seoggiPath", "Machine")
    }
    
    # Set SEOGGI_HOME environment variable
    [Environment]::SetEnvironmentVariable("SEOGGI_HOME", $env:SEOGGI_HOME, "Machine")
    
    # Create file associations
    $fileTypes = @{
        ".seo" = "Seoggi.SourceFile"
        ".seox" = "Seoggi.ExecutableFile"
        ".seom" = "Seoggi.ModuleFile"
    }
    
    foreach ($type in $fileTypes.GetEnumerator()) {
        New-Item -Path "Registry::HKEY_CLASSES_ROOT\$($type.Value)" -Force | Out-Null
        Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\$($type.Value)" -Name "(Default)" -Value "Seoggi $($type.Key) File"
        
        New-Item -Path "Registry::HKEY_CLASSES_ROOT\$($type.Key)" -Force | Out-Null
        Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\$($type.Key)" -Name "(Default)" -Value $type.Value
        
        New-Item -Path "Registry::HKEY_CLASSES_ROOT\$($type.Value)\shell\open\command" -Force | Out-Null
        Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\$($type.Value)\shell\open\command" -Name "(Default)" -Value "`"$seoggiPath\seoggi.exe`" `"%1`""
    }
}

# Run Windows-specific setup after main installation
function Post-Install {
    Setup-WindowsSpecific
    Setup-IDEIntegration
    Configure-WindowsEnvironment
}

# Run main installation
try {
    Install-PackageManagers
    Install-Dependencies
    Setup-MSYS2
    Setup-Directories
    Clone-Repository
    Build-Compiler
    Install-Compiler
    Configure-Environment
    Post-Install
    
    Write-Host "`nInstallation complete!" -ForegroundColor Green
    Write-Host "Please restart your terminal to use Seoggi." -ForegroundColor Green
    Write-Host "Type 'seoggi --version' to verify the installation." -ForegroundColor Green
}
catch {
    Write-Host "An error occurred during installation: $_" -ForegroundColor Red
    exit 1
}
