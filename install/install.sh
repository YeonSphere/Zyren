#!/usr/bin/env bash

# Seoggi Programming Language Installation Script
# This script detects the system type and configures the environment accordingly

set -e

# Configuration
SEOGGI_VERSION="0.1.0"
SEOGGI_REPO="https://github.com/YeonSphere/Seoggi.git"
SEOGGI_HOME="${HOME}/.seoggi"
SEOGGI_BIN="${SEOGGI_HOME}/bin"
SEOGGI_LIB="${SEOGGI_HOME}/lib"
SEOGGI_INCLUDE="${SEOGGI_HOME}/include"
SEOGGI_SRC="${SEOGGI_HOME}/src"
Z3_MIN_VERSION="4.8.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Print with color
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Print error and exit
error() {
    print_color "$RED" "Error: $1"
    exit 1
}

# Print info message
info() {
    print_color "$BLUE" "Info: $1"
}

# Print success message
success() {
    print_color "$GREEN" "Success: $1"
}

# Print warning message
warning() {
    print_color "$YELLOW" "Warning: $1"
}

# Detect OS type
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        detect_linux_distro
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        detect_macos_arch
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
        OS="windows"
    else
        error "Unsupported operating system: $OSTYPE"
    fi
}

# Detect Linux distribution
detect_linux_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
    elif [ -f /etc/redhat-release ]; then
        DISTRO="rhel"
    else
        DISTRO="unknown"
    fi
    
    # Detect shell more reliably
    if [ -n "$FISH_VERSION" ]; then
        SHELL_TYPE="fish"
    else
        SHELL_TYPE=$(basename "$SHELL")
    fi
}

# Detect macOS architecture
detect_macos_arch() {
    if [[ $(uname -m) == "arm64" ]]; then
        ARCH="arm64"
    else
        ARCH="x86_64"
    fi
}

# Configure shell environment
configure_shell() {
    local install_dir="$1"
    local shell_rc
    local user_bin="$HOME/bin"
    
    case "$SHELL_TYPE" in
        "bash")
            shell_rc="$HOME/.bashrc"
            ;;
        "zsh")
            shell_rc="$HOME/.zshrc"
            ;;
        "fish")
            mkdir -p "$HOME/.config/fish"
            shell_rc="$HOME/.config/fish/config.fish"
            touch "$shell_rc"
            ;;
        *)
            warning "Unsupported shell: $SHELL_TYPE. Please add ~/bin to your PATH manually."
            return
            ;;
    esac
    
    info "Configuring shell environment in $shell_rc"
    
    # Create shell configuration
    if [[ "$SHELL_TYPE" == "fish" ]]; then
        # Remove any existing Seoggi paths
        if [ -f "$shell_rc" ]; then
            sed -i '/# Seoggi PATH/d' "$shell_rc"
            sed -i '/set -gx PATH.*seoggi/d' "$shell_rc"
            sed -i '/set -gx PATH.*bin/d' "$shell_rc"
            sed -i '/set -gx SEOGGI_HOME/d' "$shell_rc"
        fi
        
        # Add new paths
        echo "# Seoggi PATH" >> "$shell_rc"
        echo "set -gx SEOGGI_HOME $install_dir" >> "$shell_rc"
        echo "if not contains $user_bin \$PATH" >> "$shell_rc"
        echo "    set -gx PATH $user_bin \$PATH" >> "$shell_rc"
        echo "end" >> "$shell_rc"
    else
        # Remove any existing Seoggi paths
        if [ -f "$shell_rc" ]; then
            sed -i '/# Seoggi PATH/d' "$shell_rc"
            sed -i '/export PATH.*seoggi/d' "$shell_rc"
            sed -i '/export PATH.*bin/d' "$shell_rc"
            sed -i '/export SEOGGI_HOME/d' "$shell_rc"
        fi
        
        # Add new paths
        echo "# Seoggi PATH" >> "$shell_rc"
        echo "export SEOGGI_HOME=$install_dir" >> "$shell_rc"
        echo 'export PATH="$HOME/bin:$PATH"' >> "$shell_rc"
    fi
    
    success "Added ~/bin to $shell_rc"
    
    # Source the shell configuration
    case "$SHELL_TYPE" in
        "fish")
            fish -c "source $shell_rc" || true
            ;;
        *)
            source "$shell_rc" || true
            ;;
    esac
    
    info "To start using Seoggi, try:"
    echo "  seo version"
}

# Dependency information with version requirements
declare -A DEPS_INFO=(
    ["cmake"]="3.10.0"
    ["llvm"]="10.0.0"
    ["z3"]="4.8.0"
    ["python3"]="3.8.0"
    ["git"]=""
    ["curl"]=""
    ["pip3"]=""
)

# Package names for different package managers
declare -A PM_DEPS=(
    ["apt"]="build-essential cmake llvm-dev libz3-dev libedit-dev python3 python3-pip curl wget git"
    ["dnf"]="gcc gcc-c++ make cmake llvm-devel z3-devel libedit-devel python3 python3-pip curl wget git"
    ["pacman"]="base-devel cmake llvm z3 libedit python python-pip curl wget git"
    ["zypper"]="gcc gcc-c++ make cmake llvm-devel libz3-devel libedit-devel python3 python3-pip curl wget git"
    ["brew"]="llvm z3 libedit python curl wget git"
    ["xbps"]="base-devel cmake llvm z3 libedit python3 python3-pip curl wget git"
    ["apk"]="build-base cmake llvm-dev z3-dev libedit-dev python3 py3-pip curl wget git"
)

# Version comparison function
version_compare() {
    [ -z "$1" ] || [ -z "$2" ] || printf '%s\n%s\n' "$2" "$1" | sort -C -V
}

# Get version of installed package
get_version() {
    local cmd="$1"
    case "$cmd" in
        cmake) cmake --version 2>/dev/null | head -n1 | awk '{print $3}' ;;
        python3) python3 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))' 2>/dev/null ;;
        llvm) llvm-config --version 2>/dev/null || clang --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' ;;
        z3) z3 --version 2>/dev/null | cut -d' ' -f2 ;;
        *) command -v "$cmd" >/dev/null 2>&1 && echo "installed" ;;
    esac
}

# Check for missing dependencies
check_dependencies() {
    info "Checking installed dependencies..."
    local missing_deps=() outdated_deps=()
    
    for dep in "${!DEPS_INFO[@]}"; do
        local required_version="${DEPS_INFO[$dep]}"
        local installed_version=$(get_version "$dep")
        
        if [[ -z "$installed_version" ]]; then
            missing_deps+=("$dep")
            warning "$dep is not installed"
        elif [[ -n "$required_version" ]] && ! version_compare "$installed_version" "$required_version"; then
            outdated_deps+=("$dep")
            warning "$dep version $installed_version is older than required $required_version"
        else
            success "Found $dep${installed_version:+ ($installed_version)}"
        fi
    done
    
    if [[ ${#missing_deps[@]} -eq 0 && ${#outdated_deps[@]} -eq 0 ]]; then
        success "All dependencies satisfied!"
        return 0
    else
        MISSING_DEPS=("${missing_deps[@]}")
        return 1
    fi
}

# Install specific dependencies
install_specific_deps() {
    local deps_to_install=("$@")
    [[ ${#deps_to_install[@]} -eq 0 ]] && return 0
    
    info "Installing missing dependencies: ${deps_to_install[*]}"
    local cmd
    case "$DISTRO" in
        "arch"|"cachyos"|"manjaro")
            # For pacman, we need to pass packages as separate arguments
            cmd="$PM_INSTALL ${deps_to_install[@]}"
            ;;
        *)
            # For other package managers, we can pass as a space-separated string
            cmd="$PM_INSTALL ${deps_to_install[*]}"
            ;;
    esac
    
    [[ $(id -u) -ne 0 ]] && cmd="sudo $cmd"
    retry_command $cmd
}

# Retry command with exponential backoff
retry_command() {
    local max_attempts=5 timeout=1 attempt=1
    while (( attempt <= max_attempts )); do
        if "$@"; then return 0; fi
        warning "Command failed. Retrying in $timeout seconds..."
        sleep $timeout
        attempt=$((attempt + 1))
        timeout=$((timeout * 2))
    done
    error "Command failed after $max_attempts attempts."
    return 1
}

# Check if a package is installed
check_package() {
    local pkg="$1"
    case "$DISTRO" in
        "arch"|"cachyos"|"manjaro")
            if pacman -Qi "$pkg" >/dev/null 2>&1; then
                return 0
            elif pacman -Qg base-devel 2>/dev/null | grep -q "^base-devel $pkg$"; then
                # Check if package is part of base-devel group
                return 0
            fi
            return 1
            ;;
        "debian"|"ubuntu")
            dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"
            return $?
            ;;
        "fedora")
            rpm -q "$pkg" >/dev/null 2>&1
            return $?
            ;;
        "opensuse-leap"|"opensuse-tumbleweed")
            rpm -q "$pkg" >/dev/null 2>&1
            return $?
            ;;
        *)
            return 1
            ;;
    esac
}

# Map generic package names to distro-specific names
map_package_name() {
    local pkg="$1"
    case "$DISTRO" in
        "arch"|"cachyos"|"manjaro")
            case "$pkg" in
                "python3") echo "python" ;;
                "pip3") echo "python-pip" ;;
                "base-devel") echo "$pkg" ;;
                *) echo "$pkg" ;;
            esac
            ;;
        "debian"|"ubuntu")
            case "$pkg" in
                "llvm") echo "llvm-dev" ;;
                "z3") echo "libz3-dev" ;;
                "libedit") echo "libedit-dev" ;;
                *) echo "$pkg" ;;
            esac
            ;;
        "fedora")
            case "$pkg" in
                "llvm") echo "llvm-devel" ;;
                "z3") echo "z3-devel" ;;
                "libedit") echo "libedit-devel" ;;
                *) echo "$pkg" ;;
            esac
            ;;
        *)
            echo "$pkg"
            ;;
    esac
}

# Install Linux dependencies
install_linux_dependencies() {
    local pkg_manager install_cmd pkgs update_cmd
    
    # Define package names for different distributions
    case "$DISTRO" in
        "arch"|"cachyos"|"manjaro")
            pkg_manager="pacman"
            install_cmd="pacman -S --noconfirm"
            update_cmd="pacman -Sy"
            # Convert space-separated string to array for pacman
            IFS=' ' read -r -a pkgs <<< "${PM_DEPS["pacman"]}"
            ;;
        "debian"|"ubuntu")
            pkg_manager="apt"
            install_cmd="apt-get install -y"
            update_cmd="apt-get update"
            IFS=' ' read -r -a pkgs <<< "${PM_DEPS["apt"]}"
            ;;
        "fedora")
            pkg_manager="dnf"
            install_cmd="dnf install -y"
            update_cmd="dnf check-update"
            IFS=' ' read -r -a pkgs <<< "${PM_DEPS["dnf"]}"
            ;;
        "opensuse-leap"|"opensuse-tumbleweed")
            pkg_manager="zypper"
            install_cmd="zypper install -y"
            update_cmd="zypper refresh"
            IFS=' ' read -r -a pkgs <<< "${PM_DEPS["zypper"]}"
            ;;
        *)
            error "Unsupported Linux distribution: $DISTRO"
            exit 1
            ;;
    esac

    # Check for missing packages
    info "Checking installed packages..."
    local missing_pkgs=()
    for pkg in "${pkgs[@]}"; do
        local mapped_pkg=$(map_package_name "$pkg")
        if ! check_package "$mapped_pkg"; then
            missing_pkgs+=("$mapped_pkg")
            warning "Package $mapped_pkg is not installed"
        else
            success "Package $mapped_pkg is already installed"
        fi
    done

    if [ ${#missing_pkgs[@]} -gt 0 ]; then
        # Update package lists only if we need to install something
        info "Updating package lists..."
        if [ "$(id -u)" -eq 0 ]; then
            retry_command $update_cmd
        else
            retry_command sudo $update_cmd
        fi

        info "Installing missing packages: ${missing_pkgs[*]}"
        if [ "$(id -u)" -eq 0 ]; then
            retry_command $install_cmd "${missing_pkgs[@]}" || {
                error "Failed to install packages"
                exit 1
            }
        else
            retry_command sudo $install_cmd "${missing_pkgs[@]}" || {
                error "Failed to install packages"
                exit 1
            }
        fi
        success "Successfully installed missing packages"
    else
        success "All required packages are already installed"
    fi
}

# Install macOS dependencies
install_macos_dependencies() {
    # Install Homebrew if not present
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install dependencies
    brew install cmake llvm python git curl pkg-config z3 libedit
    
    if [[ "$ARCH" == "arm64" ]]; then
        # Additional setup for Apple Silicon
        softwareupdate --install-rosetta --agree-to-license
    fi
}

# Install Windows dependencies (through MSYS2)
install_windows_dependencies() {
    # Check if MSYS2 is installed
    if ! command -v pacman &> /dev/null; then
        error "MSYS2 is required for Windows installation. Please install it from https://www.msys2.org"
    fi
    
    pacman -Syu --noconfirm
    pacman -S --noconfirm mingw-w64-x86_64-toolchain mingw-w64-x86_64-cmake \
        mingw-w64-x86_64-llvm mingw-w64-x86_64-clang \
        mingw-w64-x86_64-python mingw-w64-x86_64-python-pip \
        mingw-w64-x86_64-z3 git curl pkg-config
}

# Install dependencies based on OS and distribution
install_dependencies() {
    case "$OS" in
        "linux")
            install_linux_dependencies
            ;;
        "macos")
            install_macos_dependencies
            ;;
        "windows")
            install_windows_dependencies
            ;;
        *)
            error "Unsupported operating system: $OS"
            exit 1
            ;;
    esac
}

# Build Seoggi
build_seoggi() {
    local build_dir="$1"
    local src_dir="$2"
    info "Building Seoggi..."
    
    # Create build directory structure
    mkdir -p "$build_dir"/{core,std,bin}
    
    # First, copy the bootstrap compiler
    info "Setting up bootstrap compiler..."
    cp "$src_dir/bootstrap/seoggi_bootstrap" "$build_dir/bin/seo"
    chmod +x "$build_dir/bin/seo"
    
    # Build core components
    info "Building core components..."
    local core_files=(
        "base.seo"
        "kernel.seo"
        "runtime.seo"
        "types.seo"
        "ipc.seo"
        "sync.seo"
        "universal.seo"
        "syntax.seo"
    )
    
    for file in "${core_files[@]}"; do
        if [[ -f "$src_dir/core/$file" ]]; then
            info "Building $file..."
            "$build_dir/bin/seo" "$src_dir/core/$file" || {
                error "Failed to build $file"
                return 1
            }
        else
            warning "Core file $file not found, skipping..."
        fi
    done
    
    # Build standard library
    if [[ -f "$src_dir/std/prelude.seo" ]]; then
        info "Building standard library..."
        "$build_dir/bin/seo" "$src_dir/std/prelude.seo" || {
            error "Failed to build standard library"
            return 1
        }
    fi
    
    # Build core modules
    info "Building core modules..."
    local core_modules=(
        "ai"
        "compiler"
        "parser"
        "runtime"
        "system"
        "types"
    )
    
    for module in "${core_modules[@]}"; do
        if [[ -d "$src_dir/core/$module" ]]; then
            find "$src_dir/core/$module" -name "*.seo" -type f | while read -r file; do
                info "Building module file: $(basename "$file")..."
                "$build_dir/bin/seo" "$file" || {
                    error "Failed to build module file: $file"
                    return 1
                }
            done
        fi
    done
    
    success "Build completed successfully"
    return 0
}

# Install Seoggi components
install_seoggi_components() {
    local install_dir="$1"
    local core_dir="${install_dir}/lib/seoggi/core"
    local std_dir="${install_dir}/lib/seoggi/std"
    local tools_dir="${install_dir}/share/seoggi/tools"
    local user_home
    local bin_dir
    local shell_rc
    
    # Get the correct home directory even when running with sudo
    if [ -n "${SUDO_USER:-}" ]; then
        user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    else
        user_home="$HOME"
    fi
    bin_dir="$user_home/bin"
    
    info "Installing Seoggi components..."
    
    # Create directory structure with validation
    for dir in "$core_dir" "$std_dir" "$bin_dir" "$tools_dir"; do
        if ! mkdir -p "$dir"; then
            error "Failed to create directory: $dir"
            return 1
        fi
    done
    
    # Install core components with validation
    info "Installing core components..."
    if ! cp -r core/*.seo "$core_dir/" 2>/dev/null; then
        warning "Some core components could not be copied"
    fi
    
    for subdir in ai compiler parser runtime system types; do
        if [[ -d "core/$subdir" ]]; then
            if ! cp -r "core/$subdir" "$core_dir/"; then
                warning "Failed to copy core/$subdir"
            fi
        fi
    done
    
    # Install compiler with fallback
    info "Installing compiler..."
    if [[ -f "build/core/compiler/seoggi_compiler" ]]; then
        if ! install -m 755 "build/core/compiler/seoggi_compiler" "$bin_dir/seo"; then
            error "Failed to install compiler"
            return 1
        fi
        info "Installed native compiler"
    else
        if [[ ! -f "core/seoggi_bootstrap" ]]; then
            error "Neither native compiler nor bootstrap compiler found"
            return 1
        fi
        if ! install -m 755 "core/seoggi_bootstrap" "$bin_dir/seo"; then
            error "Failed to install bootstrap compiler"
            return 1
        fi
        warning "Using bootstrap compiler"
    fi
    
    # Install standard library with validation
    info "Installing standard library..."
    if ! cp -r std/* "$std_dir/" 2>/dev/null; then
        warning "Some standard library components could not be copied"
    fi
    
    # Install tools with validation
    info "Installing tools..."
    if ! cp -r tools/* "$tools_dir/" 2>/dev/null; then
        warning "Some tools could not be copied"
    fi
    
    # Set permissions
    if [ -n "${SUDO_USER:-}" ]; then
        if ! chown -R "$SUDO_USER" "$install_dir" "$bin_dir"; then
            warning "Failed to set ownership of some files"
        fi
    fi
    
    # Verify critical components
    if [[ ! -x "$bin_dir/seo" ]]; then
        error "Compiler installation verification failed"
        return 1
    fi
    
    success "Components installed successfully"
    info "Seoggi compiler installed at $bin_dir/seo"
    
    # Add bin directory to PATH for all supported shells
    if [[ ":$PATH:" != *":$bin_dir:"* ]]; then
        # Detect available shells and their rc files
        for shell_conf in \
            "$user_home/.bashrc" \
            "$user_home/.zshrc" \
            "$user_home/.config/fish/config.fish"; do
            if [[ -f "$shell_conf" ]]; then
                case "$shell_conf" in
                    *.fish)
                        echo "set -gx PATH \$PATH $bin_dir" >> "$shell_conf"
                        ;;
                    *)
                        echo "export PATH=\"\$PATH:$bin_dir\"" >> "$shell_conf"
                        ;;
                esac
                info "Added $bin_dir to PATH in ${shell_conf##*/}"
            fi
        done
    fi
    
    # Create seoggi configuration directory
    local config_dir="$user_home/.config/seoggi"
    if mkdir -p "$config_dir"; then
        if [ -n "${SUDO_USER:-}" ]; then
            chown -R "$SUDO_USER" "$config_dir"
        fi
        info "Created configuration directory at $config_dir"
    fi
    
    # Set SEOGGI_ROOT environment variable
    local env_file="$config_dir/environment"
    echo "export SEOGGI_ROOT=\"$install_dir\"" > "$env_file"
    if [ -n "${SUDO_USER:-}" ]; then
        chown "$SUDO_USER" "$env_file"
    fi
    info "Set SEOGGI_ROOT environment variable"
}

# Setup development environment
setup_dev_environment() {
    local install_dir="$1"
    local user_bin="$HOME/bin"
    
    # Create directory structure
    mkdir -p "$install_dir"/{lib,include,share/doc}
    mkdir -p "$user_bin"
    
    # Check if we're running from within the Seoggi repository
    if [ -f "$(dirname "$0")/../CMakeLists.txt" ]; then
        info "Using local Seoggi source files"
        SEOGGI_SRC="$(cd "$(dirname "$0")/.." && pwd)"
    else
        # Clone repository if not already present
        if [ ! -d "$install_dir/src" ]; then
            info "Cloning Seoggi repository from $SEOGGI_REPO"
            git clone "$SEOGGI_REPO" "$install_dir/src"
            SEOGGI_SRC="$install_dir/src"
        fi
    fi
    
    # Build and install
    cd "${SEOGGI_SRC}"
    rm -rf build
    mkdir -p build
    cd build
    info "Configuring build..."
    cmake ..
    info "Building Seoggi..."
    make -j$(nproc)
    
    # Install binaries and libraries
    mkdir -p "${SEOGGI_LIB}" "${SEOGGI_INCLUDE}"
    cp core/compiler/seoggi_compiler "${install_dir}/bin/"
    chmod +x "${install_dir}/bin/seoggi_compiler"
    
    # Create seo symlink in ~/bin
    ln -sf "${install_dir}/bin/seoggi_compiler" "${user_bin}/seo"
    chmod +x "${user_bin}/seo"
    
    # Copy headers
    cp -r "${SEOGGI_SRC}/core/compiler/include/seoggi" "${SEOGGI_INCLUDE}/"
    
    # Copy examples
    mkdir -p "${install_dir}/examples"
    cp -r "${SEOGGI_SRC}/examples"/* "${install_dir}/examples/"
    
    # Cleanup build files
    info "Cleaning up build files..."
    cd "${SEOGGI_SRC}"
    rm -rf build
    
    success "Installation complete"
}

# Cleanup function
cleanup() {
    info "Cleaning up..."
    
    # Remove duplicate bootstrap files
    rm -f bootstrap/install.sh
    rm -f bootstrap/seoggi_bootstrap
    
    # Move compiler components to core
    if [[ -f bootstrap/compiler.py ]]; then
        mv bootstrap/compiler.py core/compiler/
    fi
    if [[ -f bootstrap/compiler.rs ]]; then
        mv bootstrap/compiler.rs core/compiler/
    fi
    if [[ -f bootstrap/seoc.c ]]; then
        mv bootstrap/seoc.c core/compiler/
    fi
    
    # Remove empty bootstrap directory
    rmdir bootstrap 2>/dev/null || true
    
    # Clean build artifacts
    rm -rf build/
    
    if [[ $? -ne 0 ]]; then
        error "Installation failed! Please check the error messages above."
        log_info
    fi
}

# Main installation process
main() {
    info "Starting Seoggi installation..."
    
    # Detect system
    detect_os
    info "Detected OS: $OS"
    
    if [ "$OS" == "linux" ]; then
        info "Detected Linux distribution: $DISTRO"
        info "Detected shell: $SHELL_TYPE"
    elif [ "$OS" == "macos" ]; then
        info "Detected macOS architecture: $ARCH"
    fi
    
    # Install dependencies
    info "Installing dependencies..."
    install_dependencies
    
    # Check dependencies
    if ! check_dependencies; then
        install_specific_deps "${MISSING_DEPS[@]}"
    fi
    
    # Setup development environment
    info "Setting up development environment..."
    setup_dev_environment "${SEOGGI_HOME}"
    
    # Install Seoggi components
    install_seoggi_components "${SEOGGI_HOME}"
    
    # Configure shell
    info "Configuring shell environment..."
    configure_shell "${SEOGGI_HOME}"
    
    # Cleanup
    cleanup
    
    success "Seoggi has been successfully installed!"
    success "Please restart your shell or run:"
    echo "  source ~/.bashrc  # for bash"
    echo "  source ~/.zshrc   # for zsh"
    echo "  source ~/.config/fish/config.fish  # for fish"
    
    info "To start using Seoggi, try:"
    echo "  seo version"
}

# Run main installation
main
