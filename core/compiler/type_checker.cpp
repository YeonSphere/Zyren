#include "seoggi/compiler/type_checker.hpp"
#include <iostream>

namespace seoggi {
namespace compiler {

extern const char* COLOR_BLUE;
extern const char* COLOR_RESET;

void initialize_type_checker() {
    std::cout << COLOR_BLUE << "[INFO]" << COLOR_RESET << " Initializing type checker...\n";
}

} // namespace compiler
} // namespace seoggi
