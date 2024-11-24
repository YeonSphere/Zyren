#pragma once
#include "parser.hpp"
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/IRBuilder.h>
#include <memory>
#include <string>

class CodeGenerator {
public:
    CodeGenerator();
    std::unique_ptr<llvm::Module> generateCode(const ASTNode& ast);
    void writeToFile(const std::string& filename);

private:
    std::unique_ptr<llvm::LLVMContext> context;
    std::unique_ptr<llvm::Module> module;
    std::unique_ptr<llvm::IRBuilder<>> builder;
    
    llvm::Value* generateFunction(const ASTNode& node);
    llvm::Value* generateVariable(const ASTNode& node);
    llvm::Value* generateExpression(const ASTNode& node);
    llvm::Value* generateStatement(const ASTNode& node);
    llvm::Type* generateType(const ASTNode& node);
};
