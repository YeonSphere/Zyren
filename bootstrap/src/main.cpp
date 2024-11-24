#include "lexer.hpp"
#include "parser.hpp"
#include "codegen.hpp"
#include <fstream>
#include <iostream>
#include <sstream>

void printUsage() {
    std::cerr << "Usage: seoggi_bootstrap <input.seo> -o <output.cpp>\n";
}

int main(int argc, char* argv[]) {
    if (argc != 4 || std::string(argv[2]) != "-o") {
        printUsage();
        return 1;
    }

    std::string inputFile = argv[1];
    std::string outputFile = argv[3];

    // Read input file
    std::ifstream inFile(inputFile);
    if (!inFile) {
        std::cerr << "Error: Could not open input file: " << inputFile << "\n";
        return 1;
    }

    std::stringstream buffer;
    buffer << inFile.rdbuf();
    std::string source = buffer.str();

    try {
        // Lexical analysis
        Lexer lexer(source);
        
        // Parsing
        Parser parser(lexer);
        auto ast = parser.parse();
        
        // Code generation
        CodeGenerator codegen;
        auto module = codegen.generateCode(*ast);
        
        // Write output
        codegen.writeToFile(outputFile);
        
        return 0;
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << "\n";
        return 1;
    }
}
