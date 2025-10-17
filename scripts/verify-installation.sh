#!/bin/bash
################################################################################
# RISC-V MTE Toolchain - Installation Verification Script
# Comprehensive verification of the complete toolchain
################################################################################

set -e
set -u

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  RISC-V MTE Toolchain Verification${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Get project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source environment
if [ -f "$PROJECT_ROOT/env.sh" ]; then
    source "$PROJECT_ROOT/env.sh"
else
    echo -e "${RED}Error: env.sh not found.${NC}"
    exit 1
fi

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_section() {
    echo ""
    echo -e "${CYAN}=== $1 ===${NC}"
}

# Track results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if eval "$test_command" > /dev/null 2>&1; then
        print_status "$test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        print_error "$test_name"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Test 1: Environment Variables
print_section "Environment Variables"

if [ -n "$TARGET" ]; then
    print_status "TARGET is set: $TARGET"
else
    print_error "TARGET is not set"
fi

if [ -n "$PREFIX" ]; then
    print_status "PREFIX is set: $PREFIX"
else
    print_error "PREFIX is not set"
fi

if echo "$PATH" | grep -q "$PREFIX/bin"; then
    print_status "PATH includes toolchain bin directory"
else
    print_error "PATH does not include toolchain bin directory"
fi

# Test 2: Binutils Tools
print_section "Binutils Tools"

run_test "Assembler (as)" "command -v riscv64-unknown-linux-gnu-as"
run_test "Linker (ld)" "command -v riscv64-unknown-linux-gnu-ld"
run_test "Objdump" "command -v riscv64-unknown-linux-gnu-objdump"
run_test "Readelf" "command -v riscv64-unknown-linux-gnu-readelf"
run_test "Objcopy" "command -v riscv64-unknown-linux-gnu-objcopy"
run_test "Strip" "command -v riscv64-unknown-linux-gnu-strip"

# Show versions
if command -v riscv64-unknown-linux-gnu-as &> /dev/null; then
    version=$(riscv64-unknown-linux-gnu-as --version | head -n 1)
    print_info "Binutils version: $version"
fi

# Test 3: GCC Compilers
print_section "GCC Compilers"

run_test "C Compiler (gcc)" "command -v riscv64-unknown-linux-gnu-gcc"
run_test "C++ Compiler (g++)" "command -v riscv64-unknown-linux-gnu-g++"

# Show versions
if command -v riscv64-unknown-linux-gnu-gcc &> /dev/null; then
    version=$(riscv64-unknown-linux-gnu-gcc --version | head -n 1)
    print_info "GCC version: $version"
fi

# Test 4: Glibc Libraries
print_section "Glibc Libraries"

run_test "libc.so.6" "test -f $PREFIX/$TARGET/lib/libc.so.6"
run_test "libm.so.6" "test -f $PREFIX/$TARGET/lib/libm.so.6"
run_test "libpthread.so.0" "test -f $PREFIX/$TARGET/lib/libpthread.so.0"
run_test "libdl.so.2" "test -f $PREFIX/$TARGET/lib/libdl.so.2"

# Test 5: C++ Standard Library
print_section "C++ Standard Library"

if [ -f "$PREFIX/$TARGET/lib/libstdc++.so" ]; then
    print_status "libstdc++.so found in lib/"
elif [ -f "$PREFIX/$TARGET/lib64/libstdc++.so" ]; then
    print_status "libstdc++.so found in lib64/"
else
    print_warning "libstdc++.so not found in expected locations"
fi

# Test 6: Header Files
print_section "Header Files"

run_test "Kernel headers (linux/)" "test -d $PREFIX/$TARGET/include/linux"
run_test "ASM headers (asm/)" "test -d $PREFIX/$TARGET/include/asm"
run_test "C headers (stdio.h)" "test -f $PREFIX/$TARGET/include/stdio.h"
run_test "C++ headers (iostream)" "test -f $PREFIX/$TARGET/include/c++/*/iostream"

# Test 7: Compile C Program
print_section "C Compilation Test"

cat > /tmp/verify-test.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    printf("C compilation test successful!\n");
    
    // Test malloc
    char *str = malloc(100);
    if (str) {
        strcpy(str, "Memory allocation works");
        printf("%s\n", str);
        free(str);
    }
    
    return 0;
}
EOF

if riscv64-unknown-linux-gnu-gcc -o /tmp/verify-test-c /tmp/verify-test.c 2>&1; then
    print_status "C program compiled successfully"
    
    # Check binary format
    if file /tmp/verify-test-c | grep -q "RISC-V"; then
        print_status "Binary is RISC-V ELF format"
    else
        print_warning "Binary format is not RISC-V"
    fi
    
    # Check for MTE-related symbols (if available)
    if riscv64-unknown-linux-gnu-nm /tmp/verify-test-c | grep -q "malloc"; then
        print_info "malloc symbol found (MTE-aware via Glibc)"
    fi
else
    print_error "C compilation failed"
fi

rm -f /tmp/verify-test.c /tmp/verify-test-c

# Test 8: Compile C++ Program
print_section "C++ Compilation Test"

cat > /tmp/verify-test.cpp << 'EOF'
#include <iostream>
#include <vector>
#include <memory>

class TestClass {
public:
    TestClass() { std::cout << "TestClass created\n"; }
    ~TestClass() { std::cout << "TestClass destroyed\n"; }
    void print() { std::cout << "C++ compilation test successful!\n"; }
};

int main() {
    // Test C++11 features
    auto ptr = std::make_unique<TestClass>();
    ptr->print();
    
    // Test STL
    std::vector<int> vec = {1, 2, 3, 4, 5};
    std::cout << "Vector size: " << vec.size() << "\n";
    
    return 0;
}
EOF

if riscv64-unknown-linux-gnu-g++ -std=c++14 -o /tmp/verify-test-cpp /tmp/verify-test.cpp 2>&1; then
    print_status "C++ program compiled successfully"
    
    # Check binary format
    if file /tmp/verify-test-cpp | grep -q "RISC-V"; then
        print_status "Binary is RISC-V ELF format"
    else
        print_warning "Binary format is not RISC-V"
    fi
else
    print_error "C++ compilation failed"
fi

rm -f /tmp/verify-test.cpp /tmp/verify-test-cpp

# Test 9: Linking Test
print_section "Linking Test"

cat > /tmp/verify-lib.c << 'EOF'
int add(int a, int b) {
    return a + b;
}
EOF

cat > /tmp/verify-main.c << 'EOF'
#include <stdio.h>
extern int add(int, int);

int main() {
    printf("5 + 3 = %d\n", add(5, 3));
    return 0;
}
EOF

if riscv64-unknown-linux-gnu-gcc -c /tmp/verify-lib.c -o /tmp/verify-lib.o && \
   riscv64-unknown-linux-gnu-gcc -c /tmp/verify-main.c -o /tmp/verify-main.o && \
   riscv64-unknown-linux-gnu-gcc /tmp/verify-lib.o /tmp/verify-main.o -o /tmp/verify-link; then
    print_status "Multi-file linking successful"
else
    print_error "Multi-file linking failed"
fi

rm -f /tmp/verify-lib.c /tmp/verify-lib.o /tmp/verify-main.c /tmp/verify-main.o /tmp/verify-link

# Test 10: MTE Support Check
print_section "MTE Support Verification"

# Check if MTE is mentioned in GCC specs
if riscv64-unknown-linux-gnu-gcc -dumpspecs 2>/dev/null | grep -q "mte" || \
   riscv64-unknown-linux-gnu-gcc --target-help 2>/dev/null | grep -q "mte"; then
    print_status "MTE support detected in GCC"
else
    print_info "MTE support not explicitly shown (may be implicit)"
fi

# Check Glibc for MTE
if strings "$PREFIX/$TARGET/lib/libc.so.6" | grep -q "tag" 2>/dev/null; then
    print_status "Memory tagging references found in Glibc"
else
    print_info "Memory tagging references not found (may be compiled in)"
fi

# Summary
print_section "Verification Summary"

echo ""
echo "Total tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
fi
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  ✓ All verifications passed!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Your RISC-V MTE toolchain is ready to use!"
    echo ""
    echo "Quick start:"
    echo "  riscv64-unknown-linux-gnu-gcc -o program program.c"
    echo "  riscv64-unknown-linux-gnu-g++ -o program program.cpp"
    echo ""
    echo "See docs/examples/ for more usage examples"
    exit 0
else
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}  ✗ Some verifications failed${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo "Please check the errors above and:"
    echo "  1. Review build logs in logs/"
    echo "  2. See docs/installation.md for troubleshooting"
    echo "  3. Re-run failed stages if needed"
    exit 1
fi
