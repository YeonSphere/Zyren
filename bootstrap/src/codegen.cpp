#include "codegen.hpp"
#include <llvm/Support/raw_ostream.h>
#include <llvm/Support/FileSystem.h>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Constants.h>
#include <fstream>
#include <sstream>

CodeGenerator::CodeGenerator() {
    context = std::make_unique<llvm::LLVMContext>();
    module = std::make_unique<llvm::Module>("seoggi_module", *context);
    builder = std::make_unique<llvm::IRBuilder<>>(*context);
}

std::unique_ptr<llvm::Module> CodeGenerator::generateCode(const ASTNode& ast) {
    for (const auto& child : ast.children) {
        switch (child->type) {
            case NodeType::FUNCTION_DEF:
                generateFunction(*child);
                break;
            case NodeType::VARIABLE_DEF:
                generateVariable(*child);
                break;
            case NodeType::STATEMENT:
                generateStatement(*child);
                break;
            default:
                break;
        }
    }
    
    return std::move(module);
}

llvm::Value* CodeGenerator::generateFunction(const ASTNode& node) {
    std::vector<llvm::Type*> paramTypes;
    std::vector<std::string> paramNames;
    
    // Process parameters
    for (const auto& param : node.children) {
        if (param->type == NodeType::VARIABLE_DEF) {
            paramNames.push_back(param->value);
            if (!param->children.empty()) {
                llvm::Type* paramType = generateType(*param->children[0]);
                paramTypes.push_back(paramType);
            }
        }
    }
    
    // Get return type
    llvm::Type* returnType = llvm::Type::getVoidTy(*context);
    for (const auto& child : node.children) {
        if (child->type == NodeType::TYPE) {
            returnType = generateType(*child);
            break;
        }
    }
    
    // Create function type
    llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, paramTypes, false);
    
    // Create function
    llvm::Function* func = llvm::Function::Create(
        funcType,
        llvm::Function::ExternalLinkage,
        node.value,
        module.get()
    );
    
    // Set parameter names
    unsigned idx = 0;
    for (auto& param : func->args()) {
        if (idx < paramNames.size()) {
            param.setName(paramNames[idx]);
        }
        idx++;
    }
    
    // Create entry block
    llvm::BasicBlock* bb = llvm::BasicBlock::Create(*context, "entry", func);
    builder->SetInsertPoint(bb);
    
    // Generate function body
    for (const auto& child : node.children) {
        if (child->type == NodeType::STATEMENT) {
            generateStatement(*child);
        }
    }
    
    // Add return instruction if needed
    if (!bb->getTerminator()) {
        if (returnType->isVoidTy()) {
            builder->CreateRetVoid();
        } else {
            builder->CreateRet(llvm::Constant::getNullValue(returnType));
        }
    }
    
    return func;
}

llvm::Value* CodeGenerator::generateVariable(const ASTNode& node) {
    llvm::Type* type = llvm::Type::getDoubleTy(*context); // Default to double
    
    // Get type if specified
    for (const auto& child : node.children) {
        if (child->type == NodeType::TYPE) {
            type = generateType(*child);
            break;
        }
    }
    
    // Create alloca instruction
    llvm::AllocaInst* alloca = builder->CreateAlloca(type, nullptr, node.value);
    
    // Generate initialization if present
    for (const auto& child : node.children) {
        if (child->type == NodeType::EXPRESSION) {
            llvm::Value* init = generateExpression(*child);
            builder->CreateStore(init, alloca);
            break;
        }
    }
    
    return alloca;
}

llvm::Value* CodeGenerator::generateExpression(const ASTNode& node) {
    // Very basic expression generation for bootstrap compiler
    if (node.children.empty()) {
        // Handle literals
        try {
            double value = std::stod(node.value);
            return llvm::ConstantFP::get(*context, llvm::APFloat(value));
        } catch (...) {
            // Not a number, treat as variable reference
            if (auto* F = builder->GetInsertBlock()->getParent()) {
                for (auto& arg : F->args()) {
                    if (arg.getName() == node.value) {
                        return &arg;
                    }
                }
            }
        }
    }
    
    // Default return
    return llvm::ConstantFP::get(*context, llvm::APFloat(0.0));
}

llvm::Value* CodeGenerator::generateStatement(const ASTNode& node) {
    if (node.value == "return") {
        if (!node.children.empty()) {
            llvm::Value* retVal = generateExpression(*node.children[0]);
            return builder->CreateRet(retVal);
        } else {
            return builder->CreateRetVoid();
        }
    }
    
    if (!node.children.empty()) {
        return generateExpression(*node.children[0]);
    }
    
    return nullptr;
}

llvm::Type* CodeGenerator::generateType(const ASTNode& node) {
    // Basic type mapping for bootstrap compiler
    if (node.value == "void") {
        return llvm::Type::getVoidTy(*context);
    } else if (node.value == "bool") {
        return llvm::Type::getInt1Ty(*context);
    } else if (node.value == "int") {
        return llvm::Type::getInt32Ty(*context);
    } else if (node.value == "float") {
        return llvm::Type::getFloatTy(*context);
    } else if (node.value == "double") {
        return llvm::Type::getDoubleTy(*context);
    }
    
    // Default to double
    return llvm::Type::getDoubleTy(*context);
}

void CodeGenerator::writeToFile(const std::string& filename) {
    // First generate LLVM IR
    std::string ir;
    llvm::raw_string_ostream os(ir);
    module->print(os, nullptr);
    
    // Now convert to C++
    std::ofstream outFile(filename);
    if (!outFile) {
        throw std::runtime_error("Could not open output file: " + filename);
    }
    
    // Write basic C++ header
    outFile << "#include <cstdint>\n";
    outFile << "#include <memory>\n";
    outFile << "#include <vector>\n\n";
    
    // Convert LLVM IR to C++
    // This is a very basic conversion that only handles simple functions
    std::istringstream iss(ir);
    std::string line;
    while (std::getline(iss, line)) {
        if (line.find("define") != std::string::npos) {
            // Convert function definition
            size_t nameStart = line.find("@") + 1;
            size_t nameEnd = line.find("(", nameStart);
            std::string funcName = line.substr(nameStart, nameEnd - nameStart);
            
            outFile << "extern \"C\" double " << funcName << "(";
            
            // Add parameters (simplified)
            outFile << ") {\n";
            outFile << "    return 0.0; // Placeholder\n";
            outFile << "}\n\n";
        }
    }
    
    outFile.close();
}
