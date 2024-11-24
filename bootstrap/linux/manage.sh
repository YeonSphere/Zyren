#!/bin/bash

# Seoggi Management Tool for Linux
set -e

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Attempting to elevate privileges..."
    exec sudo "$0" "$@"
    exit $?
fi

# Set paths
SEO_HOME="/usr/local/seoggi"
SEO_BIN="$SEO_HOME/bin"
SEO_LIB="$SEO_HOME/lib"
SEO_CACHE="$SEO_HOME/cache"
SEO_TEMP="$SEO_HOME/temp"
SEO_BACKUP="$SEO_HOME/backup"
SEO_LOG="$SEO_HOME/seoggi.log"

# Logging functions
log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >> "$SEO_LOG"
}

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $*" >> "$SEO_LOG"
}

# Function to verify and repair binary
verify_binary() {
    local binary="$1"
    echo "Verifying $binary..."
    
    # Check if binary exists and is executable
    if [ ! -x "$binary" ]; then
        echo "WARNING: Binary $binary is not executable or missing"
        repair_file "$binary"
        return
    }
    
    # Check for dynamic library dependencies
    if ! ldd "$binary" &>/dev/null; then
        echo "WARNING: Binary $binary has missing dependencies"
        repair_file "$binary"
    fi
}

# Function to repair a file
repair_file() {
    local file="$1"
    local filename=$(basename "$file")
    echo "Attempting to repair $filename..."
    
    # Try to download fresh copy
    if curl -sSL "https://seoggi.org/binaries/$filename" -o "$file" 2>/dev/null; then
        chmod +x "$file"
        echo "Successfully repaired $filename"
        log_info "Repaired $filename"
    else
        echo "ERROR: Could not repair $filename. Manual intervention required."
        log_error "Failed to repair $filename"
    fi
}

# Function to check system requirements
check_system_requirements() {
    echo "Checking system requirements..."
    log_info "Starting system requirements check"
    
    # Check architecture
    arch=$(uname -m)
    if [ "$arch" != "x86_64" ] && [ "$arch" != "aarch64" ]; then
        echo "WARNING: Unsupported architecture: $arch"
        log_error "Unsupported architecture: $arch"
    fi
    
    # Check disk space
    available_space=$(df -BG "$SEO_HOME" | awk 'NR==2 {print $4}' | tr -d 'G')
    if [ "$available_space" -lt 5 ]; then
        echo "WARNING: Low disk space (less than 5GB available)"
        log_error "Low disk space: ${available_space}GB"
    fi
    
    # Check required packages
    required_packages="build-essential curl wget git"
    for pkg in $required_packages; do
        if ! dpkg -l "$pkg" &>/dev/null; then
            echo "Installing required package: $pkg"
            apt-get install -y "$pkg" >/dev/null 2>&1
        fi
    done
    
    # Check system limits
    max_files=$(ulimit -n)
    if [ "$max_files" -lt 1024 ]; then
        echo "WARNING: Low file descriptor limit"
        echo "fs.file-max = 65535" >> /etc/sysctl.conf
        sysctl -p >/dev/null
    fi
}

# Clean function
clean() {
    echo "Cleaning Seoggi environment..."
    log_info "Starting cleanup"
    
    # Clean temp directories with proper permissions
    for dir in "$SEO_CACHE" "$SEO_TEMP"; do
        if [ -d "$dir" ]; then
            find "$dir" -type f -delete 2>/dev/null || {
                echo "Retrying with elevated permissions..."
                chown -R root:root "$dir"
                find "$dir" -type f -delete
            }
        fi
    done
    
    # Recreate directories
    mkdir -p "$SEO_CACHE" "$SEO_TEMP"
    
    # Clean old logs (keep last 5)
    if [ -d "$SEO_HOME" ]; then
        cd "$SEO_HOME"
        ls -t *.log 2>/dev/null | tail -n +6 | xargs -r rm --
    fi
    
    echo "Environment cleaned successfully."
}

# Repair function
repair() {
    echo "Repairing Seoggi installation..."
    log_info "Starting repair"
    
    # Create directories if missing
    for dir in "$SEO_HOME" "$SEO_BIN" "$SEO_LIB" "$SEO_CACHE" "$SEO_TEMP" "$SEO_BACKUP"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            chown -R root:root "$dir"
            chmod -R 755 "$dir"
        fi
    done
    
    # Verify PATH configuration
    if ! grep -q "$SEO_BIN" /etc/profile.d/seoggi.sh 2>/dev/null; then
        echo "export PATH=\$PATH:$SEO_BIN" > /etc/profile.d/seoggi.sh
        chmod 644 /etc/profile.d/seoggi.sh
    fi
    
    # Verify binary integrity
    for binary in "$SEO_BIN"/*; do
        if [ -f "$binary" ]; then
            verify_binary "$binary"
        fi
    done
    
    # Fix permissions
    find "$SEO_HOME" -type f -exec chmod 644 {} \;
    find "$SEO_HOME" -type d -exec chmod 755 {} \;
    find "$SEO_BIN" -type f -exec chmod 755 {} \;
    
    echo "Repair completed successfully."
}

# Optimize function
optimize() {
    echo "Optimizing Seoggi installation..."
    log_info "Starting optimization"
    
    # Clean first
    clean
    
    # Strip debug symbols
    find "$SEO_BIN" -type f -executable -exec strip --strip-all {} \; 2>/dev/null
    
    # Optimize shared libraries
    ldconfig
    
    # Clear system cache
    sync
    echo 3 > /proc/sys/vm/drop_caches
    
    # Optimize PATH
    if [ -f /etc/profile.d/seoggi.sh ]; then
        sort -u -o /etc/profile.d/seoggi.sh /etc/profile.d/seoggi.sh
    fi
    
    echo "Optimization completed successfully."
}

# Backup function
backup() {
    local backup_path="${1:-$SEO_BACKUP/auto_$(date +%Y%m%d)}"
    echo "Creating backup at $backup_path..."
    log_info "Starting backup to $backup_path"
    
    mkdir -p "$backup_path"
    
    # Create versioned backup
    local backup_file="$backup_path/seoggi_backup_$(date +%Y%m%d_%H%M).tar.gz"
    if tar -czf "$backup_file" -C "$SEO_HOME" .; then
        echo "Backup completed successfully."
        log_info "Backup completed to $backup_file"
    else
        echo "ERROR: Backup failed"
        log_error "Backup failed to $backup_file"
    fi
}

# Restore function
restore() {
    local restore_file="$1"
    
    # If no file specified, try to find latest auto-backup
    if [ -z "$restore_file" ]; then
        echo "Searching for latest auto-backup..."
        restore_file=$(find "$SEO_BACKUP/auto_"* -name "seoggi_backup_*.tar.gz" -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)
        
        if [ -z "$restore_file" ]; then
            echo "No auto-backup found."
            return 1
        fi
    fi
    
    echo "Restoring from $restore_file..."
    log_info "Starting restore from $restore_file"
    
    # Stop running processes
    pkill -f seo || true
    
    # Backup current installation
    backup "$SEO_BACKUP/pre_restore_$(date +%Y%m%d)"
    
    # Restore files
    if tar -xzf "$restore_file" -C "$SEO_HOME"; then
        echo "Restore completed successfully."
        repair
        log_info "Restore completed from $restore_file"
    else
        echo "ERROR: Restore failed"
        log_error "Restore failed from $restore_file"
    fi
}

# Status function
status() {
    echo "Seoggi Installation Status"
    echo "-------------------------"
    log_info "Checking status"
    
    # Installation paths
    echo "Installation Paths:"
    echo "  Home: $SEO_HOME"
    echo "  Binary: $SEO_BIN"
    echo "  Library: $SEO_LIB"
    echo "  Cache: $SEO_CACHE"
    echo "  Temp: $SEO_TEMP"
    echo "  Backup: $SEO_BACKUP"
    
    # System information
    echo -e "\nSystem Information:"
    uname -a
    
    # PATH status
    echo -e "\nPATH Status:"
    if grep -q "$SEO_BIN" /etc/profile.d/seoggi.sh 2>/dev/null; then
        echo "PATH is correctly configured"
    else
        echo "WARNING: PATH is not correctly configured"
        log_error "PATH misconfiguration detected"
    fi
    
    # Storage status
    echo -e "\nStorage Status:"
    du -sh "$SEO_HOME" 2>/dev/null | cut -f1 | xargs -I{} echo "Installation size: {}"
    df -h "$SEO_HOME" | awk 'NR==2 {print "Available disk space:", $4}'
    
    # Process status
    echo -e "\nProcess Status:"
    pgrep -l seo || echo "No Seoggi processes running"
    
    # Resource usage
    echo -e "\nResource Usage:"
    free -h | grep "Mem:" | awk '{print "Memory Usage:", $3, "/", $2}'
    uptime | awk '{print "Load Average:", $(NF-2), $(NF-1), $NF}'
}

# Diagnose function
diagnose() {
    echo "Running system diagnostics..."
    log_info "Starting system diagnostics"
    
    # Check system requirements
    check_system_requirements
    
    # Check file integrity
    echo "Checking file integrity..."
    for binary in "$SEO_BIN"/*; do
        if [ -f "$binary" ]; then
            verify_binary "$binary"
        fi
    done
    
    # Check system resources
    echo "Checking system resources..."
    free -h
    uptime
    
    # Check system logs
    echo "Checking system logs..."
    tail -n 50 "$SEO_LOG" 2>/dev/null || echo "No logs found"
    
    echo "Diagnostics completed. Check $SEO_LOG for details."
}

# Main script
case "$1" in
    clean)
        clean
        ;;
    repair)
        repair
        ;;
    optimize)
        optimize
        ;;
    backup)
        backup "$2"
        ;;
    restore)
        restore "$2"
        ;;
    status)
        status
        ;;
    diagnose)
        diagnose
        ;;
    *)
        echo "Seoggi Management Tool"
        echo "Usage: $0 [command] [options]"
        echo
        echo "Commands:"
        echo "  clean     - Clean temporary files and cache"
        echo "  repair    - Repair installation and environment"
        echo "  optimize  - Optimize installation and performance"
        echo "  backup    - Create backup (optional: specify path)"
        echo "  restore   - Restore from backup (optional: specify path)"
        echo "  status    - Show installation status"
        echo "  diagnose  - Run system diagnostics"
        echo
        echo "Examples:"
        echo "  $0 clean"
        echo "  $0 backup /backup/seoggi"
        echo "  $0 restore /backup/seoggi/backup.tar.gz"
        echo "  $0 diagnose"
        ;;
esac
