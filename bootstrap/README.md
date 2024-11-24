# Seoggi Bootstrap Compilers

Platform-specific bootstrap compilers written in C that can generate native Seoggi installers.

## Structure
- `windows/` - Windows x64 bootstrap compiler
- `linux/` - Linux x64 bootstrap compiler  
- `macos/` - macOS x64/ARM64 bootstrap compiler
- `shared/` - Shared code between platforms

## Building
Each platform has its own build script that generates a native installer:
- Windows: `build.bat` generates `seo-install.exe`
- Linux: `build.sh` generates `seo-install`
- macOS: `build.sh` generates `seo-install`

## Usage
Users simply run the platform-specific installer:
```bash
# Windows
seo-install.exe

# Linux/macOS 
./seo-install
```

This will install the full Seoggi compiler and set up the environment.
