# GDB Documentation

## Overview

GDB (GNU Debugger) with RISC-V MTE support.

## Build Information

- **Version**: From riscv-gnu-toolchain
- **Build Script**: Included in `scripts/build-all.sh`
- **Installation**: `/opt/riscv/bin/riscv64-unknown-linux-gnu-gdb`

## Official Documentation

- [GDB Official Manual](https://sourceware.org/gdb/documentation/)
- [GDB GitHub Repository](https://github.com/bminor/binutils-gdb)

## Quick Start

```bash
# Basic usage
riscv64-unknown-linux-gnu-gdb ./program

# With QEMU
qemu-riscv64 -g 1234 ./program &
riscv64-unknown-linux-gnu-gdb ./program
(gdb) target remote :1234
```

## MTE Features

GDB supports debugging MTE-tagged memory. See [Installation Guide](../Installation.md#verification) for details.