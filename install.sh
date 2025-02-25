#!/usr/bin/env zsh

# Zyren Install Script

# Install Zyren
echo "Installing Zyren..."

# Create build directory if it doesn't exist
mkdir -p Zyren/build

# Build Zyren
echo "Building Zyren..."
zsh Zyren/build.sh

# Copy Zyren executable to /usr/local/bin
echo "Copying Zyren executable to /usr/local/bin..."
sudo cp Zyren/build/zyren /usr/local/bin/zyren

# Make Zyren executable
echo "Making Zyren executable..."
sudo chmod +x /usr/local/bin/zyren

echo "Zyren installation complete!"
