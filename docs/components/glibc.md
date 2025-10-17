# glibc Documentation

## Overview

GNU C Library with RISC-V MTE support.

## Build Information

- **Build Script**: `scripts/build-glibc.sh`
- **Installation**: `/opt/riscv/sysroot/`
- **Configuration**: `--enable-memory-tagging`

## Official Documentation

- [glibc Official Manual](https://www.gnu.org/software/libc/manual/)
- [glibc GitHub Repository](https://github.com/bminor/glibc)

## MTE Features

- Automatic heap tagging in `malloc()`
- Tag checking in `free()`
- Tag propagation in `realloc()`

See [Installation Guide](../Installation.md#step-5-build-glibc) for build details.