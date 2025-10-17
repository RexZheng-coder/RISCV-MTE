# GCC Documentation

## Overview

GCC Full compiler (Stage 2) with complete C/C++ support.

## Build Information

- **Version**: 14.2.0
- **Build Script**: `scripts/build-gcc-final.sh`
- **Installation**: `/opt/riscv/bin/riscv64-unknown-linux-gnu-gcc`

## Official Documentation

- [GCC Official Manual](https://gcc.gnu.org/onlinedocs/gcc-14.2.0/gcc/)
- [GCC GitHub Repository](https://github.com/gcc-mirror/gcc)

## Supported Languages

- C (gcc)
- C++ (g++)

## Quick Start

```bash
# Compile C
riscv64-unknown-linux-gnu-gcc hello.c -o hello

# Compile C++
riscv64-unknown-linux-gnu-g++ hello.cpp -o hello
```

See [Testing Guide](../Testing.md) for more examples.
