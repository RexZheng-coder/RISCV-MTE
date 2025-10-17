# QEMU Documentation

## Overview

QEMU user mode with RISC-V MTE emulation.

## Build Information

- **Version**: From riscv-gnu-toolchain
- **Build Script**: Included in `scripts/build-all.sh`
- **Installation**: `/opt/riscv/bin/qemu-riscv64`

## Official Documentation

- [QEMU Official Documentation](https://www.qemu.org/docs/master/)
- [QEMU GitHub Repository](https://github.com/qemu/qemu)

## Quick Start

```bash
# Run RISC-V binary
qemu-riscv64 ./program

# With debugging
qemu-riscv64 -g 1234 ./program
```

See [Testing Guide](../Testing.md) for usage examples.