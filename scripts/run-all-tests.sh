#!/bin/bash
# Complete Test Suite for RISC-V MTE Toolchain
# This script runs all tests and reports results

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SOURCES_DIR="$PROJECT_ROOT/tests/sources"
TEST_DIR="/tmp/riscv_test_suite_$$"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Create test directory
mkdir -p "$TEST_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# Print header
print_header() {
    echo ""
    echo "========================================="
    echo "  $1"
    echo "========================================="
    echo ""
}

# Print test result
print_result() {
    local test_name="$1"
    local result="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}[PASS]${NC} $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}[FAIL]${NC} $test_name"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Check if toolchain is available
check_toolchain() {
    print_header "Checking Toolchain"
    
    if ! command -v riscv64-unknown-linux-gnu-gcc &> /dev/null; then
        echo -e "${RED}ERROR: riscv64-unknown-linux-gnu-gcc not found!${NC}"
        echo "Please run: source ~/riscv-mte-project/scripts/setup-env.sh"
        exit 1
    fi
    
    echo -e "${GREEN}✓${NC} Toolchain found"
    riscv64-unknown-linux-gnu-gcc --version | head -n1
    echo ""
}

# Test 1: Basic C Compilation
test_basic_c() {
    local test_name="Basic C Compilation"
    echo -e "${BLUE}Testing:${NC} $test_name"
    
    if riscv64-unknown-linux-gnu-gcc "$SOURCES_DIR/hello.c" -o "$TEST_DIR/hello" 2>"$TEST_DIR/error_basic_c.log"; then
        if file "$TEST_DIR/hello" | grep -q "RISC-V" && file "$TEST_DIR/hello" | grep -q "ELF 64-bit"; then
            print_result "$test_name" "PASS"
            return 0
        else
            echo "  Binary format incorrect"
            cat "$TEST_DIR/error_basic_c.log"
            print_result "$test_name" "FAIL"
            return 1
        fi
    else
        echo "  Compilation failed:"
        cat "$TEST_DIR/error_basic_c.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
}

# Test 2: C Standard Library
test_c_stdlib() {
    local test_name="C Standard Library"
    echo -e "${BLUE}Testing:${NC} $test_name"
    
    if riscv64-unknown-linux-gnu-gcc "$SOURCES_DIR/stdlib_test.c" -o "$TEST_DIR/stdlib_test" -lm 2>"$TEST_DIR/error_stdlib.log"; then
        if file "$TEST_DIR/stdlib_test" | grep -q "RISC-V"; then
            print_result "$test_name" "PASS"
            return 0
        else
            echo "  Binary format incorrect"
            print_result "$test_name" "FAIL"
            return 1
        fi
    else
        echo "  Compilation failed:"
        cat "$TEST_DIR/error_stdlib.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
}

# Test 3: Basic C++
test_cpp_basic() {
    local test_name="Basic C++ Compilation"
    echo -e "${BLUE}Testing:${NC} $test_name"
    
    if riscv64-unknown-linux-gnu-g++ "$SOURCES_DIR/cpp_basic.cpp" -o "$TEST_DIR/cpp_basic" 2>"$TEST_DIR/error_cpp_basic.log"; then
        if file "$TEST_DIR/cpp_basic" | grep -q "RISC-V"; then
            print_result "$test_name" "PASS"
            return 0
        else
            echo "  Binary format incorrect"
            print_result "$test_name" "FAIL"
            return 1
        fi
    else
        echo "  Compilation failed:"
        cat "$TEST_DIR/error_cpp_basic.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
}

# Test 4: C++ STL
test_cpp_stl() {
    local test_name="C++ STL"
    echo -e "${BLUE}Testing:${NC} $test_name"
    
    if riscv64-unknown-linux-gnu-g++ -std=c++14 "$SOURCES_DIR/stl_test.cpp" -o "$TEST_DIR/stl_test" 2>"$TEST_DIR/error_stl.log"; then
        if file "$TEST_DIR/stl_test" | grep -q "RISC-V"; then
            print_result "$test_name" "PASS"
            return 0
        else
            echo "  Binary format incorrect"
            print_result "$test_name" "FAIL"
            return 1
        fi
    else
        echo "  Compilation failed:"
        cat "$TEST_DIR/error_stl.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
}

# Test 5: Multi-file Compilation
test_multifile() {
    local test_name="Multi-file Compilation"
    echo -e "${BLUE}Testing:${NC} $test_name"
    
    # Compile math_utils.c
    if ! riscv64-unknown-linux-gnu-gcc -c "$SOURCES_DIR/math_utils.c" -o "$TEST_DIR/math_utils.o" 2>"$TEST_DIR/error_multifile1.log"; then
        echo "  Failed to compile math_utils.c:"
        cat "$TEST_DIR/error_multifile1.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
    
    # Compile main.c
    if ! riscv64-unknown-linux-gnu-gcc -c "$SOURCES_DIR/main.c" -o "$TEST_DIR/main.o" -I"$SOURCES_DIR" 2>"$TEST_DIR/error_multifile2.log"; then
        echo "  Failed to compile main.c:"
        cat "$TEST_DIR/error_multifile2.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
    
    # Link
    if riscv64-unknown-linux-gnu-gcc "$TEST_DIR/math_utils.o" "$TEST_DIR/main.o" -o "$TEST_DIR/multifile" 2>"$TEST_DIR/error_multifile3.log"; then
        if file "$TEST_DIR/multifile" | grep -q "RISC-V"; then
            print_result "$test_name" "PASS"
            return 0
        else
            echo "  Binary format incorrect"
            print_result "$test_name" "FAIL"
            return 1
        fi
    else
        echo "  Linking failed:"
        cat "$TEST_DIR/error_multifile3.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
}

# Test 6: Static Library
test_static_lib() {
    local test_name="Static Library"
    echo -e "${BLUE}Testing:${NC} $test_name"
    
    # Compile library
    if ! riscv64-unknown-linux-gnu-gcc -c "$SOURCES_DIR/mylib.c" -o "$TEST_DIR/mylib.o" 2>"$TEST_DIR/error_lib1.log"; then
        echo "  Failed to compile library:"
        cat "$TEST_DIR/error_lib1.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
    
    # Create static library
    if ! riscv64-unknown-linux-gnu-ar rcs "$TEST_DIR/libmylib.a" "$TEST_DIR/mylib.o" 2>"$TEST_DIR/error_lib2.log"; then
        echo "  Failed to create static library:"
        cat "$TEST_DIR/error_lib2.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
    
    # Compile and link with library
    if riscv64-unknown-linux-gnu-gcc "$SOURCES_DIR/test_lib.c" -I"$SOURCES_DIR" -L"$TEST_DIR" -lmylib -o "$TEST_DIR/test_lib" 2>"$TEST_DIR/error_lib3.log"; then
        if file "$TEST_DIR/test_lib" | grep -q "RISC-V"; then
            print_result "$test_name" "PASS"
            return 0
        else
            echo "  Binary format incorrect"
            print_result "$test_name" "FAIL"
            return 1
        fi
    else
        echo "  Linking with library failed:"
        cat "$TEST_DIR/error_lib3.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
}

# Test 7: Optimization Levels
test_optimization() {
    local test_name="Optimization Levels"
    echo -e "${BLUE}Testing:${NC} $test_name"
    
    local all_passed=true
    
    for opt in O0 O1 O2 O3 Os; do
        if ! riscv64-unknown-linux-gnu-gcc -$opt "$SOURCES_DIR/optimization_test.c" -o "$TEST_DIR/opt_$opt" 2>"$TEST_DIR/error_opt_$opt.log"; then
            echo "  Failed with -$opt:"
            cat "$TEST_DIR/error_opt_$opt.log"
            all_passed=false
            break
        fi
        
        if ! file "$TEST_DIR/opt_$opt" | grep -q "RISC-V"; then
            echo "  Binary format incorrect for -$opt"
            all_passed=false
            break
        fi
    done
    
    if $all_passed; then
        print_result "$test_name (O0, O1, O2, O3, Os)" "PASS"
        return 0
    else
        print_result "$test_name" "FAIL"
        return 1
    fi
}

# Test 8: Preprocessor
test_preprocessor() {
    local test_name="Preprocessor"
    echo -e "${BLUE}Testing:${NC} $test_name"
    
    # Test without DEBUG
    if ! riscv64-unknown-linux-gnu-gcc "$SOURCES_DIR/preprocessor_test.c" -o "$TEST_DIR/preproc_test" 2>"$TEST_DIR/error_preproc1.log"; then
        echo "  Compilation without DEBUG failed:"
        cat "$TEST_DIR/error_preproc1.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
    
    # Test with DEBUG
    if ! riscv64-unknown-linux-gnu-gcc -DDEBUG "$SOURCES_DIR/preprocessor_test.c" -o "$TEST_DIR/preproc_test_debug" 2>"$TEST_DIR/error_preproc2.log"; then
        echo "  Compilation with DEBUG failed:"
        cat "$TEST_DIR/error_preproc2.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
    
    # Test preprocessor output
    if riscv64-unknown-linux-gnu-gcc -E "$SOURCES_DIR/preprocessor_test.c" > "$TEST_DIR/preprocessed.i" 2>"$TEST_DIR/error_preproc3.log"; then
        print_result "$test_name" "PASS"
        return 0
    else
        echo "  Preprocessor output generation failed:"
        cat "$TEST_DIR/error_preproc3.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
}

# Test 9: Assembly Generation
test_assembly() {
    local test_name="Assembly Generation"
    echo -e "${BLUE}Testing:${NC} $test_name"
    
    # Generate assembly
    if ! riscv64-unknown-linux-gnu-gcc -S "$SOURCES_DIR/assembly_test.c" -o "$TEST_DIR/assembly_test.s" 2>"$TEST_DIR/error_asm1.log"; then
        echo "  Assembly generation failed:"
        cat "$TEST_DIR/error_asm1.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
    
    # Check for RISC-V instructions
    if ! grep -qE "add|addi|ret" "$TEST_DIR/assembly_test.s"; then
        echo "  No RISC-V instructions found in assembly"
        print_result "$test_name" "FAIL"
        return 1
    fi
    
    # Compile from assembly
    if riscv64-unknown-linux-gnu-gcc "$TEST_DIR/assembly_test.s" -o "$TEST_DIR/assembly_test" 2>"$TEST_DIR/error_asm2.log"; then
        print_result "$test_name" "PASS"
        return 0
    else
        echo "  Compilation from assembly failed:"
        cat "$TEST_DIR/error_asm2.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
}

# Test 10: Binary Format
test_binary_format() {
    local test_name="Binary Format Verification"
    echo -e "${BLUE}Testing:${NC} $test_name"
    
    # Use hello.c for format testing
    if ! riscv64-unknown-linux-gnu-gcc "$SOURCES_DIR/hello.c" -o "$TEST_DIR/format_test" 2>"$TEST_DIR/error_format.log"; then
        echo "  Compilation failed:"
        cat "$TEST_DIR/error_format.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
    
    local all_checks_passed=true
    
    # Check ELF format
    if ! file "$TEST_DIR/format_test" | grep -q "ELF"; then
        echo "  Not ELF format"
        all_checks_passed=false
    fi
    
    # Check 64-bit
    if ! file "$TEST_DIR/format_test" | grep -q "64-bit"; then
        echo "  Not 64-bit"
        all_checks_passed=false
    fi
    
    # Check RISC-V
    if ! file "$TEST_DIR/format_test" | grep -q "RISC-V"; then
        echo "  Not RISC-V architecture"
        all_checks_passed=false
    fi
    
    # Check with readelf
    if ! riscv64-unknown-linux-gnu-readelf -h "$TEST_DIR/format_test" 2>/dev/null | grep -q "Machine.*RISC-V"; then
        echo "  readelf does not confirm RISC-V"
        all_checks_passed=false
    fi
    
    # Check little-endian
    if ! file "$TEST_DIR/format_test" | grep -q "LSB"; then
        echo "  Not little-endian"
        all_checks_passed=false
    fi
    
    if $all_checks_passed; then
        print_result "$test_name" "PASS"
        return 0
    else
        print_result "$test_name" "FAIL"
        return 1
    fi
}

# Test 11: MTE Features
test_mte() {
    local test_name="MTE Features"
    echo -e "${BLUE}Testing:${NC} $test_name"
    
    if riscv64-unknown-linux-gnu-gcc "$SOURCES_DIR/mte_test.c" -o "$TEST_DIR/mte_test" 2>"$TEST_DIR/error_mte.log"; then
        if file "$TEST_DIR/mte_test" | grep -q "RISC-V"; then
            print_result "$test_name" "PASS"
            return 0
        else
            echo "  Binary format incorrect"
            print_result "$test_name" "FAIL"
            return 1
        fi
    else
        echo "  Compilation failed:"
        cat "$TEST_DIR/error_mte.log"
        print_result "$test_name" "FAIL"
        return 1
    fi
}

# Main test execution
main() {
    print_header "RISC-V MTE Toolchain - Complete Test Suite"
    
    echo "Project Root: $PROJECT_ROOT"
    echo "Sources Dir: $SOURCES_DIR"
    echo "Test Dir: $TEST_DIR"
    echo ""
    
    # Check toolchain
    check_toolchain
    
    # Check if sources exist
    if [ ! -d "$SOURCES_DIR" ]; then
        echo -e "${RED}ERROR: Sources directory not found: $SOURCES_DIR${NC}"
        echo "Please create the test sources first."
        exit 1
    fi
    
    print_header "Running Tests"
    
    # Run all tests
    test_basic_c
    test_c_stdlib
    test_cpp_basic
    test_cpp_stl
    test_multifile
    test_static_lib
    test_optimization
    test_preprocessor
    test_assembly
    test_binary_format
    test_mte
    
    # Print summary
    print_header "Test Summary"
    
    echo "Total Tests:  $TOTAL_TESTS"
    echo -e "Passed:       ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed:       ${RED}$FAILED_TESTS${NC}"
    echo ""
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}  ✓ All tests passed!${NC}"
        echo -e "${GREEN}========================================${NC}"
        exit 0
    else
        echo -e "${RED}========================================${NC}"
        echo -e "${RED}  ✗ Some tests failed!${NC}"
        echo -e "${RED}========================================${NC}"
        echo ""
        echo "Check error logs in: $TEST_DIR"
        echo "Run individual tests to debug:"
        echo "  cd $SOURCES_DIR"
        echo "  riscv64-unknown-linux-gnu-gcc <source_file> -o test"
        exit 1
    fi
}

# Run main function
main
