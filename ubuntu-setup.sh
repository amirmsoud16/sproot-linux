#!/bin/bash

# Ubuntu Complete Setup Script
# This script fixes internet issues and installs all essential tools for Ubuntu chroot

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

print_header() {
    echo -e "${WHITE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    Ubuntu Complete Setup                     ║"
    echo "║              Fix Internet & Install All Tools               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to fix internet connectivity
fix_internet() {
    print_status "🌐 Fixing internet connectivity..."
    
    # Create /etc directory if it doesn't exist
    mkdir -p /etc
    
    # Remove existing resolv.conf and create new one
    print_status "📡 Creating /etc/resolv.conf with DNS servers..."
    rm -f /etc/resolv.conf
    cat > /etc/resolv.conf << 'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
nameserver 1.0.0.1
EOF
    
    print_success "DNS configuration updated"
    
    # Test internet connectivity
    print_status "🔍 Testing internet connectivity..."
    if ping -c 1 google.com > /dev/null 2>&1; then
        print_success "Internet connection is working!"
        return 0
    else
        print_warning "Primary DNS failed, trying alternative DNS servers..."
        
        # Try alternative DNS
        cat > /etc/resolv.conf << 'EOF'
nameserver 208.67.222.222
nameserver 208.67.220.220
nameserver 9.9.9.9
nameserver 149.112.112.112
EOF
        
        if ping -c 1 google.com > /dev/null 2>&1; then
            print_success "Internet connection restored with alternative DNS!"
            return 0
        else
            print_error "Still no internet connection!"
            print_warning "Please check your network connection and try again."
            print_status "You can manually edit /etc/resolv.conf if needed."
            return 1
        fi
    fi
}

# Function to install essential system tools
install_system_tools() {
    print_status "🔧 Installing essential system tools..."
    apt install -y \
        curl wget git nano vim \
        build-essential gcc g++ make \
        python3 python3-pip python3-venv \
        nodejs npm \
        htop neofetch \
        unzip zip tar \
        net-tools iputils-ping \
        openssh-server \
        sudo
    print_success "System tools installed"
}

# Function to install development tools
install_dev_tools() {
    print_status "💻 Installing development tools..."
    apt install -y \
        cmake \
        clang \
        gdb \
        valgrind \
        strace \
        ltrace
    print_success "Development tools installed"
}

# Function to install network tools
install_network_tools() {
    print_status "🌐 Installing network tools..."
    apt install -y \
        netcat \
        telnet \
        nmap \
        tcpdump \
        wireshark \
        iperf3
    print_success "Network tools installed"
}

# Function to install text processing tools
install_text_tools() {
    print_status "📝 Installing text processing tools..."
    apt install -y \
        grep sed awk \
        jq \
        xmlstarlet \
        csvkit
    print_success "Text processing tools installed"
}

# Function to install monitoring tools
install_monitoring_tools() {
    print_status "📊 Installing monitoring tools..."
    apt install -y \
        htop \
        iotop \
        nethogs \
        iftop \
        nload
    print_success "Monitoring tools installed"
}

# Function to install additional utilities
install_additional_utils() {
    print_status "🛠️ Installing additional utilities..."
    apt install -y \
        tree \
        mc \
        ranger \
        fzf \
        ripgrep \
        bat \
        exa \
        fd-find
    print_success "Additional utilities installed"
}

# Function to install Python packages
install_python_packages() {
    print_status "🐍 Installing Python packages..."
    pip3 install --upgrade pip
    pip3 install \
        requests \
        beautifulsoup4 \
        pandas \
        numpy \
        matplotlib \
        jupyter \
        flask \
        django
    print_success "Python packages installed"
}

# Function to install Node.js packages
install_nodejs_packages() {
    print_status "📦 Installing Node.js packages..."
    npm install -g \
        yarn \
        npx \
        create-react-app \
        express-generator
    print_success "Node.js packages installed"
}

# Function to setup user environment
setup_user_environment() {
    print_status "👤 Setting up user environment..."
    
    # Add useful aliases and environment variables
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo 'export EDITOR=nano' >> ~/.bashrc
    echo 'alias ll="ls -la"' >> ~/.bashrc
    echo 'alias la="ls -A"' >> ~/.bashrc
    echo 'alias l="ls -CF"' >> ~/.bashrc
    echo 'alias ..="cd .."' >> ~/.bashrc
    echo 'alias ...="cd ../.."' >> ~/.bashrc
    echo 'alias ....="cd ../../.."' >> ~/.bashrc
    
    # Create useful directories
    print_status "📁 Creating useful directories..."
    mkdir -p ~/projects
    mkdir -p ~/downloads
    mkdir -p ~/documents
    mkdir -p ~/scripts
    mkdir -p ~/temp
    
    # Setup SSH directory
    print_status "🔐 Setting up SSH..."
    if [ ! -d ~/.ssh ]; then
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
    fi
    
    print_success "User environment configured"
}

# Function to create a summary report
create_summary() {
    echo ""
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║                    SETUP COMPLETED!                          ║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}✅ Ubuntu setup completed successfully!${NC}"
    echo -e "${GREEN}🎉 Your Ubuntu is now ready with essential tools!${NC}"
    echo ""
    echo -e "${CYAN}📋 Installed tools include:${NC}"
    echo "   • System tools (curl, wget, git, nano, vim)"
    echo "   • Development tools (gcc, g++, make, cmake)"
    echo "   • Python and Node.js environments"
    echo "   • Network and monitoring tools"
    echo "   • Text processing utilities"
    echo "   • Modern CLI tools (fzf, ripgrep, bat, exa)"
    echo ""
    echo -e "${CYAN}📁 Created directories:${NC}"
    echo "   • ~/projects (for your projects)"
    echo "   • ~/downloads (for downloads)"
    echo "   • ~/documents (for documents)"
    echo "   • ~/scripts (for your scripts)"
    echo "   • ~/temp (for temporary files)"
    echo ""
    echo -e "${CYAN}🔧 Useful aliases added:${NC}"
    echo "   • ll (ls -la)"
    echo "   • la (ls -A)"
    echo "   • l (ls -CF)"
    echo "   • .. (cd ..)"
    echo "   • ... (cd ../..)"
    echo ""
    echo -e "${GREEN}🚀 You can now start developing!${NC}"
    echo ""
}

# Main function
main() {
    print_header
    
    print_status "Starting Ubuntu complete setup..."
    print_status "This will fix internet issues and install all essential tools"
    echo ""
    
    # Step 1: Fix internet connectivity
    if ! fix_internet; then
        print_error "Failed to establish internet connection. Exiting..."
        exit 1
    fi
    
    # Step 2: Update package lists
    print_status "📦 Updating package lists..."
    if ! apt update -y; then
        print_error "Failed to update package lists. Exiting..."
        exit 1
    fi
    print_success "Package lists updated"
    
    # Step 3: Install all tools
    install_system_tools
    install_dev_tools
    install_network_tools
    install_text_tools
    install_monitoring_tools
    install_additional_utils
    
    # Step 4: Install language-specific packages
    install_python_packages
    install_nodejs_packages
    
    # Step 5: Setup user environment
    setup_user_environment
    
    # Step 6: Final update
    print_status "🔄 Performing final system update..."
    apt update -y
    apt upgrade -y
    print_success "Final update completed"
    
    # Step 7: Create summary
    create_summary
}

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    print_error "This script should not be run as root!"
    print_status "Please run it as a regular user inside the Ubuntu chroot environment."
    exit 1
fi

# Check if we're in a chroot environment
if [ ! -f /etc/resolv.conf ]; then
    print_warning "This script is designed to run inside Ubuntu chroot environment."
    print_status "Please run this script after entering your Ubuntu chroot."
    exit 1
fi

# Run main function
main "$@" 