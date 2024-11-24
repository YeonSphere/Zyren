#!/bin/bash

# Build script for Linux bootstrap compiler

# Compile bootstrap.c to seo-install
gcc -O2 -o seo-install bootstrap.c

if [ $? -ne 0 ]; then
    echo "Error: Failed to compile bootstrap compiler"
    exit 1
fi

chmod +x seo-install
echo "Build successful! Run sudo ./seo-install to install Seoggi."
