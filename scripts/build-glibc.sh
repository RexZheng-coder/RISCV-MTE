#!/bin/bash
################################################################################
# RISC-V MTE Toolchain - Glibc Build Script
# Stage 4: Build Glibc with MTE support
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

echo -e "${GREEN}=== Stage 4: Building Glibc with MTE Support ===${NC}"

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
GLIBC_REPO="https://gitlab.com/vrull-public/glibc.git"
GLIBC_BRANCH="riscv-mte"
SRC_DIR="$PROJECT_ROOT/src"
BUILD_DIR="$SRC_DIR/glibc/build"
LOG_FILE="$PROJECT_ROOT/logs/glibc-build.log"

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

if [ ! -d "$PREFIX/$TARGET/include/linux" ]; then
    print_error "Kernel headers not found! Run install-kernel-headers.sh first."
    exit 1
fi

print_status "All prerequisites met"

# Check if already built
if [ -f "$PREFIX/$TARGET/lib/libc.so.6" ]; then
    print_info "Glibc already installed at $PREFIX/$TARGET"
    read -p "Rebuild? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Skipping Glibc build"
        exit 0
    fi
fi

# Clone source code
echo "Preparing Glibc source code..."
cd "$SRC_DIR"

if [ -d "glibc" ]; then
    print_info "Source directory exists"
    cd glibc
    git fetch origin
    git checkout "$GLIBC_BRANCH"
    git pull
else
    print_info "Cloning from $GLIBC_REPO..."
    git clone -b "$GLIBC_BRANCH" "$GLIBC_REPO"
    cd glibc
fi

print_status "Source code ready"

# Create build directory
echo "Creating build directory..."
rm -rf build
mkdir -p build
cd build

# Configure
echo "Configuring Glibc..."
print_important "Enabling MTE support with --enable-memory-tagging"
print_info "This makes malloc/free MTE-aware!"

../configure \
    --target=$TARGET \
    --host=$TARGET \
    --prefix="" \
    --with-headers=$PREFIX/$TARGET/include \
    --enable-memory-tagging \
    --disable-werror \
    2>&1 | tee "$LOG_FILE"

print_status "Configuration complete"

# Build
echo "Building Glibc..."
print_warning "This is the longest stage - may take 30-60 minutes"
print_info "Using $(nproc) parallel jobs"
print_info "Go get a coffee ☕"

make -j$(nproc) 2>&1 | tee -a "$LOG_FILE"

print_status "Build complete"

# Install
echo "Installing Glibc..."
print_info "Installing to: $PREFIX/$TARGET"

make install DESTDIR=$PREFIX/$TARGET 2>&1 | tee -a "$LOG_FILE"

print_status "Installation complete"

# Verify installation
echo "Verifying installation..."

if [ -f "$PREFIX/$TARGET/lib/libc.so.6" ]; then
    print_status "libc.so.6 installed"
else
    print_error "libc.so.6 not found!"
    exit 1
fi

if [ -f "$PREFIX/$TARGET/lib/libm.so.6" ]; then
    print_status "libm.so.6 installed"
else
    print_error "libm.so.6 not found!"
    exit 1
fi

if [ -f "$PREFIX/$TARGET/lib/libpthread.so.0" ]; then
    print_status "libpthread.so.0 installed"
else
    print_error "libpthread.so.0 not found!"
    exit 1
fi

# Check for MTE support in headers
if grep -q "memory_tagging" "$PREFIX/$TARGET/include/features.h" 2>/dev/null; then
    print_important "MTE support detected in headers!"
else
    print_warning "Could not verify MTE support in headers"
fi

# Summary
echo ""
echo -e "${GREEN}========================================"
echo "Glibc build completed successfully!"
echo "========================================${NC}"
echo ""
echo -e "${MAGENTA}★ MTE Support Enabled ★${NC}"
echo ""
echo "Installed libraries:"
echo "  ✓ libc.so.6 (C standard library)"
echo "  ✓ libm.so.6 (Math library)"
echo "  ✓ libpthread.so.0 (Threading)"
echo "  ✓ And many more..."
echo ""
echo "Location: $PREFIX/$TARGET/lib/"
echo ""
echo "Next step: ./scripts/build-gcc-final.sh"
echo ""
