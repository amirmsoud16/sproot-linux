#!/bin/bash

# CFU.SH - Custom File Utility Script (Optimized Ubuntu Tools Setup)
# Simplified version of ubuntu-tools-setup.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Simple print functions
print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check Ubuntu environment
check_environment() {
    print_info "Checking Ubuntu environment..."
    
    if [[ ! -f "/etc/os-release" ]]; then
        print_error "This script must be run inside Ubuntu!"
        exit 1
    fi
    
    if ! grep -q "Ubuntu" /etc/os-release; then
        print_error "This script is designed for Ubuntu only!"
        exit 1
    fi
    
    print_success "Ubuntu environment detected"
}

# Check sudo availability
check_sudo() {
    print_info "Checking sudo availability..."
    
    if ! command -v sudo &> /dev/null; then
        print_error "sudo is not available!"
        exit 1
    fi
    
    print_success "sudo is available"
}

# Install system tools
install_system_tools() {
    print_info "Installing system tools..."
    
    sudo apt update -y
    sudo apt install -y curl wget git nano vim build-essential gcc g++ make
    sudo apt install -y python3 python3-pip nodejs npm
    sudo apt install -y htop neofetch unzip zip tar net-tools iputils-ping
    
    print_success "System tools installed"
}

# Install development tools
install_dev_tools() {
    print_info "Installing development tools..."
    
    sudo apt install -y cmake clang gdb valgrind strace ltrace
    sudo apt install -y tree mc ranger fzf ripgrep bat exa fd-find
    
    print_success "Development tools installed"
}

# Install network tools
install_network_tools() {
    print_info "Installing network tools..."
    
    sudo apt install -y iperf3 iotop nethogs iftop nload
    
    print_success "Network tools installed"
}

# Install text processing tools
install_text_tools() {
    print_info "Installing text processing tools..."
    
    sudo apt install -y grep sed awk jq xmlstarlet csvkit
    
    print_success "Text processing tools installed"
}

# Install Python packages
install_python_packages() {
    print_info "Installing Python packages..."
    
    pip3 install requests beautifulsoup4 pandas numpy matplotlib
    
    print_success "Python packages installed"
}

# Install Node.js packages
install_nodejs_packages() {
    print_info "Installing Node.js packages..."
    
    sudo npm install -g yarn npx create-react-app express-generator
    
    print_success "Node.js packages installed"
}

# Install additional tools
install_additional_tools() {
    print_info "Installing additional tools..."
    
    sudo apt install -y tmux screen byobu fish zsh
    sudo apt install -y git git-flow
    sudo apt install -y sqlite3 postgresql-client mysql-client
    sudo apt install -y apache2-utils nginx-common
    sudo apt install -y openssl sslscan testssl.sh
    sudo apt install -y ffmpeg imagemagick sox
    sudo apt install -y rsync cron anacron logrotate
    sudo apt install -y openjdk-11-jdk
    sudo apt install -y geany
    
    print_success "Additional tools installed"
}

# Setup user environment
setup_user_environment() {
    print_info "Setting up user environment..."
    
    # Create directories
    mkdir -p ~/projects ~/downloads ~/documents ~/pictures ~/music ~/videos
    mkdir -p ~/projects/{web,python,nodejs,scripts}
    mkdir -p ~/projects/web/{frontend,backend}
    mkdir -p ~/projects/python/{scripts,web,data}
    mkdir -p ~/projects/nodejs/{apps,packages}
    
    # Add aliases
    echo 'alias ll="ls -la"' >> ~/.bashrc
    echo 'alias la="ls -A"' >> ~/.bashrc
    echo 'alias l="ls -CF"' >> ~/.bashrc
    echo 'alias ..="cd .."' >> ~/.bashrc
    echo 'alias ...="cd ../.."' >> ~/.bashrc
    echo 'alias ....="cd ../../.."' >> ~/.bashrc
    echo 'alias home="cd ~"' >> ~/.bashrc
    echo 'alias cls="clear"' >> ~/.bashrc
    
    # Setup SSH
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    
    # Setup git
    git config --global user.name "$(whoami)"
    git config --global user.email "$(whoami)@localhost"
    git config --global init.defaultBranch main
    
    # Create README
    echo "# Development Environment" > ~/projects/README.md
    echo "This directory contains all development projects." >> ~/projects/README.md
    
    print_success "User environment setup completed"
}

# Install Rust (optional)
install_rust() {
    print_info "Installing Rust..."
    
    if ! command -v rustc &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
        print_success "Rust installed"
    else
        print_info "Rust is already installed"
    fi
}

# Main function
main() {
    print_info "Starting Ubuntu Tools Setup..."
    
    check_environment
    check_sudo
    install_system_tools
    install_dev_tools
    install_network_tools
    install_text_tools
    install_python_packages
    install_nodejs_packages
    install_additional_tools
    install_rust
    setup_user_environment
    
    print_success "Tools setup completed successfully!"
    print_info "Available tools:"
    print_info "Development: gcc, g++, make, cmake, clang, gdb"
    print_info "Python: python3, pip3, requests, pandas, numpy"
    print_info "Node.js: node, npm, yarn, npx"
    print_info "Network: curl, wget, git, iperf3"
    print_info "CLI: tree, mc, ranger, fzf, ripgrep, bat"
    print_info "Editors: geany"
}

# Run main function
main 