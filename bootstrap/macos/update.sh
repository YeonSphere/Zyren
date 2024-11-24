#!/bin/bash

# Seoggi Updater for macOS

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root (sudo ./update.sh)"
    exit 1
fi

echo "Seoggi Updater"

# Get current version
if [ ! -f "/usr/local/seoggi/version" ]; then
    echo "Error: Seoggi is not installed"
    exit 1
fi

current_version=$(cat /usr/local/seoggi/version)
echo "Current version: $current_version"
echo "Checking for updates..."

# Download latest version info
if ! curl -s -o /tmp/seoggi_version.txt https://seoggi.org/version.txt; then
    echo "Error: Failed to check for updates"
    exit 1
fi

latest_version=$(cat /tmp/seoggi_version.txt)

if [ "$current_version" = "$latest_version" ]; then
    echo "You are already running the latest version."
    exit 0
fi

echo "New version available: $latest_version"
echo "Downloading update..."

# Detect architecture
arch=$(uname -m)
if [ "$arch" = "arm64" ]; then
    installer_url="https://seoggi.org/download/macos/arm64/seo-install"
else
    installer_url="https://seoggi.org/download/macos/x86_64/seo-install"
fi

# Download new version
if ! curl -s -L -o /tmp/seo-install "$installer_url"; then
    echo "Error: Failed to download update"
    exit 1
fi

# Make installer executable
chmod +x /tmp/seo-install

# Run new installer
echo "Installing update..."
/tmp/seo-install --quiet

# Clear dyld cache for clean update
update_dyld_shared_cache -force

echo "Update completed successfully!"
echo "Please open a new terminal window to use the updated version."
