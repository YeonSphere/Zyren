#include <iostream>
#include <string>
#include <vector>
#include "core/runtime/quantum_runtime.hpp"
#include "core/runtime/neural_runtime.hpp"

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cout << "Seoggi Quantum Programming Language v0.1.0\n";
        std::cout << "Usage: seo <command> [options]\n\n";
        std::cout << "Commands:\n";
        std::cout << "  help     Show this help message\n";
        std::cout << "  run      Run a Seoggi program\n";
        std::cout << "  compile  Compile a Seoggi program\n";
        std::cout << "  repl     Start Seoggi REPL\n";
        return 0;
    }

    std::string command = argv[1];
    std::vector<std::string> args(argv + 2, argv + argc);

    // TODO: Implement command handling
    if (command == "help") {
        std::cout << "Seoggi Help\n";
        // Add detailed help information
    }
    else if (command == "run") {
        std::cout << "Running Seoggi program...\n";
        // Add run implementation
    }
    else if (command == "compile") {
        std::cout << "Compiling Seoggi program...\n";
        // Add compile implementation
    }
    else if (command == "repl") {
        std::cout << "Starting Seoggi REPL...\n";
        // Add REPL implementation
    }
    else {
        std::cerr << "Unknown command: " << command << "\n";
        return 1;
    }

    return 0;
}
