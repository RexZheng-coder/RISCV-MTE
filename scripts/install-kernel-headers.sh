#!/bin/bash
################################################################################
# RISC-V MTE Toolchain - Linux Kernel Headers Installation Script
# Stage 3: Install Linux kernel headers for Glibc
################################################################################

set -e
set -u

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}=== Stage 3: Installing Linux Kernel Headers ===${NC}"

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
LINUX_REPO="https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git"
SRC_DIR="$PROJECT_ROOT/src"
LOG_FILE="$PROJECT_ROOT/logs/kernel-headers-install.log"

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

# Check prerequisites
if [ ! -f "$PREFIX/bin/riscv64-unknown-linux-gnu-gcc" ]; then
    print_error "GCC Bootstrap not found! Run build-gcc-bootstrap.sh first."
    exit 1
fi

# Check if already installed
if [ -d "$PREFIX/$TARGET/include/linux" ]; then
    print_info "Kernel headers already installed at $PREFIX/$TARGET/include"
    read -p "Reinstall? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Skipping kernel headers installation"
        exit 0
    fi
fi

# Clone source code
echo "Cloning Linux kernel source..."
cd "$SRC_DIR"

if [ -d "linux" ]; then
    print_info "Source directory exists, pulling latest changes..."
    cd linux
    git fetch origin
    git pull
else
    print_info "Shallow cloning from $LINUX_REPO..."
    print_info "This saves time and disk space"
    git clone --depth=1 "$LINUX_REPO"
    cd linux
fi

print_status "Source code ready"

# Install headers
echo "Installing kernel headers for RISC-V..."
print_info "Target directory: $PREFIX/$TARGET"

make ARCH=riscv \
    INSTALL_HDR_PATH=$PREFIX/$TARGET \
    headers_install \
    2>&1 | tee "$LOG_FILE"

print_status "Installation complete"

# Verify installation
echo "Verifying installation..."

if [ -d "$PREFIX/$TARGET/include/linux" ]; then
    print_status "Linux headers installed: $PREFIX/$TARGET/include/linux"
    header_count=$(find "$PREFIX/$TARGET/include/linux" -name "*.h" | wc -l)
    print_info "Found $header_count header files"
else
    print_error "Linux headers not found!"
    exit 1
fi

if [ -d "$PREFIX/$TARGET/include/asm" ]; then
    print_status "ASM headers installed: $PREFIX/$TARGET/include/asm"
else
    print_error "ASM headers not found!"
    exit 1
fi

if [ -d "$PREFIX/$TARGET/include/asm-generic" ]; then
    print_status "ASM-generic headers installed"
else
    print_error "ASM-generic headers not found!"
    exit 1
fi

# Summary
echo ""
echo -e "${GREEN}========================================"
echo "Kernel headers installed successfully!"
echo "========================================${NC}"
echo ""
echo "Installed to: $PREFIX/$TARGET/include/"
echo "  - linux/     (Linux kernel API)"
echo "  - asm/       (Architecture-specific)"
echo "  - asm-generic/ (Generic definitions)"
echo ""
echo "These headers allow Glibc to:"
echo "  ✓ Make system calls"
echo "  ✓ Use kernel data structures"
echo "  ✓ Interface with the OS"
echo ""
echo "Next step: ./scripts/build-glibc.sh"
echo ""
