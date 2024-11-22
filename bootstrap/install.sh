#!/bin/sh
# Minimal bootstrap installer for Seoggi compiler
# This script compiles a minimal seoc compiler that can then build the full system

set -e  # Exit on error

# Default installation paths
BIN_DIR="$HOME/bin"
TEMP_DIR="/tmp/seoggi-bootstrap"
SEOC_URL="https://raw.githubusercontent.com/YeonSphere/Seoggi/main/bootstrap/seoc.c"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# Print with color
log() {
    printf "${BLUE}[bootstrap]${NC} %s\n" "$1"
}

error() {
    printf "${RED}[error]${NC} %s\n" "$1" >&2
    exit 1
}

success() {
    printf "${GREEN}[success]${NC} %s\n" "$1"
}

# Check system requirements
check_requirements() {
    log "Checking system requirements..."
    
    # Check for C compiler
    if ! command -v gcc >/dev/null 2>&1; then
        error "gcc not found. Please install GCC first."
    fi
    
    # Check for curl/wget
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        error "Neither curl nor wget found. Please install one of them."
    fi
    
    # Check for minimum memory (512MB)
    MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    if [ "$MEM_TOTAL" -lt 524288 ]; then
        error "Insufficient memory. Minimum 512MB required."
    fi
    
    # Check for disk space (100MB)
    DISK_SPACE=$(df -k "$HOME" | awk 'NR==2 {print $4}')
    if [ "$DISK_SPACE" -lt 102400 ]; then
        error "Insufficient disk space. Minimum 100MB required."
    fi
}

# Create necessary directories
create_directories() {
    log "Creating directories..."
    
    # Create bin directory if it doesn't exist
    mkdir -p "$BIN_DIR"
    
    # Create temporary directory
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    
    # Add bin directory to PATH if not already there
    if ! echo "$PATH" | grep -q "$BIN_DIR"; then
        log "Adding $BIN_DIR to PATH..."
        echo 'export PATH="$PATH:$HOME/bin"' >> "$HOME/.bashrc"
        echo 'export PATH="$PATH:$HOME/bin"' >> "$HOME/.profile"
    fi
}

# Download bootstrap compiler
download_compiler() {
    log "Downloading bootstrap compiler..."
    
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$SEOC_URL" -o "$TEMP_DIR/seoc.c"
    else
        wget -q "$SEOC_URL" -O "$TEMP_DIR/seoc.c"
    fi
}

# Compile bootstrap compiler
compile_compiler() {
    log "Compiling bootstrap compiler..."
    
    gcc -O3 -flto -march=native \
        -o "$BIN_DIR/seoc" \
        "$TEMP_DIR/seoc.c"
    
    chmod +x "$BIN_DIR/seoc"
}

# Cleanup temporary files
cleanup() {
    log "Cleaning up..."
    rm -rf "$TEMP_DIR"
}

# Main installation process
main() {
    log "Starting Seoggi bootstrap installation..."
    
    check_requirements
    create_directories
    download_compiler
    compile_compiler
    cleanup
    
    success "Seoggi bootstrap compiler installed successfully!"
    success "Please run 'source ~/.bashrc' or start a new terminal to use seoc"
    success "Visit https://yeonsphere.github.io/docs/getting-started for next steps"
}

# Run main installation
main
