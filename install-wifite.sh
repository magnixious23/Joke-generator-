#!/bin/bash

# Wifite Installation Script for Termux
# This script installs Wifite2 and all its dependencies on Termux
# Wifite is a tool for auditing wireless networks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if running in Termux
check_termux() {
    if [ ! -d "$PREFIX" ]; then
        print_error "This script must be run in Termux"
        exit 1
    fi
    print_success "Running in Termux environment"
}

# Update system packages
update_system() {
    print_header "Updating System Packages"
    pkg update -y
    pkg upgrade -y
    print_success "System packages updated"
}

# Install dependencies
install_dependencies() {
    print_header "Installing Dependencies"
    
    print_info "Installing core packages..."
    pkg install -y \
        python \
        python-pip \
        git \
        wireless-tools \
        aircrack-ng \
        macchanger \
        curl \
        nano \
        build-essential
    
    print_success "Core packages installed"
    
    print_info "Installing Python dependencies..."
    pip install --upgrade pip setuptools wheel
    print_success "Python pip upgraded"
}

# Clone Wifite repository
install_wifite() {
    print_header "Installing Wifite2"
    
    # Create directory for installation
    WIFITE_DIR="$HOME/.local/share/wifite"
    
    if [ -d "$WIFITE_DIR" ]; then
        print_info "Wifite directory already exists, updating..."
        cd "$WIFITE_DIR"
        git pull origin master
    else
        print_info "Cloning Wifite repository..."
        mkdir -p "$HOME/.local/share"
        git clone https://github.com/derv82/wifite2.git "$WIFITE_DIR"
    fi
    
    cd "$WIFITE_DIR"
    
    print_info "Installing Python requirements..."
    pip install -r requirements.txt
    
    print_success "Wifite2 installed successfully"
}

# Create symlink for easy access
create_symlink() {
    print_header "Creating Command Symlink"
    
    WIFITE_SCRIPT="$HOME/.local/share/wifite/wifite.py"
    SYMLINK_PATH="$PREFIX/bin/wifite"
    
    # Remove existing symlink if present
    if [ -L "$SYMLINK_PATH" ]; then
        rm "$SYMLINK_PATH"
    fi
    
    # Create symlink
    ln -s "$WIFITE_SCRIPT" "$SYMLINK_PATH"
    chmod +x "$SYMLINK_PATH"
    
    print_success "Symlink created at $SYMLINK_PATH"
}

# Verify installation
verify_installation() {
    print_header "Verifying Installation"
    
    if command -v aircrack-ng &> /dev/null; then
        print_success "aircrack-ng is installed"
    else
        print_error "aircrack-ng installation failed"
    fi
    
    if command -v wifite &> /dev/null; then
        print_success "wifite command is available"
        wifite --version 2>/dev/null || echo "Version check: wifite installed"
    else
        print_error "wifite command not found"
    fi
}

# Display usage information
show_usage() {
    print_header "Installation Complete!"
    
    echo -e "${GREEN}Wifite2 has been successfully installed on Termux!${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  Run Wifite with: ${BLUE}sudo wifite${NC}"
    echo "  Or with Python:  ${BLUE}sudo python $HOME/.local/share/wifite/wifite.py${NC}"
    echo ""
    echo -e "${YELLOW}Common Options:${NC}"
    echo "  wifite -h              Show help menu"
    echo "  wifite -i wlan0        Specify interface"
    echo "  wifite --help          Detailed help"
    echo ""
    echo -e "${YELLOW}Note:${NC}"
    echo "  - This tool requires root/sudo privileges"
    echo "  - Make sure your device has WiFi capabilities"
    echo "  - Some features may require a rooted device"
    echo ""
}

# Error handling
on_error() {
    print_error "Installation failed. Please check the errors above."
    exit 1
}

trap on_error ERR

# Main installation flow
main() {
    print_header "Wifite2 Installation for Termux"
    
    check_termux
    update_system
    install_dependencies
    install_wifite
    create_symlink
    verify_installation
    show_usage
}

# Run main function
main
