#!/bin/bash
# Seoggi Language Installer

set -e  # Exit on error

# Configuration
INSTALL_DIR=${SEOGGI_ROOT:-/usr/local/seoggi}
QUANTUM_BACKEND=${QUANTUM_BACKEND:-"simulator"}
AI_BACKEND=${AI_BACKEND:-"neural"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Print with color
print_color() {
    color=$1
    message=$2
    echo -e "${color}${message}${NC}"
}

# Check system requirements
check_requirements() {
    print_color $BLUE "Checking system requirements..."
    
    # Check Python version
    python_version=$(python3 --version 2>&1 | awk '{print $2}')
    if [[ ! $python_version =~ ^3\.[0-9]+\.[0-9]+$ ]]; then
        print_color $RED "Error: Python 3.x is required"
        exit 1
    fi
    
    # Check for required packages
    for pkg in git cmake make gcc g++; do
        if ! command -v $pkg >/dev/null 2>&1; then
            print_color $RED "Error: $pkg is not installed"
            exit 1
        fi
    done
    
    print_color $GREEN "✓ System requirements met"
}

# Install dependencies
install_dependencies() {
    print_color $BLUE "Installing dependencies..."
    
    # Create virtual environment
    python3 -m venv $INSTALL_DIR/venv
    source $INSTALL_DIR/venv/bin/activate
    
    # Install Python packages
    pip install --upgrade pip
    pip install numpy scipy tensorflow torch qiskit pennylane scikit-learn
    
    # Install quantum computing packages
    if [ "$QUANTUM_BACKEND" = "simulator" ]; then
        pip install qiskit-aer
    else
        pip install qiskit-ibm-provider
    fi
    
    # Install AI packages
    if [ "$AI_BACKEND" = "neural" ]; then
        pip install tensorflow-quantum torch-quantum
    fi
    
    print_color $GREEN "✓ Dependencies installed"
}

# Build Seoggi compiler and runtime
build_seoggi() {
    print_color $BLUE "Building Seoggi..."
    
    # Create build directory
    mkdir -p build
    cd build
    
    # Configure build
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
        -DQUANTUM_BACKEND=$QUANTUM_BACKEND \
        -DAI_BACKEND=$AI_BACKEND
    
    # Build
    make -j$(nproc)
    
    # Install
    make install
    
    cd ..
    print_color $GREEN "✓ Seoggi built successfully"
}

# Configure environment
configure_environment() {
    print_color $BLUE "Configuring environment..."
    
    # Create configuration directory
    mkdir -p $INSTALL_DIR/config
    
    # Generate configuration file
    cat > $INSTALL_DIR/config/seoggi.conf << EOF
# Seoggi Configuration
SEOGGI_ROOT=$INSTALL_DIR
QUANTUM_BACKEND=$QUANTUM_BACKEND
AI_BACKEND=$AI_BACKEND
PATH=\$SEOGGI_ROOT/bin:\$PATH
LD_LIBRARY_PATH=\$SEOGGI_ROOT/lib:\$LD_LIBRARY_PATH
PYTHONPATH=\$SEOGGI_ROOT/lib/python:\$PYTHONPATH
EOF
    
    # Add to shell configuration
    echo "source $INSTALL_DIR/config/seoggi.conf" >> ~/.bashrc
    
    print_color $GREEN "✓ Environment configured"
}

# Install templates
install_templates() {
    print_color $BLUE "Installing project templates..."
    
    # Create templates directory
    mkdir -p $INSTALL_DIR/templates
    
    # Install quantum project template
    cat > $INSTALL_DIR/templates/quantum.seo << EOF
// Quantum Project Template
use std::quantum::*;

fn main() {
    // Create quantum register
    let reg = QRegister::new(2);
    
    // Apply quantum gates
    reg.apply_gate(Hadamard(0));
    reg.apply_gate(CNOT(0, 1));
    
    // Measure qubits
    let result = reg.measure();
    println!("Result: {}", result);
}
EOF
    
    # Install AI project template
    cat > $INSTALL_DIR/templates/ai.seo << EOF
// AI Project Template
use std::neural::*;

fn main() {
    // Create neural network
    let mut net = NeuralNetwork::new();
    
    // Add layers
    net.add_layer(Dense(64, activation=ReLU));
    net.add_layer(Dense(32, activation=ReLU));
    net.add_layer(Dense(10, activation=Softmax));
    
    // Train network
    net.train(data, epochs=10);
    
    // Make predictions
    let predictions = net.predict(test_data);
    println!("Predictions: {}", predictions);
}
EOF
    
    # Install hybrid project template
    cat > $INSTALL_DIR/templates/hybrid.seo << EOF
// Hybrid Quantum-AI Project Template
use std::quantum::*;
use std::neural::*;

fn main() {
    // Create quantum circuit
    let circuit = QCircuit::new();
    circuit.add_qubit(|0⟩);
    circuit.add_gate(Hadamard);
    
    // Create neural network
    let mut net = NeuralNetwork::new();
    net.add_quantum_layer(circuit);
    net.add_layer(Dense(32, activation=ReLU));
    
    // Train hybrid model
    net.train(data, epochs=10);
    
    // Make predictions
    let predictions = net.predict(test_data);
    println!("Predictions: {}", predictions);
}
EOF
    
    print_color $GREEN "✓ Templates installed"
}

# Main installation
main() {
    print_color $BLUE "Installing Seoggi Programming Language..."
    
    # Create installation directory
    mkdir -p $INSTALL_DIR
    
    # Run installation steps
    check_requirements
    install_dependencies
    build_seoggi
    configure_environment
    install_templates
    
    print_color $GREEN "✓ Seoggi installation complete!"
    print_color $BLUE "To get started, run: source ~/.bashrc && seo new quantum my_project"
}

# Run installation
main
