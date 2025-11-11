# RISC-V Memory Tagging Extension Software Toolchain

A complete cross-compilation toolchain for RISC-V with Memory Tagging Extension (MTE) support, based on Vrull GmbH's implementation with comprehensive documentation and automation.

## Overview

Memory Tagging Extension (MTE) is a hardware security feature that detects memory safety vulnerabilities. This project provides:

- **GDB** with MTE debugging support (Complete)
- **glibc** with MTE-aware memory allocation (Complete)
- **QEMU** user mode with MTE emulation (Complete)
- **GCC Bootstrap** for cross-compilation (Complete)
- **GCC Full** (In Progress)

## Quick Start

```bash
# Clone repository
git clone https://github.com/EECS6894/RISCV-MTE.git
cd RISCV-MTE

# Install dependencies
./scripts/setup-environment.sh

# Build all components
./scripts/build-all.sh

# Run tests
./scripts/run-all-tests.sh
```

## Prerequisites

- **OS**: Ubuntu 22.04/24.04 LTS
- **CPU**: x86_64, 8+ cores recommended
- **RAM**: 16GB minimum (32GB recommended)
- **Disk**: 50GB+ free space

## Documentation

| Document | Description |
|----------|-------------|
| [Installation Guide](docs/Installation.md) | Setup instructions |
| [Testing Guide](docs/Testing.md) | Test procedures and validation |
| [GDB Guide](docs/components/gdb.md) | GDB build and usage |
| [glibc Guide](docs/components/glibc.md) | glibc build and usage |
| [QEMU Guide](docs/components/qemu.md) | QEMU build and usage |
| [GCC Bootstrap Guide](docs/components/gcc-bootstrap.md) | GCC Bootstrap build |
| [GCC Guide](docs/components/gcc.md) | GCC Full build |


## Project Status

| Component | Status | Documentation |
|-----------|--------|---------------|
| GDB | Complete | [Guide](docs/components/gdb.md) |
| glibc | Complete | [Guide](docs/components/glibc.md) |
| QEMU | Complete | [Guide](docs/components/qemu.md) |
| GCC Bootstrap | Complete | [Guide](docs/components/gcc-bootstrap.md) |
| GCC Full | In Progress | [Guide](docs/components/gcc.md) |

**Overall Progress**: 80%

## Project Structure

```
RISCV-MTE/
├── docs/                              # Documentation
│   ├── Installation.md                # Build and install guide
│   ├── README.md                      # This file
│   └── Testing.md                     # Testing guide
│   └── components/
│       ├── gdb.md
│       ├── glibc.md
│       ├── qemu.md
│       ├── gcc-bootstrap.md
│       └── gcc.md
│
├── README.md                          # Project overview
├── LICENSE 
├── .gitignore 
│
├── scripts/                           # Build and test scripts
│   ├── build-all.sh                   # Build entire toolchain
│   ├── build-binutils.sh              # Build Binutils 2.43
│   ├── build-gcc-bootstrap.sh         # Build GCC stage 1
│   ├── build-gcc-final.sh             # Build GCC stage 2 (14.2.0)
│   ├── build-glibc.sh                 # Build Glibc 2.40 with MTE
│   ├── clean.sh                       # Clean build artifacts
│   ├── install-kernel-headers.sh      # Install Linux 6.11 headers
│   ├── run-all-tests.sh               # Run complete test suite
│   ├── setup-environment.sh           # Setup environment variables
│   └── verify-installation.sh         # Verify toolchain installation
│
└── tests/                             # Test files
    └── sources/                       # Test source code
        ├── assembly_test.c            # Assembly generation test
        ├── cpp_basic.cpp              # Basic C++ test
        ├── hello.c                    # Basic C test
        ├── main.c                     # Multi-file test (main)
        ├── math_utils.c               # Multi-file test (utils)
        ├── math_utils.h               # Multi-file test (header)
        ├── mte_test.c                 # MTE features test
        ├── mylib.c                    # Static library test (lib)
        ├── mylib.h                    # Static library test (header)
        ├── optimization_test.c        # Optimization levels test
        ├── preprocessor_test.c        # Preprocessor test
        ├── stdlib_test.c              # C standard library test
        ├── stl_test.cpp               # C++ STL test
        └── test_lib.c                 # Static library test (main)
```

## Known Issues

- **GCC Full compilation**: Fails in final stages
- **Test coverage**: Limited MTE functionality tests
- **Documentation**: Some advanced features documentation in progress

See [Testing Guide](docs/Testing.md) for details.

## Resources

- [RISC-V MTE Whitepaper](references/RISC-V-MTE-Whitepaper.pdf)
- [Vrull Implementation](https://gitlab.com/vrull-public)
- [RISC-V Official Site](https://riscv.org/)

## Team

**Course**: EECS 6894 - Hardware/Software Co-Design for Data Center Processing, Fall 2025  
**Institution**: Columbia University


- [Haohui Zheng] - [hz3078@columbia.edu]
- [Weihao Zhou] - [wz2750@columbia.edu]
- [Rui Li] - [rl3586@columbia.edu]
- [Charlotte Chen] - [hc3558@columbia.edu]

## License

Apache License - see [LICENSE](LICENSE) file

Third-party components (GDB, glibc, QEMU, GCC) retain their original licenses (GPL/LGPL).

## Acknowledgments

Based on [Vrull GmbH](https://vrull.eu/)'s RISC-V MTE implementation.

---

**Note**: Academic research project. Not production-ready.
