# glibc Documentation

## Overview

GNU C Library with **RISC-V MTE (Zimte) support** for heap memory tagging.

## Source Code & Modifications

- **Repository**: [vrull-public/glibc](https://gitlab.com/vrull-public/glibc), `riscv-mte` branch
- **Modifications**:
  - Implemented `malloc`/`free` hooks to utilize Zimte instructions.
  - Added support for `GLIBC_TUNABLES=glibc.mem.tagging=1` on RISC-V architecture.
  - Patched memory allocator to tag heap chunks when enabled.

## Build Information

- **Build Script**: `scripts/build-glibc.sh`
- **Installation**: `$PREFIX/$TARGET/` after `source env.sh`
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
