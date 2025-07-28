#!/bin/bash

# Ubuntu Chroot Installer for Termux
# A comprehensive shell-based installer with system check, installation, and removal

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Ubuntu directory
UBUNTU_DIR="$HOME/ubuntu"
UBUNTU_VERSION="22.04"
INSTALL_TYPE="chroot"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_header() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}  Ubuntu Chroot Installer${NC}"
    echo -e "${CYAN}================================${NC}"
}

print_menu() {
    echo -e "\n${WHITE}Available Options:${NC}"
    echo -e "${BLUE}1.${NC} System Check & Preparation"
    echo -e "${BLUE}2.${NC} Install Ubuntu"
    echo -e "${BLUE}3.${NC} Remove Ubuntu"
    echo -e "${BLUE}4.${NC} Access Ubuntu"
    echo -e "${BLUE}5.${NC} Exit"
    echo -e "${CYAN}================================${NC}"
}

# Function to check if running in Termux
check_termux() {
    if [[ ! -d "/data/data/com.termux" ]]; then
        print_error "This script must be run in Termux!"
        exit 1
    fi
    print_success "Termux environment detected"
}

# Function to check and install required packages
check_packages() {
    print_status "Checking required packages..."
    
    local packages=("wget" "curl" "proot" "tar" "git" "nano" "vim")
    local missing_packages=()
    
    for pkg in "${packages[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            missing_packages+=("$pkg")
        else
            print_success "$pkg is installed"
        fi
    done
    
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        print_warning "Missing packages: ${missing_packages[*]}"
        print_status "Installing missing packages..."
        
        pkg update -y
        for pkg in "${missing_packages[@]}"; do
            print_status "Installing $pkg..."
            pkg install "$pkg" -y
        done
    fi
}

# Function to check disk space
check_disk_space() {
    print_status "Checking disk space..."
    
    local free_space=$(df /data | awk 'NR==2 {print $4}')
    local free_space_gb=$((free_space / 1024 / 1024))
    
    print_status "Available disk space: ${free_space_gb}GB"
    
    if [[ $free_space_gb -lt 4096 ]]; then
        print_warning "Low disk space (${free_space_gb}GB). Minimum 4GB required."
        print_status "Cleaning package cache..."
        pkg clean
        apt clean 2>/dev/null || true
        
        # Recheck space
        free_space=$(df /data | awk 'NR==2 {print $4}')
        free_space_gb=$((free_space / 1024 / 1024))
        print_status "Available disk space after cleanup: ${free_space_gb}GB"
    else
        print_success "Sufficient disk space available"
    fi
}

# Function to check internet connection
check_internet() {
    print_status "Checking internet connection..."
    
    if ping -c 1 8.8.8.8 &> /dev/null; then
        print_success "Internet connection available"
    else
        print_error "Internet connection issues detected"
        print_status "Trying to fix DNS..."
        echo "nameserver 8.8.8.8" > /etc/resolv.conf
        echo "nameserver 8.8.4.4" >> /etc/resolv.conf
    fi
}

# Function to check root access
check_root() {
    print_status "Checking root access..."
    
    if [[ -f "/system/bin/su" ]] || [[ -f "/system/xbin/su" ]]; then
        print_success "Root access available"
        INSTALL_TYPE="chroot"
    else
        print_warning "Device is not rooted. Using Proot installation."
        INSTALL_TYPE="proot"
    fi
}

# Function to create Ubuntu directory
create_ubuntu_dir() {
    print_status "Setting up Ubuntu directory..."
    
    mkdir -p "$UBUNTU_DIR"
    mkdir -p "$UBUNTU_DIR/rootfs"
    mkdir -p "$UBUNTU_DIR/scripts"
    
    chmod 755 "$UBUNTU_DIR"
    print_success "Ubuntu directory created"
}

# Function to create environment file
create_env_file() {
    print_status "Creating environment file..."
    
    cat > "$HOME/.ubuntu_env" << EOF
export UBUNTU_HOME="$UBUNTU_DIR"
export DISPLAY=:0
export PULSE_SERVER=127.0.0.1
export VNC_DISPLAY=:1
EOF
    
    print_success "Environment file created"
}

# Function to perform comprehensive system check
system_check() {
    print_header
    print_status "Performing comprehensive system check..."
    
    check_termux
    check_packages
    check_disk_space
    check_internet
    check_root
    create_ubuntu_dir
    create_env_file
    
    # Check if Ubuntu is already installed
    if [[ -d "$UBUNTU_DIR" ]] && [[ -n "$(ls -A "$UBUNTU_DIR" 2>/dev/null)" ]]; then
        print_warning "Ubuntu appears to be already installed"
    else
        print_status "Ubuntu is not installed"
    fi
    
    print_success "System check completed!"
    print_status "System is ready for Ubuntu installation"
}

# Function to select Ubuntu version
select_ubuntu_version() {
    echo -e "\n${WHITE}Select Ubuntu Version:${NC}"
    echo -e "${BLUE}1.${NC} Ubuntu 24.04 LTS (Latest)"
    echo -e "${BLUE}2.${NC} Ubuntu 22.04 LTS (Recommended)"
    echo -e "${BLUE}3.${NC} Ubuntu 20.04 LTS (Stable)"
    echo -e "${BLUE}4.${NC} Ubuntu 18.04 LTS (Legacy)"
    
    read -p "Enter your choice (1-4): " version_choice
    
    case $version_choice in
        1) UBUNTU_VERSION="24.04" ;;
        2) UBUNTU_VERSION="22.04" ;;
        3) UBUNTU_VERSION="20.04" ;;
        4) UBUNTU_VERSION="18.04" ;;
        *) 
            print_warning "Invalid choice, using Ubuntu 22.04"
            UBUNTU_VERSION="22.04"
            ;;
    esac
}

# Function to select installation type
select_install_type() {
    echo -e "\n${WHITE}Select Installation Type:${NC}"
    echo -e "${BLUE}1.${NC} Chroot (Recommended for rooted devices)"
    echo -e "${BLUE}2.${NC} Proot (For non-rooted devices)"
    
    read -p "Enter your choice (1-2): " type_choice
    
    case $type_choice in
        1) INSTALL_TYPE="chroot" ;;
        2) INSTALL_TYPE="proot" ;;
        *) 
            print_warning "Invalid choice, using Chroot"
            INSTALL_TYPE="chroot"
            ;;
    esac
}

# Function to install Ubuntu (chroot)
install_ubuntu_chroot() {
    print_header
    echo -e "${WHITE}Select Ubuntu Version for Chroot Install:${NC}"
    echo -e "${BLUE}1.${NC} Ubuntu 24.04 LTS"
    echo -e "${BLUE}2.${NC} Ubuntu 22.04 LTS"
    echo -e "${BLUE}3.${NC} Ubuntu 20.04 LTS"
    echo -e "${BLUE}4.${NC} Ubuntu 18.04 LTS"
    echo -e "${BLUE}5.${NC} Back to main menu"
    read -p "Enter your choice (1-5): " chroot_choice
    case $chroot_choice in
        1)
            bash Installer/Ubuntu/ubuntu-24.04.sh
            ;;
        2)
            bash Installer/Ubuntu/ubuntu-22.04.sh
            ;;
        3)
            bash Installer/Ubuntu/ubuntu-20.04.sh
            ;;
        4)
            bash Installer/Ubuntu/ubuntu-18.04.sh
            ;;
        5)
            return
            ;;
        *)
            print_warning "Invalid choice. Returning to main menu."
            ;;
    esac
}

# Function to install Ubuntu (proot)
install_ubuntu_proot() {
    print_header
    echo -e "${WHITE}Select Ubuntu Version for Proot Install:${NC}"
    echo -e "${BLUE}1.${NC} Ubuntu 24.04 LTS"
    echo -e "${BLUE}2.${NC} Ubuntu 22.04 LTS"
    echo -e "${BLUE}3.${NC} Ubuntu 20.04 LTS"
    echo -e "${BLUE}4.${NC} Ubuntu 18.04 LTS"
    echo -e "${BLUE}5.${NC} Back to main menu"
    read -p "Enter your choice (1-5): " proot_choice
    case $proot_choice in
        1)
            bash Installer/Ubuntu/ubuntu-24.04-proot.sh
            ;;
        2)
            bash Installer/Ubuntu/ubuntu-22.04-proot.sh
            ;;
        3)
            bash Installer/Ubuntu/ubuntu-20.04-proot.sh
            ;;
        4)
            bash Installer/Ubuntu/ubuntu-18.04-proot.sh
            ;;
        5)
            return
            ;;
        *)
            print_warning "Invalid choice. Returning to main menu."
            ;;
    esac
}

# Function to create start scripts
create_start_scripts() {
    print_status "Creating start scripts..."
    
    # Main start script
    cat > "$UBUNTU_DIR/start-ubuntu.sh" << 'EOF'
#!/bin/bash
# Ubuntu Start Script

cd ~/ubuntu

if [[ -f "./start-ubuntu.sh" ]]; then
    bash ./start-ubuntu.sh
else
    echo "Ubuntu start script not found. Please reinstall Ubuntu."
fi
EOF

    # VNC start script
    cat > "$UBUNTU_DIR/start-ubuntu-vnc.sh" << 'EOF'
#!/bin/bash
# Ubuntu VNC Start Script

cd ~/ubuntu

# Start VNC server
vncserver :1 -geometry 1280x720 -depth 24

echo "VNC server started on :1"
echo "Connect using VNC viewer to: localhost:5901"

# Start Ubuntu
if [[ -f "./start-ubuntu.sh" ]]; then
    bash ./start-ubuntu.sh
fi
EOF

    # LXDE installation script
    cat > "$UBUNTU_DIR/install-lxde.sh" << 'EOF'
#!/bin/bash
# LXDE Installation Script

echo "Installing LXDE desktop environment..."
apt update
apt install lxde-core lxde lxde-common lxde-icon-theme tightvncserver firefox-esr geany leafpad -y
echo "LXDE installation completed!"
EOF

    # VNC setup script
    cat > "$UBUNTU_DIR/setup-vnc.sh" << 'EOF'
#!/bin/bash
# VNC Setup Script

mkdir -p ~/.vnc
cat > ~/.vnc/xstartup << 'VNC_EOF'
#!/bin/bash
xrdb $HOME/.Xresources
startlxde &
VNC_EOF

chmod +x ~/.vnc/xstartup
vncpasswd
echo "VNC setup completed!"
EOF

    # Post-install script
    cat > "$UBUNTU_DIR/post-install.sh" << 'EOF'
#!/bin/bash
# Post-installation Script

echo "Running post-installation tasks..."
apt update && apt upgrade -y
apt install sudo nano vim git wget curl htop -y
echo "Post-installation completed!"
EOF

    # Make all scripts executable
    chmod +x "$UBUNTU_DIR"/*.sh
    
    print_success "Start scripts created"
}

# Function to remove Ubuntu
remove_ubuntu() {
    print_header
    print_status "Ubuntu removal..."
    
    echo -e "\n${YELLOW}WARNING: This will completely remove Ubuntu and all its files!${NC}"
    read -p "Are you sure you want to continue? (y/N): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_warning "Removal cancelled"
        return
    fi
    
    # Remove Ubuntu directory
    if [[ -d "$UBUNTU_DIR" ]]; then
        print_status "Removing Ubuntu directory..."
        rm -rf "$UBUNTU_DIR"
        print_success "Ubuntu directory removed"
    else
        print_warning "Ubuntu directory not found"
    fi
    
    # Remove environment variables from .bashrc
    if [[ -f "$HOME/.bashrc" ]]; then
        print_status "Cleaning environment variables..."
        sed -i '/DISPLAY=:0/d' "$HOME/.bashrc"
        sed -i '/PULSE_SERVER=127.0.0.1/d' "$HOME/.bashrc"
        sed -i '/VNC_DISPLAY=:1/d' "$HOME/.bashrc"
        sed -i '/UBUNTU_HOME/d' "$HOME/.bashrc"
        print_success "Environment variables cleaned"
    fi
    
    # Remove environment file
    if [[ -f "$HOME/.ubuntu_env" ]]; then
        rm -f "$HOME/.ubuntu_env"
        print_success "Environment file removed"
    fi
    
    print_success "Ubuntu removal completed!"
}

# Function to access Ubuntu
access_ubuntu() {
    print_header
    print_status "Ubuntu access options..."
    
    if [[ ! -d "$UBUNTU_DIR" ]] || [[ -z "$(ls -A "$UBUNTU_DIR" 2>/dev/null)" ]]; then
        print_error "Ubuntu is not installed. Please install Ubuntu first."
        return
    fi
    
    echo -e "\n${WHITE}Access Options:${NC}"
    echo -e "${BLUE}1.${NC} Direct access (Terminal)"
    echo -e "${BLUE}2.${NC} VNC access (Graphical)"
    echo -e "${BLUE}3.${NC} Install LXDE desktop"
    echo -e "${BLUE}4.${NC} Setup VNC server"
    
    read -p "Enter your choice (1-4): " access_choice
    
    case $access_choice in
        1)
            print_status "Starting Ubuntu terminal..."
            cd "$UBUNTU_DIR"
            if [[ -f "./start-ubuntu.sh" ]]; then
                bash ./start-ubuntu.sh
            else
                print_error "Ubuntu start script not found"
            fi
            ;;
        2)
            print_status "Starting Ubuntu with VNC..."
            cd "$UBUNTU_DIR"
            if [[ -f "./start-ubuntu-vnc.sh" ]]; then
                bash ./start-ubuntu-vnc.sh
            else
                print_error "VNC start script not found"
            fi
            ;;
        3)
            print_status "Installing LXDE desktop..."
            cd "$UBUNTU_DIR"
            if [[ -f "./install-lxde.sh" ]]; then
                bash ./install-lxde.sh
            else
                print_error "LXDE installation script not found"
            fi
            ;;
        4)
            print_status "Setting up VNC server..."
            cd "$UBUNTU_DIR"
            if [[ -f "./setup-vnc.sh" ]]; then
                bash ./setup-vnc.sh
            else
                print_error "VNC setup script not found"
            fi
            ;;
        *)
            print_warning "Invalid choice"
            ;;
    esac
}

# Main menu function
main_menu() {
    while true; do
        print_header
        print_menu
        
        echo -e "${BLUE}6.${NC} Install Ubuntu (Proot)"  # Add to menu
        read -p "Enter your choice (1-6): " choice
        
        case $choice in
            1) system_check ;;
            2) install_ubuntu_chroot ;;
            3) remove_ubuntu ;;
            4) access_ubuntu ;;
            5) 
                print_status "Exiting..."
                exit 0
                ;;
            6) install_ubuntu_proot ;;
            *)
                print_error "Invalid choice. Please enter 1-6."
                ;;
        esac
        
        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read
    done
}

# Main execution
main() {
    # Check if running in Termux
    check_termux
    
    # Start main menu
    main_menu
}

# Run main function
main "$@" 