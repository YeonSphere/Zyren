#!/usr/bin/env bash

# Seoggi Programming Language Installation Script
# This script detects the system type and configures the environment accordingly

set -e

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
    
    # Detect shell
    SHELL_TYPE=$(basename "$SHELL")
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
    
    case "$SHELL_TYPE" in
        "bash")
            shell_rc="$HOME/.bashrc"
            ;;
        "zsh")
            shell_rc="$HOME/.zshrc"
            ;;
        "fish")
            shell_rc="$HOME/.config/fish/config.fish"
            ;;
        *)
            warning "Unsupported shell: $SHELL_TYPE. Please add Seoggi to your PATH manually."
            return
            ;;
    esac
    
    # Create shell configuration
    if [[ "$SHELL_TYPE" == "fish" ]]; then
        echo "set -gx PATH \$PATH $install_dir/bin" >> "$shell_rc"
        echo "set -gx SEOGGI_HOME $install_dir" >> "$shell_rc"
    else
        echo "export PATH=\$PATH:$install_dir/bin" >> "$shell_rc"
        echo "export SEOGGI_HOME=$install_dir" >> "$shell_rc"
    fi
    
    success "Added Seoggi to $shell_rc"
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
    case "$DISTRO" in
        "ubuntu"|"debian")
            sudo apt-get update
            sudo apt-get install -y build-essential cmake llvm clang libclang-dev \
                python3 python3-pip git curl pkg-config
            ;;
        "fedora"|"rhel"|"centos")
            sudo dnf install -y gcc gcc-c++ cmake llvm clang clang-devel \
                python3 python3-pip git curl pkgconfig
            ;;
        "arch"|"manjaro")
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm base-devel cmake llvm clang \
                python python-pip git curl pkg-config
            ;;
        "opensuse"|"sles")
            sudo zypper install -y gcc gcc-c++ cmake llvm clang clang-devel \
                python3 python3-pip git curl pkg-config
            ;;
        *)
            warning "Unknown Linux distribution. Please install required dependencies manually."
            ;;
    esac
}

# Install macOS dependencies
install_macos_dependencies() {
    # Install Homebrew if not present
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install dependencies
    brew install cmake llvm python git curl pkg-config
    
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
        git curl pkg-config
}

# Setup development environment
setup_dev_environment() {
    local install_dir="$1"
    
    # Create directory structure
    mkdir -p "$install_dir"/{bin,lib,include,share/doc}
    
    # Clone repository if not already present
    if [ ! -d "$install_dir/src" ]; then
        git clone https://github.com/YeonSphere/Seoggi.git "$install_dir/src"
    fi
    
    # Build and install
    (
        cd "$install_dir/src"
        mkdir -p build && cd build
        cmake ..
        make -j$(nproc)
        make install
    )
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
    
    # Set installation directory
    INSTALL_DIR="${SEOGGI_HOME:-$HOME/.seoggi}"
    
    # Install dependencies
    info "Installing dependencies..."
    install_dependencies
    
    # Setup development environment
    info "Setting up development environment..."
    setup_dev_environment "$INSTALL_DIR"
    
    # Configure shell
    info "Configuring shell environment..."
    configure_shell "$INSTALL_DIR"
    
    # Create symbolic links
    if [ "$OS" != "windows" ]; then
        sudo ln -sf "$INSTALL_DIR/bin/seoggi" /usr/local/bin/seoggi
    fi
    
    success "Seoggi has been successfully installed!"
    success "Please restart your shell or run 'source $shell_rc' to use Seoggi."
    
    # Additional setup instructions
    case "$OS" in
        "linux")
            info "For GPU support, please ensure you have the appropriate drivers installed:"
            info "- NVIDIA: nvidia-driver and nvidia-cuda-toolkit"
            info "- AMD: rocm-opencl-runtime"
            ;;
        "macos")
            if [ "$ARCH" == "arm64" ]; then
                info "For optimal performance on Apple Silicon, Metal support is enabled by default."
            else
                info "For GPU support, please ensure you have the appropriate drivers installed."
            fi
            ;;
        "windows")
            info "For GPU support, please ensure you have:"
            info "- NVIDIA: CUDA Toolkit and appropriate drivers"
            info "- AMD: ROCm for Windows or OpenCL runtime"
            info "- DirectX 12 runtime"
            ;;
    esac
}

# Run main installation
main
