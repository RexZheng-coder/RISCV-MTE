#!/bin/bash
################################################################################
# RISC-V MTE Toolchain - Complete Automated Build Script
# Executes all 5 stages in sequence
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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Track timing
START_TIME=$(date +%s)

print_banner() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

print_stage() {
    echo ""
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

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

# Error handler
handle_error() {
    local stage=$1
    echo ""
    print_error "Build failed at: $stage"
    echo ""
    echo "Troubleshooting steps:"
    echo "  1. Check the error messages above"
    echo "  2. Review logs in logs/ directory"
    echo "  3. See docs/installation.md for help"
    echo "  4. You can re-run individual stages:"
    echo "     ./scripts/build-$stage.sh"
    echo ""
    exit 1
}

# Welcome banner
print_banner "RISC-V MTE Toolchain - Automated Build"

echo "This script will build the complete toolchain in 5 stages:"
echo ""
echo "  Stage 0: Environment Setup"
echo "  Stage 1: Binutils (10-15 min)"
echo "  Stage 2: GCC Bootstrap (20-30 min)"
echo "  Stage 3: Linux Kernel Headers (2-5 min)"
echo "  Stage 4: Glibc with MTE (30-60 min)"
echo "  Stage 5: GCC Final (60-120 min)"
echo ""
echo "Total estimated time: 2-4 hours"
echo ""

print_warning "This will download several GB of source code"
print_warning "Ensure you have at least 30GB of free disk space"
echo ""

read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Build cancelled"
    exit 0
fi

# Stage 0: Setup
print_stage "Stage 0/5: Environment Setup"
stage_start=$(date +%s)

if [ -f "$SCRIPT_DIR/setup-environment.sh" ]; then
    bash "$SCRIPT_DIR/setup-environment.sh" || handle_error "setup-environment"
    print_status "Environment setup completed"
else
    print_error "setup-environment.sh not found!"
    exit 1
fi

stage_end=$(date +%s)
stage_duration=$((stage_end - stage_start))
print_info "Stage 0 completed in $((stage_duration / 60)) minutes"

# Source environment
if [ -f "$(dirname "$SCRIPT_DIR")/env.sh" ]; then
    source "$(dirname "$SCRIPT_DIR")/env.sh"
fi

# Stage 1: Binutils
print_stage "Stage 1/5: Building Binutils"
stage_start=$(date +%s)

bash "$SCRIPT_DIR/build-binutils.sh" || handle_error "binutils"
print_status "Binutils build completed"

stage_end=$(date +%s)
stage_duration=$((stage_end - stage_start))
print_info "Stage 1 completed in $((stage_duration / 60)) minutes"

# Stage 2: GCC Bootstrap
print_stage "Stage 2/5: Building GCC Bootstrap"
stage_start=$(date +%s)

bash "$SCRIPT_DIR/build-gcc-bootstrap.sh" || handle_error "gcc-bootstrap"
print_status "GCC Bootstrap build completed"

stage_end=$(date +%s)
stage_duration=$((stage_end - stage_start))
print_info "Stage 2 completed in $((stage_duration / 60)) minutes"

# Stage 3: Kernel Headers
print_stage "Stage 3/5: Installing Linux Kernel Headers"
stage_start=$(date +%s)

bash "$SCRIPT_DIR/install-kernel-headers.sh" || handle_error "kernel-headers"
print_status "Kernel headers installation completed"

stage_end=$(date +%s)
stage_duration=$((stage_end - stage_start))
print_info "Stage 3 completed in $((stage_duration / 60)) minutes"

# Stage 4: Glibc
print_stage "Stage 4/5: Building Glibc with MTE Support"
stage_start=$(date +%s)

bash "$SCRIPT_DIR/build-glibc.sh" || handle_error "glibc"
print_status "Glibc build completed"

stage_end=$(date +%s)
stage_duration=$((stage_end - stage_start))
print_info "Stage 4 completed in $((stage_duration / 60)) minutes"

# Stage 5: GCC Final
print_stage "Stage 5/5: Building GCC Final"
stage_start=$(date +%s)

bash "$SCRIPT_DIR/build-gcc-final.sh" || handle_error "gcc-final"
print_status "GCC Final build completed"

stage_end=$(date +%s)
stage_duration=$((stage_end - stage_start))
print_info "Stage 5 completed in $((stage_duration / 60)) minutes"

# Verification
print_stage "Verification"

bash "$SCRIPT_DIR/verify-installation.sh" || print_warning "Some verifications failed"

# Final summary
END_TIME=$(date +%s)
TOTAL_DURATION=$((END_TIME - START_TIME))
HOURS=$((TOTAL_DURATION / 3600))
MINUTES=$(((TOTAL_DURATION % 3600) / 60))

print_banner "Build Completed Successfully!"

echo "Total build time: ${HOURS}h ${MINUTES}m"
echo ""
echo -e "${GREEN}✓ Binutils${NC}"
echo -e "${GREEN}✓ GCC Bootstrap${NC}"
echo -e "${GREEN}✓ Linux Kernel Headers${NC}"
echo -e "${GREEN}✓ Glibc with MTE Support${NC}"
echo -e "${GREEN}✓ GCC Final (C/C++)${NC}"
echo ""
echo "Your RISC-V MTE toolchain is ready!"
echo ""
echo "Toolchain location: $PREFIX"
echo ""
echo "Quick start:"
echo "  source env.sh"
echo "  riscv64-unknown-linux-gnu-gcc --version"
echo "  riscv64-unknown-linux-gnu-g++ --version"
echo ""
echo "Next steps:"
echo "  - See docs/quick-reference.md for usage"
echo "  - See docs/examples/ for code examples"
echo "  - Run tests: ./scripts/run-tests.sh"
echo ""
