#!/bin/bash

# Seoggi Uninstaller for Linux

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
rm -f /etc/profile.d/seoggi.sh

# Remove from PATH
source /etc/profile

echo "Seoggi has been uninstalled successfully."
echo "Please log out and back in to complete the uninstallation."
