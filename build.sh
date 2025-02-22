#!/bin/bash

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT=$(pwd)
BUILD_DIR="${PROJECT_ROOT}/build"
BIN_DIR="${PROJECT_ROOT}/bin"
LIB_DIR="${PROJECT_ROOT}/lib"
INSTALL_PREFIX="/usr/local"

# Ensure we exit on any error
set -e

# Print status message
log() {
    echo -e "${BLUE}[BUILD]${NC} $1"
}

# Print error message and exit
error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Print warning message
warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Print success message
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Create required directories
setup_dirs() {
    log "Creating build directories..."
    mkdir -p "${BUILD_DIR}"
    mkdir -p "${BIN_DIR}"
    mkdir -p "${LIB_DIR}"
}

# Bootstrap phase - compile minimal compiler
bootstrap() {
    log "Starting bootstrap phase..."

    # Compile bootstrap compiler
    seoggi compile \
        "${PROJECT_ROOT}/src/bootstrap.seo" \
        -o "${BIN_DIR}/seoggi-bootstrap"

    success "Bootstrap compiler built successfully"
}

# Build phase - compile full compiler
build() {
    log "Building Seoggi compiler..."

    # Use bootstrap compiler to build full compiler
    if ! "${BIN_DIR}/seoggi-bootstrap" compile \
        "${PROJECT_ROOT}/src/compiler/main.seo" \
        -o "${BIN_DIR}/seoggi"; then
        error "Failed to build Seoggi compiler"
    fi

    success "Seoggi compiler built successfully"
}

# Install phase
install() {
    log "Installing Seoggi..."

    # Create install directories
    sudo mkdir -p "${INSTALL_PREFIX}/bin"
    sudo mkdir -p "${INSTALL_PREFIX}/lib/seoggi"
    sudo mkdir -p "${INSTALL_PREFIX}/include/seoggi"

    # Install binaries and libraries
    sudo cp "${BIN_DIR}/seoggi" "${INSTALL_PREFIX}/bin/"
    sudo cp "${LIB_DIR}"/* "${INSTALL_PREFIX}/lib/seoggi/"
    sudo cp -r "${PROJECT_ROOT}/src/std" "${INSTALL_PREFIX}/include/seoggi/"

    success "Seoggi installed successfully"
}

# Test phase
run_tests() {
    log "Running tests..."

    if ! "${BIN_DIR}/seoggi" test "${PROJECT_ROOT}/tests/**/*_test.seo"; then
        warn "Some tests failed"
    else
        success "All tests passed"
    fi
}

# Main build process
main() {
    setup_dirs
    bootstrap
    build
    run_tests

    if [ "$1" = "install" ]; then
        install
    fi

    success "Build completed successfully"
}

# Execute main with all arguments
main "$@"
