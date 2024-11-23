# Seoggi Programming Language

Seoggi is a modern, multi-paradigm programming language designed for building reliable, efficient, and maintainable software systems. It combines the best features of existing languages while introducing innovative concepts for handling effects, memory management, and concurrency.

## Documentation

 **All documentation has been moved to our website!**

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

This project is licensed under the YeonSphere Universal Open Source License (YUOSL). Key points:
- Free for personal use and revenue up to $50,000 annually
- 5% revenue share for commercial use above $50,000
- 30-day response window for inquiries
- Contact @daedaevibin for commercial licensing
- See the [LICENSE](LICENSE) file for full details

## Community & Contact

- Primary Contact: Jeremy Matlock (@daedaevibin)
- Website: https://seoggi.dev
- Discord: [Join our community](https://discord.gg/yeonsphere)
- Twitter: @seoggilang
- GitHub: https://github.com/YeonSphere/Seoggi
- Email: daedaevibin@naver.com
