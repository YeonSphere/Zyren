#!/bin/bash

# Seoggi Build Script
# This script handles the build process for Seoggi

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$PROJECT_ROOT/build.log"
BUILD_DIR="$PROJECT_ROOT/build"
INSTALL_DIR="$PROJECT_ROOT/install"

# Compiler paths
SEOC="$PROJECT_ROOT/tools/compiler/seoc"
SEO="$PROJECT_ROOT/bin/seo"

# Function to log messages
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to print user messages
print() {
    echo "$1"
}

# Clean build artifacts
clean() {
    log "Cleaning build artifacts..."
    rm -rf "$BUILD_DIR"
    rm -f "$LOG_FILE"
    mkdir -p "$BUILD_DIR"
}

# Build the seoc compiler
build_compiler() {
    log "Building seoc compiler..."
    print "Building compiler..."
    
    mkdir -p "$(dirname "$SEOC")"
    gcc -o "$SEOC" "$PROJECT_ROOT/src/compiler/seoc.c" || {
        log "Failed to build seoc compiler"
        print "Failed to build compiler"
        exit 1
    }
    chmod +x "$SEOC"
    
    log "Compiler built successfully"
    print "Compiler built successfully"
}

# Build the core runtime
build_runtime() {
    log "Building runtime..."
    print "Building runtime..."
    
    "$SEOC" "$PROJECT_ROOT/src/runtime/runtime.seo" -o "$BUILD_DIR/libruntime.so" || {
        log "Failed to build runtime"
        print "Failed to build runtime"
        exit 1
    }
    
    log "Runtime built successfully"
    print "Runtime built successfully"
}

# Build the main executable
build_main() {
    log "Building main executable..."
    print "Building main executable..."
    
    "$SEOC" "$PROJECT_ROOT/src/core/main.seo" -o "$SEO" || {
        log "Failed to build main executable"
        print "Failed to build main executable"
        exit 1
    }
    chmod +x "$SEO"
    
    log "Main executable built successfully"
    print "Main executable built successfully"
}

# Install Seoggi
install() {
    log "Installing Seoggi..."
    print "Installing Seoggi..."
    
    mkdir -p "$INSTALL_DIR"/{bin,lib,include}
    
    # Install binaries
    cp "$SEO" "$INSTALL_DIR/bin/"
    cp "$SEOC" "$INSTALL_DIR/bin/"
    
    # Install libraries
    cp "$BUILD_DIR"/*.so "$INSTALL_DIR/lib/"
    
    # Install headers
    cp -r "$PROJECT_ROOT/include"/* "$INSTALL_DIR/include/"
    
    log "Installation complete"
    print "Installation complete"
}

# Main build process
main() {
    clean
    build_compiler
    build_runtime
    build_main
    install
}

# Execute main build process
main
