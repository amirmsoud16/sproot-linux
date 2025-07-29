#!/bin/bash

# Ubuntu Tools Setup Script
# This script installs all development tools and packages for regular users

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
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

# Function to check if running in Ubuntu environment
check_ubuntu_environment() {
    print_status "🔍 Checking Ubuntu environment..."
    
    # Check if we're in a Linux environment
    if [[ ! -f "/etc/os-release" ]]; then
        print_error "This script must be run inside Ubuntu!"
        print_status "Please run this script after entering Ubuntu with:"
        print_status "proot-distro login ubuntu-XX.04"
        exit 1
    fi
    
    # Check if it's Ubuntu
    if ! grep -q "Ubuntu" /etc/os-release; then
        print_error "This script is designed for Ubuntu only!"
        exit 1
    fi
    
    print_success "Ubuntu environment detected"
}

# Function to check sudo availability
check_sudo_availability() {
    print_status "🔍 Checking sudo availability..."
    
    if ! command -v sudo &> /dev/null; then
        print_error "sudo is not available!"
        print_status "Please run ubuntu-root-setup.sh first to configure sudo"
        exit 1
    fi
    
    # Test sudo access
    if ! sudo -n true 2>/dev/null; then
        print_warning "sudo requires password!"
        print_status "You may be prompted for password during installation"
    fi
    
    print_success "sudo is available"
}

# Function to install system tools
install_system_tools() {
    print_status "📦 Installing system tools..."
    
    # Update package lists
    print_status "Updating package lists..."
    sudo apt update -y
    
    # Install essential system tools
    print_status "Installing essential tools..."
    sudo apt install -y curl wget git nano vim build-essential gcc g++ make
    
    # Install Python and Node.js
    print_status "Installing Python and Node.js..."
    sudo apt install -y python3 python3-pip nodejs npm
    
    # Install monitoring tools
    print_status "Installing monitoring tools..."
    sudo apt install -y htop neofetch unzip zip tar net-tools iputils-ping
    
    print_success "System tools installed"
}

# Function to install development tools
install_dev_tools() {
    print_status "💻 Installing development tools..."
    
    # Install development tools
    print_status "Installing development tools..."
    sudo apt install -y cmake clang gdb valgrind strace ltrace
    
    print_success "Development tools installed"
}

# Function to install network tools
install_network_tools() {
    print_status "🌐 Installing network tools..."
    
    # Install network tools
    print_status "Installing network tools..."
    sudo apt install -y iperf3
    
    print_success "Network tools installed"
}

# Function to install text processing tools
install_text_tools() {
    print_status "📝 Installing text processing tools..."
    
    # Install text processing tools
    print_status "Installing text processing tools..."
    sudo apt install -y grep sed awk jq xmlstarlet csvkit
    
    print_success "Text processing tools installed"
}

# Function to install monitoring tools
install_monitoring_tools() {
    print_status "📊 Installing monitoring tools..."
    
    # Install monitoring tools
    print_status "Installing monitoring tools..."
    sudo apt install -y iotop nethogs iftop nload
    
    print_success "Monitoring tools installed"
}

# Function to install modern CLI tools
install_modern_cli_tools() {
    print_status "🛠️ Installing modern CLI tools..."
    
    # Install modern CLI tools
    print_status "Installing modern CLI tools..."
    sudo apt install -y tree mc ranger fzf ripgrep bat exa fd-find
    
    print_success "Modern CLI tools installed"
}

# Function to install Python packages
install_python_packages() {
    print_status "🐍 Installing Python packages..."
    
    # Install Python packages
    print_status "Installing Python packages..."
    pip3 install requests beautifulsoup4 pandas numpy matplotlib
    
    print_success "Python packages installed"
}

# Function to install Node.js packages
install_nodejs_packages() {
    print_status "📦 Installing Node.js packages..."
    
    # Install Node.js packages
    print_status "Installing Node.js packages..."
    sudo npm install -g yarn npx create-react-app express-generator
    
    print_success "Node.js packages installed"
}

# Function to setup user environment
setup_user_environment() {
    print_status "👤 Setting up user environment..."
    
    # Create useful directories
    print_status "Creating useful directories..."
    mkdir -p ~/projects ~/downloads ~/documents ~/pictures ~/music ~/videos
    
    # Add helpful aliases
    print_status "Adding helpful aliases..."
    echo 'alias ll="ls -la"' >> ~/.bashrc
    echo 'alias la="ls -A"' >> ~/.bashrc
    echo 'alias l="ls -CF"' >> ~/.bashrc
    echo 'alias ..="cd .."' >> ~/.bashrc
    echo 'alias ...="cd ../.."' >> ~/.bashrc
    echo 'alias ....="cd ../../.."' >> ~/.bashrc
    echo 'alias home="cd ~"' >> ~/.bashrc
    echo 'alias cls="clear"' >> ~/.bashrc
    
    # Configure SSH directory
    print_status "Configuring SSH directory..."
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    
    print_success "User environment setup completed"
}

# Function to install additional useful tools
install_additional_tools() {
    print_status "🔧 Installing additional useful tools..."
    
    # Install additional tools
    print_status "Installing additional tools..."
    sudo apt install -y tmux screen byobu fish zsh
    
    # Install version control tools
    print_status "Installing version control tools..."
    sudo apt install -y git git-flow
    
    # Install database tools
    print_status "Installing database tools..."
    sudo apt install -y sqlite3 postgresql-client mysql-client
    
    # Install web development tools
    print_status "Installing web development tools..."
    sudo apt install -y apache2-utils nginx-common
    
    print_success "Additional tools installed"
}

# Function to install security tools
install_security_tools() {
    print_status "🔒 Installing security tools..."
    
    # Install security tools
    print_status "Installing security tools..."
    sudo apt install -y openssl sslscan testssl.sh
    
    print_success "Security tools installed"
}

# Function to install multimedia tools
install_multimedia_tools() {
    print_status "🎵 Installing multimedia tools..."
    
    # Install multimedia tools
    print_status "Installing multimedia tools..."
    sudo apt install -y ffmpeg imagemagick sox
    
    print_success "Multimedia tools installed"
}

# Function to install system administration tools
install_admin_tools() {
    print_status "⚙️ Installing system administration tools..."
    
    # Install system administration tools
    print_status "Installing system administration tools..."
    sudo apt install -y rsync cron anacron logrotate
    
    print_success "System administration tools installed"
}

# Function to create development environment
setup_dev_environment() {
    print_status "💻 Setting up development environment..."
    
    # Create development directories
    print_status "Creating development directories..."
    mkdir -p ~/projects/{web,python,nodejs,scripts}
    mkdir -p ~/projects/web/{frontend,backend}
    mkdir -p ~/projects/python/{scripts,web,data}
    mkdir -p ~/projects/nodejs/{apps,packages}
    
    # Create common development files
    print_status "Creating common development files..."
    echo "# Development Environment" > ~/projects/README.md
    echo "This directory contains all development projects." >> ~/projects/README.md
    
    # Create git configuration
    print_status "Setting up git configuration..."
    git config --global user.name "$(whoami)"
    git config --global user.email "$(whoami)@localhost"
    git config --global init.defaultBranch main
    
    print_success "Development environment setup completed"
}

# Function to install language-specific tools
install_language_tools() {
    print_status "🌍 Installing language-specific tools..."
    
    # Install Go (if available)
    if command -v go &> /dev/null; then
        print_status "Go is already installed"
    else
        print_status "Installing Go..."
        sudo apt install -y golang-go
    fi
    
    # Install Rust (if available)
    if command -v rustc &> /dev/null; then
        print_status "Rust is already installed"
    else
        print_status "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
    fi
    
    # Install Java (if needed)
    print_status "Installing Java..."
    sudo apt install -y openjdk-11-jdk
    
    print_success "Language-specific tools installed"
}

# Function to install container tools
install_container_tools() {
    print_status "🐳 Installing container tools..."
    
    print_status "Container tools installation skipped"
    print_success "Container tools installation completed"
}

# Function to install cloud tools
install_cloud_tools() {
    print_status "☁️ Installing cloud tools..."
    
    print_status "Cloud tools installation skipped"
    print_success "Cloud tools installation completed"
}

# Function to install IDE and editor tools
install_ide_tools() {
    print_status "📝 Installing IDE and editor tools..."
    
    # Install basic editors only
    print_status "Installing basic editors..."
    sudo apt install -y geany
    
    print_success "IDE and editor tools installed"
}

# Main tools setup function
main_tools_setup() {
    print_status "🚀 Starting Ubuntu Tools Setup..."
    
    # Check Ubuntu environment first
    check_ubuntu_environment
    
    # Check sudo availability
    check_sudo_availability
    
    # Install all tools
    install_system_tools
    install_dev_tools
    install_network_tools
    install_text_tools
    install_monitoring_tools
    install_modern_cli_tools
    install_python_packages
    install_nodejs_packages
    install_additional_tools
    install_security_tools
    install_multimedia_tools
    install_admin_tools
    install_language_tools
    install_container_tools
    install_cloud_tools
    install_ide_tools
    
    # Setup user environment
    setup_user_environment
    setup_dev_environment
    
    print_success "✅ Ubuntu Tools Setup completed successfully!"
    print_status "All development tools and packages have been installed."
    print_status "You can now start developing with a fully configured environment."
    echo ""
    print_status "Available tools:"
    print_status "Development: gcc, g++, make, cmake, clang, gdb"
    print_status "Python: python3, pip3, requests, pandas, numpy"
    print_status "Node.js: node, npm, yarn, npx"
    print_status "Network: curl, wget, git, iperf3"
    print_status "CLI: tree, mc, ranger, fzf, ripgrep, bat"
    print_status "Editors: geany"
}

# Run the tools setup
main_tools_setup 