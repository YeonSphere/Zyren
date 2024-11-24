#!/bin/bash

# Colors and symbols for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Special characters
CHECK="✓"
CROSS="✗"
ARROW="→"
GEAR="⚙"
SPARKLE="✨"
QUANTUM="⚛"
ROCKET="🚀"
CLEAN="🧹"
BUILD="🔨"
TEST="🔬"
INSTALL="📦"

# Animation settings
FRAMES=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
FRAME_DELAY=0.08
STEP_DELAY=0.5

# Get script directory for absolute paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"

# Banner colors
BANNER_COLOR="${MAGENTA}${BOLD}"
TITLE_COLOR="${CYAN}"
VERSION_COLOR="${CYAN}${DIM}"

# Success message colors
SUCCESS_COLOR="${GREEN}"
HEADER_COLOR="${CYAN}"
STEP_COLOR="${YELLOW}${BOLD}"
NOTE_COLOR="${BLUE}"
LINK_COLOR="${CYAN}"

# Cleanup old logs first
cleanup_logs() {
    print_status "Cleaning up old logs" "clean"
    
    # Create logs directory if it doesn't exist
    mkdir -p "$LOG_DIR"
    
    # Remove all seoggi log files in logs directory
    rm -f "$LOG_DIR"/*
}

# Cleanup old files
cleanup_old_files() {
    # Remove old build artifacts
    rm -rf build/ >/dev/null 2>&1
    
    # Remove old binary
    rm -f "$HOME/bin/seo" >/dev/null 2>&1
    
    # Clean up temporary files
    find . -name "*.tmp" -type f -delete >/dev/null 2>&1
    find . -name "*.o" -type f -delete >/dev/null 2>&1
    find . -name "*.a" -type f -delete >/dev/null 2>&1
    find . -name "*.so" -type f -delete >/dev/null 2>&1
    find . -name ".DS_Store" -type f -delete >/dev/null 2>&1
}

# Initialize logging
setup_logging() {
    # Clean up old logs before starting
    cleanup_logs
    
    # Setup logging with date only
    LOG_FILE="$LOG_DIR/seoggi_$(date +%Y%m%d).log"
    
    # Save original stdout and stderr
    exec 3>&1 4>&2
    
    # Redirect stdout and stderr to log file
    exec 1>>"$LOG_FILE" 2>&1
    
    # Log system information
    printf "=== Seoggi Installation Log ===\n" > "$LOG_FILE"
    printf "Date: %s\n" "$(date)" >> "$LOG_FILE"
    printf "System: %s\n" "$(uname -a)" >> "$LOG_FILE"
    printf "===========================\n" >> "$LOG_FILE"
}

# Cleanup function to restore file descriptors
cleanup_descriptors() {
    # Restore original stdout and stderr
    [[ -n "${3:-}" ]] && exec 3>&-
    [[ -n "${4:-}" ]] && exec 4>&-
}

# Reset terminal on exit or interrupt
cleanup_terminal() {
    # Reset colors and cursor
    printf "\033[0m"  # Reset all attributes
    printf "\033[?25h" # Show cursor
    printf "\n"  # Ensure we're on a new line
}

# Function to cleanup and exit
cleanup_and_exit() {
    local exit_code=$1
    local show_message=${2:-false}
    
    # Remove the EXIT trap to prevent recursive calls
    trap - EXIT
    
    # Cleanup based on exit type
    if [ "$show_message" = true ]; then
        print_status "Cleaning up after error" "clean"
        cleanup_descriptors
        cleanup_terminal
        print_status "Cleanup complete" "success"
    else
        cleanup_descriptors >/dev/null 2>&1
        cleanup_terminal >/dev/null 2>&1
    fi
    
    exit "$exit_code"
}

# Handle signals
handle_error() {
    cleanup_and_exit 1 true
}

# Add cleanup to relevant signals
trap 'handle_error' INT TERM HUP

# Hide cursor during installation
hide_cursor() {
    printf "\033[?25l"
}

# Show cursor
show_cursor() {
    printf "\033[?25h"
}

# Function to show spinner animation
show_spinner() {
    local pid=$1
    local message=$2
    local i=0
    local fd=3
    
    # Check if fd 3 is available
    if ! { : >&3; } 2>/dev/null; then
        fd=1  # Fallback to stdout
    fi
    
    hide_cursor
    while kill -0 $pid 2>/dev/null; do
        printf "\r${BLUE}${FRAMES[i]} ${message}...${NC}" >&$fd
        i=$(((i + 1) % ${#FRAMES[@]}))
        sleep $FRAME_DELAY
    done
    
    wait $pid
    local status=$?
    printf "\r" >&$fd
    show_cursor
    return $status
}

# Function to show progress bar
show_progress() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    local bar=""
    local space=""
    local fd=3
    
    # Check if fd 3 is available
    if ! { : >&3; } 2>/dev/null; then
        fd=1  # Fallback to stdout
    fi
    
    hide_cursor
    # Smoother progress bar with gradient
    for ((i = 0; i < filled; i++)); do
        if [ $i -lt $((filled / 3)) ]; then
            bar="${bar}▰"
        else
            bar="${bar}▰"
        fi
    done
    for ((i = 0; i < empty; i++)); do
        space="${space}▱"
    done
    
    printf "\r${BLUE}[${bar}${space}] %d%%${NC}" $percentage >&$fd
    
    if [ "$current" -eq "$total" ]; then
        show_cursor
    fi
}

# Function to print status messages with animation
print_status() {
    local message=$1
    local status=${2:-"start"}
    local fd=3
    
    # Check if fd 3 is available
    if ! { : >&3; } 2>/dev/null; then
        fd=1  # Fallback to stdout
    fi
    
    case $status in
        "start")
            if [ "$message" = "Cleaning up old installation" ]; then
                printf "\n${CLEAN} %s\n" "$message" >&$fd
            else
                printf "\n${GEAR} %s\n" "$message" >&$fd
            fi
            ;;
        "success")
            printf "\r${GREEN}${CHECK} %s${NC}\n" "$message" >&$fd
            ;;
        "error")
            printf "\r${RED}${CROSS} %s${NC}\n" "$message" >&$fd
            ;;
        "clean")
            printf "\r${CLEAN} %s\n" "$message" >&$fd
            ;;
        *)
            printf "\r${ARROW} %s\n" "$message" >&$fd
            ;;
    esac
}

# Detect current shell
detect_shell() {
    # First try to detect parent shell
    if [ -n "$SHELL" ]; then
        basename "$SHELL"
    else
        # Fallback to checking process
        local ppid=$(ps -p $$ -o ppid=)
        local parent_process=$(ps -p $ppid -o comm=)
        basename "$parent_process"
    fi
}

# Check if a package is installed
is_package_installed() {
    local pkg=$1
    local pkg_manager=$2
    
    case $pkg_manager in
        "apt")
            dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"
            ;;
        "dnf"|"yum")
            rpm -q "$pkg" >/dev/null 2>&1
            ;;
        "pacman")
            pacman -Qi "$pkg" >/dev/null 2>&1
            ;;
        "zypper")
            rpm -q "$pkg" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
    return $?
}

# Detect package manager
detect_package_manager() {
    print_status "Detecting package manager" "info"
    
    if command -v apt-get &> /dev/null; then
        print_status "Found apt package manager" "success"
        echo "apt"
    elif command -v dnf &> /dev/null; then
        print_status "Found dnf package manager" "success"
        echo "dnf"
    elif command -v yum &> /dev/null; then
        print_status "Found yum package manager" "success"
        echo "yum"
    elif command -v pacman &> /dev/null; then
        print_status "Found pacman package manager" "success"
        echo "pacman"
    elif command -v zypper &> /dev/null; then
        print_status "Found zypper package manager" "success"
        echo "zypper"
    else
        print_status "No supported package manager found (apt, dnf, yum, pacman, or zypper)" "error"
        echo "unknown"
    fi
}

# Package names for different package managers
declare -A PKG_NAMES=(
    ["apt"]="build-essential cmake ninja-build llvm-dev libboost-all-dev libssl-dev z3 libedit-dev libxml2-dev libcurl4-openssl-dev libncurses-dev zlib1g-dev"
    ["dnf"]="gcc gcc-c++ cmake ninja-build llvm-devel boost-devel openssl-devel z3 libedit-devel libxml2-devel libcurl-devel ncurses-devel zlib-devel"
    ["yum"]="gcc gcc-c++ cmake ninja-build llvm-devel boost-devel openssl-devel z3 libedit-devel libxml2-devel libcurl-devel ncurses-devel zlib-devel"
    ["pacman"]="base-devel cmake ninja llvm boost openssl z3 libedit libxml2 curl ncurses zlib"
    ["zypper"]="gcc gcc-c++ cmake ninja llvm-devel boost-devel libopenssl-devel z3 libedit-devel libxml2-devel libcurl-devel ncurses-devel zlib-devel"
)

# Install missing packages
install_missing_packages() {
    local pkg_manager=$1
    local packages=${PKG_NAMES[$pkg_manager]}
    local missing_packages=()
    
    if [ -z "$packages" ]; then
        print_status "No package list defined for $pkg_manager" "error"
        return 1
    fi
    
    # Check which packages need to be installed
    print_status "Checking installed packages" "info"
    for pkg in $packages; do
        if ! is_package_installed "$pkg" "$pkg_manager"; then
            missing_packages+=("$pkg")
        fi
    done
    
    # If no packages need to be installed, we're done
    if [ ${#missing_packages[@]} -eq 0 ]; then
        print_status "All required packages are already installed" "success"
        return 0
    fi
    
    # First check for sudo access without starting the animation
    print_status "Requesting administrator privileges" "info"
    if ! sudo -v; then
        print_status "Administrator privileges required" "error"
        return 1
    fi
    
    print_status "Installing missing packages" "start"
    
    case $pkg_manager in
        "apt")
            # Update package list first
            sudo apt-get update >/dev/null 2>&1
            local total_pkgs=${#missing_packages[@]}
            local current=0
            for pkg in "${missing_packages[@]}"; do
                current=$((current + 1))
                print_status "Installing: $pkg" "info"
                show_progress $current $total_pkgs
                sudo apt-get install -y "$pkg" >>"$LOG_FILE" 2>&1
            done
            ;;
        "dnf"|"yum")
            local total_pkgs=${#missing_packages[@]}
            local current=0
            for pkg in "${missing_packages[@]}"; do
                current=$((current + 1))
                print_status "Installing: $pkg" "info"
                show_progress $current $total_pkgs
                sudo $pkg_manager install -y "$pkg" >>"$LOG_FILE" 2>&1
            done
            ;;
        "pacman")
            # Update package database first
            sudo pacman -Sy >/dev/null 2>&1
            local total_pkgs=${#missing_packages[@]}
            local current=0
            for pkg in "${missing_packages[@]}"; do
                current=$((current + 1))
                print_status "Installing: $pkg" "info"
                show_progress $current $total_pkgs
                sudo pacman -S --noconfirm "$pkg" >>"$LOG_FILE" 2>&1
            done
            ;;
        "zypper")
            local total_pkgs=${#missing_packages[@]}
            local current=0
            for pkg in "${missing_packages[@]}"; do
                current=$((current + 1))
                print_status "Installing: $pkg" "info"
                show_progress $current $total_pkgs
                sudo zypper install -y "$pkg" >>"$LOG_FILE" 2>&1
            done
            ;;
        *)
            print_status "Unsupported package manager: $pkg_manager" "error"
            return 1
            ;;
    esac
    
    printf "\n" >&3 # New line after progress bar
    print_status "Package installation complete" "success"
    return 0
}

# Install binary
install_binary() {
    print_status "Installing Seoggi binary" "start"
    
    # Create $HOME/bin if it doesn't exist
    if [ ! -d "$HOME/bin" ]; then
        print_status "Creating $HOME/bin directory" "info"
        mkdir -p "$HOME/bin"
        chmod 755 "$HOME/bin"
    fi
    
    # Check if source binary exists and is readable
    if [ ! -f "./tools/seo" ]; then
        print_status "Source binary not found at ./tools/seo" "error"
        return 1
    fi
    
    if [ ! -r "./tools/seo" ]; then
        print_status "Source binary not readable" "error"
        return 1
    fi
    
    # Debug info
    ls -l "./tools/seo" >> "$LOG_FILE" 2>&1
    
    # Simply replace or create the binary in $HOME/bin
    print_status "Installing binary to $HOME/bin/seo" "info"
    cp -v "./tools/seo" "$HOME/bin/seo" >> "$LOG_FILE" 2>&1 || {
        print_status "Failed to copy binary (see log for details)" "error"
        return 1
    }
    
    # Ensure binary is executable
    chmod 755 "$HOME/bin/seo"
    
    print_status "Binary installation complete" "success"
    return 0
}

# Verify installation
verify_installation() {
    print_status "Verifying installation" "start"
    
    # Only check if binary exists in $HOME/bin and is executable
    if [ ! -f "$HOME/bin/seo" ]; then
        print_status "Binary not found at $HOME/bin/seo" "error"
        return 1
    fi
    
    if [ ! -x "$HOME/bin/seo" ]; then
        print_status "Binary is not executable" "error"
        chmod 755 "$HOME/bin/seo"
    fi
    
    # Verify PATH includes $HOME/bin
    if ! echo "$PATH" | grep -q "$HOME/bin"; then
        print_status "PATH not properly set" "error"
        return 1
    fi
    
    print_status "Installation verified" "success"
    return 0
}

# Configure shell environment
configure_shell() {
    local shell_name=$(detect_shell)
    local shell_rc=""
    local source_cmd=""
    local path_cmd=""
    
    print_status "Configuring shell environment" "start"
    
    case "$shell_name" in
        "bash"|"sh")
            shell_rc="$HOME/.bashrc"
            source_cmd="source ~/.bashrc"
            path_cmd='export PATH="$HOME/bin:$PATH"'
            ;;
        "zsh")
            shell_rc="$HOME/.zshrc"
            source_cmd="source ~/.zshrc"
            path_cmd='export PATH="$HOME/bin:$PATH"'
            ;;
        "fish")
            shell_rc="$HOME/.config/fish/config.fish"
            source_cmd="source ~/.config/fish/config.fish"
            path_cmd='set PATH $HOME/bin $PATH'
            ;;
        *)
            # Fallback to bash if shell detection fails
            shell_rc="$HOME/.bashrc"
            source_cmd="source ~/.bashrc"
            path_cmd='export PATH="$HOME/bin:$PATH"'
            print_status "Using default bash configuration" "info"
            ;;
    esac
    
    # Create config directory if it doesn't exist
    mkdir -p "$(dirname "$shell_rc")"
    
    # Remove old Seoggi PATH configuration if it exists
    if [ -f "$shell_rc" ]; then
        sed -i '/# Seoggi Environment/d' "$shell_rc"
        sed -i '/PATH.*\$HOME\/bin/d' "$shell_rc"
    fi
    
    # Add new Seoggi PATH configuration
    printf "\n" >> "$shell_rc"
    printf "# Seoggi Environment\n" >> "$shell_rc"
    printf "%s\n" "$path_cmd" >> "$shell_rc"
    
    # Export PATH immediately for current session
    eval "$path_cmd"
    
    print_status "Shell environment configured" "success"
    sleep $STEP_DELAY
}

# Print welcome banner with animation
print_banner() {
    clear >&3
    local fd=3
    
    # Check if fd 3 is available
    if ! { : >&3; } 2>/dev/null; then
        fd=1  # Fallback to stdout
    fi
    
    # Print banner with magenta color
    printf "${BANNER_COLOR}" >&$fd
    local banner=(
        "███████╗███████╗ ██████╗  ██████╗  ██████╗ ██╗"
        "██╔════╝██╔════╝██╔═══██╗██╔════╝ ██╔════╝ ██║"
        "███████╗█████╗  ██║   ██║██║  ███╗██║  ███╗██║"
        "╚════██║██╔══╝  ██║   ██║██║   ██║██║   ██║██║"
        "███████║███████╗╚██████╔╝╚██████╔╝╚██████╔╝██║"
        "╚══════╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝"
    )
    
    for ((i = 0; i < ${#banner[@]}; i++)); do
        printf "%s\n" "${banner[$i]}" >&$fd
        sleep 0.1
    done
    
    # Reset color before quantum text
    printf "${NC}" >&$fd
    
    # Print quantum text with cyan color
    printf "\n${TITLE_COLOR}${QUANTUM} Quantum Programming Language Installation ${QUANTUM}${NC}\n" >&$fd
    
    # Print version with dimmed cyan
    printf "${VERSION_COLOR}Version 0.1.0${NC}\n\n" >&$fd
    
    sleep 0.5
}

# Final success message with shell-specific instructions
print_success_message() {
    local shell_config="$1"
    local fd=3
    
    # Check if fd 3 is available
    if ! { : >&3; } 2>/dev/null; then
        fd=1  # Fallback to stdout
    fi
    
    # Print success header with sparkles
    printf "\n${SUCCESS_COLOR}${SPARKLE} Installation Complete! ${SPARKLE}${NC}\n" >&$fd
    
    # Print getting started header
    printf "${HEADER_COLOR}${ROCKET} To start using Seoggi:${NC}\n" >&$fd
    
    # Print steps with bold numbering
    printf "${STEP_COLOR}  1. ${BOLD}source %s${NC}\n" "$shell_config" >&$fd
    printf "${STEP_COLOR}  2. ${BOLD}seo help${NC}\n\n" >&$fd
    
    # Print note about terminal restart
    printf "${NOTE_COLOR}Note: If updating from a previous version, you may need to restart your terminal.${NC}\n" >&$fd
    
    # Print issue reporting link
    printf "${HEADER_COLOR}${ARROW} Report issues:${NC} https://github.com/YeonSphere/Seoggi/issues\n\n" >&$fd
}

# Main installation process
main() {
    # Hide cursor during installation
    hide_cursor
    
    # Initial cleanup with messages
    print_status "Cleaning up old installation" "clean"
    cleanup_logs
    cleanup_old_files
    print_status "Cleanup complete" "success"
    
    # Setup new logging
    setup_logging
    
    # Show welcome banner
    print_banner
    
    # Check dependencies with spinner
    print_status "Checking system requirements" "start"
    PKG_MANAGER=$(detect_package_manager)
    if [ "$PKG_MANAGER" = "unknown" ]; then
        print_status "Unsupported package manager" "error"
        printf "%sPlease install required packages manually:%s\n" "${RED}" "${NC}" >&3
        printf "%s  - cmake%s" "${YELLOW}" >&3
        printf "%s  - ninja-build%s" "${YELLOW}" >&3
        printf "%s  - llvm%s" "${YELLOW}" >&3
        printf "%s  - boost%s" "${YELLOW}" >&3
        printf "%s  - openssl%s" "${YELLOW}" >&3
        printf "%s  - z3%s" "${YELLOW}" >&3
        printf "%s  - libedit%s" "${YELLOW}" >&3
        printf "%s  - libxml2%s" "${YELLOW}" >&3
        printf "%s  - libcurl%s" "${YELLOW}" >&3
        printf "%s  - ncurses%s" "${YELLOW}" >&3
        printf "%s  - zlib%s\n" "${YELLOW}" "${NC}" >&3
        exit 1
    fi
    
    # Install packages
    if ! install_missing_packages "$PKG_MANAGER"; then
        print_status "Failed to install required packages" "error"
        printf "%sCheck %s for details%s\n" "${RED}" "$LOG_FILE" "${NC}" >&3
        exit 1
    fi
    
    # Configure build system
    print_status "Setting up build environment" "start"
    rm -rf build
    mkdir -p build
    cd build || exit 1
    
    # Configure with animation
    print_status "Configuring build system" "config"
    (cmake .. -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$HOME" \
        -DENABLE_AI=ON) &  # Enable AI components
    show_spinner $! "Configuring build system"
    
    # Build with animation
    print_status "Building Seoggi" "build"
    (ninja -v) &  # Added -v for verbose output
    show_spinner $! "Compiling source files"
    
    # Test with animation
    print_status "Running tests" "test"
    (ninja test) &
    show_spinner $! "Executing test suite"
    
    # Install with animation
    print_status "Installing Seoggi" "install"
    (ninja install) &
    show_spinner $! "Installing components"
    
    # Return to original directory
    cd .. || exit 1
    
    # Final setup
    print_status "Finalizing installation" "start"
    install_binary
    
    # Configure shell environment
    configure_shell
    
    # Verify installation
    if ! verify_installation; then
        print_status "Installation verification failed" "error"
        printf "%sPlease check the log file: %s%s\n" "${RED}" "$LOG_FILE" "${NC}" >&3
        exit 1
    fi
    
    # Show success message with shell-specific instructions
    local shell_name=$(detect_shell)
    local shell_rc=""
    local source_cmd=""
    
    case "$shell_name" in
        "bash"|"sh")
            source_cmd="~/.bashrc"
            ;;
        "zsh")
            source_cmd="~/.zshrc"
            ;;
        "fish")
            source_cmd="~/.config/fish/config.fish"
            ;;
        *)
            source_cmd="~/.bashrc"
            ;;
    esac
    
    print_success_message "$source_cmd"
    
    # Clean exit without messages
    cleanup_and_exit 0 false
}

# Run main function
main "$@"
