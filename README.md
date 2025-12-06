# RISC-V Memory Tagging Extension Software Toolchain

A complete cross-compilation toolchain and benchmarking suite for RISC-V with Memory Tagging Extension (MTE) support. This project integrates industry-standard components (GCC, glibc, QEMU, LLVM Scudo) to enable hardware-assisted memory safety research on RISC-V.

## Overview

Memory Tagging Extension (MTE) is a hardware security feature that detects memory safety vulnerabilities (like buffer overflows and use-after-free) with low overhead. This project provides a fully integrated environment including:

- **GCC Toolchain**: Full cross-compilation support (GCC 14.2, Binutils 2.43) patched for Zimte instructions (`gentag`, `settag`, etc.).
- **QEMU User Mode**: Patched emulator with full Zimte logic support, custom shadow memory implementation, and fixes for syscall compatibility (e.g., handling tagged pointers in `write`).
- **glibc MTE**: Standard C library configured for automatic heap tagging.
- **LLVM Scudo**: A hardened memory allocator ported to RISC-V Zimte, enabling fine-grained memory safety with dynamic MTE toggling.
- **CoreMark Benchmark**: Integrated performance testing suite to quantify MTE hardware overhead.

## Quick Start

```bash
# Clone repository
git clone [https://github.com/EECS6894/RISCV-MTE.git](https://github.com/EECS6894/RISCV-MTE.git)
cd RISCV-MTE

# Install dependencies
./scripts/setup-environment.sh

# Build generic toolchain (GCC, Glibc, QEMU)
./scripts/build-all.sh

# Run validation tests
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
|[Scudo Guide](LLVM_SCUDO_MTE/README.md)| LLVM Scudo allocator build and usage|

## Project Status

| Component      | Status       | Notes                                  |
| -------------- | ------------ | -------------------------------------- |
| GDB            | Complete     | MTE debugging supported                |
| glibc          | Complete     | MTE-aware `malloc`/`free`              |
| QEMU           | Complete     | Includes syscall fixes & debug logging |
| GCC Full       | Complete     | Version 14.2.0                         |
| LLVM Scudo | Complete | Ported to RISC-V Zimte     |
| CoreMark       | Complete     | Benchmarking suite integrated          |

## Performance Benchmarks

We evaluated the overhead of the RISC-V Zimte extension using the CoreMark benchmark in QEMU user-mode emulation.

| Allocator           | MTE State | Iterations/Sec | Overhead         |
| :------------------ | :-------- | :------------- | :--------------- |
| **Glibc (Default)** | **OFF**   | **498.88**     | **- (Baseline)** |
| **Glibc**           | **ON**    | **424.12**     | **14.98%**       |
| **Scudo**           | **ON**    | **410.90**     | **17.63%**       |

> **Key Finding**: Hardware MTE introduces a modest **\~17% overhead** in emulation, which is significantly lower than software-based sanitizers (like ASan, typically \>100% overhead), validating the efficiency of the architecture.

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
