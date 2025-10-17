#!/bin/bash
################################################################################
# RISC-V MTE Toolchain - Environment Setup Script
# Stage 0: Install dependencies and configure environment
################################################################################

set -e  # Exit on error
set -u  # Exit on undefined variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Stage 0: Environment Setup ===${NC}"

# Function to print status
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if running on supported OS
check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
            print_warning "This script is tested on Ubuntu/Debian. Your OS: $ID"
            read -p "Continue anyway? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    fi
}

# Check system resources
check_resources() {
    echo "Checking system resources..."
    
    # Check RAM
    total_ram=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$total_ram" -lt 8 ]; then
        print_warning "Low RAM detected: ${total_ram}GB (8GB+ recommended)"
    else
        print_status "RAM: ${total_ram}GB"
    fi
    
    # Check disk space
    available_space=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$available_space" -lt 30 ]; then
        print_error "Insufficient disk space: ${available_space}GB (30GB+ required)"
        exit 1
    else
        print_status "Available disk space: ${available_space}GB"
    fi
    
    # Check CPU cores
    cpu_cores=$(nproc)
    print_status "CPU cores: $cpu_cores"
}

# Create directory structure
create_directories() {
    echo "Creating directory structure..."
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
    
    cd "$PROJECT_ROOT"
    
    mkdir -p src
    mkdir -p toolchain
    mkdir -p logs
    mkdir -p tests
    
    print_status "Created directories: src/, toolchain/, logs/, tests/"
}

# Install dependencies
install_dependencies() {
    echo "Installing dependencies..."
    
    print_status "Updating package lists..."
    sudo apt-get update
    
    print_status "Installing build dependencies..."
    sudo apt-get install -y \
        git \
        build-essential \
        autoconf \
        texinfo \
        bison \
        flex \
        libgmp-dev \
        libmpfr-dev \
        libmpc-dev \
        libtool \
        wget \
        curl \
        gawk \
        python3 \
        python3-pip
    
    print_status "All dependencies installed successfully"
}

# Set environment variables
setup_environment() {
    echo "Setting up environment variables..."
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
    
    export TARGET=riscv64-unknown-linux-gnu
    export PREFIX="$PROJECT_ROOT/toolchain"
    export PATH="$PREFIX/bin:$PATH"
    
    # Check if already in .bashrc
    if ! grep -q "RISC-V MTE Toolchain Environment" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# RISC-V MTE Toolchain Environment" >> ~/.bashrc
        echo "export TARGET=riscv64-unknown-linux-gnu" >> ~/.bashrc
        echo "export PREFIX=$PREFIX" >> ~/.bashrc
        echo 'export PATH=$PREFIX/bin:$PATH' >> ~/.bashrc
        
        print_status "Environment variables added to ~/.bashrc"
    else
        print_status "Environment variables already in ~/.bashrc"
    fi
    
    # Create env.sh for sourcing
    cat > "$PROJECT_ROOT/env.sh" << EOF
#!/bin/bash
# RISC-V MTE Toolchain Environment
export TARGET=riscv64-unknown-linux-gnu
export PREFIX=$PREFIX
export PATH=\$PREFIX/bin:\$PATH

echo "RISC-V MTE Toolchain environment loaded"
echo "TARGET: \$TARGET"
echo "PREFIX: \$PREFIX"
EOF
    
    chmod +x "$PROJECT_ROOT/env.sh"
    print_status "Created env.sh for quick environment setup"
}

# Verify setup
verify_setup() {
    echo "Verifying setup..."
    
    # Check if essential tools are available
    local tools=("gcc" "make" "git" "autoconf" "bison" "flex")
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            print_status "$tool is available"
        else
            print_error "$tool is NOT available"
            exit 1
        fi
    done
}

# Main execution
main() {
    echo "========================================"
    echo "RISC-V MTE Toolchain - Environment Setup"
    echo "========================================"
    echo ""
    
    check_os
    check_resources
    create_directories
    install_dependencies
    setup_environment
    verify_setup
    
    echo ""
    echo -e "${GREEN}========================================"
    echo "Environment setup completed successfully!"
    echo "========================================${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Reload environment: source ~/.bashrc"
    echo "  2. Or use: source env.sh"
    echo "  3. Run: ./scripts/build-binutils.sh"
    echo ""
}

main "$@"
