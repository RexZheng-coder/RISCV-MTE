# GDB & Binutils Documentation

## Overview

GDB (GNU Debugger) and Binutils (Assembler/Linker) with **RISC-V Zimte instruction support**.

## Source Code & Modifications

- **Repository**: [RexZheng-coder/binutils-gdb](https://gitlab.com/RexZheng-coder/binutils-gdb)
- **Modifications**:
  - **Assembler (`gas`)**: Added opcode support for Zimte instructions: `gentag`, `settag`, `addtag`, etc.
  - **Debugger (`gdb`)**: Added support for inspecting MTE-tagged memory addresses.

## Build Information

- **Version**: Custom RISC-V Branch
- **Build Script**: Included in `scripts/build-binutils.sh` (or `build-all.sh`)
- **Installation**: 
  - GDB: `/opt/riscv/bin/riscv64-unknown-linux-gnu-gdb`
  - AS: `/opt/riscv/bin/riscv64-unknown-linux-gnu-as`
  - LD: `/opt/riscv/bin/riscv64-unknown-linux-gnu-ld`

## Official Documentation

- [GDB Official Manual](https://sourceware.org/gdb/documentation/)

## Quick Start

```bash
# Debugging a program
riscv64-unknown-linux-gnu-gdb ./program

# Remote debugging with QEMU
qemu-riscv64 -g 1234 ./program &
riscv64-unknown-linux-gnu-gdb ./program
(gdb) target remote :1234
```


## MTE Features

You can use the modified assembler to write inline assembly for MTE:

```
asm volatile("gentag %0, %1" : "=r"(tagged_ptr) : "r"(ptr));
```
