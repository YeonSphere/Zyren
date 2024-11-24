#include "parser.hpp"
#include <stdexcept>

Parser::Parser(Lexer& lexer) : lexer(lexer) {
    advance();
}

void Parser::advance() {
    currentToken = lexer.nextToken();
}

bool Parser::match(TokenType type) {
    return currentToken.type == type;
}

bool Parser::expect(TokenType type) {
    if (!match(type)) {
        throw std::runtime_error("Unexpected token: " + currentToken.value);
    }
    advance();
    return true;
}

std::unique_ptr<ASTNode> Parser::parse() {
    auto root = std::make_unique<ASTNode>(NodeType::STATEMENT, "root");
    
    while (lexer.hasMoreTokens()) {
        if (match(TokenType::EOF_TOKEN)) {
            break;
        }
        
        if (match(TokenType::KEYWORD)) {
            if (currentToken.value == "fn") {
                root->children.push_back(parseFunction());
            } else if (currentToken.value == "let" || currentToken.value == "mut") {
                root->children.push_back(parseVariable());
            } else {
                root->children.push_back(parseStatement());
            }
        } else {
            root->children.push_back(parseStatement());
        }
    }
    
    return root;
}

std::unique_ptr<ASTNode> Parser::parseFunction() {
    expect(TokenType::KEYWORD); // 'fn'
    
    auto node = std::make_unique<ASTNode>(NodeType::FUNCTION_DEF, "function");
    
    // Function name
    expect(TokenType::IDENTIFIER);
    node->value = currentToken.value;
    
    // Parameters
    expect(TokenType::PUNCTUATION); // '('
    while (!match(TokenType::PUNCTUATION) || currentToken.value != ")") {
        if (match(TokenType::IDENTIFIER)) {
            auto param = std::make_unique<ASTNode>(NodeType::VARIABLE_DEF, currentToken.value);
            advance();
            
            expect(TokenType::PUNCTUATION); // ':'
            expect(TokenType::IDENTIFIER); // Type
            param->children.push_back(parseType());
            
            node->children.push_back(std::move(param));
            
            if (match(TokenType::PUNCTUATION) && currentToken.value == ",") {
                advance();
            }
        }
    }
    expect(TokenType::PUNCTUATION); // ')'
    
    // Return type
    if (match(TokenType::OPERATOR) && currentToken.value == "->") {
        advance();
        node->children.push_back(parseType());
    }
    
    // Function body
    expect(TokenType::PUNCTUATION); // '{'
    while (!match(TokenType::PUNCTUATION) || currentToken.value != "}") {
        node->children.push_back(parseStatement());
    }
    expect(TokenType::PUNCTUATION); // '}'
    
    return node;
}

std::unique_ptr<ASTNode> Parser::parseVariable() {
    expect(TokenType::KEYWORD); // 'let' or 'mut'
    bool isMutable = currentToken.value == "mut";
    
    auto node = std::make_unique<ASTNode>(NodeType::VARIABLE_DEF, isMutable ? "mutable" : "immutable");
    
    expect(TokenType::IDENTIFIER);
    node->value = currentToken.value;
    
    if (match(TokenType::PUNCTUATION) && currentToken.value == ":") {
        advance();
        node->children.push_back(parseType());
    }
    
    if (match(TokenType::OPERATOR) && currentToken.value == "=") {
        advance();
        node->children.push_back(parseExpression());
    }
    
    expect(TokenType::PUNCTUATION); // ';'
    
    return node;
}

std::unique_ptr<ASTNode> Parser::parseExpression() {
    auto node = std::make_unique<ASTNode>(NodeType::EXPRESSION, "expression");
    
    // Very basic expression parsing for the bootstrap compiler
    // Just handle literals and simple operators
    while (!match(TokenType::PUNCTUATION) || currentToken.value != ";") {
        if (match(TokenType::NUMBER) || match(TokenType::STRING) || match(TokenType::IDENTIFIER)) {
            node->children.push_back(std::make_unique<ASTNode>(NodeType::EXPRESSION, currentToken.value));
            advance();
        } else if (match(TokenType::OPERATOR)) {
            node->children.push_back(std::make_unique<ASTNode>(NodeType::EXPRESSION, currentToken.value));
            advance();
        } else {
            break;
        }
    }
    
    return node;
}

std::unique_ptr<ASTNode> Parser::parseStatement() {
    auto node = std::make_unique<ASTNode>(NodeType::STATEMENT, "statement");
    
    if (match(TokenType::KEYWORD)) {
        if (currentToken.value == "return") {
            advance();
            node->value = "return";
            if (!match(TokenType::PUNCTUATION) || currentToken.value != ";") {
                node->children.push_back(parseExpression());
            }
        } else if (currentToken.value == "if") {
            advance();
            node->value = "if";
            node->children.push_back(parseExpression());
            node->children.push_back(parseStatement());
            
            if (match(TokenType::KEYWORD) && currentToken.value == "else") {
                advance();
                node->children.push_back(parseStatement());
            }
            return node;
        }
    } else {
        node->children.push_back(parseExpression());
    }
    
    expect(TokenType::PUNCTUATION); // ';'
    return node;
}

std::unique_ptr<ASTNode> Parser::parseType() {
    auto node = std::make_unique<ASTNode>(NodeType::TYPE, "type");
    
    expect(TokenType::IDENTIFIER);
    node->value = currentToken.value;
    
    // Handle generic types
    if (match(TokenType::OPERATOR) && currentToken.value == "<") {
        advance();
        while (!match(TokenType::OPERATOR) || currentToken.value != ">") {
            node->children.push_back(parseType());
            if (match(TokenType::PUNCTUATION) && currentToken.value == ",") {
                advance();
            }
        }
        expect(TokenType::OPERATOR); // '>'
    }
    
    return node;
}
