#!/bin/bash

# Seoggi Language Setup Script
SEOGGI_VERSION="0.1.0"
SEOGGI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux" ;;
        Darwin*)    echo "macos" ;;
        CYGWIN*)    echo "windows" ;;
        MINGW*)     echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

# Check dependencies
check_dependencies() {
    local os=$1
    local missing_deps=()

    # Common dependencies
    for cmd in bash awk sed grep; do
        if ! command -v $cmd &> /dev/null; then
            missing_deps+=($cmd)
        fi
    done

    # OS-specific dependencies
    case $os in
        linux)
            for cmd in gcc make; do
                if ! command -v $cmd &> /dev/null; then
                    missing_deps+=($cmd)
                fi
            done
            ;;
        macos)
            if ! command -v clang &> /dev/null; then
                missing_deps+=(clang)
            fi
            ;;
        windows)
            if ! command -v mingw32-make &> /dev/null; then
                missing_deps+=(mingw32-make)
            fi
            ;;
    esac

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Missing dependencies: ${missing_deps[*]}"
        return 1
    fi
    return 0
}

# Setup environment
setup_environment() {
    local os=$1
    
    # Create necessary directories
    mkdir -p "$SEOGGI_ROOT/bin"
    mkdir -p "$SEOGGI_ROOT/lib"
    mkdir -p "$SEOGGI_ROOT/examples"
    mkdir -p "$SEOGGI_ROOT/docs"
    
    # Set up OS-specific configurations
    case $os in
        linux)
            echo "export SEOGGI_ROOT=\"$SEOGGI_ROOT\"" > "$SEOGGI_ROOT/bin/seoggi.env"
            echo "export PATH=\"\$SEOGGI_ROOT/bin:\$PATH\"" >> "$SEOGGI_ROOT/bin/seoggi.env"
            ;;
        macos)
            echo "export SEOGGI_ROOT=\"$SEOGGI_ROOT\"" > "$SEOGGI_ROOT/bin/seoggi.env"
            echo "export PATH=\"\$SEOGGI_ROOT/bin:\$PATH\"" >> "$SEOGGI_ROOT/bin/seoggi.env"
            ;;
        windows)
            echo "set SEOGGI_ROOT=$SEOGGI_ROOT" > "$SEOGGI_ROOT/bin/seoggi.env.bat"
            echo "set PATH=%SEOGGI_ROOT%\bin;%PATH%" >> "$SEOGGI_ROOT/bin/seoggi.env.bat"
            ;;
    esac
}

# Install Seoggi
install_seoggi() {
    local os=$1
    
    echo "Installing Seoggi v$SEOGGI_VERSION..."
    
    # Make core scripts executable
    chmod +x "$SEOGGI_ROOT/core/seoggi_bootstrap"
    chmod +x "$SEOGGI_ROOT/tools/seo"
    
    # Create platform-specific launcher
    case $os in
        linux|macos)
            cat > "$SEOGGI_ROOT/bin/seo" <<EOF
#!/bin/bash
SEOGGI_ROOT="$SEOGGI_ROOT"
exec "\$SEOGGI_ROOT/tools/seo" "\$@"
EOF
            chmod +x "$SEOGGI_ROOT/bin/seo"
            ;;
        windows)
            cat > "$SEOGGI_ROOT/bin/seo.bat" <<EOF
@echo off
set SEOGGI_ROOT=$SEOGGI_ROOT
"%SEOGGI_ROOT%\tools\seo" %*
EOF
            ;;
    esac
}

# Main setup process
main() {
    echo "Seoggi Language Setup"
    echo "===================="
    echo

    # Detect OS
    OS=$(detect_os)
    echo "Detected OS: $OS"
    
    # Check dependencies
    echo "Checking dependencies..."
    if ! check_dependencies "$OS"; then
        echo "Please install missing dependencies and try again."
        exit 1
    fi
    
    # Setup environment
    echo "Setting up environment..."
    setup_environment "$OS"
    
    # Install Seoggi
    install_seoggi "$OS"
    
    echo
    echo "Seoggi has been successfully installed!"
    echo
    case $OS in
        linux|macos)
            echo "To complete setup, run:"
            echo "  source \"$SEOGGI_ROOT/bin/seoggi.env\""
            ;;
        windows)
            echo "To complete setup, run:"
            echo "  %SEOGGI_ROOT%\\bin\\seoggi.env.bat"
            ;;
    esac
    echo
    echo "Try running some examples:"
    echo "  seo exec hello_world"
    echo "  seo exec calculator"
    echo "  seo exec universal_app"
    echo "  seo exec web_server"
    echo "  seo exec ai_model"
    echo "  seo exec kernel_module"
}

main
