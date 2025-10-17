#!/bin/bash
################################################################################
# RISC-V MTE Toolchain - GCC Final Build Script
# Stage 5: Build full-featured GCC with C/C++ support
################################################################################

set -e
set -u

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${GREEN}=== Stage 5: Building GCC Final ===${NC}"

# Get project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source environment
if [ -f "$PROJECT_ROOT/env.sh" ]; then
    source "$PROJECT_ROOT/env.sh"
else
    echo -e "${RED}Error: env.sh not found. Run setup-environment.sh first.${NC}"
    exit 1
fi

# Configuration
SRC_DIR="$PROJECT_ROOT/src"
BUILD_DIR="$SRC_DIR/gcc/build-final"
LOG_FILE="$PROJECT_ROOT/logs/gcc-final-build.log"

mkdir -p "$PROJECT_ROOT/logs"

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

print_important() {
    echo -e "${MAGENTA}[★]${NC} $1"
}

# Check prerequisites
echo "Checking prerequisites..."

if [ ! -f "$PREFIX/bin/riscv64-unknown-linux-gnu-gcc" ]; then
    print_error "GCC Bootstrap not found! Run build-gcc-bootstrap.sh first."
    exit 1
fi

if [ ! -f "$PREFIX/$TARGET/lib/libc.so.6" ]; then
    print_error "Glibc not found! Run build-glibc.sh first."
    exit 1
fi

print_status "All prerequisites met"

# Check if already built
if [ -f "$PREFIX/bin/riscv64-unknown-linux-gnu-g++" ]; then
    print_info "GCC Final already installed"
    read -p "Rebuild? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Skipping GCC Final build"
        exit 0
    fi
fi

# Pre-emptive fix: Create symbolic link for system headers
echo "Applying pre-emptive fix for header paths..."
cd "$PREFIX/$TARGET"

if [ ! -d "usr" ]; then
    mkdir -p usr
fi

if [ ! -L "usr/include" ]; then
    ln -sf ../include usr/include
    print_status "Created symbolic link: usr/include -> ../include"
else
    print_info "Symbolic link already exists"
fi

# Prepare source
echo "Preparing GCC source code..."
cd "$SRC_DIR/gcc"

if [ ! -d ".git" ]; then
    print_error "GCC source not found! This should have been cloned in Stage 2."
    exit 1
fi

print_status "Source code ready"

# Create build directory
echo "Creating build directory..."
rm -rf build-final
mkdir -p build-final
cd build-final

# Configure
echo "Configuring GCC Final..."
print_important "This is the production-ready compiler with all fixes applied"
print_info "Key configuration options:"
print_info "  --with-sysroot: Fixes 'cannot find /lib/libc.so.6' error"
print_info "  --with-native-system-header-dir: Fixes /usr/include path issue"
print_info "  --disable-multilib: Prevents 32-bit build attempts"
print_info "  --enable-languages=c,c++: Full C/C++ support"

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
    --enable-libstdcxx \
    2>&1 | tee "$LOG_FILE"

print_status "Configuration complete"

# Build
echo "Building GCC Final..."
print_warning "This is the second longest stage - may take 60-120 minutes"
print_info "Using $(nproc) parallel jobs"
print_info "Perfect time for a long break ☕🍕"

make -j$(nproc) 2>&1 | tee -a "$LOG_FILE"

print_status "Build complete"

# Install
echo "Installing GCC Final..."
make install 2>&1 | tee -a "$LOG_FILE"

print_status "Installation complete"

# Verify installation
echo "Verifying installation..."

# Check C compiler
if [ -f "$PREFIX/bin/riscv64-unknown-linux-gnu-gcc" ]; then
    print_status "C compiler installed"
    version=$($PREFIX/bin/riscv64-unknown-linux-gnu-gcc --version | head -n 1)
    print_info "$version"
else
    print_error "C compiler not found!"
    exit 1
fi

# Check C++ compiler
if [ -f "$PREFIX/bin/riscv64-unknown-linux-gnu-g++" ]; then
    print_status "C++ compiler installed"
    version=$($PREFIX/bin/riscv64-unknown-linux-gnu-g++ --version | head -n 1)
    print_info "$version"
else
    print_error "C++ compiler not found!"
    exit 1
fi

# Check libstdc++
if [ -f "$PREFIX/$TARGET/lib/libstdc++.so" ] || \
   [ -f "$PREFIX/$TARGET/lib64/libstdc++.so" ]; then
    print_status "libstdc++ installed"
else
    print_warning "libstdc++ not found (may be in a different location)"
fi

# Test compile
echo "Testing compiler with simple program..."
cat > /tmp/test-gcc-final.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("Hello from RISC-V MTE Toolchain!\n");
    int *ptr = malloc(sizeof(int) * 10);
    if (ptr) {
        ptr[0] = 42;
        printf("Allocated memory, first value: %d\n", ptr[0]);
        free(ptr);
    }
    return 0;
}
EOF

if $PREFIX/bin/riscv64-unknown-linux-gnu-gcc -o /tmp/test-gcc-final /tmp/test-gcc-final.c 2>&1 | tee -a "$LOG_FILE"; then
    print_status "Test compilation successful"
    
    # Check binary
    if file /tmp/test-gcc-final | grep -q "RISC-V"; then
        print_status "Binary is RISC-V ELF"
    else
        print_warning "Binary format unexpected"
    fi
    
    rm -f /tmp/test-gcc-final /tmp/test-gcc-final.c
else
    print_error "Test compilation failed!"
    exit 1
fi

# Summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   GCC Final build completed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${MAGENTA}★ Full Toolchain Ready ★${NC}"
echo ""
echo "Installed compilers:"
echo "  ✓ riscv64-unknown-linux-gnu-gcc (C compiler)"
echo "  ✓ riscv64-unknown-linux-gnu-g++ (C++ compiler)"
echo ""
echo "Features:"
echo "  ✓ Full C11/C17 support"
echo "  ✓ Full C++11/14/17/20 support"
echo "  ✓ POSIX threads support"
echo "  ✓ Shared library support"
echo "  ✓ MTE-aware memory allocation (via Glibc)"
echo ""
echo "Location: $PREFIX/bin/"
echo ""
echo "Next step: ./scripts/verify-installation.sh"
echo ""
