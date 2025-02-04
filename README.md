# Seoggi Documentation

Seoggi is a modern, multi-paradigm programming language designed for building reliable, efficient, and maintainable software systems. It combines the best features of existing languages while introducing innovative concepts for handling effects, memory management, and concurrency.

## Overview

Seoggi is a modern, multi-paradigm programming language designed for building reliable, efficient, and maintainable software systems.

## Documentation

 **All documentation has been moved to our website!**

Visit [yeonsphere.github.io/seoggi](https://yeonsphere.github.io/seoggi.html) for:
- API Documentation
- Best Practices
- Contributing Guidelines
- Installation Guide
- Language Reference
- Tutorials & Examples

## Getting Started

### Installation

#### Quick Install

For a standard installation to `/usr/local`:

```bash
sudo ./install.seo
```

For installation to a custom location:

```bash
./install.seo --prefix=/path/to/install
```

#### Build from Source

1. Clone the repository:
```bash
git clone https://github.com/yeonsphere/seoggi.git
cd seoggi
```

2. Build and install:
```bash
./build.seo
sudo ./install.seo
```

#### Requirements

- LLVM 15.0.0 or later
- QuickJS 0.1.0 or later
- Wasmtime 1.0.0 or later

### Updater

To keep your Seoggi installation up to date, use the updater function included in the build script. Run the following command:
```bash
./build.sh update
```
This will pull the latest changes from the GitHub repository and prompt you to run the installer after building.

### Running Tests

To ensure that your installation is working correctly, you can run the unit tests included in the `tests` directory. Execute the following command:
```bash
./tests/unit_tests.seo
```
This will run all the unit tests and report any issues.

## Usage

### Quick Start

```bash
# Install Seoggi
curl -fsSL https://raw.githubusercontent.com/YeonSphere/Seoggi/main/bootstrap/install.seo | sh

# Create a new project
seoc new myproject
cd myproject

# Run your project
seoc run
```

### Examples

The `examples` directory contains several sample projects demonstrating the capabilities of Seoggi. You can explore these examples to understand how to use the language effectively.

## License

This project is licensed under the YeonSphere Universal Open Source License (YUOSL). Key points:
- 30-day response window for inquiries
- 5% revenue share for commercial use above $50,000
- Contact @daedaevibin for commercial licensing
- Free for personal use and revenue up to $50,000 annually
- See the [LICENSE](LICENSE) file for full details

## Community & Contact

- Discord: [Join our community](https://discord.gg/yeonsphere)
- Email: daedaevibin@naver.com
- GitHub: https://github.com/YeonSphere/Seoggi
- Primary Contact: Jeremy Matlock (@daedaevibin)
- Twitter: @seoggilang
- Website: https://seoggi.dev
