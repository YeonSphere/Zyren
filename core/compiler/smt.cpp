#include "seoggi/compiler/smt.hpp"
#include <iostream>
#include <string>
#include <fstream>
#include <sstream>
#include <map>
#include <functional>
#include <vector>
#include <filesystem>

namespace seoggi {
namespace compiler {

// ANSI color codes
const char* COLOR_RESET = "\033[0m";
const char* COLOR_BLUE  = "\033[34m";
const char* COLOR_RED   = "\033[31m";

// Version information
const char* VERSION = "0.1.0";
const char* LICENSE = "YeonSphere Universal Open Source License (YUOSL)";
const char* AUTHOR = "Dae Sanghwi";

// Environment
struct Environment {
    std::map<std::string, std::string> variables;
    std::map<std::string, std::function<void(const std::vector<std::string>&)>> functions;
};

// Log levels
enum class LogLevel {
    INFO,
    ERROR
};

// Log message with level
void log_message(LogLevel level, const std::string& message) {
    if (level == LogLevel::INFO && message == "Running program...") {
        std::cout << COLOR_BLUE << "[INFO] " << COLOR_RESET 
                  << message << "\n";
    } else if (level == LogLevel::ERROR) {
        std::cout << COLOR_RED << "[ERROR] " << COLOR_RESET 
                  << message << "\n";
    }
}

// Built-in functions
void write(Environment& env, const std::vector<std::string>& args) {
    if (args.empty()) return;
    std::cout << args[0] << "\n";
}

std::string read(Environment& env, const std::string& prompt = "") {
    if (!prompt.empty()) {
        std::cout << prompt;
    }
    std::string input;
    std::getline(std::cin, input);
    return input;
}

std::string platform() {
    #ifdef __EMSCRIPTEN__
        return "web";
    #else
        #ifdef __linux__
            return "linux";
        #elif _WIN32
            return "windows";
        #elif __APPLE__
            return "macos";
        #else
            return "unknown";
        #endif
    #endif
}

// Initialize environment with built-in functions
Environment create_environment() {
    Environment env;
    
    // Add built-in functions
    env.functions["write"] = [](const std::vector<std::string>& args) {
        if (!args.empty()) std::cout << args[0] << "\n";
    };
    
    env.functions["read"] = [](const std::vector<std::string>& args) {
        std::string input;
        std::getline(std::cin, input);
        return input;
    };
    
    env.functions["platform"] = [](const std::vector<std::string>& args) {
        return platform();
    };
    
    env.functions["str"] = [](const std::vector<std::string>& args) {
        return args[0];
    };
    
    return env;
}

// Evaluate string expression
std::string evaluate_string(const std::string& str, Environment& env) {
    std::stringstream result;
    size_t pos = 0;
    
    while (pos < str.length()) {
        // Find next variable reference
        size_t start = str.find('"', pos);
        if (start == std::string::npos) {
            result << str.substr(pos);
            break;
        }
        
        // Add text before the variable
        result << str.substr(pos, start - pos);
        
        // Find end of variable reference
        size_t end = str.find('"', start + 1);
        if (end == std::string::npos) {
            result << str.substr(start);
            break;
        }
        
        // Extract variable name
        std::string var_name = str.substr(start + 1, end - start - 1);
        
        // Look up variable value
        auto it = env.variables.find(var_name);
        if (it != env.variables.end()) {
            result << it->second;
        } else {
            // If not found, try to evaluate as a literal
            result << var_name;
        }
        
        pos = end + 1;
    }
    
    return result.str();
}

// Execute a line of code
void execute_line(const std::string& line, Environment& env) {
    if (line.empty() || line[0] == '#') return;
    
    std::string trimmed = line;
    trimmed.erase(0, trimmed.find_first_not_of(" \t\r\n"));
    trimmed.erase(trimmed.find_last_not_of(" \t\r\n") + 1);
    
    if (trimmed.substr(0, 5) == "write") {
        size_t start = trimmed.find('(');
        if (start != std::string::npos) {
            size_t end = trimmed.find_last_of(')');
            if (end != std::string::npos) {
                std::string text = trimmed.substr(start + 1, end - start - 1);
                // Remove quotes if present
                if (text.front() == '"' && text.back() == '"') {
                    text = text.substr(1, text.length() - 2);
                }
                std::cout << evaluate_string(text, env) << std::endl;
            }
        }
    } else if (trimmed.substr(0, 4) == "read") {
        std::string input;
        std::getline(std::cin, input);
        env.variables["_input"] = input;
    } else if (auto eq_pos = trimmed.find('='); eq_pos != std::string::npos) {
        std::string var_name = trimmed.substr(0, eq_pos);
        std::string value = trimmed.substr(eq_pos + 1);
        
        // Clean up variable name and value
        var_name.erase(0, var_name.find_first_not_of(" \t\r\n"));
        var_name.erase(var_name.find_last_not_of(" \t\r\n") + 1);
        value.erase(0, value.find_first_not_of(" \t\r\n"));
        value.erase(value.find_last_not_of(" \t\r\n") + 1);
        
        if (value == "read()") {
            std::string input;
            std::getline(std::cin, input);
            env.variables[var_name] = input;
        } else {
            env.variables[var_name] = evaluate_string(value, env);
        }
    }
}

// Find file in directory recursively
std::string find_file_recursive(const std::string& dir, const std::string& filename) {
    // Always add .seo extension if not present
    std::string target = filename;
    if (target.length() < 4 || target.substr(target.length() - 4) != ".seo") {
        target += ".seo";
    }
    
    for (const auto& entry : std::filesystem::recursive_directory_iterator(dir)) {
        if (entry.is_regular_file() && entry.path().extension() == ".seo") {
            if (entry.path().filename() == target) {
                return entry.path().string();
            }
        }
    }
    return "";
}

// Execute a Seoggi program
void execute_program(const std::string& filename) {
    std::string filepath;
    
    // Always ensure .seo extension
    std::string target = filename;
    if (target.length() < 4 || target.substr(target.length() - 4) != ".seo") {
        target += ".seo";
    }
    
    // 1. Try exact path first
    std::ifstream test_file(target);
    if (test_file.good()) {
        filepath = target;
        test_file.close();
    } else {
        // 2. Search recursively in current directory
        filepath = find_file_recursive(".", filename);
        
        // 3. If not found, try ~/.seoggi/examples
        if (filepath.empty()) {
            const char* home = getenv("HOME");
            if (home) {
                std::string examples_dir = std::string(home) + "/.seoggi/examples";
                filepath = find_file_recursive(examples_dir, filename);
            }
        }
    }
    
    if (filepath.empty()) {
        throw std::runtime_error("File not found: " + target + 
                               "\nNote: Only files with .seo extension are supported");
    }
    
    // Open and read the file
    std::ifstream file(filepath);
    if (!file.good()) {
        throw std::runtime_error("Could not open file: " + filepath);
    }

    std::stringstream buffer;
    buffer << file.rdbuf();
    std::string content = buffer.str();
    
    log_message(LogLevel::INFO, "Running program...");
    
    // Create environment
    Environment env = create_environment();
    
    // Simple interpreter for basic commands
    std::istringstream iss(content);
    std::string line;
    while (std::getline(iss, line)) {
        execute_line(line, env);
    }
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cout << COLOR_BLUE << "Usage: seo <command> [filename]\n" << COLOR_RESET;
        std::cout << "Commands:\n";
        std::cout << "  exec    - Execute a program\n";
        std::cout << "  version - Display version information\n";
        return 1;
    }

    std::string command = argv[1];
    std::string filename = argc > 2 ? argv[2] : "";

    try {
        if (command == "version") {
            std::cout << "Seoggi " << VERSION << "\n";
            std::cout << "Created by " << AUTHOR << "\n";
            std::cout << "Licensed under " << LICENSE << "\n";
            return 0;
        } else if (command == "exec") {
            execute_program(filename);
        } else {
            throw std::runtime_error("Unknown command: " + command);
        }
    } catch (const std::exception& e) {
        log_message(LogLevel::ERROR, e.what());
        return 1;
    }

    return 0;
}

} // namespace compiler
} // namespace seoggi

int main(int argc, char* argv[]) {
    return seoggi::compiler::main(argc, argv);
}
