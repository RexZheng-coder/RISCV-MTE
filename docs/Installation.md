# Installation Guide

Complete step-by-step installation instructions for building RISC-V MTE Toolchain from scratch.

## Table of Contents

1. [Overview](#overview)
2. [System Requirements](#system-requirements)
3. [Quick Start](#quick-start)
4. [Detailed Installation Steps](#detailed-installation-steps)
5. [Post-installation Verification](#post-installation-verification)
6. [Troubleshooting](#troubleshooting)
7. [Next Steps](#next-steps)

---

## Overview

This guide will walk you through building a complete RISC-V 64-bit cross-compilation toolchain with Memory Tagging Extension (MTE) support from source code.

**Final Result**: A fully functional cross-compiler suite at `~/riscv-mte-project/toolchain`

**Estimated Time**: 2-4 hours (depending on your system)

**Build Order**:
```
Stage 0: Environment Setup
    ↓
Stage 1: Binutils (Foundation)
    ↓
Stage 2: GCC Bootstrap (Temporary compiler)
    ↓
Stage 3: Linux Kernel Headers (OS API)
    ↓
Stage 4: Glibc (C Library with MTE)
    ↓
Stage 5: GCC Final (Complete compiler)
```

---

## System Requirements

### Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | x86_64, 4 cores | x86_64, 8+ cores |
| RAM | 8GB | 16GB+ |
| Disk Space | 30GB free | 50GB+ free |

### Software Requirements

- **Operating System**: Ubuntu 22.04 LTS or newer
- **Internet**: Stable connection for downloading source code
- **Privileges**: sudo access for installing dependencies

---

## Quick Start

### Automated Installation (Recommended)

For most users, the automated build script is the easiest way:

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/riscv-mte-toolchain.git
cd riscv-mte-toolchain

# Run the automated build script (builds all 5 stages)
./scripts/build-all.sh
```

**What happens**:
- ✓ Checks system requirements
- ✓ Installs all dependencies
- ✓ Downloads all source code
- ✓ Builds all components in correct order
- ✓ Verifies installation
- ✓ Total time: 2-4 hours

### Manual Installation

If you prefer step-by-step control or need to debug issues, follow the [Detailed Installation Steps](#detailed-installation-steps) below.

---

## Detailed Installation Steps

### Stage 0: Environment Setup

**Purpose**: Install dependencies and configure build environment

**Script**: `./scripts/setup-environment.sh`

```bash
./scripts/setup-environment.sh
```

**What this does**:
- ✓ Checks system requirements (RAM, disk space, OS compatibility)
- ✓ Installs all build dependencies via apt-get
- ✓ Creates project directory structure (`src/`, `toolchain/`, `logs/`)
- ✓ Sets up environment variables (`TARGET`, `PREFIX`, `PATH`)
- ✓ Creates `env.sh` for quick environment reloading

**Output**:
```
✓ RAM: 16GB
✓ Available disk space: 50GB
✓ Created directories: src/, toolchain/, logs/, tests/
✓ All dependencies installed successfully
✓ Environment variables added to ~/.bashrc
```

<details>
<summary>📋 Click to see manual steps</summary>

```bash
# Create project structure
mkdir -p ~/riscv-mte-project/{src,toolchain,logs,tests}
cd ~/riscv-mte-project

# Install dependencies
sudo apt-get update
sudo apt-get install -y \
    git \
    build-essential \
    autoconf \
    texinfo \
    bison \
    flex \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    libtool \
    wget \
    curl \
    gawk \
    python3 \
    python3-pip

# Set environment variables
export TARGET=riscv64-unknown-linux-gnu
export PREFIX=~/riscv-mte-project/toolchain
export PATH=$PREFIX/bin:$PATH

# Make permanent
echo '' >> ~/.bashrc
echo '# RISC-V MTE Toolchain Environment' >> ~/.bashrc
echo 'export TARGET=riscv64-unknown-linux-gnu' >> ~/.bashrc
echo 'export PREFIX=~/riscv-mte-project/toolchain' >> ~/.bashrc
echo 'export PATH=$PREFIX/bin:$PATH' >> ~/.bashrc

# Reload
source ~/.bashrc
```
</details>

---

### Stage 1: Build Binutils

**Purpose**: Build assembler and linker (foundation of the toolchain)

**Script**: `./scripts/build-binutils.sh`

```bash
./scripts/build-binutils.sh
```

**What this does**:
- ✓ Clones Binutils source from Vrull's MTE-enabled repository
- ✓ Configures for RISC-V 64-bit target
- ✓ Builds assembler (`riscv64-unknown-linux-gnu-as`)
- ✓ Builds linker (`riscv64-unknown-linux-gnu-ld`)
- ✓ Installs to `$PREFIX/bin/`

**Time**: ~10-15 minutes

**Key Tools Built**:
- `riscv64-unknown-linux-gnu-as` - Assembler
- `riscv64-unknown-linux-gnu-ld` - Linker
- `riscv64-unknown-linux-gnu-objdump` - Object file analyzer
- `riscv64-unknown-linux-gnu-readelf` - ELF file reader

<details>
<summary>📋 Click to see manual steps</summary>

```bash
cd ~/riscv-mte-project/src

# Clone Binutils with MTE support
git clone -b riscv-mte https://gitlab.com/vrull-public/binutils-gdb.git
cd binutils-gdb

# Create build directory
mkdir build && cd build

# Configure
../configure \
    --target=$TARGET \
    --prefix=$PREFIX \
    --disable-nls \
    --disable-werror

# Build (using all CPU cores)
make -j$(nproc)

# Install
make install

# Verify
$PREFIX/bin/riscv64-unknown-linux-gnu-as --version
$PREFIX/bin/riscv64-unknown-linux-gnu-ld --version
```
</details>

---

### Stage 2: Build GCC Bootstrap

**Purpose**: Build minimal C compiler to break circular dependency

**Script**: `./scripts/build-gcc-bootstrap.sh`

```bash
./scripts/build-gcc-bootstrap.sh
```

**What this does**:
- ✓ Clones GCC source with MTE support
- ✓ Downloads GCC prerequisites (GMP, MPFR, MPC libraries)
- ✓ Builds minimal C-only compiler **without Glibc dependency**
- ✓ This bootstrap compiler can compile Glibc

**Time**: ~20-30 minutes

**Why this is needed**: 
- GCC needs Glibc to compile programs
- Glibc needs GCC to be compiled
- This bootstrap compiler breaks the circular dependency

**Key Configuration**:
- `--without-headers`: No C library headers needed
- `--disable-threads`: No threading support (temporary)
- `--disable-shared`: No shared libraries (temporary)
- `--enable-languages=c`: C only (C++ comes later)

<details>
<summary>📋 Click to see manual steps</summary>

```bash
cd ~/riscv-mte-project/src

# Clone GCC with MTE support
git clone -b riscv-mte https://gitlab.com/vrull-public/gcc.git
cd gcc

# Download prerequisites (GMP, MPFR, MPC)
./contrib/download_prerequisites

# Create build directory
mkdir build-bootstrap && cd build-bootstrap

# Configure minimal GCC
../configure \
    --target=$TARGET \
    --prefix=$PREFIX \
    --disable-nls \
    --without-headers \
    --enable-languages=c \
    --disable-threads \
    --disable-libgcov \
    --disable-shared \
    --disable-werror

# Build GCC and libgcc
make -j$(nproc) all-gcc
make -j$(nproc) all-target-libgcc

# Install
make install-gcc
make install-target-libgcc

# Verify
$PREFIX/bin/riscv64-unknown-linux-gnu-gcc --version
```
</details>

---

### Stage 3: Install Linux Kernel Headers

**Purpose**: Install kernel headers for system call interface

**Script**: `./scripts/install-kernel-headers.sh`

```bash
./scripts/install-kernel-headers.sh
```

**What this does**:
- ✓ Clones Linux kernel source (shallow clone to save time/space)
- ✓ Installs RISC-V kernel headers to `$PREFIX/$TARGET/include/`
- ✓ Provides system call definitions for Glibc
- ✓ Provides kernel data structures and interfaces

**Time**: ~2-5 minutes

**Headers Installed**:
- `linux/` - Linux kernel API
- `asm/` - Architecture-specific definitions
- `asm-generic/` - Generic architecture definitions

<details>
<summary>📋 Click to see manual steps</summary>

```bash
cd ~/riscv-mte-project/src

# Clone Linux kernel (shallow clone)
git clone --depth=1 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
cd linux

# Install headers for RISC-V
make ARCH=riscv \
    INSTALL_HDR_PATH=$PREFIX/$TARGET \
    headers_install

# Verify
ls $PREFIX/$TARGET/include/linux
ls $PREFIX/$TARGET/include/asm
```
</details>

---

### Stage 4: Build Glibc with MTE Support

**Purpose**: Build C standard library with MTE-aware memory allocation

**Script**: `./scripts/build-glibc.sh`

```bash
./scripts/build-glibc.sh
```

**What this does**:
- ✓ Clones Glibc source with MTE support
- ✓ Configures with `--enable-memory-tagging` (**CRITICAL FOR MTE**)
- ✓ Builds C standard library with MTE-aware `malloc`/`free`
- ✓ Installs to `$PREFIX/$TARGET/lib/`

**Time**: ~30-60 minutes (longest compilation stage)

**Why this matters**: 
- This is where MTE support enters the toolchain!
- `malloc()` and `free()` will automatically use memory tagging
- All heap allocations get tagged for memory safety

**Key Configuration**:
- `--enable-memory-tagging`: Enables MTE support in malloc/free
- `--with-headers`: Points to kernel headers from Stage 3

<details>
<summary>📋 Click to see manual steps</summary>

```bash
cd ~/riscv-mte-project/src

# Clone Glibc with MTE support
git clone -b riscv-mte https://gitlab.com/vrull-public/glibc.git
cd glibc

# Create build directory
mkdir build && cd build

# Configure with MTE support
../configure \
    --target=$TARGET \
    --host=$TARGET \
    --prefix="" \
    --with-headers=$PREFIX/$TARGET/include \
    --enable-memory-tagging \
    --disable-werror

# Build (this takes a while)
make -j$(nproc)

# Install
make install DESTDIR=$PREFIX/$TARGET

# Verify
ls $PREFIX/$TARGET/lib/libc.so.6
ls $PREFIX/$TARGET/lib/libm.so.6
ls $PREFIX/$TARGET/lib/libpthread.so.0
```
</details>

---

### Stage 5: Build GCC Final

**Purpose**: Build full-featured GCC with C/C++ support

**Script**: `./scripts/build-gcc-final.sh`

```bash
./scripts/build-gcc-final.sh
```

**What this does**:
- ✓ Creates symbolic link fix for header paths (`usr/include -> ../include`)
- ✓ Builds full-featured GCC with C and C++ support
- ✓ Links against the Glibc we just built
- ✓ Applies all critical fixes for common issues

**Time**: ~60-120 minutes

**Key Fixes Applied**:
- `--with-sysroot=$PREFIX/$TARGET`: Fixes "cannot find /lib/libc.so.6" error
- `--with-native-system-header-dir=/include`: Fixes header path issues
- `--disable-multilib`: Prevents unnecessary 32-bit builds

**Features Enabled**:
- ✓ Full C11/C17 support
- ✓ Full C++11/14/17/20 support
- ✓ POSIX threads support
- ✓ Shared library support
- ✓ libstdc++ (C++ standard library)

<details>
<summary>📋 Click to see manual steps</summary>

```bash
# Pre-emptive fix for header paths
cd $PREFIX/$TARGET
mkdir -p usr
ln -sf ../include usr/include

# Build GCC Final
cd ~/riscv-mte-project/src/gcc
rm -rf build-final
mkdir build-final && cd build-final

# Configure full GCC
../configure \
    --target=$TARGET \
    --prefix=$PREFIX \
    --with-sysroot=$PREFIX/$TARGET \
    --with-build-sysroot=$PREFIX/$TARGET \
    --with-native-system-header-dir=/include \
    --disable-nls \
    --enable-languages=c,c++ \
    --disable-multilib \
    --disable-werror \
    --enable-threads=posix \
    --enable-shared \
    --enable-libstdcxx

# Build (this takes the longest)
make -j$(nproc)

# Install
make install

# Verify
$PREFIX/bin/riscv64-unknown-linux-gnu-gcc --version
$PREFIX/bin/riscv64-unknown-linux-gnu-g++ --version
```
</details>

---

## Post-installation Verification

### Automated Verification (Recommended)

Run the comprehensive verification script:

```bash
./scripts/verify-installation.sh
```

**What it checks**:
- ✓ Environment variables are set
- ✓ All Binutils tools are present
- ✓ GCC compilers work
- ✓ Glibc libraries exist
- ✓ C++ standard library is installed
- ✓ Header files are accessible
- ✓ C compilation works
- ✓ C++ compilation works
- ✓ Multi-file linking works
- ✓ Binary format is RISC-V ELF

**Expected output**:
```
=== Verification Summary ===

Total tests: 25
Passed: 25
Failed: 0

========================================
  ✓ All verifications passed!
========================================
```

### Manual Verification

#### Check Tool Versions

```bash
# Check GCC
riscv64-unknown-linux-gnu-gcc --version
# Expected: gcc (GCC) 13.x.x or similar

# Check G++
riscv64-unknown-linux-gnu-g++ --version
# Expected: g++ (GCC) 13.x.x or similar

# Check Binutils
riscv64-unknown-linux-gnu-as --version
riscv64-unknown-linux-gnu-ld --version
```

#### Test C Compilation

```bash
# Create test program
cat > test.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("Hello from RISC-V MTE Toolchain!\n");
    
    // Test malloc (MTE-aware)
    int *ptr = malloc(sizeof(int) * 10);
    if (ptr) {
        ptr[0] = 42;
        printf("Allocated memory, value: %d\n", ptr[0]);
        free(ptr);
    }
    
    return 0;
}
EOF

# Compile
riscv64-unknown-linux-gnu-gcc -o test test.c

# Check binary format
file test
# Expected: test: ELF 64-bit LSB executable, UCB RISC-V, ...

# Inspect with readelf
riscv64-unknown-linux-gnu-readelf -h test
# Should show "Machine: RISC-V"
```

#### Test C++ Compilation

```bash
# Create C++ test
cat > test.cpp << 'EOF'
#include <iostream>
#include <vector>
#include <memory>

int main() {
    std::cout << "Hello from C++!" << std::endl;
    
    // Test STL
    std::vector<int> vec = {1, 2, 3, 4, 5};
    std::cout << "Vector size: " << vec.size() << std::endl;
    
    // Test smart pointers
    auto ptr = std::make_unique<int>(42);
    std::cout << "Value: " << *ptr << std::endl;
    
    return 0;
}
EOF

# Compile with C++14
riscv64-unknown-linux-gnu-g++ -std=c++14 -o test_cpp test.cpp

# Check
file test_cpp
```

### Run Test Suite

Run comprehensive tests covering all toolchain features:

```bash
./scripts/run-tests.sh
```

**Tests included**:
1. Basic C compilation
2. C standard library (malloc, string, math)
3. Basic C++ compilation
4. C++ STL (vector, string, algorithms, smart pointers)
5. Multi-file compilation and linking
6. Static library creation and linking
7. Optimization levels (-O0, -O1, -O2, -O3, -Os)
8. Preprocessor directives
9. Assembly output generation
10. Binary format verification

**Expected output**:
```
========================================
  Test Results
========================================

Total tests: 10
Passed: 10
Failed: 0

Success rate: 100%

========================================
  ✓ All tests passed!
========================================
```

---

## Troubleshooting

### Quick Fixes

| Problem | Solution |
|---------|----------|
| `command not found` | Run `source ~/.bashrc` or `source env.sh` |
| Out of disk space | Run `./scripts/clean.sh` (option 1) |
| Build fails | Check `logs/` directory for details |
| Permission denied | `sudo chown -R $USER:$USER ~/riscv-mte-project` |
| Slow build | Reduce parallel jobs: edit scripts, change `-j$(nproc)` to `-j4` |

### Common Issues

#### Issue 1: "cannot find -lgcc_s"

**Cause**: GCC bootstrap wasn't built correctly

**Solution**:
```bash
./scripts/build-gcc-bootstrap.sh
```

#### Issue 2: "cannot find /lib/libc.so.6"

**Cause**: Sysroot wasn't configured correctly in GCC Final

**Solution**: Rebuild GCC Final (the script includes the fix)
```bash
./scripts/build-gcc-final.sh
```

#### Issue 3: "No such file or directory: /usr/include/stdio.h"

**Cause**: Header path issue

**Solution**: The symbolic link fix should handle this
```bash
cd $PREFIX/$TARGET
mkdir -p usr
ln -sf ../include usr/include
./scripts/build-gcc-final.sh
```

#### Issue 4: Build hangs or system becomes unresponsive

**Cause**: Too many parallel jobs for available RAM

**Solution**: Reduce parallel jobs
```bash
# Edit the script and change:
make -j$(nproc)
# to:
make -j4  # or j2 for systems with 8GB RAM
```

#### Issue 5: "configure: error: C compiler cannot create executables"

**Cause**: Missing dependencies or environment not set

**Solution**:
```bash
# Reinstall dependencies
sudo apt-get install build-essential

# Reload environment
source ~/.bashrc

# Retry
./scripts/setup-environment.sh
```

### Checking Build Logs

All build output is saved to `logs/` directory:

```bash
# View recent errors
tail -n 50 logs/gcc-final-build.log

# Search for specific error
grep -i "error" logs/glibc-build.log

# View entire log
less logs/binutils-build.log
```

### Getting Help

If you encounter issues not covered here:

1. **Check Documentation**:
   - [Troubleshooting Guide](troubleshooting.md)
   - [FAQ](faq.md)
   - Component-specific guides in [components/](components/)

2. **Review Logs**: Check `logs/` directory for detailed error messages

3. **GitHub Issues**: Search or create an issue at [repository URL]

4. **Contact**: Email your.email@columbia.edu

---

## Next Steps

### 1. Component Guides
Deep dive into each component:
- [GCC Guide](components/gcc.md) - Compiler options and features
- [Glibc Guide](components/glibc.md) - C library and MTE support
- [Binutils Guide](components/binutils.md) - Assembler and linker usage

### 2. Testing
[docs/testing.md](Testing.md) - How to test your programs

---

## Build Time Summary

Approximate build times on a typical system (Intel i7, 16GB RAM, SSD):

| Stage | Component | Time |
|-------|-----------|------|
| 0 | Environment Setup | 5-10 min |
| 1 | Binutils | 10-15 min |
| 2 | GCC Bootstrap | 20-30 min |
| 3 | Kernel Headers | 2-5 min |
| 4 | Glibc | 30-60 min |
| 5 | GCC Final | 60-120 min |
| **Total** | **Complete Toolchain** | **2-4 hours** |

**Note**: Times may vary based on:
- CPU speed and core count
- Available RAM
- Disk I/O speed (SSD vs HDD)
- Internet connection speed (for downloads)
- System load

---

## Disk Space Usage

Approximate disk space requirements:

| Directory | Size | Description |
|-----------|------|-------------|
| `src/` | ~15-20 GB | Source code |
| `toolchain/` | ~5-8 GB | Compiled toolchain |
| `logs/` | ~100-500 MB | Build logs |
| **Total** | **~20-30 GB** | Complete project |

**Space-saving tips**:
- After successful build, you can delete `src/` to save ~15-20 GB
- Keep `toolchain/` - this is what you need to use the compiler
- Archive `logs/` if you don't need them for debugging
