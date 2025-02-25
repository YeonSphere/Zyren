#!/usr/bin/env zsh

# Zyren Build Script

# Compile Zyren source files
echo "Compiling Zyren source files..."

# Lexer
echo "Compiling lexer..."
./zyrenc Zyren/src/compiler/lexer.zy -o Zyren/build/lexer.o

# Parser
echo "Compiling parser..."
./zyrenc Zyren/src/compiler/parser.zy -o Zyren/build/parser.o

# Code Generator
echo "Compiling code generator..."
./zyrenc Zyren/src/compiler/codegen.zy -o Zyren/build/codegen.o

# Virtual Machine
echo "Compiling virtual machine..."
./zyrenc Zyren/src/runtime/vm.zy -o Zyren/build/vm.o

# Standard Library
echo "Compiling standard library..."
./zyrenc Zyren/src/stdlib/io.zy -o Zyren/build/io.o
./zyrenc Zyren/src/stdlib/collections.zy -o Zyren/build/collections.o
./zyrenc Zyren/src/stdlib/concurrent.zy -o Zyren/build/concurrent.o
./zyrenc Zyren/src/stdlib/events.zy -o Zyren/build/events.o
./zyrenc Zyren/src/stdlib/graphics.zy -o Zyren/build/graphics.o
./zyrenc Zyren/src/stdlib/net.zy -o Zyren/build/net.o

# Linking
echo "Linking compiled objects..."
./zyrenc -o Zyren/build/zyren Zyren/build/lexer.o Zyren/build/parser.o Zyren/build/codegen.o Zyren/build/vm.o Zyren/build/io.o Zyren/build/collections.o Zyren/build/concurrent.o Zyren/build/events.o Zyren/build/graphics.o Zyren/build/net.o

echo "Build complete!"
