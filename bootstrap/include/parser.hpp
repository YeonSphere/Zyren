#pragma once
#include "lexer.hpp"
#include <memory>
#include <vector>

enum class NodeType {
    FUNCTION_DEF,
    VARIABLE_DEF,
    EXPRESSION,
    STATEMENT,
    TYPE
};

struct ASTNode {
    NodeType type;
    std::string value;
    std::vector<std::unique_ptr<ASTNode>> children;
    
    ASTNode(NodeType t, std::string v) : type(t), value(std::move(v)) {}
};

class Parser {
public:
    explicit Parser(Lexer& lexer);
    std::unique_ptr<ASTNode> parse();

private:
    Lexer& lexer;
    Token currentToken;
    
    void advance();
    bool match(TokenType type);
    bool expect(TokenType type);
    
    std::unique_ptr<ASTNode> parseFunction();
    std::unique_ptr<ASTNode> parseVariable();
    std::unique_ptr<ASTNode> parseExpression();
    std::unique_ptr<ASTNode> parseStatement();
    std::unique_ptr<ASTNode> parseType();
};
