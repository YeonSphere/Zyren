#ifndef SEO_COMPILER_H
#define SEO_COMPILER_H

// Shared definitions for the Seoggi bootstrap compiler

// Target architectures
typedef enum {
    TARGET_X86_64,
    TARGET_ARM64,
    TARGET_RISCV,
    TARGET_WASM
} Target;

// Operating systems
typedef enum {
    OS_WINDOWS,
    OS_LINUX,
    OS_MACOS,
    OS_WEB
} OS;

// Minimal IR instruction set
typedef enum {
    IR_LOAD,
    IR_STORE,
    IR_ADD,
    IR_SUB,
    IR_MUL,
    IR_DIV,
    IR_CALL,
    IR_RET
} IROpcode;

// Error handling
typedef enum {
    ERR_NONE,
    ERR_FILE_NOT_FOUND,
    ERR_SYNTAX_ERROR,
    ERR_TYPE_ERROR,
    ERR_SYSTEM_ERROR
} ErrorCode;

#endif // SEO_COMPILER_H
