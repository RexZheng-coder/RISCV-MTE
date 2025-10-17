#!/bin/bash
################################################################################
# RISC-V MTE Toolchain - GCC Bootstrap Build Script
# Stage 2: Build minimal GCC to break circular dependency
################################################################################

set -e
set -u

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}=== Stage 2: Building GCC Bootstrap ===${NC}"

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
GCC_REPO="https://gitlab.com/vrull-public/gcc.git"
GCC_BRANCH="riscv-mte"
SRC_DIR="$PROJECT_ROOT/src"
BUILD_DIR="$SRC_DIR/gcc/build-bootstrap"
LOG_FILE="$PROJECT_ROOT/logs/gcc-bootstrap-build.log"

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

# Check prerequisites
if [ ! -f "$PREFIX/bin/riscv64-unknown-linux-gnu-as" ]; then
    print_error "Binutils not found! Run build-binutils.sh first."
    exit 1
fi

# Clone source code
echo "Preparing GCC source code..."
cd "$SRC_DIR"

if [ -d "gcc" ]; then
    print_info "Source directory exists"
    cd gcc
    git fetch origin
    git checkout "$GCC_BRANCH"
    git pull
else
    print_info "Cloning from $GCC_REPO..."
    git clone -b "$GCC_BRANCH" "$GCC_REPO"
    cd gcc
fi

print_status "Source code ready"

# Download prerequisites
echo "Downloading GCC prerequisites..."
if [ ! -d "gmp" ] || [ ! -d "mpfr" ] || [ ! -d "mpc" ]; then
    ./contrib/download_prerequisites
    print_status "Prerequisites downloaded"
else
    print_info "Prerequisites already downloaded"
fi

# Create build directory
echo "Creating build directory..."
rm -rf build-bootstrap
mkdir -p build-bootstrap
cd build-bootstrap

# Configure
echo "Configuring GCC Bootstrap..."
print_info "This is a minimal C-only compiler without Glibc dependency"
print_warning "The following options break the circular dependency:"
print_info "  --without-headers: No C library headers needed"
print_info "  --disable-threads: No threading support"
print_info "  --disable-shared: No shared libraries"
print_info "  --disable-libgcov: No code coverage tools"

../configure \
    --target=$TARGET \
    --prefix=$PREFIX \
    --disable-nls \
    --without-headers \
    --enable-languages=c \
    --disable-threads \
    --disable-libgcov \
    --disable-shared \
    --disable-werror \
    2>&1 | tee "$LOG_FILE"

print_status "Configuration complete"

# Build
echo "Building GCC Bootstrap..."
print_info "This may take 20-30 minutes..."
print_info "Using $(nproc) parallel jobs"

echo "Building all-gcc..."
make -j$(nproc) all-gcc 2>&1 | tee -a "$LOG_FILE"
print_status "GCC compiler built"

echo "Building all-target-libgcc..."
make -j$(nproc) all-target-libgcc 2>&1 | tee -a "$LOG_FILE"
print_status "libgcc built"

# Install
echo "Installing GCC Bootstrap..."
make install-gcc 2>&1 | tee -a "$LOG_FILE"
make install-target-libgcc 2>&1 | tee -a "$LOG_FILE"

print_status "Installation complete"

# Verify installation
echo "Verifying installation..."

if [ -f "$PREFIX/bin/riscv64-unknown-linux-gnu-gcc" ]; then
    print_status "GCC installed: $PREFIX/bin/riscv64-unknown-linux-gnu-gcc"
    $PREFIX/bin/riscv64-unknown-linux-gnu-gcc --version | head -n 1
else
    print_error "GCC not found!"
    exit 1
fi

# Check libgcc
if [ -f "$PREFIX/lib/gcc/$TARGET"/*/libgcc.a ]; then
    print_status "libgcc.a installed"
else
    print_error "libgcc.a not found!"
    exit 1
fi

# Summary
echo ""
echo -e "${GREEN}========================================"
echo "GCC Bootstrap build completed!"
echo "========================================${NC}"
echo ""
echo "This is a minimal C compiler that:"
echo "  ✓ Does NOT depend on Glibc"
echo "  ✓ Can compile Glibc"
echo "  ✓ Will be replaced by full GCC later"
echo ""
echo "Next step: ./scripts/install-kernel-headers.sh"
echo ""
