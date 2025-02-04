# Contributing to Seoggi

Thank you for considering contributing to Seoggi! We welcome contributions from everyone and are excited to welcome you aboard.

## Table of Contents
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Submitting Changes](#submitting-changes)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Code of Conduct](#code-of-conduct)
- [Getting Help](#getting-help)

## Getting Started

### Prerequisites
- Git
- Bash (Linux/macOS) or Git Bash (Windows)
- Basic development tools (gcc/clang/mingw)

### Setup Development Environment
1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Seoggi.seo.git
   cd Seoggi.seo
   ```
3. Run setup script:
   ```bash
   ./setup.sh
   ```
4. Source the environment:
   ```bash
   # Linux/macOS:
   source bin/seoggi.env
   
   # Windows:
   bin\seoggi.env.bat
   ```

## Development Process

### Branches
- `main`: Stable release branch
- `develop`: Main development branch
- `feature/*`: New features
- `fix/*`: Bug fixes
- `docs/*`: Documentation changes

### Working on Features
1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. Make your changes
3. Write tests
4. Update documentation
5. Commit changes
6. Push to your fork
7. Create a Pull Request

## Submitting Changes

### Pull Request Process
1. Update the README.md with details of changes if needed
2. Update the documentation
3. Add tests for new functionality
4. Ensure all tests pass
5. Update the CHANGELOG.md
6. Get approval from maintainers

### Commit Messages
Follow the conventional commits specification:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `test`: Adding tests
- `refactor`: Code refactoring
- `style`: Code style changes
- `chore`: Maintenance tasks

Example:
```
feat(web): add HTTP/2 support

- Implement HTTP/2 protocol
- Add stream multiplexing
- Update documentation
```

## Coding Standards

### General Guidelines
- Use 4 spaces for indentation
- Keep lines under 100 characters
- Use meaningful variable and function names
- Write self-documenting code
- Add comments for complex logic

### Language-Specific Standards
```seoggi
// Good
module MyModule {
    fn process_data(input: str) -> Result<int, Error> {
        // Implementation
    }
}

// Bad
module mymodule {
    fn processdata(i: str) -> Result<int, Error> {
        // Implementation
    }
}
```

## Testing Guidelines

### Writing Tests
1. Create test files in the appropriate `/tests` directory
2. Name tests descriptively
3. Test both success and failure cases
4. Use meaningful assertions

Example:
```seoggi
module Test {
    use Test
    
    fn test_data_processing() {
        input = "test data"
        result = process_data(input)
        Test.assert_eq(result, expected)
    }
}
```

### Running Tests
```bash
seo test                 # Run all tests
seo test web            # Run web tests
seo test ai             # Run AI tests
seo test kernel         # Run kernel tests
```

## Documentation

### Code Documentation
- Document all public APIs
- Include examples in documentation
- Keep documentation up to date
- Use clear and concise language

Example:
```seoggi
/// Processes input data and returns a result
/// 
/// # Arguments
/// * `input` - The input string to process
/// 
/// # Returns
/// * `Result<int, Error>` - The processed result or an error
/// 
/// # Examples
/// ```seoggi
/// result = process_data("test")
/// assert_eq(result, Ok(42))
/// ```
fn process_data(input: str) -> Result<int, Error> {
    // Implementation
}
```

### Project Documentation
- Keep README.md up to date
- Document new features
- Update API documentation
- Add examples for new functionality

## Code of Conduct
We are committed to fostering a welcoming and inclusive community. Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## Getting Help
- Join our [Discord](https://discord.gg/)
- Check the [Documentation](https://yeonsphere.io/seoggi.seo/docs/)
- Ask in GitHub Discussions
- Contact the maintainers

Thank you for contributing to Seoggi! 
