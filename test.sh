#!/usr/bin/env zsh

# Zyren Test Script

# Run tests for Zyren
echo "Running tests for Zyren..."

# Compile test files
echo "Compiling test files..."
./zyrenc Zyren/tests/test1.zy -o Zyren/build/test1.o
./zyrenc Zyren/tests/test2.zy -o Zyren/build/test2.o
./zyrenc Zyren/tests/test3.zy -o Zyren/build/test3.o

# Run test executables
echo "Running test executables..."
./Zyren/build/test1.o
./Zyren/build/test2.o
./Zyren/build/test3.o

echo "Tests complete!"
