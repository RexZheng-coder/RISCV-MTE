# glibc Documentation

## Overview

GNU C Library with **RISC-V MTE (Zimte) support** for heap memory tagging.

## Source Code & Modifications

- **Repository**: [RexZheng-coder/glibc](https://gitlab.com/RexZheng-coder/glibc)
- **Modifications**:
  - Implemented `malloc`/`free` hooks to utilize Zimte instructions.
  - Added support for `GLIBC_TUNABLES=glibc.mem.tagging=1` on RISC-V architecture.
  - Patched memory allocator to tag heap chunks when enabled.

## Build Information

- **Build Script**: `scripts/build-glibc.sh`
- **Installation**: `/opt/riscv/sysroot/`
- **Configuration**: Compiled with `--enable-memory-tagging`

## Usage (Enabling MTE)

MTE is disabled by default in Glibc. You must enable it via environment variables when running your program:

```bash
# Enable Heap Tagging
export GLIBC_TUNABLES=glibc.mem.tagging=1
./your_program
```
## MTE Features

- **Automatic Tagging**: `malloc()` returns tagged pointers.
- **Tag Checking**: `free()` checks if the pointer tag matches the memory tag.
- **Tag Propagation**: `realloc()` preserves or updates tags correctly.

