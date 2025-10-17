#!/bin/bash
################################################################################
# RISC-V MTE Toolchain - Binutils Build Script
# Stage 1: Build Binutils (assembler and linker)
################################################################################

set -e
set -u

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}=== Stage 1: Building Binutils ===${NC}"

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
BINUTILS_REPO="https://gitlab.com/vrull-public/binutils-gdb.git"
BINUTILS_BRANCH="riscv-mte"
SRC_DIR="$PROJECT_ROOT/src"
BUILD_DIR="$SRC_DIR/binutils-gdb/build"
LOG_FILE="$PROJECT_ROOT/logs/binutils-build.log"

# Create log directory
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

# Check if already built
if [ -f "$PREFIX/bin/riscv64-unknown-linux-gnu-as" ]; then
    print_info "Binutils already installed at $PREFIX"
    read -p "Rebuild? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Skipping Binutils build"
        exit 0
    fi
fi

# Clone source code
echo "Cloning Binutils source code..."
cd "$SRC_DIR"

if [ -d "binutils-gdb" ]; then
    print_info "Source directory exists, pulling latest changes..."
    cd binutils-gdb
    git fetch origin
    git checkout "$BINUTILS_BRANCH"
    git pull
else
    print_info "Cloning from $BINUTILS_REPO..."
    git clone -b "$BINUTILS_BRANCH" "$BINUTILS_REPO"
    cd binutils-gdb
fi

print_status "Source code ready"

# Create build directory
echo "Creating build directory..."
rm -rf build
mkdir -p build
cd build

# Configure
echo "Configuring Binutils..."
print_info "Target: $TARGET"
print_info "Prefix: $PREFIX"

../configure \
    --target=$TARGET \
    --prefix=$PREFIX \
    --disable-nls \
    --disable-werror \
    2>&1 | tee "$LOG_FILE"

print_status "Configuration complete"

# Build
echo "Building Binutils..."
print_info "This may take 10-15 minutes..."
print_info "Using $(nproc) parallel jobs"

make -j$(nproc) 2>&1 | tee -a "$LOG_FILE"

print_status "Build complete"

# Install
echo "Installing Binutils..."
make install 2>&1 | tee -a "$LOG_FILE"

print_status "Installation complete"

# Verify installation
echo "Verifying installation..."

if [ -f "$PREFIX/bin/riscv64-unknown-linux-gnu-as" ]; then
    print_status "Assembler installed: $PREFIX/bin/riscv64-unknown-linux-gnu-as"
    $PREFIX/bin/riscv64-unknown-linux-gnu-as --version | head -n 1
else
    print_error "Assembler not found!"
    exit 1
fi

if [ -f "$PREFIX/bin/riscv64-unknown-linux-gnu-ld" ]; then
    print_status "Linker installed: $PREFIX/bin/riscv64-unknown-linux-gnu-ld"
    $PREFIX/bin/riscv64-unknown-linux-gnu-ld --version | head -n 1
else
    print_error "Linker not found!"
    exit 1
fi

# Summary
echo ""
echo -e "${GREEN}========================================"
echo "Binutils build completed successfully!"
echo "========================================${NC}"
echo ""
echo "Installed tools:"
echo "  - riscv64-unknown-linux-gnu-as (assembler)"
echo "  - riscv64-unknown-linux-gnu-ld (linker)"
echo "  - riscv64-unknown-linux-gnu-objdump"
echo "  - riscv64-unknown-linux-gnu-readelf"
echo "  - and more..."
echo ""
echo "Next step: ./scripts/build-gcc-bootstrap.sh"
echo ""
