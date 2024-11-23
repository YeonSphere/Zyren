# Seoggi Programming Language

Seoggi is a modern, multi-paradigm programming language designed for building reliable, efficient, and maintainable software systems. It combines the best features of existing languages while introducing innovative concepts for handling effects, memory management, and concurrency.

## Documentation

📚 **All documentation has been moved to our website!**

Visit [yeonsphere.github.io/seoggi](https://yeonsphere.github.io/seoggi.html) for:
- Installation Guide
- Language Reference
- Tutorials & Examples
- API Documentation
- Best Practices
- Contributing Guidelines

## Installation

### Quick Install

For a standard installation to `/usr/local`:

```bash
sudo ./install.sh
```

For installation to a custom location:

```bash
./install.sh --prefix=/path/to/install
```

### Build from Source

1. Clone the repository:
```bash
git clone https://github.com/yeonsphere/seoggi.git
cd seoggi
```

2. Build and install:
```bash
./build.seo
sudo ./install.sh
```

### Requirements

- LLVM 15.0.0 or later
- Wasmtime 1.0.0 or later
- QuickJS 0.1.0 or later

## Quick Start

```bash
# Install Seoggi
curl -fsSL https://raw.githubusercontent.com/YeonSphere/Seoggi/main/bootstrap/install.sh | sh

# Create a new project
seoc new myproject
cd myproject

# Run your project
seoc run
```

## License

Seoggi is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Community

- Website: https://seoggi.dev
- Discord: https://discord.gg/seoggi
- Twitter: @seoggilang
- GitHub: https://github.com/YeonSphere/Seoggi
