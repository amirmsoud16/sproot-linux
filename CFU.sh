#!/bin/bash

# CFU.SH - Custom File Utility Script (Optimized Ubuntu Tools Setup)
# Simplified version of ubuntu-tools-setup.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
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

# Loading animation function
show_loading() {
    local message="$1"
    local pid=$2
    
    echo -e "${YELLOW}Installing...${NC}"
    echo -e "${WHITE}$message${NC}"
    echo ""
    
    # Loading animation with spinner
    local i=0
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spin:$i:1}
        echo -ne "${YELLOW}Please wait... ${temp}${NC}\r"
        i=$(( (i+1) % ${#spin} ))
        sleep 0.1
    done
    
    echo -e "${GREEN}✓ Installation completed!${NC}"
    echo ""
}

# Background installation function
install_in_background() {
    local install_function="$1"
    local message="$2"
    
    # Start installation in background
    $install_function > /dev/null 2>&1 &
    local pid=$!
    
    # Show loading animation
    show_loading "$message" $pid
    
    # Wait for installation to complete
    wait $pid
    
    return $?
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

# Install system tools (background version)
install_system_tools() {
    sudo apt update -y
    sudo apt install -y curl wget git nano vim build-essential gcc g++ make
    sudo apt install -y python3 python3-pip nodejs npm
    sudo apt install -y htop neofetch unzip zip tar net-tools iputils-ping
}

# Install system tools with loading
install_system_tools_with_loading() {
    print_info "Installing system tools..."
    install_in_background "install_system_tools" "Installing development tools and packages..."
    print_success "System tools installed"
}

# Install development tools (background version)
install_dev_tools() {
    sudo apt install -y cmake clang gdb valgrind strace ltrace
    sudo apt install -y tree mc ranger fzf ripgrep bat exa fd-find
}

# Install development tools with loading
install_dev_tools_with_loading() {
    print_info "Installing development tools..."
    install_in_background "install_dev_tools" "Installing development and debugging tools..."
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

# Install Python packages (background version)
install_python_packages() {
    pip3 install requests beautifulsoup4 pandas numpy matplotlib
}

# Install Python packages with loading
install_python_packages_with_loading() {
    print_info "Installing Python packages..."
    install_in_background "install_python_packages" "Installing Python packages and libraries..."
    print_success "Python packages installed"
}

# Install Node.js packages (background version)
install_nodejs_packages() {
    sudo npm install -g yarn npx create-react-app express-generator
}

# Install Node.js packages with loading
install_nodejs_packages_with_loading() {
    print_info "Installing Node.js packages..."
    install_in_background "install_nodejs_packages" "Installing Node.js packages and tools..."
    print_success "Node.js packages installed"
}

# Install desktop environments
install_desktop_environments() {
    print_info "Installing desktop environments..."
    
    # Install LXDE (Lightweight Desktop Environment)
    print_info "Installing LXDE..."
    sudo apt install -y lxde-core lxde
    
    # Install XFCE (Xfce Desktop Environment)
    print_info "Installing XFCE..."
    sudo apt install -y xfce4 xfce4-goodies
    
    # Install GNOME (if not already installed)
    print_info "Installing GNOME..."
    sudo apt install -y ubuntu-desktop
    
    # Install KDE Plasma (optional)
    print_info "Installing KDE Plasma..."
    sudo apt install -y kubuntu-desktop
    
    # Install MATE (GNOME 2 fork)
    print_info "Installing MATE..."
    sudo apt install -y ubuntu-mate-desktop
    
    # Install Cinnamon
    print_info "Installing Cinnamon..."
    sudo apt install -y cinnamon
    
    # Install display manager
    sudo apt install -y lightdm
    
    print_success "Desktop environments installed"
    print_info "Available desktops: LXDE, XFCE, GNOME, KDE, MATE, Cinnamon"
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

# Install Rust (background version)
install_rust() {
    if ! command -v rustc &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
    fi
}

# Install Rust with loading
install_rust_with_loading() {
    print_info "Installing Rust..."
    if ! command -v rustc &> /dev/null; then
        install_in_background "install_rust" "Installing Rust programming language..."
        print_success "Rust installed"
    else
        print_info "Rust is already installed"
    fi
}

# Show main menu
show_main_menu() {
    clear
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}    Ubuntu Tools Installer${NC}"
    echo -e "${CYAN}================================${NC}"
    echo ""
    echo -e "${WHITE}Select installation type:${NC}"
    echo -e "${BLUE}1.${NC} Install Basic Packages (Development Tools)"
    echo -e "${BLUE}2.${NC} Install Network Tools"
    echo -e "${BLUE}3.${NC} Install User Applications"
    echo -e "${BLUE}4.${NC} Install Desktop Environment"
    echo -e "${BLUE}5.${NC} Install All (Complete Setup)"
    echo -e "${BLUE}6.${NC} Exit"
    echo ""
}

# Show desktop menu
show_desktop_menu() {
    clear
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}    Desktop Environment Setup${NC}"
    echo -e "${CYAN}================================${NC}"
    echo ""
    echo -e "${WHITE}Select desktop environment:${NC}"
    echo -e "${GREEN}1.${NC} XFCE (Recommended - Lightweight)"
    echo -e "${BLUE}2.${NC} LXDE (Very Lightweight)"
    echo -e "${BLUE}3.${NC} GNOME (Full Featured)"
    echo -e "${BLUE}4.${NC} KDE (Beautiful & Modern)"
    echo -e "${BLUE}5.${NC} MATE (Classic GNOME)"
    echo -e "${BLUE}6.${NC} Back to Main Menu"
    echo ""
}

# Install basic packages
install_basic_packages() {
    print_info "Installing basic development packages..."
    
    check_environment
    check_sudo
    install_system_tools_with_loading
    install_dev_tools_with_loading
    install_python_packages_with_loading
    install_nodejs_packages_with_loading
    install_rust_with_loading
    setup_user_environment
    
    print_success "Basic packages installed successfully!"
    clear
}

# Install network tools (background version)
install_network_packages() {
    sudo apt update -y
    sudo apt install -y nmap wireshark-cli netcat-openbsd tcpdump
}

# Install network tools with loading
install_network_packages_with_loading() {
    print_info "Installing network tools..."
    install_in_background "install_network_packages" "Installing network analysis tools..."
    print_success "Network tools installed:"
    print_info "  nmap - Network scanner"
    print_info "  wireshark-cli - Network analyzer"
    print_info "  netcat - Network utility"
    print_info "  tcpdump - Packet analyzer"
    clear
}

# Install user applications (background version)
install_user_applications() {
    sudo apt update -y
    sudo apt install -y firefox-esr libreoffice-writer libreoffice-calc gimp
}

# Install user applications with loading
install_user_applications_with_loading() {
    print_info "Installing user applications..."
    install_in_background "install_user_applications" "Installing user applications and office tools..."
    print_success "User applications installed:"
    print_info "  firefox-esr - Web browser"
    print_info "  libreoffice-writer - Word processor"
    print_info "  libreoffice-calc - Spreadsheet"
    print_info "  gimp - Image editor"
    clear
}

# Install desktop environment
install_desktop() {
    show_desktop_menu
    
    read -p "Enter your choice (1-6): " desktop_choice
    
            case $desktop_choice in
            1) install_xfce_with_loading ;;
            2) install_lxde_with_loading ;;
            3) install_gnome_with_loading ;;
            4) install_kde_with_loading ;;
            5) install_mate_with_loading ;;
            6) return ;;
            *) print_error "Invalid choice" ;;
        esac
}

# Install XFCE (background version)
install_xfce() {
    sudo apt update -y
    sudo apt install -y xfce4 xfce4-goodies tightvncserver
}

# Install XFCE with loading
install_xfce_with_loading() {
    print_info "Installing XFCE Desktop Environment..."
    install_in_background "install_xfce" "Installing XFCE desktop environment..."
    
    # Ask for VNC
    read -p "Install VNC server? (y/N): " install_vnc
    if [[ "$install_vnc" =~ ^[Yy]$ ]]; then
        print_info "VNC server is already installed with XFCE"
        print_info "To start VNC: vncserver :1"
    fi
    
    print_success "XFCE installed successfully!"
    clear
}

# Install LXDE (background version)
install_lxde() {
    sudo apt update -y
    sudo apt install -y lxde-core tightvncserver
}

# Install LXDE with loading
install_lxde_with_loading() {
    print_info "Installing LXDE Desktop Environment..."
    install_in_background "install_lxde" "Installing LXDE desktop environment..."
    
    # Ask for VNC
    read -p "Install VNC server? (y/N): " install_vnc
    if [[ "$install_vnc" =~ ^[Yy]$ ]]; then
        print_info "VNC server is already installed with LXDE"
        print_info "To start VNC: vncserver :1"
    fi
    
    print_success "LXDE installed successfully!"
    clear
}

# Install GNOME (background version)
install_gnome() {
    sudo apt update -y
    sudo apt install -y ubuntu-desktop tightvncserver
}

# Install GNOME with loading
install_gnome_with_loading() {
    print_info "Installing GNOME Desktop Environment..."
    install_in_background "install_gnome" "Installing GNOME desktop environment..."
    
    # Ask for VNC
    read -p "Install VNC server? (y/N): " install_vnc
    if [[ "$install_vnc" =~ ^[Yy]$ ]]; then
        print_info "VNC server is already installed with GNOME"
        print_info "To start VNC: vncserver :1"
    fi
    
    print_success "GNOME installed successfully!"
    clear
}

# Install KDE (background version)
install_kde() {
    sudo apt update -y
    sudo apt install -y kubuntu-desktop tightvncserver
}

# Install KDE with loading
install_kde_with_loading() {
    print_info "Installing KDE Desktop Environment..."
    install_in_background "install_kde" "Installing KDE desktop environment..."
    
    # Ask for VNC
    read -p "Install VNC server? (y/N): " install_vnc
    if [[ "$install_vnc" =~ ^[Yy]$ ]]; then
        print_info "VNC server is already installed with KDE"
        print_info "To start VNC: vncserver :1"
    fi
    
    print_success "KDE installed successfully!"
    clear
}

# Install MATE (background version)
install_mate() {
    sudo apt update -y
    sudo apt install -y ubuntu-mate-desktop tightvncserver
}

# Install MATE with loading
install_mate_with_loading() {
    print_info "Installing MATE Desktop Environment..."
    install_in_background "install_mate" "Installing MATE desktop environment..."
    
    # Ask for VNC
    read -p "Install VNC server? (y/N): " install_vnc
    if [[ "$install_vnc" =~ ^[Yy]$ ]]; then
        print_info "VNC server is already installed with MATE"
        print_info "To start VNC: vncserver :1"
    fi
    
    print_success "MATE installed successfully!"
    clear
}

# Install all packages
install_all_packages() {
    print_info "Installing all packages (complete setup)..."
    
    install_basic_packages
    install_network_packages_with_loading
    install_user_applications_with_loading
    
    print_success "Complete setup finished!"
    clear
}

# Main menu function
main_menu() {
    while true; do
        show_main_menu
        read -p "Enter your choice (1-6): " choice
        
        case $choice in
            1) install_basic_packages ;;
            2) install_network_packages_with_loading ;;
            3) install_user_applications_with_loading ;;
            4) install_desktop ;;
            5) install_all_packages ;;
            6) 
                print_success "Goodbye!"
                exit 0
                ;;
            *) print_error "Invalid choice" ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Main function
main() {
    print_info "Starting Ubuntu Tools Setup..."
    
    check_environment
    check_sudo
    main_menu
}

# Run main function
main 
