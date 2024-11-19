# Seoggi Programming Language

[![CI](https://github.com/YeonSphere/Seoggi/actions/workflows/ci.yml/badge.svg)](https://github.com/YeonSphere/Seoggi/actions/workflows/ci.yml)
[![Rust](https://img.shields.io/badge/Rust-1.75.0-orange.svg)](https://www.rust-lang.org)
[![License](https://img.shields.io/badge/License-YUOSL-purple)](LICENSE)
[![codecov](https://codecov.io/gh/YeonSphere/Seoggi/branch/main/graph/badge.svg)](https://codecov.io/gh/YeonSphere/Seoggi)
[![Security Audit](https://github.com/YeonSphere/Seoggi/actions/workflows/ci.yml/badge.svg?event=schedule)](https://github.com/YeonSphere/Seoggi/security/advisories)

## Overview
Seoggi is a versatile programming language designed for modern computing challenges. It seamlessly integrates web development, AI/ML capabilities, and system-level programming into a single, cohesive language.

## Features
- **Universal Context Switching**: Write code that adapts to web, AI, or kernel contexts
- **Modern Web Development**: Built-in HTTP server and JSON handling
- **AI/ML Integration**: Neural network and tensor operations support
- **System Programming**: Direct kernel module and device driver development
- **Cross-Platform**: Runs on Linux, macOS, and Windows

## Project Structure
```
seoggi/
├── ai/              # AI/ML related modules
├── bin/             # Compiled binaries
├── core/            # Core language implementation
│   ├── compiler/    # Compiler components
│   ├── types/       # Type system
│   └── runtime/     # Runtime environment
├── docs/            # Documentation
├── examples/        # Example programs
│   ├── ai/          # AI/ML examples
│   ├── kernel/      # Kernel module examples
│   └── web/         # Web development examples
├── kernel/          # Kernel-related modules
├── lib/             # Standard library
├── tests/           # Test suite
├── tools/           # Development tools
└── web/             # Web-related modules
```

## Quick Start
1. Clone the repository:
   ```bash
   git clone https://github.com/YeonSphere/Seoggi.git
   cd Seoggi
   ```

2. Run the setup script:
   ```bash
   ./setup.sh
   ```

3. Source the environment:
   ```bash
   # Linux/macOS:
   source bin/seoggi.env
   
   # Windows:
   bin\seoggi.env.bat
   ```

4. Try some examples:
   ```bash
   # Basic examples
   seo exec hello_world
   seo exec calculator
   
   # Advanced examples
   seo exec web/server        # HTTP server
   seo exec ai/model         # Neural network
   seo exec kernel/module    # Kernel driver
   ```

## Development Status
- Version: 0.1.0 (Early Development)
- License: YeonSphere Universal Open Source License (YUOSL)

## Example Programs

### Web Server
```seoggi
module Main {
    use Web
    use JSON
    
    fn handle_root(req: Web.Request) -> Web.Response {
        return Web.Response {
            status: 200,
            body: "<h1>Welcome to Seoggi!</h1>"
        }
    }
}
```

### AI Model
```seoggi
module Main {
    use AI
    use Tensor
    
    fn create_model() -> AI.Model {
        return AI.Sequential([
            AI.Layer.Dense(128, "relu"),
            AI.Layer.Dense(10, "softmax")
        ])
    }
}
```

### Kernel Module
```seoggi
module Main {
    use Kernel
    use Memory
    
    fn module_init() {
        device = init_device()
        Kernel.register_device(device)
    }
}
```

## Contributing
We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on our code of conduct and development process.

## Community
- [Discord Chat](https://discord.gg/seoggi)
- [Twitter](https://twitter.com/YeonSphere)
- [Documentation](https://seoggi.dev/docs)

## License

This project is licensed under the YeonSphere Universal Open Source License (YUOSL). Key points:
- 10% revenue share for commercial use
- 30-day response window for inquiries
- Contact @daedaevibin for commercial licensing
- See the [LICENSE](LICENSE) file for full details

## Contact

- Primary Contact: Jeremy Matlock (@daedaevibin)
- Email: daedaevibin@naver.com
