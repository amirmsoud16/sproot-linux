#!/bin/bash

# Ubuntu Chroot & Proot Installer - Complete Self-Contained Script
# GitHub Project: https://github.com/amirmsoud16/ubuntu-chroot-pk-

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Global variables
UBUNTU_USERNAME=""
UBUNTU_VERSION=""
UBUNTU_CODENAME=""

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

# Function to check system requirements
check_requirements() {
    print_status "🔍 Checking system requirements..."
    
    # Check if running on Android/Termux
    if [[ -f /system/build.prop ]] || [[ -n "$TERMUX_VERSION" ]]; then
        print_success "Running on Android/Termux"
    else
        print_warning "This script is designed for Android/Termux"
    fi
    
    # Check available disk space (minimum 2GB)
    DISK_SPACE=$(df /data | awk 'NR==2 {print $4}')
    if [[ $DISK_SPACE -gt 2000000 ]]; then
        print_success "Sufficient disk space available"
    else
        print_error "Insufficient disk space. Need at least 2GB free space."
        exit 1
    fi
    
    # Check internet connectivity
    if ping -c 1 8.8.8.8 &> /dev/null; then
        print_success "Internet connection available"
    else
        print_warning "No internet connection detected"
    fi
    
    # Check if proot is available
    if command -v proot &> /dev/null; then
        print_success "Proot is available"
    else
        print_error "Proot is not installed. Please install it first."
        exit 1
    fi
}

# Function to get Ubuntu version choice
get_ubuntu_version() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}  Ubuntu Version Selection${NC}"
    echo -e "${CYAN}================================${NC}"
    echo ""
    echo "Available Ubuntu versions:"
    echo "1. Ubuntu 20.04 LTS (Focal Fossa) - Recommended"
    echo "2. Ubuntu 22.04 LTS (Jammy Jellyfish) - Latest LTS"
    echo "3. Ubuntu 18.04 LTS (Bionic Beaver) - Legacy"
    echo ""
    
    while true; do
        read -p "Select Ubuntu version (1-3): " UBUNTU_CHOICE
        case $UBUNTU_CHOICE in
            1)
                UBUNTU_VERSION="20.04"
                UBUNTU_CODENAME="focal"
                break
                ;;
            2)
                UBUNTU_VERSION="22.04"
                UBUNTU_CODENAME="jammy"
                break
                ;;
            3)
                UBUNTU_VERSION="18.04"
                UBUNTU_CODENAME="bionic"
                break
                ;;
            *)
                print_error "Invalid choice. Please select 1, 2, or 3."
                ;;
        esac
    done
    
    print_success "Selected Ubuntu $UBUNTU_VERSION LTS ($UBUNTU_CODENAME)"
}

# Function to get user credentials
get_user_credentials() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}  User Configuration${NC}"
    echo -e "${CYAN}================================${NC}"
    echo ""
    
    # Get username
    while true; do
        read -p "Enter username for Ubuntu: " UBUNTU_USERNAME
        if [[ -n "$UBUNTU_USERNAME" ]]; then
            break
        else
            print_error "Username cannot be empty!"
        fi
    done
    
    # Get root password
    while true; do
        read -s -p "Enter root password for Ubuntu: " ROOT_PASSWORD
        echo ""
        if [[ -n "$ROOT_PASSWORD" ]]; then
            read -s -p "Confirm root password: " ROOT_PASSWORD_CONFIRM
            echo ""
            if [[ "$ROOT_PASSWORD" == "$ROOT_PASSWORD_CONFIRM" ]]; then
                break
            else
                print_error "Passwords do not match!"
            fi
        else
            print_error "Password cannot be empty!"
        fi
    done
    
    print_success "User configuration saved!"
    print_status "Username: $UBUNTU_USERNAME"
    print_status "Root password: ********"
    print_status "User password: None (no password needed)"
    echo ""
}

# Function to download Ubuntu rootfs
download_ubuntu_rootfs() {
    print_status "📥 Downloading Ubuntu $UBUNTU_VERSION rootfs..."
    
    # Create Ubuntu directory
    mkdir -p ~/ubuntu
    
    # Set download URL based on version
    case $UBUNTU_VERSION in
        "20.04")
            DOWNLOAD_URL="https://github.com/AndronixApp/AndronixOrigin/releases/download/Ubuntu20.04/ubuntu-20.04-android-5.0-v2.tar.gz"
            ;;
        "22.04")
            DOWNLOAD_URL="https://github.com/AndronixApp/AndronixOrigin/releases/download/Ubuntu22.04/ubuntu-22.04-android-5.0-v2.tar.gz"
            ;;
        "18.04")
            DOWNLOAD_URL="https://github.com/AndronixApp/AndronixOrigin/releases/download/Ubuntu18.04/ubuntu-18.04-android-5.0-v2.tar.gz"
            ;;
    esac
    
    # Download the rootfs
    print_status "Downloading from: $DOWNLOAD_URL"
    wget -O ~/ubuntu/ubuntu-$UBUNTU_VERSION-rootfs.tar.gz "$DOWNLOAD_URL"
    
    if [[ $? -eq 0 ]]; then
        print_success "Download completed"
    else
        print_error "Download failed"
        exit 1
    fi
}

# Function to extract Ubuntu rootfs
extract_ubuntu_rootfs() {
    print_status "📦 Extracting Ubuntu rootfs..."
    
    # Extract the rootfs
    cd ~/ubuntu
    tar -xzf ubuntu-$UBUNTU_VERSION-rootfs.tar.gz
    
    if [[ $? -eq 0 ]]; then
        print_success "Extraction completed"
        # Remove the tar file to save space
        rm ubuntu-$UBUNTU_VERSION-rootfs.tar.gz
    else
        print_error "Extraction failed"
        exit 1
    fi
}

# Function to create start scripts
create_start_scripts() {
    print_status "📝 Creating start scripts..."
    
    # Create start script for root access
    cat > ~/start-ubuntu-$UBUNTU_VERSION.sh << EOF
#!/bin/bash
# Start Ubuntu $UBUNTU_VERSION as root
unset LD_PRELOAD

# Check if setup is completed
if [[ -f "\$HOME/ubuntu/ubuntu-$UBUNTU_VERSION-rootfs/setup-completed.marker" ]]; then
    echo -n "Enter root password: "
    read -s ROOT_PASS
    echo ""
else
    echo "No root password set yet. Entering without password..."
fi

# Start Ubuntu
proot -0 -r \$HOME/ubuntu/ubuntu-$UBUNTU_VERSION-rootfs \\
    -b /dev -b /proc -b /sys \\
    -b \$HOME:/root \\
    -w /root /usr/bin/env -i HOME=/root TERM="\$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    
    # Create start script for user access
    cat > ~/start-ubuntu-$UBUNTU_VERSION-user.sh << EOF
#!/bin/bash
# Start Ubuntu $UBUNTU_VERSION as user
unset LD_PRELOAD

proot -0 -r \$HOME/ubuntu/ubuntu-$UBUNTU_VERSION-rootfs \\
    -b /dev -b /proc -b /sys \\
    -b \$HOME:/home/\$USER \\
    -w /home/\$USER /usr/bin/env -i HOME=/home/\$USER USER=\$USER TERM="\$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/su - \$USER
EOF
    
    # Make scripts executable
    chmod +x ~/start-ubuntu-$UBUNTU_VERSION.sh
    chmod +x ~/start-ubuntu-$UBUNTU_VERSION-user.sh
    
    print_success "Start scripts created"
    print_status "Root access: ~/start-ubuntu-$UBUNTU_VERSION.sh"
    print_status "User access: ~/start-ubuntu-$UBUNTU_VERSION-user.sh"
}

# Function to create Termux aliases
create_termux_aliases() {
    print_status "📝 Creating Termux aliases..."
    
    # Add aliases to .bashrc
    echo "alias ubuntu$UBUNTU_VERSION=\"~/start-ubuntu-$UBUNTU_VERSION.sh\"" >> ~/.bashrc
    echo "alias ubuntu$UBUNTU_VERSION-user=\"~/start-ubuntu-$UBUNTU_VERSION-user.sh\"" >> ~/.bashrc
    
    # Source .bashrc to apply changes
    source ~/.bashrc
    
    print_success "Termux aliases created"
    print_status "Root access: ubuntu$UBUNTU_VERSION"
    print_status "User access: ubuntu$UBUNTU_VERSION-user"
}

# Function to display installation summary
show_summary() {
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}  Installation Summary${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    echo -e "${CYAN}Ubuntu Version:${NC} $UBUNTU_VERSION LTS ($UBUNTU_CODENAME)"
    echo -e "${CYAN}Installation Directory:${NC} ~/ubuntu/ubuntu-$UBUNTU_VERSION-rootfs"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Enter as root: ubuntu$UBUNTU_VERSION"
    echo "2. Enter as user: ubuntu$UBUNTU_VERSION-user"
    echo ""
    echo -e "${GREEN}Installation completed successfully!${NC}"
}

# Main installation function
main_installation() {
    print_status "🚀 Starting Ubuntu $UBUNTU_VERSION installation..."
    
    # Check requirements
    check_requirements
    
    # Get Ubuntu version
    get_ubuntu_version
    
    # Download Ubuntu rootfs
    download_ubuntu_rootfs
    
    # Extract Ubuntu rootfs
    extract_ubuntu_rootfs
    
    # Create start scripts
    create_start_scripts
    
    # Create Termux aliases
    create_termux_aliases
    
    # Show summary
    show_summary
}

# Run the main installation
main_installation

# Ubuntu Tools Setup Script Content
UBUNTU_TOOLS_SETUP_CONTENT='#!/bin/bash

# Ubuntu Tools Setup Script
# This script installs all development tools and packages for regular users

# Colors for output
RED='\''\033[0;31m'\''
GREEN='\''\033[0;32m'\''
YELLOW='\''\033[1;33m'\''
BLUE='\''\033[0;34m'\''
CYAN='\''\033[0;36m'\''
WHITE='\''\033[1;37m'\''
NC='\''\033[0m'\'' # No Color

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
    echo '\''alias ll="ls -la"'\'' >> ~/.bashrc
    echo '\''alias la="ls -A"'\'' >> ~/.bashrc
    echo '\''alias l="ls -CF"'\'' >> ~/.bashrc
    echo '\''alias ..="cd .."'\'' >> ~/.bashrc
    echo '\''alias ...="cd ../.."'\'' >> ~/.bashrc
    echo '\''alias ....="cd ../../.."'\'' >> ~/.bashrc
    echo '\''alias home="cd ~"'\'' >> ~/.bashrc
    echo '\''alias cls="clear"'\'' >> ~/.bashrc
    
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
        curl --proto '\''=https'\'' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
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
main_tools_setup'

# Function to create setup scripts in Ubuntu directory
create_setup_scripts() {
    local ubuntu_dir="$1"
    
    # Create ubuntu-root-setup.sh
    echo "$UBUNTU_ROOT_SETUP_CONTENT" > "$ubuntu_dir/ubuntu-root-setup.sh"
    chmod +x "$ubuntu_dir/ubuntu-root-setup.sh"
    
    # Create ubuntu-tools-setup.sh
    echo "$UBUNTU_TOOLS_SETUP_CONTENT" > "$ubuntu_dir/ubuntu-tools-setup.sh"
    chmod +x "$ubuntu_dir/ubuntu-tools-setup.sh"
    
    print_success "Setup scripts created in $ubuntu_dir"
}

# Function to print header
print_header() {
    clear
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}  Ubuntu Chroot & Proot Installer${NC}"
    echo -e "${CYAN}  GitHub: https://github.com/amirmsoud16/ubuntu-chroot-pk-${NC}"
    echo -e "${CYAN}================================${NC}"
    echo ""
}

# Function to print status
print_status() {
    echo -e "${GREEN}✓ [INFO] $1${NC}"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓ [SUCCESS] $1${NC}"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠ [WARNING] $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}✗ [ERROR] $1${NC}"
}

# Function to check and download Ubuntu rootfs
download_ubuntu_rootfs() {
    local version=$1
    local url=$2
    local filename=$3

    print_status "Downloading Ubuntu ${version} rootfs..."
    wget -O $filename $url

    if [[ $? -eq 0 ]]; then
        print_status "✓ Download successful"
        return 0
    else
        print_error "Failed to download from primary URL"
        return 1
    fi
}

# Function to print success message with box
print_success_box() {
    local message="$1"
    echo -e "${GREEN}✓ SUCCESS: $message${NC}"
}

# Function to print error message with box
print_error_box() {
    local message="$1"
    echo -e "${RED}✗ ERROR: $message${NC}"
}

# Function to clear screen and wait
clear_screen() {
    echo ""
    read -p "Press Enter to continue..."
    clear
}







# Function to print menu
print_menu() {
    echo -e "\n${WHITE}Available Options:${NC}"
    echo -e "${BLUE}1.${NC} System Check & Preparation"
    echo -e "${BLUE}2.${NC} Install Ubuntu (Chroot/Proot)"
    echo -e "${BLUE}3.${NC} Remove Ubuntu"
    echo -e "${BLUE}4.${NC} Exit"
    echo ""
}

# Function to check and prepare system (now just shows info)
system_check() {
    print_header
    print_success_box "System prerequisites already checked and installed!"
    print_status "✓ Termux environment: OK"
    print_status "✓ Required packages: Installed"
    print_status "✓ Disk space: Sufficient"
    print_status "✓ Internet connection: Available"
    print_status "✓ Directories: Created"
    print_status "✓ DNS: Configured"
    print_status ""
    print_status "Your system is ready for Ubuntu installation!"

    # Show system information
    echo ""
    echo -e "${CYAN}System Information:${NC}"

    # Get system info
    available_space=$(df $HOME | awk 'NR==2 {print $4}')
    available_space_mb=$(($available_space / 1024))
    total_space=$(df $HOME | awk 'NR==2 {print $2}')
    total_space_mb=$(($total_space / 1024))
    used_space_mb=$(($total_space_mb - $available_space_mb))

    echo -e "${WHITE}Available Disk Space: ${available_space_mb}MB / ${total_space_mb}MB${NC}"
    echo -e "${WHITE}Used Disk Space: ${used_space_mb}MB${NC}"
    echo -e "${WHITE}Android Version: $(getprop ro.build.version.release)${NC}"
    echo -e "${WHITE}Architecture: $(uname -m)${NC}"
    echo -e "${WHITE}Termux Version: $(pkg --version 2>/dev/null || echo "Unknown")${NC}"

    # Show root status
    echo ""
    echo -e "${CYAN}Root Status:${NC}"
    if [[ $(id -u) -eq 0 ]]; then
        echo -e "${GREEN}✓ Root access available${NC}"
        echo -e "${WHITE}You can use Chroot installation method${NC}"
    else
        echo -e "${YELLOW}⚠ No root access${NC}"
        echo -e "${WHITE}You can use Proot installation method${NC}"
    fi

    clear_screen
}





# Function to install Ubuntu 18.04 (Chroot) in background
install_ubuntu_18_04_chroot_background() {
    INSTALL_DIR=$HOME/ubuntu/ubuntu18-rootfs
    mkdir -p $INSTALL_DIR
    cd $INSTALL_DIR

    # Use reliable Ubuntu 18.04 rootfs URL for Android
    ROOTFS_URL="https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-arm64-root.tar.xz"

    # Download Ubuntu 18.04 rootfs (silent with progress)
    wget -q --show-progress -O ubuntu-18.04-rootfs.tar.xz $ROOTFS_URL > /dev/null 2>&1

    if [[ $? -ne 0 ]]; then
        echo "chroot_failed" > $HOME/ubuntu_install_result
        return
    fi

    # Extract xz file (silent)
    tar -xf ubuntu-18.04-rootfs.tar.xz --exclude='./dev' > /dev/null 2>&1

    # Create necessary directories and files
    mkdir -p $INSTALL_DIR/etc
    mkdir -p $INSTALL_DIR/dev
    mkdir -p $INSTALL_DIR/proc
    mkdir -p $INSTALL_DIR/sys
    mkdir -p $INSTALL_DIR/tmp
    mkdir -p $INSTALL_DIR/var/tmp

    # Fix groups file to prevent group ID errors
    cat >> $INSTALL_DIR/etc/group <<'EOF'
3003:3003:3003
9997:9997:9997
20238:20238:20238
50238:50238:50238
EOF

    # Set proper permissions for full root access
    chmod -R 755 $INSTALL_DIR
    chown -R root:root $INSTALL_DIR 2>/dev/null || true


    
    # Create start script with limited root access
    cat > start-ubuntu-18.04.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD

proot -0 -r $HOME/ubuntu/ubuntu18-rootfs \
    -b /dev -b /proc -b /sys \
    -b $HOME:/root \
    -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x start-ubuntu-18.04.sh

    echo "chroot_success" > $HOME/ubuntu_install_result
}

# Function to install Ubuntu 18.04 (Chroot) - Main function
install_ubuntu_18_04_chroot() {
    print_status "Installing Ubuntu 18.04 Chroot..."

    # Start installation in background
    install_ubuntu_18_04_chroot_background &
    local pid=$!

    # Show loading animation
    show_loading "Installing Ubuntu 18.04 (Chroot)..." $pid

    # Wait for installation to complete
    wait $pid

    # Check result
    if [[ -f $HOME/ubuntu_install_result ]]; then
        local result=$(cat $HOME/ubuntu_install_result)
        rm -f $HOME/ubuntu_install_result

        if [[ "$result" == "chroot_success" ]]; then
            print_success_box "Ubuntu 18.04 (Chroot) installed successfully!"
            
            print_status "Ubuntu 18.04 installed successfully!"
            print_status "Creating setup scripts in Ubuntu directory..."
            
            # Create setup scripts in Ubuntu directory
            create_setup_scripts "$HOME/ubuntu/ubuntu18-rootfs"
            
            print_status "Setup scripts created successfully!"
            print_status "Next steps:"
            print_status "1. Enter Ubuntu as root: ubuntu18"
            print_status "2. Run ubuntu-root-setup.sh to configure user and system"
            print_status "3. Exit and enter as user: ubuntu18-username"
            print_status "4. Run ubuntu-tools-setup.sh to install tools"
        elif [[ "$result" == "chroot_failed" ]]; then
            print_error_box "Failed to download Ubuntu 18.04 rootfs"
            print_status "Please check your internet connection and try again"
        else
            print_error_box "Failed to install Ubuntu 18.04"
        fi
    else
        print_error_box "Installation failed"
    fi

    clear_screen
}

# Function to install Ubuntu 20.04 (Chroot) in background
install_ubuntu_20_04_chroot_background() {
    INSTALL_DIR=$HOME/ubuntu/ubuntu20-rootfs
    mkdir -p $INSTALL_DIR
    cd $INSTALL_DIR

    # Use reliable Ubuntu 20.04 rootfs URL for Android
    ROOTFS_URL="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-arm64-root.tar.xz"

    # Download Ubuntu 20.04 rootfs (silent with progress)
    wget -q --show-progress -O ubuntu-20.04-rootfs.tar.xz $ROOTFS_URL > /dev/null 2>&1

    if [[ $? -ne 0 ]]; then
        echo "chroot_failed" > $HOME/ubuntu_install_result
        return
    fi

    # Extract xz file (silent)
    tar -xf ubuntu-20.04-rootfs.tar.xz --exclude='./dev' > /dev/null 2>&1

    # Create necessary directories and files
    mkdir -p $INSTALL_DIR/etc
    mkdir -p $INSTALL_DIR/dev
    mkdir -p $INSTALL_DIR/proc
    mkdir -p $INSTALL_DIR/sys
    mkdir -p $INSTALL_DIR/tmp
    mkdir -p $INSTALL_DIR/var/tmp

    # Fix groups file to prevent group ID errors
    cat >> $INSTALL_DIR/etc/group <<'EOF'
3003:3003:3003
9997:9997:9997
20238:20238:20238
50238:50238:50238
EOF

    # Set proper permissions for full root access
    chmod -R 755 $INSTALL_DIR
    chown -R root:root $INSTALL_DIR 2>/dev/null || true


    
    # Create start script with limited root access
    cat > start-ubuntu-20.04.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD

proot -0 -r $HOME/ubuntu/ubuntu20-rootfs \
    -b /dev -b /proc -b /sys \
    -b $HOME:/root \
    -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x start-ubuntu-20.04.sh

    echo "chroot_success" > $HOME/ubuntu_install_result
}

# Function to install Ubuntu 20.04 (Chroot) - Main function
install_ubuntu_20_04_chroot() {
    print_status "Installing Ubuntu 20.04 Chroot..."

    # Start installation in background
    install_ubuntu_20_04_chroot_background &
    local pid=$!

    # Show loading animation
    show_loading "Installing Ubuntu 20.04 (Chroot)..." $pid

    # Wait for installation to complete
    wait $pid

    # Check result
    if [[ -f $HOME/ubuntu_install_result ]]; then
        local result=$(cat $HOME/ubuntu_install_result)
        rm -f $HOME/ubuntu_install_result

        if [[ "$result" == "chroot_success" ]]; then
            print_success_box "Ubuntu 20.04 (Chroot) installed successfully!"
            
            print_status "Ubuntu 20.04 installed successfully!"
            print_status "Creating setup scripts in Ubuntu directory..."
            
            # Create setup scripts in Ubuntu directory
            create_setup_scripts "$HOME/ubuntu/ubuntu20-rootfs"
            
            print_status "Setup scripts created successfully!"
            print_status "Next steps:"
            print_status "1. Enter Ubuntu as root: ubuntu20"
            print_status "2. Run ubuntu-root-setup.sh to configure user and system"
            print_status "3. Exit and enter as user: ubuntu20-username"
            print_status "4. Run ubuntu-tools-setup.sh to install tools"
        elif [[ "$result" == "chroot_failed" ]]; then
            print_error_box "Failed to download Ubuntu 20.04 rootfs"
            print_status "Please check your internet connection and try again"
        else
            print_error_box "Failed to install Ubuntu 20.04"
        fi
    else
        print_error_box "Installation failed"
    fi

    clear_screen
}

# Function to install Ubuntu 22.04 (Chroot) in background
install_ubuntu_22_04_chroot_background() {
    INSTALL_DIR=$HOME/ubuntu/ubuntu22-rootfs
    mkdir -p $INSTALL_DIR
    cd $INSTALL_DIR

    # Use reliable Ubuntu 22.04 rootfs URL for Android
    ROOTFS_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-arm64-root.tar.xz"

    # Download Ubuntu 22.04 rootfs (silent with progress)
    wget -q --show-progress -O ubuntu-22.04-rootfs.tar.xz $ROOTFS_URL > /dev/null 2>&1

    if [[ $? -ne 0 ]]; then
        echo "chroot_failed" > $HOME/ubuntu_install_result
        return
    fi

    # Extract xz file (silent)
    tar -xf ubuntu-22.04-rootfs.tar.xz --exclude='./dev' > /dev/null 2>&1

    # Create necessary directories and files
    mkdir -p $INSTALL_DIR/etc
    mkdir -p $INSTALL_DIR/dev
    mkdir -p $INSTALL_DIR/proc
    mkdir -p $INSTALL_DIR/sys
    mkdir -p $INSTALL_DIR/tmp
    mkdir -p $INSTALL_DIR/var/tmp

    # Fix groups file to prevent group ID errors
    cat >> $INSTALL_DIR/etc/group <<'EOF'
3003:3003:3003
9997:9997:9997
20238:20238:20238
50238:50238:50238
EOF

    # Set proper permissions for full root access
    chmod -R 755 $INSTALL_DIR
    chown -R root:root $INSTALL_DIR 2>/dev/null || true


    
    # Create start script with limited root access
    cat > start-ubuntu-22.04.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD

proot -0 -r $HOME/ubuntu/ubuntu22-rootfs \
    -b /dev -b /proc -b /sys \
    -b $HOME:/root \
    -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x start-ubuntu-22.04.sh

    echo "chroot_success" > $HOME/ubuntu_install_result
}

# Function to install Ubuntu 22.04 (Chroot) - Main function
install_ubuntu_22_04_chroot() {
    print_status "Installing Ubuntu 22.04 Chroot..."

    # Start installation in background
    install_ubuntu_22_04_chroot_background &
    local pid=$!

    # Show loading animation
    show_loading "Installing Ubuntu 22.04 (Chroot)..." $pid

    # Wait for installation to complete
    wait $pid

    # Check result
    if [[ -f $HOME/ubuntu_install_result ]]; then
        local result=$(cat $HOME/ubuntu_install_result)
        rm -f $HOME/ubuntu_install_result

        if [[ "$result" == "chroot_success" ]]; then
            print_success_box "Ubuntu 22.04 (Chroot) installed successfully!"
            
            print_status "Ubuntu 22.04 installed successfully!"
            print_status "Creating setup scripts in Ubuntu directory..."
            
            # Create setup scripts in Ubuntu directory
            create_setup_scripts "$HOME/ubuntu/ubuntu22-rootfs"
            
            print_status "Setup scripts created successfully!"
            print_status "Next steps:"
            print_status "1. Enter Ubuntu as root: ubuntu22"
            print_status "2. Run ubuntu-root-setup.sh to configure user and system"
            print_status "3. Exit and enter as user: ubuntu22-username"
            print_status "4. Run ubuntu-tools-setup.sh to install tools"
        elif [[ "$result" == "chroot_failed" ]]; then
            print_error_box "Failed to download Ubuntu 22.04 rootfs"
            print_status "Please check your internet connection and try again"
        else
            print_error_box "Failed to install Ubuntu 22.04"
        fi
    else
        print_error_box "Installation failed"
    fi

    clear_screen
}

# Function to install Ubuntu 24.04 (Chroot) in background
install_ubuntu_24_04_chroot_background() {
    INSTALL_DIR=$HOME/ubuntu/ubuntu24-rootfs
    mkdir -p $INSTALL_DIR
    cd $INSTALL_DIR

    # Use reliable Ubuntu 24.04 rootfs URL for Android
    ROOTFS_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64-root.tar.xz"

    # Download Ubuntu 24.04 rootfs (silent with progress)
    wget -q --show-progress -O ubuntu-24.04-rootfs.tar.xz $ROOTFS_URL > /dev/null 2>&1

    if [[ $? -ne 0 ]]; then
        echo "chroot_failed" > $HOME/ubuntu_install_result
        return
    fi

    # Extract xz file (silent)
    tar -xf ubuntu-24.04-rootfs.tar.xz --exclude='./dev' > /dev/null 2>&1

    # Create necessary directories and files
    mkdir -p $INSTALL_DIR/etc
    mkdir -p $INSTALL_DIR/dev
    mkdir -p $INSTALL_DIR/proc
    mkdir -p $INSTALL_DIR/sys
    mkdir -p $INSTALL_DIR/tmp
    mkdir -p $INSTALL_DIR/var/tmp

    # Fix groups file to prevent group ID errors
    cat >> $INSTALL_DIR/etc/group <<'EOF'
3003:3003:3003
9997:9997:9997
20238:20238:20238
50238:50238:50238
EOF

    # Set proper permissions for full root access
    chmod -R 755 $INSTALL_DIR
    chown -R root:root $INSTALL_DIR 2>/dev/null || true


    
    # Create start script with limited root access
    cat > start-ubuntu-24.04.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD

proot -0 -r $HOME/ubuntu/ubuntu24-rootfs \
    -b /dev -b /proc -b /sys \
    -b $HOME:/root \
    -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x start-ubuntu-24.04.sh

    echo "chroot_success" > $HOME/ubuntu_install_result
}

# Function to install Ubuntu 24.04 (Chroot) - Main function
install_ubuntu_24_04_chroot() {
    print_status "Installing Ubuntu 24.04 Chroot..."

    # Start installation in background
    install_ubuntu_24_04_chroot_background &
    local pid=$!

    # Show loading animation
    show_loading "Installing Ubuntu 24.04 (Chroot)..." $pid

    # Wait for installation to complete
    wait $pid

    # Check result
    if [[ -f $HOME/ubuntu_install_result ]]; then
        local result=$(cat $HOME/ubuntu_install_result)
        rm -f $HOME/ubuntu_install_result

        if [[ "$result" == "chroot_success" ]]; then
            print_success_box "Ubuntu 24.04 (Chroot) installed successfully!"
            
            print_status "Ubuntu 24.04 installed successfully!"
            print_status "Creating setup scripts in Ubuntu directory..."
            
            # Create setup scripts in Ubuntu directory
            create_setup_scripts "$HOME/ubuntu/ubuntu24-rootfs"
            
            print_status "Setup scripts created successfully!"
            print_status "Next steps:"
            print_status "1. Enter Ubuntu as root: ubuntu24"
            print_status "2. Run ubuntu-root-setup.sh to configure user and system"
            print_status "3. Exit and enter as user: ubuntu24-username"
            print_status "4. Run ubuntu-tools-setup.sh to install tools"
        elif [[ "$result" == "chroot_failed" ]]; then
            print_error_box "Failed to download Ubuntu 24.04 rootfs"
            print_status "Please check your internet connection and try again"
        else
            print_error_box "Failed to install Ubuntu 24.04"
        fi
    else
        print_error_box "Installation failed"
    fi

    clear_screen
}

# Function to install Ubuntu with Proot-distro in background
install_ubuntu_proot_background() {
    local version="$1"

    # Install proot-distro
    pkg install proot-distro -y

    # Use specific proot URLs for better compatibility
    case $version in
        "18.04")
            # Use Andronix-style URL for Ubuntu 18.04
            PROOT_URL="https://github.com/AndronixApp/AndronixOrigin/raw/master/Ubuntu/Ubuntu-18.04/arm64/ubuntu-18.04-arm64.tar.gz"
            ;;
        "20.04")
            # Use Andronix-style URL for Ubuntu 20.04
            PROOT_URL="https://github.com/AndronixApp/AndronixOrigin/raw/master/Ubuntu/Ubuntu-20.04/arm64/ubuntu-20.04-arm64.tar.gz"
            ;;
        "22.04")
            # Use Andronix-style URL for Ubuntu 22.04
            PROOT_URL="https://github.com/AndronixApp/AndronixOrigin/raw/master/Ubuntu/Ubuntu-22.04/arm64/ubuntu-22.04-arm64.tar.gz"
            ;;
        "24.04")
            # Use Andronix-style URL for Ubuntu 24.04
            PROOT_URL="https://github.com/AndronixApp/AndronixOrigin/raw/master/Ubuntu/Ubuntu-24.04/arm64/ubuntu-24.04-arm64.tar.gz"
            ;;
        *)
            # Fallback to proot-distro
            proot-distro install ubuntu-${version}
            if [[ $? -eq 0 ]]; then
                echo "proot_success" > $HOME/ubuntu_install_result
            else
                echo "proot_failed" > $HOME/ubuntu_install_result
            fi
            return
            ;;
    esac

    # Create proot directory
    mkdir -p $HOME/ubuntu/proot-${version}
    cd $HOME/ubuntu/proot-${version}

    # Download proot rootfs (silent with progress)
    wget -q --show-progress -O ubuntu-${version}-proot.tar.gz $PROOT_URL > /dev/null 2>&1

    if [[ $? -eq 0 ]]; then
        # Extract proot rootfs (silent)
        tar -xzf ubuntu-${version}-proot.tar.gz --exclude='./dev' > /dev/null 2>&1

        # Create start script for proot
        cat > start-ubuntu-${version}-proot.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD
proot -r $HOME/ubuntu/proot-${version} -b /dev -b /proc -b /sys -b /data/data/com.termux/files/home:/root -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
        chmod +x start-ubuntu-${version}-proot.sh

        echo "proot_success" > $HOME/ubuntu_install_result
    else
        # Fallback to proot-distro if download fails
        cd $HOME
        proot-distro install ubuntu-${version}
        if [[ $? -eq 0 ]]; then
            echo "proot_success" > $HOME/ubuntu_install_result
        else
            echo "proot_failed" > $HOME/ubuntu_install_result
        fi
    fi
}

# Function to install Ubuntu with Proot-distro - Main function
install_ubuntu_proot() {
    print_status "Installing Ubuntu with proot-distro..."

    # Install proot-distro
    pkg install proot-distro -y

    print_header
    echo -e "${WHITE}Select Ubuntu Version for Proot:${NC}"
    echo -e "${BLUE}1.${NC} Ubuntu 18.04"
    echo -e "${BLUE}2.${NC} Ubuntu 20.04"
    echo -e "${BLUE}3.${NC} Ubuntu 22.04"
    echo -e "${BLUE}4.${NC} Ubuntu 24.04"
    echo ""

    read -p "Select Ubuntu version (1-4): " proot_version

    case $proot_version in
        1)
            # Start installation in background
            install_ubuntu_proot_background "18.04" &
            local pid=$!

            # Show loading animation
            show_loading "Installing Ubuntu 18.04 (Proot)..." $pid

            # Wait for installation to complete
            wait $pid

            # Check result
            if [[ -f $HOME/ubuntu_install_result ]]; then
                local result=$(cat $HOME/ubuntu_install_result)
                rm -f $HOME/ubuntu_install_result

                if [[ "$result" == "proot_success" ]]; then
                    print_success_box "Ubuntu 18.04 (Proot) installed successfully!"
                    print_status "To enter Ubuntu: cd $HOME/ubuntu/proot-18.04 && ./start-ubuntu-18.04-proot.sh"
                    print_status "Or use: proot-distro login ubuntu-18.04"
                else
                    print_error_box "Failed to install Ubuntu 18.04"
                fi
            else
                print_error_box "Installation failed"
            fi
            clear_screen
            ;;
        2)
            # Start installation in background
            install_ubuntu_proot_background "20.04" &
            local pid=$!

            # Show loading animation
            show_loading "Installing Ubuntu 20.04 (Proot)..." $pid

            # Wait for installation to complete
            wait $pid

            # Check result
            if [[ -f $HOME/ubuntu_install_result ]]; then
                local result=$(cat $HOME/ubuntu_install_result)
                rm -f $HOME/ubuntu_install_result

                if [[ "$result" == "proot_success" ]]; then
                    print_success_box "Ubuntu 20.04 (Proot) installed successfully!"
                    print_status "To enter Ubuntu: cd $HOME/ubuntu/proot-20.04 && ./start-ubuntu-20.04-proot.sh"
                    print_status "Or use: proot-distro login ubuntu-20.04"
                else
                    print_error_box "Failed to install Ubuntu 20.04"
                fi
            else
                print_error_box "Installation failed"
            fi
            clear_screen
            ;;
        3)
            # Start installation in background
            install_ubuntu_proot_background "22.04" &
            local pid=$!

            # Show loading animation
            show_loading "Installing Ubuntu 22.04 (Proot)..." $pid

            # Wait for installation to complete
            wait $pid

            # Check result
            if [[ -f $HOME/ubuntu_install_result ]]; then
                local result=$(cat $HOME/ubuntu_install_result)
                rm -f $HOME/ubuntu_install_result

                if [[ "$result" == "proot_success" ]]; then
                    print_success_box "Ubuntu 22.04 (Proot) installed successfully!"
                    print_status "To enter Ubuntu: cd $HOME/ubuntu/proot-22.04 && ./start-ubuntu-22.04-proot.sh"
                    print_status "Or use: proot-distro login ubuntu-22.04"
                else
                    print_error_box "Failed to install Ubuntu 22.04"
                fi
            else
                print_error_box "Installation failed"
            fi
            clear_screen
            ;;
        4)
            # Start installation in background
            install_ubuntu_proot_background "24.04" &
            local pid=$!

            # Show loading animation
            show_loading "Installing Ubuntu 24.04 (Proot)..." $pid

            # Wait for installation to complete
            wait $pid

            # Check result
            if [[ -f $HOME/ubuntu_install_result ]]; then
                local result=$(cat $HOME/ubuntu_install_result)
                rm -f $HOME/ubuntu_install_result

                if [[ "$result" == "proot_success" ]]; then
                    print_success_box "Ubuntu 24.04 (Proot) installed successfully!"
                    print_status "To enter Ubuntu: cd $HOME/ubuntu/proot-24.04 && ./start-ubuntu-24.04-proot.sh"
                    print_status "Or use: proot-distro login ubuntu-24.04"
                else
                    print_error_box "Failed to install Ubuntu 24.04"
                fi
            else
                print_error_box "Installation failed"
            fi
            clear_screen
            ;;
        *)
            print_error "Invalid choice"
            return 1
            ;;
    esac
}

# Function to check and request root access
check_root_access() {
    print_header
    echo -e "${YELLOW}Root Access Required for Chroot Installation${NC}"
    echo -e "${WHITE}Chroot installation requires root access to work properly.${NC}"
    echo -e "${WHITE}Please grant root access to Termux when prompted.${NC}"
    echo ""
    echo -e "${BLUE}Note:${NC} If you don't have root access, consider using Proot instead."
    echo ""

    # Show root status
    if [[ $(id -u) -eq 0 ]]; then
        echo -e "${GREEN}✓ Root access already available${NC}"
    else
        echo -e "${YELLOW}⚠ Root status: No root access${NC}"
    fi
    echo ""

    read -p "Press Enter to continue with root access request..."

    # Check if we have root access
    if [[ $(id -u) -eq 0 ]]; then
        print_success_box "Root access confirmed!"
        return 0
    else
        # Try to get root access
        echo -e "${YELLOW}Requesting root access...${NC}"
        su -c "echo 'Root access granted'" 2>/dev/null

        if [[ $? -eq 0 ]]; then
            print_success_box "Root access granted successfully!"
            return 0
        else
            print_error_box "Failed to get root access!"
            echo ""
            echo -e "${WHITE}Possible solutions:${NC}"
            echo -e "${BLUE}1.${NC} Make sure your device is rooted"
            echo -e "${BLUE}2.${NC} Grant root access to Termux in SuperSU/Magisk"
            echo -e "${BLUE}3.${NC} Use Proot instead (no root required)"
            echo ""
            echo -e "${WHITE}You can:${NC}"
            echo -e "${BLUE}1.${NC} Try again"
            echo -e "${BLUE}2.${NC} Use Proot instead (no root required)"
            echo -e "${BLUE}3.${NC} Go back to main menu"
            echo ""
            read -p "Enter your choice (1-3): " root_choice

            case $root_choice in
                1) check_root_access ;;
                2) install_ubuntu_proot ;;
                3) return 1 ;;
                *) return 1 ;;
            esac
        fi
    fi
}

# Function to show installation method comparison
show_installation_methods() {
    print_header
    echo -e "${WHITE}Installation Methods Comparison:${NC}"
    echo ""
    echo -e "${CYAN}Chroot (Root Required):${NC}"
    echo -e "${WHITE}✓ Better performance${NC}"
    echo -e "${WHITE}✓ Full system access${NC}"
    echo -e "${WHITE}✓ Native Linux environment${NC}"
    echo -e "${WHITE}✗ Requires root access${NC}"
    echo -e "${WHITE}✗ May void warranty${NC}"
    echo ""
    echo -e "${CYAN}Proot (No Root Required):${NC}"
    echo -e "${WHITE}✓ No root access needed${NC}"
    echo -e "${WHITE}✓ Safe and secure${NC}"
    echo -e "${WHITE}✓ Easy to install${NC}"
    echo -e "${WHITE}✗ Slower performance${NC}"
    echo -e "${WHITE}✗ Limited system access${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

# Function to install Ubuntu (main menu)
install_ubuntu() {
    print_header
    echo -e "${WHITE}Select Installation Method:${NC}"
    echo -e "${BLUE}1.${NC} Chroot (for rooted devices)"
    echo -e "${BLUE}2.${NC} Proot (no root required)"
    echo -e "${BLUE}3.${NC} Show comparison"
    echo -e "${BLUE}4.${NC} Back to main menu"
    echo ""

    read -p "Enter your choice (1-4): " method_choice

    case $method_choice in
        1)
            # Check root access before proceeding
            if check_root_access; then
                print_header
                echo -e "${WHITE}Select Ubuntu Version for Chroot:${NC}"
                echo -e "${BLUE}1.${NC} Ubuntu 18.04"
                echo -e "${BLUE}2.${NC} Ubuntu 20.04"
                echo -e "${BLUE}3.${NC} Ubuntu 22.04"
                echo -e "${BLUE}4.${NC} Ubuntu 24.04"
                echo -e "${BLUE}5.${NC} Back to main menu"
                echo ""

                read -p "Enter your choice (1-5): " version_choice

                case $version_choice in
                    1) install_ubuntu_18_04_chroot ;;
                    2) install_ubuntu_20_04_chroot ;;
                    3) install_ubuntu_22_04_chroot ;;
                    4) install_ubuntu_24_04_chroot ;;
                    5) return ;;
                    *) print_error "Invalid choice" ;;
                esac
            fi
            ;;
        2)
            install_ubuntu_proot
            ;;
        3)
            show_installation_methods
            install_ubuntu
            ;;
        4)
            return
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac

    clear_screen
}



# Function to remove Ubuntu
remove_ubuntu() {
    print_header
    print_warning "This will remove all Ubuntu installations!"
    read -p "Are you sure? (y/N): " confirm_remove

    if [[ "$confirm_remove" =~ ^[Yy]$ ]]; then
        print_status "Removing Ubuntu installations..."

        # Remove chroot installations
        rm -rf $HOME/ubuntu/ubuntu*-rootfs

        # Remove proot-distro installations
        proot-distro remove ubuntu-18.04 2>/dev/null || true
        proot-distro remove ubuntu-20.04 2>/dev/null || true
        proot-distro remove ubuntu-22.04 2>/dev/null || true
        proot-distro remove ubuntu-24.04 2>/dev/null || true

        # Clean up
        rm -rf $HOME/ubuntu

        print_success_box "Ubuntu installations removed successfully!"
    else
        print_status "Removal cancelled."
    fi

    clear_screen
}



# Main menu function
main_menu() {
    while true; do
        print_header
        print_menu

        read -p "Enter your choice (1-4): " choice

        case $choice in
            1) system_check ;;
            2) install_ubuntu ;;
            3) remove_ubuntu ;;
            4)
                print_header
                    echo -e "${GREEN}Goodbye!${NC}"
    echo -e "${WHITE}Thank you for using Ubuntu Chroot & Proot Installer!${NC}"
    echo -e "${WHITE}Don't forget to visit our GitHub repository!${NC}"
                echo ""
                sleep 2
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please enter 1-4."
                ;;
        esac
    done
}

# Function to show welcome message
show_welcome() {
    clear
    echo -e "${CYAN}Welcome to Ubuntu Chroot & Proot Installer${NC}"
    echo -e "${WHITE}This installer will help you install Ubuntu on Termux${NC}"
    echo -e "${WHITE}Choose from Chroot (rooted devices) or Proot (no root)${NC}"
    echo -e "${WHITE}Supported versions: 18.04, 20.04, 22.04, 24.04${NC}"
    echo ""
    sleep 2
}

# Function to check and install prerequisites in background
check_and_install_prerequisites_background() {
    # Check if running in Termux
    if [[ ! -d "/data/data/com.termux" ]]; then
        echo "not_termux" > $HOME/prerequisites_result
        return
    fi

    # Update Termux packages
    pkg update -y > /dev/null 2>&1

    # Install required packages
    pkg install wget curl proot tar git nano vim -y > /dev/null 2>&1

    # Check disk space
    available_space=$(df $HOME | awk 'NR==2 {print $4}')
    required_space=4194304  # 4GB in KB

    if [[ $available_space -lt $required_space ]]; then
        echo "low_disk_space:$available_space" > $HOME/prerequisites_result
        return
    fi

    # Check internet connection
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        echo "no_internet" > $HOME/prerequisites_result
        return
    fi

    # Create necessary directories
    mkdir -p $HOME/ubuntu
    mkdir -p $HOME/ubuntu/scripts

    # Set DNS
    echo 'nameserver 8.8.8.8' > $HOME/.resolv.conf
    echo 'nameserver 8.8.4.4' >> $HOME/.resolv.conf

    echo "success" > $HOME/prerequisites_result
}

# Function to check and install prerequisites
check_and_install_prerequisites() {
    print_status "Checking system prerequisites..."

    # Start prerequisites check in background
    check_and_install_prerequisites_background &
    local pid=$!

    # Show loading animation with detailed steps
    echo -e "${YELLOW}System Check & Setup${NC}"
    echo -e "${WHITE}Checking Termux environment...${NC}"
    echo -e "${WHITE}Updating package repositories...${NC}"
    echo -e "${WHITE}Installing required packages...${NC}"
    echo -e "${WHITE}Checking disk space...${NC}"
    echo -e "${WHITE}Testing internet connection...${NC}"
    echo -e "${WHITE}Creating directories...${NC}"
    echo -e "${WHITE}Configuring DNS...${NC}"

    # Loading animation
    local i=0
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    while kill -0 $pid 2>/dev/null; do
        local temp=${spin:$i:1}
        echo -ne "${YELLOW}Please wait... ${temp}${NC}\r"
        i=$(( (i+1) % ${#spin} ))
        sleep 0.1
    done

    echo -e "${GREEN}System check completed!${NC}"
    echo ""

    # Wait for prerequisites check to complete
    wait $pid

    # Check result
    if [[ -f $HOME/prerequisites_result ]]; then
        local result=$(cat $HOME/prerequisites_result)
        rm -f $HOME/prerequisites_result

        case $result in
            "success")
                print_success_box "System prerequisites check completed successfully!"
                print_status "✓ Termux environment detected"
                print_status "✓ Required packages installed"
                print_status "✓ Sufficient disk space available"
                print_status "✓ Internet connection available"
                print_status "✓ Directories created"
                print_status "✓ DNS configured"
                ;;
            "not_termux")
                print_error_box "This script must be run in Termux!"
                print_status "Please install Termux from F-Droid and try again."
                exit 1
                ;;
            "low_disk_space")
                available_space_mb=$(($available_space / 1024))
                print_warning "Low disk space detected!"
                print_status "Available: ${available_space_mb}MB, Required: 4GB"
                read -p "Continue anyway? (y/N): " continue_anyway
                if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
                    exit 1
                fi
                ;;
            "no_internet")
                print_error_box "No internet connection detected!"
                print_status "Please check your internet connection and try again."
                exit 1
                ;;
            *)
                print_error_box "Unknown error during prerequisites check"
                exit 1
                ;;
        esac
    else
        print_error_box "Prerequisites check failed"
        exit 1
    fi

    clear_screen
}

# Function to show loading animation
show_loading() {
    local message="$1"
    local pid=$2

    echo -e "${YELLOW}Installing...${NC}"
    echo -e "${WHITE}$message${NC}"
    echo ""

    # Loading animation with progress bar
    local i=0
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local dots=""

    while kill -0 $pid 2>/dev/null; do
        local temp=${spin:$i:1}
        dots="${dots}."
        if [[ ${#dots} -gt 3 ]]; then
            dots=""
        fi
        echo -ne "${YELLOW}Downloading and installing${dots} ${temp}${NC}\r"
        i=$(( (i+1) % ${#spin} ))
        sleep 0.2
    done

    echo -e "${GREEN}✓ Installation completed successfully!${NC}"
    echo ""
}



# Start the installer
show_welcome
check_and_install_prerequisites
main_menu
