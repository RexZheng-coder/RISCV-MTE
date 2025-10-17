#!/bin/bash
################################################################################
# RISC-V MTE Toolchain - Clean Script
# Remove build artifacts and optionally source code
################################################################################

set -e
set -u

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

echo "RISC-V MTE Toolchain - Clean Script"
echo ""
echo "What would you like to clean?"
echo ""
echo "  1) Build directories only (keep source code)"
echo "  2) Build directories and source code"
echo "  3) Everything (including toolchain)"
echo "  4) Cancel"
echo ""
read -p "Enter choice [1-4]: " choice

case $choice in
    1)
        echo ""
        print_info "Cleaning build directories..."
        cd "$PROJECT_ROOT/src"
        
        rm -rf binutils-gdb/build
        rm -rf gcc/build-bootstrap
        rm -rf gcc/build-final
        rm -rf glibc/build
        
        print_status "Build directories cleaned"
        ;;
        
    2)
        echo ""
        print_warning "This will remove all source code!"
        read -p "Are you sure? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Cleaning source code..."
            rm -rf "$PROJECT_ROOT/src"
            mkdir -p "$PROJECT_ROOT/src"
            print_status "Source code cleaned"
        else
            print_info "Cancelled"
        fi
        ;;
        
    3)
        echo ""
        print_warning "This will remove EVERYTHING including the compiled toolchain!"
        print_warning "You will need to rebuild from scratch!"
        read -p "Are you ABSOLUTELY sure? (yes/N) " -r
        echo
        if [[ $REPLY == "yes" ]]; then
            print_info "Cleaning everything..."
            rm -rf "$PROJECT_ROOT/src"
            rm -rf "$PROJECT_ROOT/toolchain"
            rm -rf "$PROJECT_ROOT/logs"
            mkdir -p "$PROJECT_ROOT/src"
            mkdir -p "$PROJECT_ROOT/toolchain"
            mkdir -p "$PROJECT_ROOT/logs"
            print_status "Everything cleaned"
        else
            print_info "Cancelled"
        fi
        ;;
        
    4)
        print_info "Cancelled"
        exit 0
        ;;
        
    *)
        print_warning "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "Disk space freed:"
du -sh "$PROJECT_ROOT" 2>/dev/null || echo "N/A"
echo ""
