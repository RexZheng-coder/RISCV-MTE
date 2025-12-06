# Scudo Hardened Allocator for RISC-V Zimte (MTE)

## Overview

This directory contains a modified version of the **LLVM Scudo Standalone Allocator**, ported to support the **RISC-V Zimte (Zimop + Ssnpm + Zimte)** hardware extension for Memory Tagging Extension (MTE).

This implementation allows Scudo to utilize RISC-V hardware instructions (such as `gentag`, `settag`) to provide fine-grained memory safety, detecting Heap Buffer Overflows and Use-After-Free vulnerabilities with low overhead.

## Key Modifications

Unlike the standard Scudo allocator (which primarily supports AArch64 MTE), this version introduces specific support for the RISC-V Zimte specification:

1.  **Architecture Backend (`memtag_zimte.h` / `memtag.h`)**:
      * Implemented RISC-V specific inline assembly for MTE operations.
      * **GENTAG**: Generates random tags for pointers.
      * **SETTAG**: Stores tags into Shadow Memory (associated with the Zimte extension).
2.  **Runtime Control**:
      * Added environment variable checks (`SCUDO_MTE_ENABLE`) to dynamically enable/disable MTE logic at runtime, facilitating performance A/B testing.
3.  **GCC Compatibility**:
      * Patched headers and source files to ensure compatibility with the RISC-V GCC toolchain (standard Scudo depends heavily on Clang-specific builtins).

## Directory Structure

Key files relevant to the Zimte port:

  * **`memtag.h`**: The core MTE abstraction layer. Modified to detect RISC-V architecture (`SCUDO_ZIMTE`) and dispatch calls to Zimte implementation.
  * **`memtag_zimte.h`**: (Optional) Contains RISC-V specific definitions and inline assembly macros for `gentag`, `settag`, etc.
  * **`allocator_config.h`**: Configuration definitions defining the allocator layout (Primary/Secondary) suitable for embedded or Linux environments.
  * **`wrappers_c.cpp`**: Implements the C-style `malloc`/`free` wrappers to replace the system allocator.

## Build Instructions

This version of Scudo is designed to be built as a **Standalone Library** using `g++` (RISC-V Toolchain).

### 1\. Prerequisites

  * **RISC-V GNU Toolchain**: Support for `rv64gc` or `rv64gc_zimte`.
  * **QEMU (User Mode)**: Must support `zimte` extension (patched version recommended).

### 2\. Compilation Flags

To compile Scudo with Zimte support, the following flags are mandatory:

```bash
# Core Architecture Flags
-march=rv64gc_zimte

# Scudo Specific Macros
-DSCUDO_STANDALONE_BUILD=1
-DSCUDO_ZIMTE=1
-DSCUDO_CAN_USE_MTE=1
```

### 3\. Example Build Script (Static Link)

Since Scudo is C++17 and many benchmarks (like CoreMark) are C, a **Separate Compilation** approach is recommended:

```bash
# 1. Compile Scudo sources (C++)
riscv64-unknown-linux-gnu-g++ -std=c++17 -O3 -march=rv64gc_zimte \
    -DSCUDO_STANDALONE_BUILD=1 -DSCUDO_ZIMTE=1 -DSCUDO_CAN_USE_MTE=1 \
    -I./include -I. \
    -c checksum.cpp common.cpp flags.cpp ... (all .cpp files)

# 2. Compile your application (C)
riscv64-unknown-linux-gnu-gcc -O3 -march=rv64gc_zimte \
    -c main.c -o main.o

# 3. Link together
riscv64-unknown-linux-gnu-g++ -march=rv64gc_zimte \
    *.o main.o -o my_app_scudo \
    -lpthread -ldl -latomic -lrt
```

## Usage & Configuration

Once compiled, the allocator's behavior can be controlled via environment variables.

### Enabling MTE

To enable Memory Tagging checks at runtime:

```bash
# 1. Enable Scudo's internal MTE logic (if modified to check this env var)
export SCUDO_MTE_ENABLE=1

# 2. Standard Scudo Options (Force MTE on)
export SCUDO_OPTIONS="UseMte=1"

# 3. Run with QEMU (Ensure Zimte CPU flags are set)
QEMU_CPU="rv64,zimop=true,ssnpm=true,zimte=true,pmlen=7,ptw=4" \
./my_app_scudo
```

### Disabling MTE (Baseline Performance)

To run as a standard allocator without MTE overhead:

```bash
unset SCUDO_MTE_ENABLE
export SCUDO_OPTIONS="UseMte=0"
./my_app_scudo
```

## Performance Note

Based on CoreMark benchmarks in QEMU user-mode emulation:

  * **MTE Overhead**: \~15-18% compared to Glibc baseline.
  * **Memory Overhead**: Minimal (\~3-5%) due to hardware tagging efficiency compared to software Redzones (ASan).

## References

  * [RISC-V Zimte Specification](https://www.google.com/search?q=https://github.com/riscv/riscv-zimte)
  * [LLVM Scudo Documentation](https://llvm.org/docs/ScudoHardenedAllocator.html)
