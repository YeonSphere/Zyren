#include "lexer.hpp"
#include <cctype>
#include <stdexcept>
#include <unordered_set>

static const std::unordered_set<std::string> KEYWORDS = {
    "fn", "let", "mut", "if", "else", "while", "return",
    "type", "struct", "enum", "trait", "impl",
    "pub", "unsafe", "extern", "quantum"
};

Lexer::Lexer(const std::string& source) : source(source) {}

char Lexer::peek() const {
    if (position >= source.length()) {
        return '\0';
    }
    return source[position];
}

char Lexer::advance() {
    char current = peek();
    if (current != '\0') {
        position++;
        if (current == '\n') {
            line++;
            column = 1;
        } else {
            column++;
        }
    }
    return current;
}

void Lexer::skipWhitespace() {
    while (std::isspace(peek())) {
        advance();
    }
}

Token Lexer::readIdentifier() {
    std::string value;
    size_t startColumn = column;
    
    while (std::isalnum(peek()) || peek() == '_') {
        value += advance();
    }
    
    TokenType type = isKeyword(value) ? TokenType::KEYWORD : TokenType::IDENTIFIER;
    return {type, value, line, startColumn};
}

Token Lexer::readNumber() {
    std::string value;
    size_t startColumn = column;
    
    while (std::isdigit(peek()) || peek() == '.') {
        value += advance();
    }
    
    return {TokenType::NUMBER, value, line, startColumn};
}

Token Lexer::readString() {
    std::string value;
    size_t startColumn = column;
    
    // Skip opening quote
    advance();
    
    while (peek() != '"' && peek() != '\0') {
        if (peek() == '\\') {
            advance(); // Skip escape character
            value += advance();
        } else {
            value += advance();
        }
    }
    
    if (peek() == '"') {
        advance(); // Skip closing quote
    } else {
        throw std::runtime_error("Unterminated string literal");
    }
    
    return {TokenType::STRING, value, line, startColumn};
}

Token Lexer::readOperator() {
    std::string value;
    size_t startColumn = column;
    
    static const std::string OPERATORS = "+-*/%=<>!&|^~.";
    while (OPERATORS.find(peek()) != std::string::npos) {
        value += advance();
    }
    
    return {TokenType::OPERATOR, value, line, startColumn};
}

bool Lexer::isKeyword(const std::string& word) const {
    return KEYWORDS.find(word) != KEYWORDS.end();
}

Token Lexer::nextToken() {
    skipWhitespace();
    
    char c = peek();
    if (c == '\0') {
        return {TokenType::EOF_TOKEN, "", line, column};
    }
    
    if (std::isalpha(c) || c == '_') {
        return readIdentifier();
    }
    
    if (std::isdigit(c)) {
        return readNumber();
    }
    
    if (c == '"') {
        return readString();
    }
    
    static const std::string OPERATORS = "+-*/%=<>!&|^~.";
    if (OPERATORS.find(c) != std::string::npos) {
        return readOperator();
    }
    
    static const std::string PUNCTUATION = "(){}[];,";
    if (PUNCTUATION.find(c) != std::string::npos) {
        return {TokenType::PUNCTUATION, std::string(1, advance()), line, column - 1};
    }
    
    throw std::runtime_error("Invalid character: " + std::string(1, c));
}

bool Lexer::hasMoreTokens() const {
    return position < source.length();
}
