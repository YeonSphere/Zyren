#!/bin/bash

# Seoggi Installation Script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Print banner
echo -e "${GREEN}"
echo "███████╗███████╗ ██████╗  ██████╗  ██████╗ ██╗"
echo "██╔════╝██╔════╝██╔═══██╗██╔════╝ ██╔════╝ ██║"
echo "███████╗█████╗  ██║   ██║██║  ███╗██║  ███╗██║"
echo "╚════██║██╔══╝  ██║   ██║██║   ██║██║   ██║██║"
echo "███████║███████╗╚██████╔╝╚██████╔╝╚██████╔╝██║"
echo "╚══════╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝"
echo -e "${NC}"
echo "Quantum Programming Language Installation"
echo "Version 0.1.0"
echo

# Check system requirements
echo -e "${YELLOW}Checking system requirements...${NC}"

# Check for required commands
REQUIRED_COMMANDS=("git" "cmake" "make" "gcc" "g++")
MISSING_COMMANDS=()

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command -v $cmd &> /dev/null; then
        MISSING_COMMANDS+=($cmd)
    fi
done

if [ ${#MISSING_COMMANDS[@]} -ne 0 ]; then
    echo -e "${RED}Error: Missing required commands: ${MISSING_COMMANDS[*]}${NC}"
    echo "Please install these dependencies and try again."
    exit 1
fi

# Create installation directory
INSTALL_DIR="$HOME/.seoggi"
echo -e "${YELLOW}Creating installation directory at $INSTALL_DIR${NC}"
mkdir -p "$INSTALL_DIR"

# Clone repository if not already in it
if [ ! -f "project.seo" ]; then
    echo -e "${YELLOW}Cloning Seoggi repository...${NC}"
    git clone https://github.com/YeonSphere/Seoggi.git "$INSTALL_DIR/source"
    cd "$INSTALL_DIR/source"
fi

# Create build directory
echo -e "${YELLOW}Creating build directory...${NC}"
mkdir -p build
cd build

# Configure build
echo -e "${YELLOW}Configuring build...${NC}"
cmake .. -DCMAKE_BUILD_TYPE=Release \
        -DSEOGGI_ENABLE_QUANTUM=ON \
        -DSEOGGI_ENABLE_AI=ON \
        -DSEOGGI_ENABLE_TESTS=ON

# Build
echo -e "${YELLOW}Building Seoggi...${NC}"
make -j$(nproc)

# Run tests
echo -e "${YELLOW}Running tests...${NC}"
make test

# Install
echo -e "${YELLOW}Installing Seoggi...${NC}"
make install

# Set up environment
echo -e "${YELLOW}Setting up environment...${NC}"
BASHRC="$HOME/.bashrc"
PROFILE="$HOME/.profile"

# Add Seoggi to PATH
SEOGGI_PATH_LINE='export PATH="$HOME/.seoggi/bin:$PATH"'
SEOGGI_ROOT_LINE='export SEOGGI_ROOT="$HOME/.seoggi"'

if ! grep -q "$SEOGGI_PATH_LINE" "$BASHRC"; then
    echo "$SEOGGI_PATH_LINE" >> "$BASHRC"
fi

if ! grep -q "$SEOGGI_ROOT_LINE" "$BASHRC"; then
    echo "$SEOGGI_ROOT_LINE" >> "$BASHRC"
fi

# Create quantum configuration
echo -e "${YELLOW}Configuring quantum backend...${NC}"
cat > "$INSTALL_DIR/quantum.config" << EOL
{
    "backend": "simulator",
    "error_correction": true,
    "optimization_level": 2,
    "max_qubits": 32,
    "noise_model": "ideal"
}
EOL

# Create AI configuration
echo -e "${YELLOW}Configuring AI backend...${NC}"
cat > "$INSTALL_DIR/ai.config" << EOL
{
    "backend": "auto",
    "device": "cpu",
    "quantum_enabled": true,
    "optimization_level": 3,
    "parallel_training": true
}
EOL

# Create example project
echo -e "${YELLOW}Creating example project...${NC}"
mkdir -p "$HOME/seoggi-example"
cat > "$HOME/seoggi-example/main.seo" << EOL
quantum Main {
    // Quantum circuit example
    let circuit = QuantumCircuit(2)
    
    // Apply quantum gates
    circuit.hadamard(0)
    circuit.cnot(0, 1)
    
    // Create neural network
    let network = Network()
    network.add_quantum_layer(QuantumLayer(2))
    
    // Print results
    print("Quantum Circuit State: ", circuit.get_state())
    print("Neural Network Output: ", network.forward([1.0, 0.0]))
}
EOL

# Final message
echo -e "${GREEN}Seoggi has been successfully installed!${NC}"
echo
echo "To get started:"
echo "1. Open a new terminal or run: source ~/.bashrc"
echo "2. Try the example project: cd ~/seoggi-example"
echo "3. Run: seo main.seo"
echo
echo "For more information, visit: https://seoggi.dev"
echo "Report issues at: https://github.com/YeonSphere/Seoggi/issues"
echo
echo -e "${YELLOW}Happy quantum programming!${NC}"
