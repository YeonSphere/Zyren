#!/bin/bash

# Build script for macOS bootstrap compiler

# Build for current architecture (will be either x86_64 or arm64)
clang -O2 -o seo-install bootstrap.c

if [ $? -ne 0 ]; then
    echo "Error: Failed to compile bootstrap compiler"
    exit 1
fi

# If on Apple Silicon, also build for Intel
if [ "$(uname -m)" = "arm64" ]; then
    echo "Building Intel (x86_64) version..."
    clang -O2 -target x86_64-apple-macos11 -o seo-install-x86_64 bootstrap.c
fi

chmod +x seo-install*
echo "Build successful! Run sudo ./seo-install to install Seoggi."
