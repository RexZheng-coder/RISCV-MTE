# QEMU Documentation

## Overview

QEMU user-mode emulation updated with **full RISC-V Zimte (MTE) Extension support**.

## Source Code & Modifications

- **Repository**: [RexZheng-coder/qemu](https://gitlab.com/RexZheng-coder/qemu)
- **Modifications**:
  1.  **Zimte Logic**: Implemented `Zimop`, `Ssnpm`, and `Zimte` extensions.
  2.  **Shadow Memory**: Implemented software-based shadow memory for storing 4-bit tags.
  3.  **Instruction Support**: Added helpers for `gentag`, `settag`, `addtag`, `ld`, `st` (with tag checks).
  4.  **Syscall Compatibility Patch (Critical)**: 
      - **Problem**: The Linux kernel's `write` syscall returns `EFAULT` when passed a tagged pointer (e.g., from `printf` buffers) because QEMU's user-mode emulation treats the tag as part of an invalid virtual address.
      - **Fix**: Patched `linux-user/syscall.c` to manually mask out the top byte (MTE tag) of pointers before invoking the host's `write` syscall.
  5.  **Debug Logging**: Added `ZIMTE_DEBUG` environment variable to control verbose logging.

## Build Information

- **Build Script**: 
  ```bash
  cd qemu
  mkdir build && cd build
  ../configure --target-list=riscv64-linux-user --prefix=/opt/riscv --disable-werror
  make -j$(nproc)
  make install
  ```
- **Installation**: `/opt/riscv/bin/qemu-riscv64`

## Quick Start

### Basic Execution

To run a RISC-V binary with MTE extensions enabled:

```bash
# Enable Zimte CPU properties
export QEMU_CPU="rv64,zimop=true,ssnpm=true,zimte=true,pmlen=7,ptw=4"

# Run the program
qemu-riscv64 ./program
```

### Enabling MTE with Glibc

Combine QEMU CPU flags with Glibc Tunables:

```bash
QEMU_CPU="rv64,zimop=true,ssnpm=true,zimte=true,pmlen=7,ptw=4" \
GLIBC_TUNABLES=glibc.mem.tagging=1 \
qemu-riscv64 ./program
```

### Debugging MTE

If you need to see QEMU's internal tag check logs (e.g., `helper_settag`, `riscv_mte_validate_tag`), enable the debug flag:


```bash
export ZIMTE_DEBUG=1
qemu-riscv64 ./program
```

See [Testing Guide](https://www.google.com/search?q=../Testing.md) for comprehensive usage examples.