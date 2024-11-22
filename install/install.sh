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

# Check if a package is installed
check_package() {
    local pkg="$1"
    case "$DISTRO" in
        "arch"|"cachyos"|"manjaro")
            pacman -Qi "$pkg" &>/dev/null
            ;;
        "debian"|"ubuntu")
            dpkg -l "$pkg" &>/dev/null
            ;;
        "fedora")
            rpm -q "$pkg" &>/dev/null
            ;;
        "opensuse-leap"|"opensuse-tumbleweed")
            rpm -q "$pkg" &>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
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
    esac
}

# Install Linux dependencies
install_linux_dependencies() {
    local missing_pkgs=()
    local pkg_manager
    local install_cmd
    local pkgs
    
    # Define package names for different distributions
    case "$DISTRO" in
        "arch"|"cachyos"|"manjaro")
            pkg_manager="pacman"
            install_cmd="pacman -S --noconfirm"
            pkgs=(
                "llvm"
                "clang"
                "z3"
                "cmake"
                "git"
                "libedit"
                "gcc"
                "make"
            )
            ;;
        "debian"|"ubuntu")
            pkg_manager="apt"
            install_cmd="apt-get install -y"
            pkgs=(
                "llvm"
                "clang"
                "z3"
                "cmake"
                "git"
                "libedit-dev"
                "gcc"
                "make"
            )
            ;;
        "fedora")
            pkg_manager="dnf"
            install_cmd="dnf install -y"
            pkgs=(
                "llvm"
                "clang"
                "z3"
                "cmake"
                "git"
                "libedit-devel"
                "gcc"
                "make"
            )
            ;;
        "opensuse-leap"|"opensuse-tumbleweed")
            pkg_manager="zypper"
            install_cmd="zypper install -y"
            pkgs=(
                "llvm"
                "clang"
                "z3"
                "cmake"
                "git"
                "libedit-devel"
                "gcc"
                "make"
            )
            ;;
        *)
            error "Unsupported Linux distribution: $DISTRO"
            exit 1
            ;;
    esac
    
    # Check for missing packages
    info "Checking for required packages..."
    for pkg in "${pkgs[@]}"; do
        if ! check_package "$pkg"; then
            missing_pkgs+=("$pkg")
        fi
    done
    
    # Install missing packages if any
    if [ ${#missing_pkgs[@]} -eq 0 ]; then
        success "All required packages are already installed"
    else
        info "Installing missing packages: ${missing_pkgs[*]}"
        case "$DISTRO" in
            "arch"|"cachyos"|"manjaro")
                sudo $install_cmd "${missing_pkgs[@]}" || error "Failed to install packages"
                ;;
            "debian"|"ubuntu")
                sudo apt-get update
                sudo $install_cmd "${missing_pkgs[@]}" || error "Failed to install packages"
                ;;
            "fedora")
                sudo $install_cmd "${missing_pkgs[@]}" || error "Failed to install packages"
                ;;
            "opensuse-leap"|"opensuse-tumbleweed")
                sudo $install_cmd "${missing_pkgs[@]}" || error "Failed to install packages"
                ;;
        esac
        success "Successfully installed missing packages"
    fi
    
    # Verify minimum versions
    info "Checking package versions..."
    local cmake_version=$(cmake --version | head -n1 | cut -d' ' -f3)
    local llvm_version=$(llvm-config --version)
    local z3_version=$(z3 --version | cut -d' ' -f3)
    
    if ! printf '%s\n%s\n' "3.10" "$cmake_version" | sort -V -C; then
        error "CMake version $cmake_version is too old. Minimum required: 3.10"
        exit 1
    fi
    
    if ! printf '%s\n%s\n' "18.1.8" "$llvm_version" | sort -V -C; then
        error "LLVM version $llvm_version is too old. Minimum required: 18.1.8"
        exit 1
    fi
    
    if ! printf '%s\n%s\n' "4.8.0" "$z3_version" | sort -V -C; then
        error "Z3 version $z3_version is too old. Minimum required: 4.8.0"
        exit 1
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
    
    # Setup development environment
    info "Setting up development environment..."
    setup_dev_environment "${SEOGGI_HOME}"
    
    # Configure shell
    info "Configuring shell environment..."
    configure_shell "${SEOGGI_HOME}"
    
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
