#!/bin/bash

# Seoggi Build Script
# This script handles the build process for Seoggi

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$PROJECT_ROOT/build.log"
BUILD_DIR="$PROJECT_ROOT/build"
INSTALL_DIR="$PROJECT_ROOT/install"

# Interpreter path
INTERPRETER="$PROJECT_ROOT/bin/interpreter"

# Lexer and parser paths
LEXER="$PROJECT_ROOT/bin/lexer"
PARSER="$PROJECT_ROOT/bin/parser"

# Function to log messages
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to print user messages
print() {
    echo "$1"
}

# Clean build artifacts
clean() {
    log "Cleaning build artifacts..."
    rm -rf "$BUILD_DIR"
    rm -f "$LOG_FILE"
    mkdir -p "$BUILD_DIR"
}

# Compile the lexer and parser
compile_lexer_parser() {
    log "Compiling lexer and parser..."
    print "Compiling lexer and parser..."
    
    mkdir -p "$(dirname "$LEXER")"
    cat > "$LEXER" << 'EOF'
#!/bin/bash

# Simple lexer for Seoggi language

function lex() {
    script="$1"
    # Tokenization logic here
    echo "Lexing: $script"
}

# Process each .seo file
for file in "$PROJECT_ROOT/src/compiler/"*.seo; do
    lex "$file"
done
EOF
    chmod +x "$LEXER"

    mkdir -p "$(dirname "$PARSER")"
    cat > "$PARSER" << 'EOF'
#!/bin/bash

# Simple parser for Seoggi language

function parse() {
    tokens="$1"
    # Parsing logic here
    echo "Parsing: $tokens"
}

# Process each .seo file
for file in "$PROJECT_ROOT/src/compiler/"*.seo; do
    parse "$file"
done
EOF
    chmod +x "$PARSER"
    
    if [ $? -eq 0 ]; then
        log "Lexer and parser compiled successfully"
        print "Lexer and parser compiled successfully"
    else
        log "Failed to compile lexer and parser"
        print "Failed to compile lexer and parser"
        exit 1
    fi
}

# Build the interpreter
build_interpreter() {
    log "Building interpreter..."
    print "Building interpreter..."
    
    mkdir -p "$(dirname "$INTERPRETER")"
    cat > "$INTERPRETER" << 'EOF'
#!/bin/bash

# Simple interpreter for Seoggi language

function interpret() {
    script="$1"
    tokens=$(./bin/lexer "$script")
    ast=$(./bin/parser "$tokens")
    execute "$ast"
}

function execute() {
    ast="$1"
    # Logic to execute the AST
    echo "Executing AST: $ast"
}

# Process each .seo file
for file in "$PROJECT_ROOT/src/compiler/"*.seo; do
    interpret "$file"
done
EOF
    chmod +x "$INTERPRETER"
    
    if [ $? -eq 0 ]; then
        log "Interpreter built successfully"
        print "Interpreter built successfully"
    else
        log "Failed to build interpreter"
        print "Failed to build interpreter"
        exit 1
    fi
}

# Main build process
main() {
    clean
    compile_lexer_parser
    build_interpreter
    echo "Build completed!"
}

# Execute main build process
main
