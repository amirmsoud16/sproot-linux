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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required commands before proceeding
for cmd in apt dpkg wget curl; do
    if ! command_exists $cmd; then
        echo -e "${RED}[ERROR]${NC} Command '$cmd' not found! Please make sure your Ubuntu chroot is healthy."
        exit 1
    fi
done

# Check for internet connection before updating or installing
check_internet() {
    print_status "Checking internet connection..."
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        print_error "No internet connection! Please connect to the internet and try again."
        exit 1
    fi
    print_success "Internet connection is OK."
}

# Function to fix permission issues
fix_permissions() {
    print_status "🔧 Fixing permission issues..."
    
    # Fix dpkg directory permissions
    print_status "Fixing dpkg directory permissions..."
    [ -d /var/lib/dpkg ] && chmod 755 /var/lib/dpkg 2>/dev/null || true
    [ -d /var/lib/dpkg/info ] && chmod 755 /var/lib/dpkg/info 2>/dev/null || true
    [ -d /var/lib/dpkg/updates ] && chmod 755 /var/lib/dpkg/updates 2>/dev/null || true
    [ -d /var/lib/dpkg/triggers ] && chmod 755 /var/lib/dpkg/triggers 2>/dev/null || true
    
    # Fix dpkg status file permissions
    print_status "Fixing dpkg status file permissions..."
    [ -f /var/lib/dpkg/status ] && chmod 644 /var/lib/dpkg/status 2>/dev/null || true
    [ -f /var/lib/dpkg/status-old ] && chmod 644 /var/lib/dpkg/status-old 2>/dev/null || true
    
    # Remove problematic backup files
    print_status "Cleaning dpkg backup files..."
    [ -f /var/lib/dpkg/status-old ] && rm -f /var/lib/dpkg/status-old
    [ -f /var/lib/dpkg/status.backup ] && rm -f /var/lib/dpkg/status.backup
    rm -f /var/lib/dpkg/status-* 2>/dev/null || true
    
    # Fix library permissions - more comprehensive
    print_status "Fixing library permissions..."
    [ -d /usr/lib ] && find /usr/lib -name "*.so*" -exec chmod 755 {} \; 2>/dev/null || true
    [ -d /usr/lib/aarch64-linux-gnu ] && find /usr/lib/aarch64-linux-gnu -name "*.so*" -exec chmod 755 {} \; 2>/dev/null || true
    [ -d /lib ] && find /lib -name "*.so*" -exec chmod 755 {} \; 2>/dev/null || true
    [ -d /lib/aarch64-linux-gnu ] && find /lib/aarch64-linux-gnu -name "*.so*" -exec chmod 755 {} \; 2>/dev/null || true
    
    # Fix specific problematic libraries
    print_status "Fixing specific library permissions..."
    [ -f /usr/lib/aarch64-linux-gnu/libsqlite3.so.0.8.6 ] && chmod 755 /usr/lib/aarch64-linux-gnu/libsqlite3.so.0.8.6 2>/dev/null || true
    [ -f /usr/lib/aarch64-linux-gnu/libgnutls.so.30.31.0 ] && chmod 755 /usr/lib/aarch64-linux-gnu/libgnutls.so.30.31.0 2>/dev/null || true
    [ -f /usr/lib/aarch64-linux-gnu/libsqlite3.so.0 ] && chmod 755 /usr/lib/aarch64-linux-gnu/libsqlite3.so.0 2>/dev/null || true
    [ -f /usr/lib/aarch64-linux-gnu/libgnutls.so.30 ] && chmod 755 /usr/lib/aarch64-linux-gnu/libgnutls.so.30 2>/dev/null || true
    
    # Fix apt cache permissions
    print_status "Fixing apt cache permissions..."
    [ -d /var/cache/apt ] && chmod 755 /var/cache/apt 2>/dev/null || true
    [ -d /var/cache/apt/archives ] && chmod 755 /var/cache/apt/archives 2>/dev/null || true
    [ -d /var/cache/apt/archives/partial ] && chmod 755 /var/cache/apt/archives/partial 2>/dev/null || true
    
    # Fix tmp directory permissions
    print_status "Fixing tmp directory permissions..."
    [ -d /tmp ] && chmod 1777 /tmp 2>/dev/null || true
    [ -d /var/tmp ] && chmod 1777 /var/tmp 2>/dev/null || true
    
    # Fix dpkg lock files
    print_status "Removing dpkg lock files..."
    [ -f /var/lib/dpkg/lock ] && rm -f /var/lib/dpkg/lock 2>/dev/null || true
    [ -f /var/lib/dpkg/lock-frontend ] && rm -f /var/lib/dpkg/lock-frontend 2>/dev/null || true
    [ -f /var/cache/apt/archives/lock ] && rm -f /var/cache/apt/archives/lock 2>/dev/null || true
    [ -f /var/lib/apt/lists/lock ] && rm -f /var/lib/apt/lists/lock 2>/dev/null || true
    
    print_success "Permission issues fixed"
}

# Function to fix apt/dpkg issues
fix_apt_issues() {
    print_status "🔧 Fixing apt/dpkg issues..."
    
    # Force remove all lock files
    print_status "Removing all lock files..."
    rm -f /var/lib/dpkg/lock* 2>/dev/null || true
    rm -f /var/cache/apt/archives/lock 2>/dev/null || true
    rm -f /var/lib/apt/lists/lock 2>/dev/null || true
    
    # Configure dpkg to handle broken packages
    print_status "Configuring dpkg..."
    dpkg --configure -a 2>/dev/null || true
    
    # Force configure all packages
    print_status "Force configuring all packages..."
    dpkg --configure --pending 2>/dev/null || true
    
    # Fix broken packages
    print_status "Fixing broken packages..."
    apt --fix-broken install -y 2>/dev/null || true
    
    # Clean apt cache completely
    print_status "Cleaning apt cache..."
    apt clean 2>/dev/null || true
    apt autoclean 2>/dev/null || true
    rm -rf /var/cache/apt/archives/* 2>/dev/null || true
    
    # Reconfigure packages
    print_status "Reconfiguring packages..."
    dpkg-reconfigure -a 2>/dev/null || true
    
    # Force update package lists
    print_status "Force updating package lists..."
    rm -f /var/lib/apt/lists/lock 2>/dev/null || true
    apt update --fix-missing 2>/dev/null || true
    
    print_success "Apt/dpkg issues fixed"
}

# Function to fix specific dpkg backup issues
fix_dpkg_backup_issues() {
    print_status "🔧 Fixing dpkg backup issues..."
    
    # Remove all backup files that might cause issues
    print_status "Removing problematic backup files..."
    rm -f /var/lib/dpkg/status-old
    rm -f /var/lib/dpkg/status.backup
    rm -f /var/lib/dpkg/status-*
    rm -f /var/lib/dpkg/info/*.old
    rm -f /var/lib/dpkg/info/*.backup
    
    # Fix library backup issues
    print_status "Fixing library backup issues..."
    find /usr/lib -name "*.so*.old" -delete 2>/dev/null || true
    find /usr/lib/aarch64-linux-gnu -name "*.so*.old" -delete 2>/dev/null || true
    find /lib -name "*.so*.old" -delete 2>/dev/null || true
    find /lib/aarch64-linux-gnu -name "*.so*.old" -delete 2>/dev/null || true
    
    # Force remove specific problematic files
    print_status "Removing specific problematic files..."
    rm -f /usr/lib/aarch64-linux-gnu/libsqlite3.so.0.8.6.old 2>/dev/null || true
    rm -f /usr/lib/aarch64-linux-gnu/libgnutls.so.30.31.0.old 2>/dev/null || true
    
    # Create fresh status file if needed
    print_status "Ensuring fresh dpkg status..."
    if [ ! -f /var/lib/dpkg/status ]; then
        touch /var/lib/dpkg/status
        chmod 644 /var/lib/dpkg/status
    fi
    
    print_success "Dpkg backup issues fixed"
}

# Function to install packages with retry mechanism
install_packages_with_retry() {
    local packages=("$@")
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        if apt install -y "${packages[@]}"; then
            return 0
        else
            retry_count=$((retry_count + 1))
            print_warning "Installation failed, attempt $retry_count of $max_retries"
            
            if [ $retry_count -lt $max_retries ]; then
                print_status "Fixing apt issues and retrying..."
                fix_apt_issues
                sleep 2
            fi
        fi
    done
    
    print_error "Failed to install packages after $max_retries attempts"
    return 1
}

print_header() {
    echo -e "${WHITE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    Ubuntu Complete Setup                     ║"
    echo "║                 Install All Essential Tools                 ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}



# Function to install essential system tools
install_system_tools() {
    print_status "🔧 Installing essential system tools..."
    
    local system_packages=(
        curl wget git nano vim
        build-essential gcc g++ make
        python3 python3-pip python3-venv
        nodejs npm
        htop neofetch
        unzip zip tar
        net-tools iputils-ping
        openssh-server
        sudo
    )
    
    if install_packages_with_retry "${system_packages[@]}"; then
        print_success "System tools installed"
    else
        print_error "Failed to install system tools"
        return 1
    fi
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
    print_status "This will install all essential tools for Ubuntu"
    echo ""
    
    # Step 0: Check internet and required commands
    check_internet
    # Step 1: Fix permissions and update package lists
    print_status "🔧 Fixing permissions and updating package lists..."
    
    # Fix permission issues
    fix_permissions
    
    # Fix dpkg backup issues
    fix_dpkg_backup_issues
    
    # Fix apt/dpkg issues
    fix_apt_issues
    
    # Update package lists
    print_status "📦 Updating package lists..."
    if ! apt update -y; then
        print_error "Failed to update package lists. Exiting..."
        exit 1
    fi
    print_success "Package lists updated"
    
    # Step 2: Install all tools
    install_system_tools
    install_dev_tools
    install_network_tools
    install_text_tools
    install_monitoring_tools
    install_additional_utils
    
    # Step 3: Install language-specific packages
    install_python_packages
    install_nodejs_packages
    
    # Step 4: Setup user environment
    setup_user_environment
    
    # Step 5: Final update
    print_status "🔄 Performing final system update..."
    apt update -y
    apt upgrade -y
    print_success "Final update completed"
    
    # Step 6: Create summary
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
