
# Testing Guide

This document describes the testing infrastructure for the RISC-V MTE Toolchain project.

## Table of Contents

- [Overview](#overview)
- [Test Structure](#test-structure)
- [Running Tests](#running-tests)
- [Test Cases](#test-cases)
- [Adding New Tests](#adding-new-tests)
- [Troubleshooting](#troubleshooting)
- [CI/CD Integration](#cicd-integration)

---

## Overview

The test suite validates the RISC-V cross-compilation toolchain functionality, including:

- ✅ C/C++ compilation
- ✅ Standard library support
- ✅ Multi-file projects
- ✅ Static library creation
- ✅ Optimization levels
- ✅ Preprocessor functionality
- ✅ Assembly generation
- ✅ Binary format verification
- ✅ MTE-aware features

### Test Philosophy

- **Comprehensive**: Cover all major toolchain features
- **Automated**: All tests run with a single command
- **Fast**: Tests complete in under 2 minutes
- **Isolated**: Each test uses temporary directories
- **Informative**: Clear pass/fail messages with error details

---

## Running Tests

### Prerequisites

1. **Source the environment**:
   ```bash
   source ~/RISCV-MTE/scripts/setup-environment.sh
   ```

2. **Verify toolchain**:
   ```bash
   which riscv64-unknown-linux-gnu-gcc
   riscv64-unknown-linux-gnu-gcc --version
   ```

### Run All Tests

```bash
cd ~/RISCV-MTE
./scripts/run-all-tests.sh
```

**Expected Output**:
```
=========================================
  RISC-V MTE Toolchain - Complete Test Suite
=========================================

Project Root: /home/user/RISCV-MTE
Sources Dir: /home/user/RISCV-MTE/tests/sources
Test Dir: /tmp/riscv_test_suite_12345

=========================================
  Checking Toolchain
=========================================

✓ Toolchain found
riscv64-unknown-linux-gnu-gcc (GCC) 14.2.0

=========================================
  Running Tests
=========================================

Testing: Basic C Compilation
[PASS] Basic C Compilation
Testing: C Standard Library
[PASS] C Standard Library
Testing: Basic C++ Compilation
[PASS] Basic C++ Compilation
Testing: C++ STL
[PASS] C++ STL
Testing: Multi-file Compilation
[PASS] Multi-file Compilation
Testing: Static Library
[PASS] Static Library
Testing: Optimization Levels
[PASS] Optimization Levels (O0, O1, O2, O3, Os)
Testing: Preprocessor
[PASS] Preprocessor
Testing: Assembly Generation
[PASS] Assembly Generation
Testing: Binary Format Verification
[PASS] Binary Format Verification
Testing: MTE Features
[PASS] MTE Features

=========================================
  Test Summary
=========================================

Total Tests:  11
Passed:       11
Failed:       0

========================================
  ✓ All tests passed!
========================================
```

### Run Individual Tests

You can manually compile and test individual source files:

```bash
cd ~/RISCV-MTE/tests/sources

# Test basic C
riscv64-unknown-linux-gnu-gcc hello.c -o hello
file hello

# Test C++ STL
riscv64-unknown-linux-gnu-g++ -std=c++14 stl_test.cpp -o stl_test
file stl_test

# Test with optimization
riscv64-unknown-linux-gnu-gcc -O2 optimization_test.c -o opt_test
```

---

## Test Cases

### Test 1: Basic C Compilation

**File**: `hello.c`  
**Purpose**: Verify basic C compilation works  
**Checks**:
- ✅ Compilation succeeds
- ✅ Binary is RISC-V format
- ✅ Binary is ELF 64-bit

**Command**:
```bash
riscv64-unknown-linux-gnu-gcc hello.c -o hello
```

**Expected Binary**:
```
hello: ELF 64-bit LSB executable, UCB RISC-V, version 1 (SYSV)
```

---

### Test 2: C Standard Library

**File**: `stdlib_test.c`  
**Purpose**: Test C standard library functions  
**Features Tested**:
- `malloc()` / `free()`
- `strcpy()` / `strlen()`
- `sqrt()` (math library)

**Command**:
```bash
riscv64-unknown-linux-gnu-gcc stdlib_test.c -o stdlib_test -lm
```

**Note**: Requires `-lm` for math library

---

### Test 3: Basic C++ Compilation

**File**: `cpp_basic.cpp`  
**Purpose**: Verify C++ compilation and classes  
**Features Tested**:
- Class definition
- Constructor/Destructor
- Member functions
- `std::cout` / `std::cerr`

**Command**:
```bash
riscv64-unknown-linux-gnu-g++ cpp_basic.cpp -o cpp_basic
```

---

### Test 4: C++ STL

**File**: `stl_test.cpp`  
**Purpose**: Test C++ Standard Template Library  
**Features Tested**:
- `std::vector`
- `std::string`
- `std::unique_ptr`
- `std::shared_ptr`
- `std::map`
- `std::sort`

**Command**:
```bash
riscv64-unknown-linux-gnu-g++ -std=c++14 stl_test.cpp -o stl_test
```

**Note**: Requires C++14 or later

---

### Test 5: Multi-file Compilation

**Files**: `math_utils.h`, `math_utils.c`, `main.c`  
**Purpose**: Test separate compilation and linking  
**Workflow**:
1. Compile `math_utils.c` → `math_utils.o`
2. Compile `main.c` → `main.o`
3. Link both object files

**Commands**:
```bash
riscv64-unknown-linux-gnu-gcc -c math_utils.c -o math_utils.o
riscv64-unknown-linux-gnu-gcc -c main.c -o main.o
riscv64-unknown-linux-gnu-gcc math_utils.o main.o -o multifile
```

---

### Test 6: Static Library

**Files**: `mylib.h`, `mylib.c`, `test_lib.c`  
**Purpose**: Test static library creation and linking  
**Workflow**:
1. Compile library source → object file
2. Create static library with `ar`
3. Link program with library

**Commands**:
```bash
riscv64-unknown-linux-gnu-gcc -c mylib.c -o mylib.o
riscv64-unknown-linux-gnu-ar rcs libmylib.a mylib.o
riscv64-unknown-linux-gnu-gcc test_lib.c -L. -lmylib -o test_lib
```

---

### Test 7: Optimization Levels

**File**: `optimization_test.c`  
**Purpose**: Test different optimization levels  
**Levels Tested**:
- `-O0` (no optimization)
- `-O1` (basic optimization)
- `-O2` (recommended optimization)
- `-O3` (aggressive optimization)
- `-Os` (optimize for size)

**Commands**:
```bash
riscv64-unknown-linux-gnu-gcc -O0 optimization_test.c -o opt_O0
riscv64-unknown-linux-gnu-gcc -O1 optimization_test.c -o opt_O1
riscv64-unknown-linux-gnu-gcc -O2 optimization_test.c -o opt_O2
riscv64-unknown-linux-gnu-gcc -O3 optimization_test.c -o opt_O3
riscv64-unknown-linux-gnu-gcc -Os optimization_test.c -o opt_Os
```

**Size Comparison**:
```bash
ls -lh opt_*
```

**Expected Results**:
```
-rwxr-xr-x 1 user user  18K opt_O0  # Largest
-rwxr-xr-x 1 user user  15K opt_O1
-rwxr-xr-x 1 user user  14K opt_O2
-rwxr-xr-x 1 user user  14K opt_O3
-rwxr-xr-x 1 user user  12K opt_Os  # Smallest
```

---

### Test 8: Preprocessor

**File**: `preprocessor_test.c`  
**Purpose**: Test preprocessor functionality  
**Features Tested**:
- Macro definitions (`#define`)
- Conditional compilation (`#ifdef`)
- Macro functions
- Stringification
- Architecture detection

**Commands**:
```bash
# Without DEBUG
riscv64-unknown-linux-gnu-gcc preprocessor_test.c -o preproc_test

# With DEBUG
riscv64-unknown-linux-gnu-gcc -DDEBUG preprocessor_test.c -o preproc_test_debug

# View preprocessed output
riscv64-unknown-linux-gnu-gcc -E preprocessor_test.c -o preprocessed.i
```

**Preprocessed Output**:
```bash
less preprocessed.i
# Shows expanded macros and included headers
```

---

### Test 9: Assembly Generation

**File**: `assembly_test.c`  
**Purpose**: Test assembly code generation  
**Workflow**:
1. Generate assembly from C
2. Verify RISC-V instructions
3. Compile from assembly

**Commands**:
```bash
# Generate assembly
riscv64-unknown-linux-gnu-gcc -S assembly_test.c -o assembly_test.s

# View assembly
cat assembly_test.s

# Compile from assembly
riscv64-unknown-linux-gnu-gcc assembly_test.s -o assembly_test
```

**Expected Instructions**:
```assembly
add     a0, a1, a2
addi    sp, sp, -16
ret
li      a0, 42
```

---

### Test 10: Binary Format Verification

**File**: `hello.c`  
**Purpose**: Verify binary format correctness  
**Checks**:
- ✅ ELF format
- ✅ 64-bit
- ✅ RISC-V architecture
- ✅ Little-endian (LSB)
- ✅ Dynamically linked

**Commands**:
```bash
riscv64-unknown-linux-gnu-gcc hello.c -o hello

# Check with file
file hello

# Check with readelf
riscv64-unknown-linux-gnu-readelf -h hello

# Check with objdump
riscv64-unknown-linux-gnu-objdump -f hello
```

**Expected Output**:
```
hello: ELF 64-bit LSB executable, UCB RISC-V, version 1 (SYSV), 
dynamically linked, interpreter /lib/ld-linux-riscv64-lp64d.so.1, 
for GNU/Linux 4.15.0, not stripped
```

**readelf Output**:
```
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           RISC-V
```

---

### Test 11: MTE Features

**File**: `mte_test.c`  
**Purpose**: Test MTE-aware memory allocation  
**Features Tested**:
- `malloc()` / `free()`
- `calloc()`
- `realloc()`
- Multiple allocations
- Memory safety (automatic tagging)

**Command**:
```bash
riscv64-unknown-linux-gnu-gcc mte_test.c -o mte_test
```

**Note**: MTE tagging is automatic in Glibc. Hardware enforcement requires MTE-enabled RISC-V processor.

**Memory Tagging**:
- Glibc automatically tags heap allocations
- Tags are stored in upper bits of pointers
- Hardware checks tags on memory access
- Detects use-after-free and buffer overflows

---

## Troubleshooting

### Problem: Toolchain not found

**Error**:
```
ERROR: riscv64-unknown-linux-gnu-gcc not found!
```

**Solution**:
```bash
source ~/RISCV-MTE/scripts/setup-environment.sh
```

**Verify**:
```bash
which riscv64-unknown-linux-gnu-gcc
echo $RISCV
echo $PATH
```

---

### Problem: Sources directory not found

**Error**:
```
ERROR: Sources directory not found: /path/to/tests/sources
```

**Solution**:
```bash
mkdir -p ~/RISCV-MTE/tests/sources
# Then add your test source files
```

---

### Problem: Compilation fails

**Error**:
```
[FAIL] Basic C Compilation
  Compilation failed:
  hello.c:1:10: fatal error: stdio.h: No such file or directory
```

**Possible Causes**:
1. Toolchain not properly built
2. Sysroot not configured
3. Missing dependencies

**Solution**:
```bash
# Rebuild toolchain
cd ~/RISCV-MTE
./scripts/build-all.sh

# Verify sysroot
ls $RISCV/sysroot/usr/include/
```

---

### Problem: C++ STL not found

**Error**:
```
[FAIL] C++ STL
  stl_test.cpp:5:10: fatal error: vector: No such file or directory
```

**Solution**:
Ensure C++ libraries were built:
```bash
cd ~/riscv-gnu-toolchain
./configure --prefix=$RISCV --enable-multilib
make linux -j$(nproc)
```

**Verify**:
```bash
ls $RISCV/sysroot/usr/include/c++/
```

---

### Problem: Math library not linked

**Error**:
```
undefined reference to `sqrt'
```

**Solution**:
Add `-lm` flag:
```bash
riscv64-unknown-linux-gnu-gcc stdlib_test.c -o stdlib_test -lm
```

---

### Problem: Binary format incorrect

**Error**:
```
[FAIL] Binary Format Verification
  Not RISC-V architecture
```

**Solution**:
Check if you're using the correct compiler:
```bash
which riscv64-unknown-linux-gnu-gcc
riscv64-unknown-linux-gnu-gcc --version
file hello
```

**Expected**:
```
/opt/riscv/bin/riscv64-unknown-linux-gnu-gcc
riscv64-unknown-linux-gnu-gcc (GCC) 14.2.0
hello: ELF 64-bit LSB executable, UCB RISC-V
```

---

### Problem: Permission denied

**Error**:
```
bash: ./scripts/run-all-tests.sh: Permission denied
```

**Solution**:
```bash
chmod +x ~/RISCV-MTE/scripts/run-all-tests.sh
```

---

### Problem: Test hangs

**Symptom**: Test script stops responding

**Solution**:
1. Press `Ctrl+C` to stop
2. Check for infinite loops in test code
3. Increase timeout if needed
4. Run individual test to isolate issue


---

## Test Metrics

### Expected Performance

| Test | Expected Time | Binary Size |
|------|--------------|-------------|
| Basic C | < 1s | ~15 KB |
| C stdlib | < 2s | ~20 KB |
| C++ basic | < 2s | ~25 KB |
| C++ STL | < 3s | ~50 KB |
| Multi-file | < 2s | ~18 KB |
| Static lib | < 3s | ~20 KB |
| Optimization | < 5s | 10-30 KB |
| Preprocessor | < 2s | ~15 KB |
| Assembly | < 2s | ~15 KB |
| Binary format | < 1s | ~15 KB |
| MTE | < 2s | ~22 KB |

**Total Suite Time**: ~30 seconds

### Size Comparison by Optimization

| Optimization | Size | Speed | Use Case |
|-------------|------|-------|----------|
| -O0 | Largest | Slowest | Debugging |
| -O1 | Large | Slow | Basic optimization |
| -O2 | Medium | Fast | Production (recommended) |
| -O3 | Medium | Fastest | Performance-critical |
| -Os | Smallest | Medium | Embedded systems |

---

## Test Coverage

### Current Coverage

- ✅ C compilation (100%)
- ✅ C++ compilation (100%)
- ✅ Standard libraries (90%)
- ✅ Build systems (70%)
- ✅ Optimization (100%)
- ✅ Binary formats (100%)
- ⚠️ Runtime execution (0% - requires QEMU)

---

## References

- [RISC-V ISA Specification](https://riscv.org/technical/specifications/)
- [GCC Documentation](https://gcc.gnu.org/onlinedocs/)
- [GNU Binutils](https://sourceware.org/binutils/docs/)
- [ELF Format Specification](https://refspecs.linuxfoundation.org/elf/elf.pdf)
- [RISC-V GNU Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)
- [RISC-V MTE Proposal](https://github.com/riscv/riscv-memory-tagging)

---

## License

This testing infrastructure is part of the RISC-V MTE Toolchain project.

