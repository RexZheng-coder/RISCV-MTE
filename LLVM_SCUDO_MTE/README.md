# Scudo for RISC-V Zimte MTE

This directory contains the project version of LLVM's standalone Scudo allocator, adapted for the RISC-V Zimte memory-tagging experiment. It is the allocator-side companion to the patched toolchain and QEMU stack documented at the repository root.

The purpose of this port is to evaluate whether Scudo's MTE abstraction can be mapped onto RISC-V Zimte-style tagging so heap allocations can receive tags, tag metadata can be written through the target instructions, and runtime overhead can be compared with the glibc heap-tagging path.

## What Changed

| Area | Files | Role |
| --- | --- | --- |
| Zimte tag operations | `memtag_zimte.h`, `memtag.h` | Adds RISC-V-specific `gentag`, `addtag`, and `settag` paths. |
| Platform gating | `platform.h` | Allows the standalone allocator to recognize the `SCUDO_ZIMTE` configuration. |
| Runtime enablement | `memtag.h` | Uses `SCUDO_MTE_ENABLE` and Scudo options to support on/off comparisons. |
| C/C++ allocator wrappers | `wrappers_c.cpp`, `wrappers_cpp.cpp`, `wrappers_c.inc` | Exposes allocator entry points used when linking applications or benchmarks. |
| Compatibility work | allocator headers and support files | Keeps the standalone allocator buildable with the project RISC-V GNU toolchain. |

## Build Assumptions

This directory is not a full LLVM monorepo checkout. Treat it as a standalone allocator source tree used by the course project.

Required context:

- The repository-level RISC-V MTE toolchain has been built.
- `source ../env.sh` has been run from this directory, or `source env.sh` has been run from the repository root.
- The compiler accepts `-march=rv64gc_zimte`.
- The runtime target is QEMU user mode with Zimte CPU properties enabled.

## Important Build Flags

Use the same architecture and configuration flags consistently across Scudo objects and the final program:

```bash
-march=rv64gc_zimte
-DSCUDO_STANDALONE_BUILD=1
-DSCUDO_ZIMTE=1
-DSCUDO_CAN_USE_MTE=1
```

Scudo is C++17 code, so build allocator sources with the RISC-V `g++` driver even when the benchmark or application is written in C.

## Example Standalone Build Shape

The exact object list depends on the experiment, but the compile/link pattern is:

```bash
source ../env.sh

riscv64-unknown-linux-gnu-g++ -std=c++17 -O3 -march=rv64gc_zimte \
  -DSCUDO_STANDALONE_BUILD=1 -DSCUDO_ZIMTE=1 -DSCUDO_CAN_USE_MTE=1 \
  -I./include -I. \
  -c common.cpp flags.cpp flags_parser.cpp checksum.cpp report.cpp \
     string_utils.cpp timing.cpp release.cpp wrappers_c.cpp wrappers_cpp.cpp

riscv64-unknown-linux-gnu-gcc -O3 -march=rv64gc_zimte \
  -c ../tests/sources/mte_test.c -o mte_test.o

riscv64-unknown-linux-gnu-g++ -march=rv64gc_zimte \
  *.o mte_test.o -o mte_test_scudo \
  -lpthread -ldl -latomic -lrt
```

For benchmark work, keep Scudo objects and benchmark objects in a separate build directory so generated files do not pollute this source tree.

## Runtime Configuration

Enable the Zimte QEMU model:

```bash
export QEMU_CPU="rv64,zimop=true,ssnpm=true,zimte=true,pmlen=7,ptw=4"
```

Run with Scudo MTE enabled:

```bash
SCUDO_MTE_ENABLE=1 \
SCUDO_OPTIONS="UseMte=1" \
qemu-riscv64 ./mte_test_scudo
```

Run a baseline with Scudo MTE disabled:

```bash
unset SCUDO_MTE_ENABLE
SCUDO_OPTIONS="UseMte=0" \
qemu-riscv64 ./mte_test_scudo
```

## Engineering Notes

- Keep Zimte-specific behavior behind `SCUDO_ZIMTE` so upstream Scudo assumptions remain visible.
- Do not mix glibc heap tagging and Scudo MTE measurements unless the experiment explicitly calls for it.
- When comparing performance, record the compiler flags, QEMU CPU string, allocator configuration, benchmark iteration count, and host machine details.
- Treat the current numbers as QEMU user-mode measurements. They are useful for relative project comparisons, not as a hardware performance claim.

## Current Measurement Context

In the repository-level CoreMark runs, the Scudo MTE configuration measured about 17.63% overhead relative to the glibc non-MTE baseline. See the root README and `../coremark/README.md` for the benchmark framing.

## References

- [LLVM Scudo Hardened Allocator](https://llvm.org/docs/ScudoHardenedAllocator.html)
- [RISC-V International](https://riscv.org/)
- [Project whitepaper](../references/RISC-V-MTE-Whitepaper.pdf)
