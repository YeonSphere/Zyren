#pragma once

#include <string>

namespace seoggi {
namespace compiler {

enum class OptimizationLevel {
    None,
    Basic,
    Aggressive
};

class SeoggiBackend {
public:
    SeoggiBackend();
    
    // Compilation pipeline
    void compile(const std::string& source_file, const std::string& output_file);
    void optimize(OptimizationLevel level);
    
    // Code generation
    void emit_ir();
    void emit_binary();
    
private:
    // TODO: Add backend state
};

} // namespace compiler
} // namespace seoggi
