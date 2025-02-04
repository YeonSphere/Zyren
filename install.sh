#!/bin/bash

# Installation script for Seoggi

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Define log file
LOG_FILE="install.log"

# Function to print messages in color
print_color() {
    echo -e "$1$2$RESET"
}

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Function to display the logo
display_logo() {
    echo -e "${CYAN}
 SSSS  EEEEE  OOO   GGGG  GGGG  I
 S     E     O   O G     G      I
  SSS  EEEE  O   O G  GG G  GG  I
     S E     O   O G   G G   G  I
 SSSS  EEEEE  OOO   GGGG  GGGG  I
${RESET}"
}

# Function to show a colorful loading animation
loading_animation() {
    local pid=$1
    local delay=0.5
    local spin='|/-\'
    local colors=($GREEN $YELLOW $BLUE $CYAN $MAGENTA)
    local i=0
    while [ -d /proc/$pid ]; do
        for c in "${colors[@]}"; do
            echo -ne "\r${c}${spin:i:1} Installing..."
            sleep $delay
            i=$(( (i + 1) % 4 ))
        done
    done
    echo -ne '\r'
}

# Function to build Seoggi
build_seoggi() {
    log_message "Starting build of Seoggi..."
    print_color $BLUE "Building Seoggi..."
    bash ./build.sh &
    loading_animation $!
    if [ $? -eq 0 ]; then
        log_message "Build completed successfully!"
        print_color $GREEN "Build completed successfully!"
    else
        log_message "Build failed! Installation aborted."
        print_color $RED "Build failed! Installation aborted."
        exit 1
    fi
}

# Function to install Seoggi
install_seoggi() {
    log_message "Starting installation of Seoggi..."
    print_color $BLUE "Installing Seoggi..."

    # Move the compiled binary to /usr/local/bin for global access
    if [ -f "./bin/interpreter" ]; then
        sudo mv ./bin/interpreter /usr/local/bin/seoggi
        log_message "Seoggi installed successfully!"
        print_color $GREEN "Seoggi installed successfully!"
    else
        log_message "Error: Seoggi binary not found!"
        print_color $RED "Error: Seoggi binary not found!"
    fi
}

# Start installation
log_message "Starting Seoggi installation..."
print_color $YELLOW "=== Seoggi Installation ==="
display_logo
build_seoggi
install_seoggi
log_message "Seoggi installation completed."
print_color $YELLOW "=========================="
