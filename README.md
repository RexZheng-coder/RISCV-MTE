# RISC-V MTE Toolchain

Course project for EECS 6894 at Columbia University. The repository packages a RISC-V software stack for experimenting with Memory Tagging Extension (MTE) ideas on the Zimte extension path: a patched GNU toolchain, MTE-aware runtime support, QEMU user-mode execution, Scudo allocator experiments, and CoreMark-based performance evaluation.

The engineering goal is not only to collect patches, but to make the full research loop reproducible: build the toolchain, compile tagged-memory programs, run them under an emulator with tag checks, compare allocator behavior, and document what each layer contributes.

## Project Goals

- Build a reproducible `riscv64-unknown-linux-gnu` cross toolchain with Zimte-aware binutils, GCC, kernel headers, and glibc.
- Run RISC-V user programs in a QEMU configuration that models the Zimte memory-tagging behavior.
- Evaluate two runtime strategies: glibc heap tagging and a RISC-V port of LLVM Scudo's MTE path.
- Provide a small validation suite for compiler/runtime sanity checks and a CoreMark workflow for performance measurements.
- Keep the repository understandable as a course project deliverable: clear ownership boundaries, repeatable scripts, and explicit assumptions.

## Repository Map

| Path | Purpose |
| --- | --- |
| `scripts/` | Stage-based build, verification, testing, and cleanup scripts. |
| `docs/` | Installation, testing, and component-level engineering notes. |
| `tests/sources/` | Small C/C++ programs used by `scripts/run-all-tests.sh`. |
| `LLVM_SCUDO_MTE/` | Modified Scudo standalone allocator with RISC-V Zimte MTE support. |
| `coremark/` | CoreMark benchmark submodule plus project-specific usage notes. |
| `references/` | Background material, including the RISC-V MTE whitepaper. |
| `toolchain/` | Generated install prefix created by the build scripts. Ignored by git. |
| `src/` | Downloaded upstream/patched sources created by the build scripts. Ignored by git. |
| `logs/` | Build logs created by the build scripts. Ignored by git. |

## Architecture

The stack is intentionally layered:

1. **Binutils/GDB** assemble and inspect Zimte-related instructions such as `gentag`, `settag`, and `addtag`.
2. **GCC bootstrap** provides the minimal compiler needed to build the target C library.
3. **Linux kernel headers** define the target userspace ABI used by glibc.
4. **glibc** provides an MTE-aware heap path enabled through runtime tunables.
5. **GCC final** provides the complete C/C++ cross compiler.
6. **QEMU user mode** executes RISC-V binaries with Zimop, Ssnpm, and Zimte properties enabled.
7. **Scudo and CoreMark** support allocator experiments and overhead measurement.

The default build order follows that dependency chain.

## Quick Start

The scripts are designed for Ubuntu/Debian hosts. The full build downloads and compiles several large components, so expect a multi-hour run.

```bash
git clone https://github.com/EECS6894/RISCV-MTE.git
cd RISCV-MTE

./scripts/build-all.sh
source env.sh

./scripts/verify-installation.sh
./scripts/run-all-tests.sh
```

For step-by-step control, run the scripts in this order:

```bash
./scripts/setup-environment.sh
./scripts/build-binutils.sh
./scripts/build-gcc-bootstrap.sh
./scripts/install-kernel-headers.sh
./scripts/build-glibc.sh
./scripts/build-gcc-final.sh
```

## System Requirements

| Resource | Minimum | Recommended |
| --- | --- | --- |
| OS | Ubuntu/Debian Linux | Ubuntu 22.04 or 24.04 LTS |
| CPU | x86_64, 4 cores | x86_64, 8+ cores |
| RAM | 8 GB | 16-32 GB |
| Disk | 30 GB free | 50 GB+ free |
| Privileges | `sudo` for package installation | same |

The setup script creates a local `env.sh` and uses this repository as the project root. It installs the toolchain into `./toolchain` by default.

## Common Workflows

Compile a RISC-V program with the final toolchain:

```bash
source env.sh
riscv64-unknown-linux-gnu-gcc -march=rv64gc_zimte -O2 tests/sources/hello.c -o hello
```

Run a program under QEMU with Zimte enabled:

```bash
QEMU_CPU="rv64,zimop=true,ssnpm=true,zimte=true,pmlen=7,ptw=4" \
qemu-riscv64 ./hello
```

Enable glibc heap tagging for a run:

```bash
QEMU_CPU="rv64,zimop=true,ssnpm=true,zimte=true,pmlen=7,ptw=4" \
GLIBC_TUNABLES=glibc.mem.tagging=1 \
qemu-riscv64 ./hello
```

Run the repository validation suite:

```bash
./scripts/run-all-tests.sh
```

## Current Benchmark Snapshot

CoreMark was used to compare allocator/MTE configurations in QEMU user-mode emulation.

| Allocator | MTE state | Iterations/sec | Overhead |
| --- | --- | ---: | ---: |
| glibc default | off | 498.88 | baseline |
| glibc | on | 424.12 | 14.98% |
| Scudo | on | 410.90 | 17.63% |

Interpretation: in this emulated setup, hardware-style memory tagging adds roughly 15-18% overhead for the tested CoreMark configuration. The numbers should be treated as project measurements, not production hardware claims.

## Documentation

| Document | Description |
| --- | --- |
| [docs/README.md](docs/README.md) | Documentation index and recommended reading order. |
| [docs/Installation.md](docs/Installation.md) | Full build and installation guide. |
| [docs/Testing.md](docs/Testing.md) | Test strategy and validation workflow. |
| [docs/components/gdb.md](docs/components/gdb.md) | Binutils/GDB notes. |
| [docs/components/gcc-bootstrap.md](docs/components/gcc-bootstrap.md) | Bootstrap compiler notes. |
| [docs/components/gcc.md](docs/components/gcc.md) | Final GCC notes. |
| [docs/components/glibc.md](docs/components/glibc.md) | glibc MTE notes. |
| [docs/components/qemu.md](docs/components/qemu.md) | QEMU Zimte execution notes. |
| [LLVM_SCUDO_MTE/README.md](LLVM_SCUDO_MTE/README.md) | Scudo allocator port notes. |
| [coremark/README.md](coremark/README.md) | CoreMark usage in this project. |

## Team

Course: EECS 6894 - Hardware/Software Co-Design for Data Center Processing, Fall 2025

Institution: Columbia University

- Haohui Zheng, hz3078@columbia.edu, project maintainer
- Weihao Zhou, wz2750@columbia.edu
- Rui Li, rl3586@columbia.edu
- Charlotte Chen, hc3558@columbia.edu

## License

This repository is distributed under the Apache License. See [LICENSE](LICENSE).

Third-party components retain their original licenses. CoreMark is included as a submodule; toolchain sources are downloaded by scripts from their upstream or project branches.

## Acknowledgments

This course project builds on the public RISC-V MTE work from Vrull GmbH and the broader RISC-V, GNU, QEMU, LLVM, and EEMBC ecosystems.

Academic research project. Not production-ready.
