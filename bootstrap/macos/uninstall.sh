#!/bin/bash

# Seoggi Uninstaller for macOS

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root (sudo ./uninstall.sh)"
    exit 1
fi

echo "Seoggi Uninstaller"

# Remove installation
echo "Removing Seoggi installation..."
rm -rf /usr/local/seoggi
rm -f /usr/local/bin/seo
rm -f /etc/paths.d/seoggi

# Clear dyld cache for clean uninstall
update_dyld_shared_cache -force

echo "Seoggi has been uninstalled successfully."
echo "Please open a new terminal window to complete the uninstallation."
