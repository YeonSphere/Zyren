#!/bin/bash

# Seoggi Programming Language Installer for Linux
echo "Installing Seoggi Programming Language..."

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root or with sudo"
        exit 1
    fi
}

# Function to detect Linux distribution and package manager
detect_package_manager() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_LIKE=$ID_LIKE
    else
        echo "Could not detect Linux distribution"
        exit 1
    fi

    case $DISTRO in
        # Debian-based
        debian|ubuntu|linuxmint|pop|elementary|zorin|kali|parrot|deepin|raspbian)
            PKG_MANAGER="apt-get"
            PKG_UPDATE="apt-get update && apt-get upgrade -y"
            PKG_INSTALL="apt-get install -y"
            PACKAGES="git make gcc g++ llvm llvm-dev clang cmake ninja-build libssl-dev pkg-config python3 python3-pip nodejs npm golang rustc cargo cuda-toolkit nvidia-cuda-toolkit vulkan-tools libvulkan-dev opencl-headers nvidia-opencl-dev"
            # Add LLVM repository
            bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
            ;;
        
        # Red Hat-based with DNF
        fedora)
            PKG_MANAGER="dnf"
            PKG_UPDATE="dnf check-update && dnf upgrade -y"
            PKG_INSTALL="dnf install -y"
            PACKAGES="git make gcc gcc-c++ llvm llvm-devel clang cmake ninja-build openssl-devel pkg-config python3 python3-pip nodejs npm golang rust cargo cuda nvidia-cuda-toolkit vulkan-tools vulkan-loader-devel opencl-headers ocl-icd-devel kernel-devel"
            # Enable RPM Fusion
            $PKG_INSTALL https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
            $PKG_INSTALL https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
            ;;
        
        # Red Hat-based with YUM
        rhel|centos|rocky|alma)
            PKG_MANAGER="yum"
            PKG_UPDATE="yum check-update && yum upgrade -y"
            PKG_INSTALL="yum install -y"
            PACKAGES="git make gcc gcc-c++ llvm llvm-devel clang cmake ninja-build openssl-devel pkg-config python3 python3-pip nodejs npm golang rust cargo cuda nvidia-cuda-toolkit vulkan-tools vulkan-loader-devel opencl-headers ocl-icd-devel kernel-devel"
            # Enable EPEL and other repositories
            $PKG_INSTALL epel-release
            if [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "rhel" ]; then
                $PKG_INSTALL centos-release-scl
            fi
            ;;
        
        # Arch-based
        arch|manjaro|endeavouros|artix|garuda)
            PKG_MANAGER="pacman"
            PKG_UPDATE="pacman -Syu --noconfirm"
            PKG_INSTALL="pacman -S --noconfirm"
            PACKAGES="git make gcc llvm clang cmake ninja openssl pkg-config python python-pip nodejs npm go rust cuda nvidia vulkan-tools vulkan-headers opencl-headers opencl-nvidia linux-headers"
            # Enable multilib repository
            sed -i "/\[multilib\]/,/Include/s/^#//" /etc/pacman.conf
            pacman -Sy
            ;;
        
        # SUSE-based
        opensuse-leap|opensuse-tumbleweed|suse)
            PKG_MANAGER="zypper"
            PKG_UPDATE="zypper refresh && zypper update -y"
            PKG_INSTALL="zypper install -y"
            PACKAGES="git make gcc gcc-c++ llvm-devel clang cmake ninja pkg-config libopenssl-devel python3 python3-pip nodejs npm go rust cargo cuda nvidia-cuda-toolkit vulkan-tools vulkan-devel opencl-headers opencl-cpp-headers kernel-devel"
            # Add necessary repositories
            zypper addrepo https://download.nvidia.com/opensuse/leap/\${VERSION_ID} NVIDIA
            ;;
        
        # Gentoo
        gentoo)
            PKG_MANAGER="emerge"
            PKG_UPDATE="emerge --sync && emerge -uDN @world"
            PKG_INSTALL="emerge -v"
            PACKAGES="dev-vcs/git sys-devel/make sys-devel/gcc sys-devel/llvm sys-devel/clang dev-util/cmake dev-util/ninja dev-libs/openssl dev-util/pkgconfig dev-lang/python dev-lang/nodejs dev-lang/go dev-lang/rust dev-util/cuda dev-util/vulkan-tools dev-util/vulkan-headers dev-libs/opencl-headers sys-kernel/gentoo-sources"
            ;;
        
        # Void Linux
        void)
            PKG_MANAGER="xbps-install"
            PKG_UPDATE="xbps-install -Su"
            PKG_INSTALL="xbps-install -y"
            PACKAGES="git make gcc llvm clang cmake ninja openssl pkg-config python3 python3-pip nodejs npm go rust cuda nvidia vulkan-tools vulkan-headers opencl-headers linux-headers"
            ;;
        
        *)
            # Check for common package managers in ID_LIKE
            if [[ "$DISTRO_LIKE" == *"debian"* ]]; then
                PKG_MANAGER="apt-get"
                PKG_UPDATE="apt-get update && apt-get upgrade -y"
                PKG_INSTALL="apt-get install -y"
                PACKAGES="git make gcc g++ llvm llvm-dev clang cmake ninja-build libssl-dev pkg-config python3 python3-pip nodejs npm golang rustc cargo cuda-toolkit nvidia-cuda-toolkit vulkan-tools libvulkan-dev opencl-headers nvidia-opencl-dev"
            elif [[ "$DISTRO_LIKE" == *"rhel"* ]]; then
                PKG_MANAGER="yum"
                PKG_UPDATE="yum check-update && yum upgrade -y"
                PKG_INSTALL="yum install -y"
                PACKAGES="git make gcc gcc-c++ llvm llvm-devel clang cmake ninja-build openssl-devel pkg-config python3 python3-pip nodejs npm golang rust cargo cuda nvidia-cuda-toolkit vulkan-tools vulkan-loader-devel opencl-headers ocl-icd-devel kernel-devel"
            else
                echo "Unsupported distribution: $DISTRO"
                echo "Please install the following packages manually:"
                echo "- git"
                echo "- make"
                echo "- gcc/g++"
                echo "- llvm"
                echo "- clang"
                echo "- cmake"
                echo "- ninja"
                echo "- openssl"
                echo "- pkg-config"
                echo "- python3"
                echo "- nodejs"
                echo "- golang"
                echo "- rust"
                echo "- cuda toolkit"
                echo "- vulkan development files"
                echo "- opencl development files"
                echo "- kernel headers"
                exit 1
            fi
            ;;
    esac
}

# Function to install dependencies
install_dependencies() {
    echo "Updating package lists..."
    $PKG_UPDATE

    echo "Installing required packages..."
    $PKG_INSTALL $PACKAGES

    # Install additional development tools
    if command -v pip3 &> /dev/null; then
        pip3 install --upgrade pip
        pip3 install numpy tensorflow torch pandas scikit-learn
    fi

    if command -v npm &> /dev/null; then
        npm install -g typescript webpack webpack-cli
    fi

    if command -v cargo &> /dev/null; then
        cargo install wasm-pack
    fi

    # Check if all required commands are available
    REQUIRED_COMMANDS="git make gcc cmake ninja pkg-config python3 node go rustc"
    for cmd in $REQUIRED_COMMANDS; do
        if ! command -v $cmd &> /dev/null; then
            echo "Error: $cmd is required but not installed."
            exit 1
        fi
    done
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
setup_repository() {
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
        -DLLVM_DIR="$(llvm-config --prefix)/lib/cmake/llvm" \
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
llvm_dir = "$(llvm-config --prefix)"

[kernel]
linux_headers = "/usr/src/linux/include"
enable_module_support = true
enable_kvm = true
enable_bpf = true

[gpu]
cuda_path = "/usr/local/cuda"
enable_cuda = true
enable_vulkan = true
enable_opencl = true

[web]
node_path = "$(which node)"
enable_wasm = true
enable_ssr = true
enable_webgl = true
enable_webgpu = true

[ai]
enable_cuda = true
enable_tensorrt = true
enable_openvino = true
enable_tensorflow = true
enable_pytorch = true
enable_oneapi = true
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
    
    # Configure CUDA environment
    if [ -d "/usr/local/cuda" ]; then
        if ! grep -q "export CUDA_HOME=/usr/local/cuda" "$SHELL_RC"; then
            echo 'export CUDA_HOME=/usr/local/cuda' >> "$SHELL_RC"
            echo 'export PATH=$PATH:$CUDA_HOME/bin' >> "$SHELL_RC"
            echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CUDA_HOME/lib64' >> "$SHELL_RC"
        fi
    fi
    
    # Configure VS Code if installed
    VSCODE_PATH="$HOME/.config/Code/User"
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

# Function to setup Linux-specific features
setup_linux_specific() {
    info "Setting up Linux-specific features..."
    
    # Setup kernel development environment
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y linux-headers-$(uname -r) dkms
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y kernel-devel kernel-headers dkms
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm linux-headers dkms
    fi
    
    # Setup GPU development
    if lspci | grep -i nvidia &> /dev/null; then
        info "NVIDIA GPU detected, setting up CUDA development environment..."
        case "$DISTRO" in
            "ubuntu"|"debian")
                sudo apt-get install -y nvidia-cuda-toolkit nvidia-cuda-dev
                ;;
            "fedora"|"rhel"|"centos")
                sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora/x86_64/cuda-fedora.repo
                sudo dnf install -y cuda-toolkit
                ;;
            "arch"|"manjaro")
                sudo pacman -S --noconfirm cuda cuda-tools
                ;;
        esac
    elif lspci | grep -i amd &> /dev/null; then
        info "AMD GPU detected, setting up ROCm development environment..."
        case "$DISTRO" in
            "ubuntu"|"debian")
                wget -q -O - https://repo.radeon.com/rocm/rocm.gpg.key | sudo apt-key add -
                echo 'deb [arch=amd64] https://repo.radeon.com/rocm/apt/debian/ ubuntu main' | sudo tee /etc/apt/sources.list.d/rocm.list
                sudo apt-get update
                sudo apt-get install -y rocm-dev
                ;;
            "fedora"|"rhel"|"centos")
                sudo dnf install -y rocm-dev
                ;;
            "arch"|"manjaro")
                sudo pacman -S --noconfirm rocm-dev
                ;;
        esac
    fi
    
    # Setup Android development environment
    info "Setting up Android development environment..."
    case "$DISTRO" in
        "ubuntu"|"debian")
            sudo apt-get install -y android-sdk android-sdk-platform-tools
            ;;
        "fedora"|"rhel"|"centos")
            sudo dnf install -y android-tools
            ;;
        "arch"|"manjaro")
            sudo pacman -S --noconfirm android-tools android-udev
            ;;
    esac
    
    # Setup game development dependencies
    info "Setting up game development environment..."
    case "$DISTRO" in
        "ubuntu"|"debian")
            sudo apt-get install -y libsdl2-dev libglew-dev libglfw3-dev \
                libopenal-dev libalut-dev libvulkan-dev \
                libfreetype6-dev libharfbuzz-dev
            ;;
        "fedora"|"rhel"|"centos")
            sudo dnf install -y SDL2-devel glew-devel glfw-devel \
                openal-devel freealut-devel vulkan-devel \
                freetype-devel harfbuzz-devel
            ;;
        "arch"|"manjaro")
            sudo pacman -S --noconfirm sdl2 glew glfw openal \
                freealut vulkan-devel freetype2 harfbuzz
            ;;
    esac
    
    # Setup AI/ML development environment
    info "Setting up AI/ML development environment..."
    case "$DISTRO" in
        "ubuntu"|"debian")
            sudo apt-get install -y python3-dev python3-pip \
                libblas-dev liblapack-dev libatlas-base-dev
            ;;
        "fedora"|"rhel"|"centos")
            sudo dnf install -y python3-devel blas-devel lapack-devel atlas-devel
            ;;
        "arch"|"manjaro")
            sudo pacman -S --noconfirm python-dev blas lapack atlas
            ;;
    esac
    
    # Install Python ML packages
    pip3 install --user numpy pandas scikit-learn torch tensorflow
}

# Function to setup VSCode integration
post_install() {
    setup_linux_specific
    
    # Setup VSCode integration
    if command -v code &> /dev/null; then
        info "Setting up VSCode integration..."
        code --install-extension seoggi.seoggi-lang
        code --install-extension seoggi.seoggi-debug
    fi
}

# Main installation process
main() {
    check_root
    detect_package_manager
    install_dependencies
    setup_directories
    setup_repository
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
