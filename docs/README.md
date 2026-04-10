# Documentation Index

This directory is the engineering notebook for the RISC-V MTE course project. The root README explains the project at a high level; these documents explain how to build, validate, and reason about each layer of the stack.

## Recommended Reading Order

1. [Installation Guide](Installation.md) - build the complete cross toolchain from a clean host.
2. [Testing Guide](Testing.md) - run the validation suite and understand what it covers.
3. [Component Notes](#component-notes) - inspect the layer you are modifying or debugging.
4. [Scudo README](../LLVM_SCUDO_MTE/README.md) - understand the allocator-side MTE experiment.
5. [CoreMark README](../coremark/README.md) - reproduce the benchmark workflow used for overhead evaluation.

## Component Notes

| Component | Document | Engineering role |
| --- | --- | --- |
| Binutils/GDB | [components/gdb.md](components/gdb.md) | Assembler, linker, and debugging support for Zimte instructions and tagged addresses. |
| GCC bootstrap | [components/gcc-bootstrap.md](components/gcc-bootstrap.md) | Minimal compiler stage needed before glibc can be built. |
| glibc | [components/glibc.md](components/glibc.md) | Target C library and heap-tagging runtime behavior. |
| GCC final | [components/gcc.md](components/gcc.md) | Full C/C++ cross compiler used by tests and benchmarks. |
| QEMU | [components/qemu.md](components/qemu.md) | User-mode execution environment with Zimop/Ssnpm/Zimte settings. |

## Build Flow

The automated build follows this dependency graph:

```text
setup-environment
  -> binutils
  -> gcc-bootstrap
  -> kernel-headers
  -> glibc
  -> gcc-final
  -> verify-installation
```

The corresponding scripts are in `../scripts/`. Build logs are written to `../logs/`, and downloaded source trees are placed under `../src/`.

## Repository Outputs

| Generated path | Created by | Notes |
| --- | --- | --- |
| `../env.sh` | `setup-environment.sh` | Local shell environment for `TARGET`, `PREFIX`, and `PATH`. |
| `../src/` | build scripts | Downloaded source repositories and build directories. |
| `../toolchain/` | build scripts | Installed cross compiler, binutils, sysroot, and emulator tools. |
| `../logs/` | build scripts | Stage logs for debugging failed builds. |

These outputs are generated locally and should not be committed.

## Validation Strategy

The project uses two levels of validation:

- **Toolchain checks**: `scripts/verify-installation.sh` confirms that the expected cross tools and environment are present.
- **Functional tests**: `scripts/run-all-tests.sh` compiles representative C/C++ sources, standard-library examples, static library cases, optimization variants, assembly output, binary format checks, and an MTE-oriented sample.

CoreMark is used separately for performance-oriented measurements, because benchmark runs should be configured and recorded more carefully than smoke tests.

## Documentation Maintenance

When changing a component, update the nearest component note first, then update the root README only if the public workflow or project claim changes. Keep command examples runnable from the repository root unless the section explicitly says otherwise.
