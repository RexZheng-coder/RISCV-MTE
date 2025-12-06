# GCC Documentation

## Overview

GCC Full compiler (Stage 2) with complete C/C++ support, **patched for RISC-V Zimte extension**.

## Source Code & Modifications

- **Repository**: [RexZheng-coder/gcc](https://gitlab.com/RexZheng-coder/gcc)
- **Modifications**:
  - Added support for the `-march=rv64gc_zimte` architecture string.
  - Enabled code generation compatibility for Zimte extension instructions.

## Build Information

- **Version**: 14.2.0 (Custom Branch)
- **Build Script**: `scripts/build-gcc-final.sh`
- **Installation**: `/opt/riscv/bin/riscv64-unknown-linux-gnu-gcc`

To build from source using the provided scripts:
```bash
# Ensure the script clones from [gitlab.com/RexZheng-coder/gcc](https://gitlab.com/RexZheng-coder/gcc)
bash scripts/build-gcc-final.sh
```

## Supported Languages

- C (gcc)
- C++ (g++)

## Quick Start

To compile code with MTE support, you must specify the architecture:

```
# Compile C with Zimte support
riscv64-unknown-linux-gnu-gcc -march=rv64gc_zimte -O3 hello.c -o hello

# Compile C++ with Zimte support
riscv64-unknown-linux-gnu-g++ -march=rv64gc_zimte -O3 hello.cpp -o hello
```

See [Testing Guide](https://www.google.com/search?q=../Testing.md) for more examples.


