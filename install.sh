#!/bin/bash

# Ubuntu Chroot Installer - Complete Self-Contained Script
# GitHub Project: https://github.com/amirmsoud16/ubuntu-chroot-pk-

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Function to print header
print_header() {
    clear
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Ubuntu Chroot Installer${NC}"
    echo -e "${BLUE}  GitHub: https://github.com/amirmsoud16/ubuntu-chroot-pk-${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# Function to print status
print_status() {
    echo -e "${GREEN}[INFO] $1${NC}"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Function to print menu
print_menu() {
    echo -e "\n${WHITE}Available Options:${NC}"
    echo -e "${BLUE}1.${NC} System Check & Preparation"
    echo -e "${BLUE}2.${NC} Install Ubuntu (Chroot/Proot)"
    echo -e "${BLUE}3.${NC} Remove Ubuntu"
    echo -e "${BLUE}4.${NC} Access Ubuntu"
    echo -e "${BLUE}5.${NC} Exit"
    echo -e "${CYAN}================================${NC}"
}

# Function to check and prepare system
system_check() {
    print_header
    print_status "Performing system check and preparation..."
    
    # Check if running in Termux
    if [[ ! -d "/data/data/com.termux" ]]; then
        print_error "This script must be run in Termux!"
        return 1
    fi
    print_status "✓ Termux environment detected"
    
    # Update Termux
    print_status "Updating Termux packages..."
    pkg update -y
    
    # Install required packages
    print_status "Installing required packages..."
    pkg install wget curl proot tar git nano vim -y
    
    # Check disk space (minimum 4GB)
    available_space=$(df $HOME | awk 'NR==2 {print $4}')
    required_space=4194304  # 4GB in KB
    
    if [[ $available_space -lt $required_space ]]; then
        print_warning "Low disk space. Available: $(($available_space / 1024))MB, Required: 4GB"
        read -p "Continue anyway? (y/N): " continue_anyway
        if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
            return 1
        fi
    else
        print_status "✓ Sufficient disk space available"
    fi
    
    # Check internet connection
    if ping -c 1 8.8.8.8 &> /dev/null; then
        print_status "✓ Internet connection available"
    else
        print_error "No internet connection detected"
        return 1
    fi
    
    # Create necessary directories
    print_status "Creating necessary directories..."
    mkdir -p $HOME/ubuntu
    mkdir -p $HOME/ubuntu/scripts
    
    # Set DNS
    print_status "Setting up DNS..."
    echo 'nameserver 8.8.8.8' > $HOME/.resolv.conf
    echo 'nameserver 8.8.4.4' >> $HOME/.resolv.conf
    
    print_status "✓ System check completed successfully!"
    echo ""
    read -p "Press Enter to continue..."
}

# Function to install Ubuntu 18.04 (Chroot)
install_ubuntu_18_04_chroot() {
    print_status "Installing Ubuntu 18.04 (Chroot)..."
    
    INSTALL_DIR=$HOME/ubuntu/ubuntu18-rootfs
    mkdir -p $INSTALL_DIR
    cd $INSTALL_DIR
    
    ROOTFS_URL="https://partner-images.canonical.com/core/bionic/current/ubuntu-bionic-core-cloudimg-arm64-root.tar.gz"
    
    print_status "Downloading Ubuntu 18.04 rootfs..."
    wget -O ubuntu-18.04-rootfs.tar.gz $ROOTFS_URL
    
    print_status "Extracting rootfs..."
    proot --link2symlink tar -xf ubuntu-18.04-rootfs.tar.gz --exclude='./dev'
    
    # Create start script
    cat > start-ubuntu-18.04.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD
proot -0 -r $HOME/ubuntu/ubuntu18-rootfs -b /dev -b /proc -b /sys -b /data/data/com.termux/files/home:/root -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x start-ubuntu-18.04.sh
    
    print_status "✓ Ubuntu 18.04 (Chroot) installed successfully!"
    print_status "To enter Ubuntu: cd $HOME/ubuntu/ubuntu18-rootfs && ./start-ubuntu-18.04.sh"
}

# Function to install Ubuntu 20.04 (Chroot)
install_ubuntu_20_04_chroot() {
    print_status "Installing Ubuntu 20.04 (Chroot)..."
    
    INSTALL_DIR=$HOME/ubuntu/ubuntu20-rootfs
    mkdir -p $INSTALL_DIR
    cd $INSTALL_DIR
    
    ROOTFS_URL="https://partner-images.canonical.com/core/focal/current/ubuntu-focal-core-cloudimg-arm64-root.tar.gz"
    
    print_status "Downloading Ubuntu 20.04 rootfs..."
    wget -O ubuntu-20.04-rootfs.tar.gz $ROOTFS_URL
    
    print_status "Extracting rootfs..."
    proot --link2symlink tar -xf ubuntu-20.04-rootfs.tar.gz --exclude='./dev'
    
    # Create start script
    cat > start-ubuntu-20.04.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD
proot -0 -r $HOME/ubuntu/ubuntu20-rootfs -b /dev -b /proc -b /sys -b /data/data/com.termux/files/home:/root -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x start-ubuntu-20.04.sh
    
    print_status "✓ Ubuntu 20.04 (Chroot) installed successfully!"
    print_status "To enter Ubuntu: cd $HOME/ubuntu/ubuntu20-rootfs && ./start-ubuntu-20.04.sh"
}

# Function to install Ubuntu 22.04 (Chroot)
install_ubuntu_22_04_chroot() {
    print_status "Installing Ubuntu 22.04 (Chroot)..."
    
    INSTALL_DIR=$HOME/ubuntu/ubuntu22-rootfs
    mkdir -p $INSTALL_DIR
    cd $INSTALL_DIR
    
    ROOTFS_URL="https://partner-images.canonical.com/core/jammy/current/ubuntu-jammy-core-cloudimg-arm64-root.tar.gz"
    
    print_status "Downloading Ubuntu 22.04 rootfs..."
    wget -O ubuntu-22.04-rootfs.tar.gz $ROOTFS_URL
    
    print_status "Extracting rootfs..."
    proot --link2symlink tar -xf ubuntu-22.04-rootfs.tar.gz --exclude='./dev'
    
    # Create start script
    cat > start-ubuntu-22.04.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD
proot -0 -r $HOME/ubuntu/ubuntu22-rootfs -b /dev -b /proc -b /sys -b /data/data/com.termux/files/home:/root -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x start-ubuntu-22.04.sh
    
    print_status "✓ Ubuntu 22.04 (Chroot) installed successfully!"
    print_status "To enter Ubuntu: cd $HOME/ubuntu/ubuntu22-rootfs && ./start-ubuntu-22.04.sh"
}

# Function to install Ubuntu 24.04 (Chroot)
install_ubuntu_24_04_chroot() {
    print_status "Installing Ubuntu 24.04 (Chroot)..."
    
    INSTALL_DIR=$HOME/ubuntu/ubuntu24-rootfs
    mkdir -p $INSTALL_DIR
    cd $INSTALL_DIR
    
    ROOTFS_URL="https://partner-images.canonical.com/core/noble/current/ubuntu-noble-core-cloudimg-arm64-root.tar.gz"
    
    print_status "Downloading Ubuntu 24.04 rootfs..."
    wget -O ubuntu-24.04-rootfs.tar.gz $ROOTFS_URL
    
    print_status "Extracting rootfs..."
    proot --link2symlink tar -xf ubuntu-24.04-rootfs.tar.gz --exclude='./dev'
    
    # Create start script
    cat > start-ubuntu-24.04.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD
proot -0 -r $HOME/ubuntu/ubuntu24-rootfs -b /dev -b /proc -b /sys -b /data/data/com.termux/files/home:/root -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x start-ubuntu-24.04.sh
    
    print_status "✓ Ubuntu 24.04 (Chroot) installed successfully!"
    print_status "To enter Ubuntu: cd $HOME/ubuntu/ubuntu24-rootfs && ./start-ubuntu-24.04.sh"
}

# Function to install Ubuntu with Proot-distro
install_ubuntu_proot() {
    print_status "Installing Ubuntu with proot-distro..."
    
    # Install proot-distro
    pkg install proot-distro -y
    
    print_status "Available Ubuntu versions for proot-distro:"
    echo -e "${BLUE}1.${NC} Ubuntu 18.04"
    echo -e "${BLUE}2.${NC} Ubuntu 20.04"
    echo -e "${BLUE}3.${NC} Ubuntu 22.04"
    echo -e "${BLUE}4.${NC} Ubuntu 24.04"
    
    read -p "Select Ubuntu version (1-4): " proot_version
    
    case $proot_version in
        1)
            print_status "Installing Ubuntu 18.04 (proot-distro)..."
            proot-distro install ubuntu-18.04
            print_status "✓ Ubuntu 18.04 (proot) installed successfully!"
            print_status "To enter Ubuntu: proot-distro login ubuntu-18.04"
            ;;
        2)
            print_status "Installing Ubuntu 20.04 (proot-distro)..."
            proot-distro install ubuntu-20.04
            print_status "✓ Ubuntu 20.04 (proot) installed successfully!"
            print_status "To enter Ubuntu: proot-distro login ubuntu-20.04"
            ;;
        3)
            print_status "Installing Ubuntu 22.04 (proot-distro)..."
            proot-distro install ubuntu-22.04
            print_status "✓ Ubuntu 22.04 (proot) installed successfully!"
            print_status "To enter Ubuntu: proot-distro login ubuntu-22.04"
            ;;
        4)
            print_status "Installing Ubuntu 24.04 (proot-distro)..."
            proot-distro install ubuntu-24.04
            print_status "✓ Ubuntu 24.04 (proot) installed successfully!"
            print_status "To enter Ubuntu: proot-distro login ubuntu-24.04"
            ;;
        *)
            print_error "Invalid choice"
            return 1
            ;;
    esac
}

# Function to install Ubuntu (main menu)
install_ubuntu() {
    print_header
    echo -e "${WHITE}Select installation method:${NC}"
    echo -e "${BLUE}1.${NC} Chroot (for rooted devices)"
    echo -e "${BLUE}2.${NC} Proot (no root required)"
    echo -e "${BLUE}3.${NC} Back to main menu"
    
    read -p "Enter your choice (1-3): " method_choice
    
    case $method_choice in
        1)
            print_header
            echo -e "${WHITE}Select Ubuntu version for Chroot:${NC}"
            echo -e "${BLUE}1.${NC} Ubuntu 18.04"
            echo -e "${BLUE}2.${NC} Ubuntu 20.04"
            echo -e "${BLUE}3.${NC} Ubuntu 22.04"
            echo -e "${BLUE}4.${NC} Ubuntu 24.04"
            echo -e "${BLUE}5.${NC} Back to main menu"
            
            read -p "Enter your choice (1-5): " version_choice
            
            case $version_choice in
                1) install_ubuntu_18_04_chroot ;;
                2) install_ubuntu_20_04_chroot ;;
                3) install_ubuntu_22_04_chroot ;;
                4) install_ubuntu_24_04_chroot ;;
                5) return ;;
                *) print_error "Invalid choice" ;;
            esac
            ;;
        2)
            install_ubuntu_proot
            ;;
        3)
            return
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
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
        
        print_status "✓ Ubuntu installations removed successfully!"
    else
        print_status "Removal cancelled."
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Function to access Ubuntu
access_ubuntu() {
    print_header
    echo -e "${WHITE}Ubuntu Access Options:${NC}"
    echo -e "${BLUE}1.${NC} List installed Ubuntu versions"
    echo -e "${BLUE}2.${NC} Access Ubuntu (Chroot)"
    echo -e "${BLUE}3.${NC} Access Ubuntu (Proot)"
    echo -e "${BLUE}4.${NC} Back to main menu"
    
    read -p "Enter your choice (1-4): " access_choice
    
    case $access_choice in
        1)
            print_status "Checking installed Ubuntu versions..."
            echo ""
            echo -e "${CYAN}Chroot installations:${NC}"
            ls -la $HOME/ubuntu/ 2>/dev/null | grep ubuntu || echo "No chroot installations found"
            echo ""
            echo -e "${CYAN}Proot installations:${NC}"
            proot-distro list 2>/dev/null | grep ubuntu || echo "No proot installations found"
            ;;
        2)
            echo -e "${WHITE}Available Chroot installations:${NC}"
            ls -la $HOME/ubuntu/ 2>/dev/null | grep ubuntu || echo "No chroot installations found"
            echo ""
            read -p "Enter Ubuntu version (e.g., 22.04): " chroot_version
            if [[ -d "$HOME/ubuntu/ubuntu${chroot_version}-rootfs" ]]; then
                cd $HOME/ubuntu/ubuntu${chroot_version}-rootfs
                ./start-ubuntu-${chroot_version}.sh
            else
                print_error "Ubuntu ${chroot_version} not found"
            fi
            ;;
        3)
            echo -e "${WHITE}Available Proot installations:${NC}"
            proot-distro list 2>/dev/null | grep ubuntu || echo "No proot installations found"
            echo ""
            read -p "Enter Ubuntu version (e.g., 22.04): " proot_version
            proot-distro login ubuntu-${proot_version}
            ;;
        4)
            return
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
}

# Main menu function
main_menu() {
    while true; do
        print_header
        print_menu
        
        read -p "Enter your choice (1-5): " choice
        
        case $choice in
            1) system_check ;;
            2) install_ubuntu ;;
            3) remove_ubuntu ;;
            4) access_ubuntu ;;
            5)
                print_status "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please enter 1-5."
                ;;
        esac
    done
}

# Start the installer
main_menu 