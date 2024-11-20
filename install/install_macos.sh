#!/bin/bash

# Seoggi Programming Language Installer for macOS
echo "Installing Seoggi Programming Language..."

# Function to check for command line tools
check_command_line_tools() {
    if ! xcode-select -p &> /dev/null; then
        echo "Installing Command Line Tools..."
        xcode-select --install
        # Wait for installation to complete
        until xcode-select -p &> /dev/null; do
            sleep 1
        done
    fi
}

# Function to check and install Homebrew
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
}

# Function to install dependencies
install_dependencies() {
    echo "Installing required packages..."
    
    # Update Homebrew
    brew update
    
    # Install required packages
    brew install \
        git \
        cmake \
        ninja \
        llvm \
        python3 \
        node \
        go \
        rust \
        cuda \
        tensorflow \
        pytorch \
        vulkan-headers \
        metal \
        swift \
        docker \
        kubernetes-cli
        
    # Install Rosetta 2 for Apple Silicon Macs if needed
    if [[ $(uname -m) == 'arm64' ]]; then
        softwareupdate --install-rosetta --agree-to-license
    fi
}

# Function to setup directories
setup_directories() {
    INSTALL_DIR="$HOME/.seoggi"
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR/bin"
    mkdir -p "$INSTALL_DIR/lib"
    mkdir -p "$INSTALL_DIR/include"
    mkdir -p "$INSTALL_DIR/kernel"
    mkdir -p "$INSTALL_DIR/tools"
    mkdir -p "$INSTALL_DIR/web"
    mkdir -p "$INSTALL_DIR/ai"
}

# Function to clone repository
clone_repository() {
    if [ -d "$INSTALL_DIR/src" ]; then
        echo "Updating Seoggi..."
        cd "$INSTALL_DIR/src"
        git pull
    else
        echo "Downloading Seoggi..."
        git clone https://github.com/YeonSphere/Seoggi.git "$INSTALL_DIR/src"
        cd "$INSTALL_DIR/src"
    fi
}

# Function to build compiler
build_compiler() {
    echo "Building Seoggi compiler..."
    mkdir -p build && cd build
    
    # Configure with CMake
    cmake -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_KERNEL_DEV=ON \
        -DENABLE_GPU_SUPPORT=ON \
        -DENABLE_WEB=ON \
        -DENABLE_AI=ON \
        -DLLVM_DIR="$(brew --prefix llvm)/lib/cmake/llvm" \
        ..
    
    # Build
    ninja
}

# Function to install compiler
install_compiler() {
    echo "Installing Seoggi..."
    cp build/seoggi "$INSTALL_DIR/bin/"
    cp -r lib/* "$INSTALL_DIR/lib/"
    cp -r include/* "$INSTALL_DIR/include/"
    
    # Create configuration file
    cat > "$INSTALL_DIR/config.toml" << EOL
[compiler]
version = "0.1.0"
default_target = "native"
optimization_level = 2
enable_kernel_dev = true
enable_gpu_support = true
enable_web = true
enable_ai = true

[paths]
stdlib = "$INSTALL_DIR/lib/std"
include = "$INSTALL_DIR/include"
kernel = "$INSTALL_DIR/kernel"
tools = "$INSTALL_DIR/tools"
web = "$INSTALL_DIR/web"
ai = "$INSTALL_DIR/ai"

[llvm]
target_triple = "$(llvm-config --host-target)"
llvm_dir = "$(brew --prefix llvm)"

[kernel]
xnu_headers = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Kernel.framework/Headers"
enable_kext = true
enable_dext = true

[gpu]
metal_sdk = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Metal.framework"
enable_metal = true
enable_cuda = true
enable_vulkan = true

[web]
node_path = "$(brew --prefix node)"
enable_wasm = true
enable_ssr = true

[ai]
enable_coreml = true
enable_metal_performance_shaders = true
enable_accelerate = true
enable_cuda = true
EOL
}

# Function to configure environment
configure_environment() {
    # Detect shell
    SHELL_RC=""
    if [ -n "$BASH_VERSION" ]; then
        SHELL_RC="$HOME/.bashrc"
        [ -f "$HOME/.bash_profile" ] && SHELL_RC="$HOME/.bash_profile"
    elif [ -n "$ZSH_VERSION" ]; then
        SHELL_RC="$HOME/.zshrc"
    else
        SHELL_RC="$HOME/.profile"
    fi
    
    # Add to PATH
    if ! grep -q "export PATH=\"\$PATH:\$HOME/.seoggi/bin\"" "$SHELL_RC"; then
        echo 'export PATH="$PATH:$HOME/.seoggi/bin"' >> "$SHELL_RC"
        echo "Added Seoggi to PATH in $SHELL_RC"
    fi
    
    # Configure VS Code if installed
    VSCODE_PATH="$HOME/Library/Application Support/Code/User"
    if [ -d "$VSCODE_PATH" ]; then
        cat > "$VSCODE_PATH/settings.json" << EOL
{
    "seoggi.path": "$INSTALL_DIR/bin/seoggi",
    "seoggi.includePath": "$INSTALL_DIR/include",
    "seoggi.kernelPath": "$INSTALL_DIR/kernel",
    "seoggi.enableIntelliSense": true,
    "seoggi.formatOnSave": true
}
EOL
    fi
}

# Function to setup macOS-specific features
setup_macos_specific() {
    info "Setting up macOS-specific features..."
    
    # Install Xcode Command Line Tools if not present
    if ! xcode-select -p &> /dev/null; then
        info "Installing Xcode Command Line Tools..."
        xcode-select --install
        read -p "Press enter after Xcode Command Line Tools installation completes"
    fi
    
    # Install Homebrew if not present
    if ! command -v brew &> /dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Setup Metal development environment
    info "Setting up Metal development environment..."
    xcode-select --install
    
    # Setup kernel development
    info "Setting up kernel development environment..."
    brew install --cask xcode
    sudo xcodebuild -license accept
    
    # Setup Android development
    info "Setting up Android development environment..."
    brew install --cask android-studio
    brew install android-platform-tools
    
    # Setup game development environment
    info "Setting up game development environment..."
    brew install sdl2 glew glfw openal-soft vulkan-headers \
        freetype harfbuzz cmake ninja
    
    if [[ "$ARCH" == "arm64" ]]; then
        # Setup Rosetta 2 for x86_64 compatibility
        softwareupdate --install-rosetta --agree-to-license
        
        # Install native ARM versions of dependencies
        brew install molten-vk
    else
        # Install Intel-specific dependencies
        brew install intel-compute-runtime
    fi
    
    # Setup AI/ML development
    info "Setting up AI/ML development environment..."
    brew install python@3.11 openblas lapack
    
    # Install Python ML packages
    pip3 install --user numpy pandas scikit-learn torch tensorflow
    
    if [[ "$ARCH" == "arm64" ]]; then
        # Install Apple Silicon optimized ML frameworks
        pip3 install --user tensorflow-macos tensorflow-metal
        
        # Setup CoreML tools
        pip3 install --user coremltools
    fi
    
    # Setup browser development environment
    info "Setting up browser development environment..."
    brew install qt6 webkit2gtk
}

# Function to setup IDE integration
setup_ide_integration() {
    # Setup VSCode integration
    if command -v code &> /dev/null; then
        info "Setting up VSCode integration..."
        code --install-extension seoggi.seoggi-lang
        code --install-extension seoggi.seoggi-debug
    fi
    
    # Setup Xcode integration
    info "Setting up Xcode integration..."
    mkdir -p ~/Library/Developer/Xcode/Templates/File\ Templates/Seoggi
    cp -r "$INSTALL_DIR/share/xcode/templates/"* ~/Library/Developer/Xcode/Templates/File\ Templates/Seoggi/
}

# Function to run macOS-specific setup after main installation
post_install() {
    setup_macos_specific
    setup_ide_integration
}

# Main installation process
main() {
    check_command_line_tools
    install_homebrew
    install_dependencies
    setup_directories
    clone_repository
    build_compiler
    install_compiler
    configure_environment
    post_install
    
    echo "Installation complete!"
    echo "Please restart your terminal or run 'source $SHELL_RC' to use Seoggi."
    echo "Type 'seoggi --version' to verify the installation."
}

# Run the installation
main
