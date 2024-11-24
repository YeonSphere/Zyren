#pragma once
#include <string>
#include <vector>

enum class TokenType {
    IDENTIFIER,
    NUMBER,
    STRING,
    OPERATOR,
    KEYWORD,
    PUNCTUATION,
    EOF_TOKEN
};

struct Token {
    TokenType type;
    std::string value;
    size_t line;
    size_t column;
};

class Lexer {
public:
    explicit Lexer(const std::string& source);
    Token nextToken();
    bool hasMoreTokens() const;

private:
    std::string source;
    size_t position = 0;
    size_t line = 1;
    size_t column = 1;
    
    char peek() const;
    char advance();
    void skipWhitespace();
    Token readIdentifier();
    Token readNumber();
    Token readString();
    Token readOperator();
    bool isKeyword(const std::string& word) const;
};
