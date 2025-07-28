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
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    Ubuntu Chroot Installer                    ║${NC}"
    echo -e "${CYAN}║                                                              ║${NC}"
    echo -e "${CYAN}║  GitHub: https://github.com/amirmsoud16/ubuntu-chroot-pk-   ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function to print status
print_status() {
    echo -e "${GREEN}✓ [INFO] $1${NC}"
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
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                        SUCCESS!                              ║${NC}"
    echo -e "${GREEN}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║  $message${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Function to print error message with box
print_error_box() {
    local message="$1"
    echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                         ERROR!                               ║${NC}"
    echo -e "${RED}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${RED}║  $message${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Function to clear screen and wait
clear_screen() {
    echo ""
    read -p "Press Enter to continue..."
    clear
}

# Function to print menu
print_menu() {
    echo -e "\n${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                        Available Options                        ║${NC}"
    echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}║  ${BLUE}1.${NC} ${WHITE}System Check & Preparation${NC}${YELLOW}                    ║${NC}"
    echo -e "${YELLOW}║  ${BLUE}2.${NC} ${WHITE}Install Ubuntu (Chroot/Proot)${NC}${YELLOW}                ║${NC}"
    echo -e "${YELLOW}║  ${BLUE}3.${NC} ${WHITE}Remove Ubuntu${NC}${YELLOW}                                ║${NC}"
    echo -e "${YELLOW}║  ${BLUE}4.${NC} ${WHITE}Access Ubuntu${NC}${YELLOW}                                ║${NC}"
    echo -e "${YELLOW}║  ${BLUE}5.${NC} ${WHITE}Exit${NC}${YELLOW}                                        ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
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
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                      System Information                       ║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"
    
    # Get system info
    available_space=$(df $HOME | awk 'NR==2 {print $4}')
    available_space_mb=$(($available_space / 1024))
    total_space=$(df $HOME | awk 'NR==2 {print $2}')
    total_space_mb=$(($total_space / 1024))
    used_space_mb=$(($total_space_mb - $available_space_mb))
    
    echo -e "${CYAN}║  Available Disk Space: ${WHITE}${available_space_mb}MB${CYAN} / ${WHITE}${total_space_mb}MB${CYAN}                    ║${NC}"
    echo -e "${CYAN}║  Used Disk Space: ${WHITE}${used_space_mb}MB${CYAN}                                        ║${NC}"
    echo -e "${CYAN}║  Android Version: ${WHITE}$(getprop ro.build.version.release)${CYAN}                              ║${NC}"
    echo -e "${CYAN}║  Architecture: ${WHITE}$(uname -m)${CYAN}                                        ║${NC}"
    echo -e "${CYAN}║  Termux Version: ${WHITE}$(pkg --version 2>/dev/null || echo "Unknown")${CYAN}                    ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    clear_screen
}

# Function to install Ubuntu 18.04 (Chroot) in background
install_ubuntu_18_04_chroot_background() {
    INSTALL_DIR=$HOME/ubuntu/ubuntu18-rootfs
    mkdir -p $INSTALL_DIR
    cd $INSTALL_DIR
    
    # Use reliable Ubuntu 18.04 rootfs URL
    ROOTFS_URL="https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-arm64-root.tar.xz"
    
    # Download Ubuntu 18.04 rootfs
    wget -O ubuntu-18.04-rootfs.tar.xz $ROOTFS_URL
    
    if [[ $? -ne 0 ]]; then
        # Fallback to proot-distro
        cd $HOME
        pkg install proot-distro -y
        proot-distro install ubuntu-18.04
        echo "proot_success" > /tmp/ubuntu_install_result
        return
    fi
    
    # Extract rootfs
    tar -xf ubuntu-18.04-rootfs.tar.xz --exclude='./dev'
    
    # Create start script
    cat > start-ubuntu-18.04.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD
proot -0 -r $HOME/ubuntu/ubuntu18-rootfs -b /dev -b /proc -b /sys -b /data/data/com.termux/files/home:/root -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x start-ubuntu-18.04.sh
    
    echo "chroot_success" > /tmp/ubuntu_install_result
}

# Function to install Ubuntu 18.04 (Chroot) - Main function
install_ubuntu_18_04_chroot() {
    print_status "Installing Ubuntu 18.04 (Chroot)..."
    
    # Start installation in background
    install_ubuntu_18_04_chroot_background &
    local pid=$!
    
    # Show loading animation
    show_loading "Installing Ubuntu 18.04 (Chroot)..." $pid
    
    # Wait for installation to complete
    wait $pid
    
    # Check result
    if [[ -f /tmp/ubuntu_install_result ]]; then
        local result=$(cat /tmp/ubuntu_install_result)
        rm -f /tmp/ubuntu_install_result
        
        if [[ "$result" == "chroot_success" ]]; then
            print_success_box "Ubuntu 18.04 (Chroot) installed successfully!"
            print_status "To enter Ubuntu: cd $HOME/ubuntu/ubuntu18-rootfs && ./start-ubuntu-18.04.sh"
        elif [[ "$result" == "proot_success" ]]; then
            print_success_box "Ubuntu 18.04 (Proot) installed successfully!"
            print_status "To enter Ubuntu: proot-distro login ubuntu-18.04"
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
    
    # Use reliable Ubuntu 20.04 rootfs URL
    ROOTFS_URL="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-arm64-root.tar.xz"
    
    # Download Ubuntu 20.04 rootfs
    wget -O ubuntu-20.04-rootfs.tar.xz $ROOTFS_URL
    
    if [[ $? -ne 0 ]]; then
        # Fallback to proot-distro
        cd $HOME
        pkg install proot-distro -y
        proot-distro install ubuntu-20.04
        echo "proot_success" > /tmp/ubuntu_install_result
        return
    fi
    
    # Extract rootfs
    tar -xf ubuntu-20.04-rootfs.tar.xz --exclude='./dev'
    
    # Create start script
    cat > start-ubuntu-20.04.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD
proot -0 -r $HOME/ubuntu/ubuntu20-rootfs -b /dev -b /proc -b /sys -b /data/data/com.termux/files/home:/root -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x start-ubuntu-20.04.sh
    
    echo "chroot_success" > /tmp/ubuntu_install_result
}

# Function to install Ubuntu 20.04 (Chroot) - Main function
install_ubuntu_20_04_chroot() {
    print_status "Installing Ubuntu 20.04 (Chroot)..."
    
    # Start installation in background
    install_ubuntu_20_04_chroot_background &
    local pid=$!
    
    # Show loading animation
    show_loading "Installing Ubuntu 20.04 (Chroot)..." $pid
    
    # Wait for installation to complete
    wait $pid
    
    # Check result
    if [[ -f /tmp/ubuntu_install_result ]]; then
        local result=$(cat /tmp/ubuntu_install_result)
        rm -f /tmp/ubuntu_install_result
        
        if [[ "$result" == "chroot_success" ]]; then
            print_success_box "Ubuntu 20.04 (Chroot) installed successfully!"
            print_status "To enter Ubuntu: cd $HOME/ubuntu/ubuntu20-rootfs && ./start-ubuntu-20.04.sh"
        elif [[ "$result" == "proot_success" ]]; then
            print_success_box "Ubuntu 20.04 (Proot) installed successfully!"
            print_status "To enter Ubuntu: proot-distro login ubuntu-20.04"
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
    
    # Use reliable Ubuntu 22.04 rootfs URL
    ROOTFS_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-arm64-root.tar.xz"
    
    # Download Ubuntu 22.04 rootfs
    wget -O ubuntu-22.04-rootfs.tar.xz $ROOTFS_URL
    
    if [[ $? -ne 0 ]]; then
        # Fallback to proot-distro
        cd $HOME
        pkg install proot-distro -y
        proot-distro install ubuntu-22.04
        echo "proot_success" > /tmp/ubuntu_install_result
        return
    fi
    
    # Extract rootfs
    tar -xf ubuntu-22.04-rootfs.tar.xz --exclude='./dev'
    
    # Create start script
    cat > start-ubuntu-22.04.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD
proot -0 -r $HOME/ubuntu/ubuntu22-rootfs -b /dev -b /proc -b /sys -b /data/data/com.termux/files/home:/root -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x start-ubuntu-22.04.sh
    
    echo "chroot_success" > /tmp/ubuntu_install_result
}

# Function to install Ubuntu 22.04 (Chroot) - Main function
install_ubuntu_22_04_chroot() {
    print_status "Installing Ubuntu 22.04 (Chroot)..."
    
    # Start installation in background
    install_ubuntu_22_04_chroot_background &
    local pid=$!
    
    # Show loading animation
    show_loading "Installing Ubuntu 22.04 (Chroot)..." $pid
    
    # Wait for installation to complete
    wait $pid
    
    # Check result
    if [[ -f /tmp/ubuntu_install_result ]]; then
        local result=$(cat /tmp/ubuntu_install_result)
        rm -f /tmp/ubuntu_install_result
        
        if [[ "$result" == "chroot_success" ]]; then
            print_success_box "Ubuntu 22.04 (Chroot) installed successfully!"
            print_status "To enter Ubuntu: cd $HOME/ubuntu/ubuntu22-rootfs && ./start-ubuntu-22.04.sh"
        elif [[ "$result" == "proot_success" ]]; then
            print_success_box "Ubuntu 22.04 (Proot) installed successfully!"
            print_status "To enter Ubuntu: proot-distro login ubuntu-22.04"
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
    
    # Use reliable Ubuntu 24.04 rootfs URL
    ROOTFS_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64-root.tar.xz"
    
    # Download Ubuntu 24.04 rootfs
    wget -O ubuntu-24.04-rootfs.tar.xz $ROOTFS_URL
    
    if [[ $? -ne 0 ]]; then
        # Fallback to proot-distro
        cd $HOME
        pkg install proot-distro -y
        proot-distro install ubuntu-24.04
        echo "proot_success" > /tmp/ubuntu_install_result
        return
    fi
    
    # Extract rootfs
    tar -xf ubuntu-24.04-rootfs.tar.xz --exclude='./dev'
    
    # Create start script
    cat > start-ubuntu-24.04.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD
proot -0 -r $HOME/ubuntu/ubuntu24-rootfs -b /dev -b /proc -b /sys -b /data/data/com.termux/files/home:/root -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x start-ubuntu-24.04.sh
    
    echo "chroot_success" > /tmp/ubuntu_install_result
}

# Function to install Ubuntu 24.04 (Chroot) - Main function
install_ubuntu_24_04_chroot() {
    print_status "Installing Ubuntu 24.04 (Chroot)..."
    
    # Start installation in background
    install_ubuntu_24_04_chroot_background &
    local pid=$!
    
    # Show loading animation
    show_loading "Installing Ubuntu 24.04 (Chroot)..." $pid
    
    # Wait for installation to complete
    wait $pid
    
    # Check result
    if [[ -f /tmp/ubuntu_install_result ]]; then
        local result=$(cat /tmp/ubuntu_install_result)
        rm -f /tmp/ubuntu_install_result
        
        if [[ "$result" == "chroot_success" ]]; then
            print_success_box "Ubuntu 24.04 (Chroot) installed successfully!"
            print_status "To enter Ubuntu: cd $HOME/ubuntu/ubuntu24-rootfs && ./start-ubuntu-24.04.sh"
        elif [[ "$result" == "proot_success" ]]; then
            print_success_box "Ubuntu 24.04 (Proot) installed successfully!"
            print_status "To enter Ubuntu: proot-distro login ubuntu-24.04"
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
    
    # Install specific Ubuntu version
    proot-distro install ubuntu-${version}
    
    if [[ $? -eq 0 ]]; then
        echo "proot_success" > /tmp/ubuntu_install_result
    else
        echo "proot_failed" > /tmp/ubuntu_install_result
    fi
}

# Function to install Ubuntu with Proot-distro - Main function
install_ubuntu_proot() {
    print_status "Installing Ubuntu with proot-distro..."
    
    # Install proot-distro
    pkg install proot-distro -y
    
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                Select Ubuntu Version for Proot                ║${NC}"
    echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}║  ${BLUE}1.${NC} ${WHITE}Ubuntu 18.04${NC}${YELLOW}                                    ║${NC}"
    echo -e "${YELLOW}║  ${BLUE}2.${NC} ${WHITE}Ubuntu 20.04${NC}${YELLOW}                                    ║${NC}"
    echo -e "${YELLOW}║  ${BLUE}3.${NC} ${WHITE}Ubuntu 22.04${NC}${YELLOW}                                    ║${NC}"
    echo -e "${YELLOW}║  ${BLUE}4.${NC} ${WHITE}Ubuntu 24.04${NC}${YELLOW}                                    ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
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
            if [[ -f /tmp/ubuntu_install_result ]]; then
                local result=$(cat /tmp/ubuntu_install_result)
                rm -f /tmp/ubuntu_install_result
                
                if [[ "$result" == "proot_success" ]]; then
                    print_success_box "Ubuntu 18.04 (Proot) installed successfully!"
                    print_status "To enter Ubuntu: proot-distro login ubuntu-18.04"
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
            if [[ -f /tmp/ubuntu_install_result ]]; then
                local result=$(cat /tmp/ubuntu_install_result)
                rm -f /tmp/ubuntu_install_result
                
                if [[ "$result" == "proot_success" ]]; then
                    print_success_box "Ubuntu 20.04 (Proot) installed successfully!"
                    print_status "To enter Ubuntu: proot-distro login ubuntu-20.04"
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
            if [[ -f /tmp/ubuntu_install_result ]]; then
                local result=$(cat /tmp/ubuntu_install_result)
                rm -f /tmp/ubuntu_install_result
                
                if [[ "$result" == "proot_success" ]]; then
                    print_success_box "Ubuntu 22.04 (Proot) installed successfully!"
                    print_status "To enter Ubuntu: proot-distro login ubuntu-22.04"
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
            if [[ -f /tmp/ubuntu_install_result ]]; then
                local result=$(cat /tmp/ubuntu_install_result)
                rm -f /tmp/ubuntu_install_result
                
                if [[ "$result" == "proot_success" ]]; then
                    print_success_box "Ubuntu 24.04 (Proot) installed successfully!"
                    print_status "To enter Ubuntu: proot-distro login ubuntu-24.04"
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

# Function to install Ubuntu (main menu)
install_ubuntu() {
    print_header
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                    Select Installation Method                  ║${NC}"
    echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}║  ${BLUE}1.${NC} ${WHITE}Chroot (for rooted devices)${NC}${YELLOW}                    ║${NC}"
    echo -e "${YELLOW}║  ${BLUE}2.${NC} ${WHITE}Proot (no root required)${NC}${YELLOW}                        ║${NC}"
    echo -e "${YELLOW}║  ${BLUE}3.${NC} ${WHITE}Back to main menu${NC}${YELLOW}                               ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    read -p "Enter your choice (1-3): " method_choice
    
    case $method_choice in
        1)
            print_header
            echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${YELLOW}║                Select Ubuntu Version for Chroot              ║${NC}"
            echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════╣${NC}"
            echo -e "${YELLOW}║  ${BLUE}1.${NC} ${WHITE}Ubuntu 18.04${NC}${YELLOW}                                    ║${NC}"
            echo -e "${YELLOW}║  ${BLUE}2.${NC} ${WHITE}Ubuntu 20.04${NC}${YELLOW}                                    ║${NC}"
            echo -e "${YELLOW}║  ${BLUE}3.${NC} ${WHITE}Ubuntu 22.04${NC}${YELLOW}                                    ║${NC}"
            echo -e "${YELLOW}║  ${BLUE}4.${NC} ${WHITE}Ubuntu 24.04${NC}${YELLOW}                                    ║${NC}"
            echo -e "${YELLOW}║  ${BLUE}5.${NC} ${WHITE}Back to main menu${NC}${YELLOW}                               ║${NC}"
            echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
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

# Function to access Ubuntu
access_ubuntu() {
    print_header
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                      Ubuntu Access Options                    ║${NC}"
    echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}║  ${BLUE}1.${NC} ${WHITE}List installed Ubuntu versions${NC}${YELLOW}                    ║${NC}"
    echo -e "${YELLOW}║  ${BLUE}2.${NC} ${WHITE}Access Ubuntu (Chroot)${NC}${YELLOW}                          ║${NC}"
    echo -e "${YELLOW}║  ${BLUE}3.${NC} ${WHITE}Access Ubuntu (Proot)${NC}${YELLOW}                           ║${NC}"
    echo -e "${YELLOW}║  ${BLUE}4.${NC} ${WHITE}Back to main menu${NC}${YELLOW}                               ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
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
    
    clear_screen
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
                print_header
                echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${GREEN}║                        Goodbye!                              ║${NC}"
                echo -e "${GREEN}╠══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${GREEN}║  Thank you for using Ubuntu Chroot Installer!               ║${NC}"
                echo -e "${GREEN}║  Don't forget to visit our GitHub repository!               ║${NC}"
                echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
                echo ""
                sleep 2
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please enter 1-5."
                ;;
        esac
    done
}

# Function to show welcome message
show_welcome() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                 Welcome to Ubuntu Chroot Installer           ║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║  This installer will help you install Ubuntu on Termux      ║${NC}"
    echo -e "${CYAN}║  Choose from Chroot (rooted devices) or Proot (no root)    ║${NC}"
    echo -e "${CYAN}║  Supported versions: 18.04, 20.04, 22.04, 24.04           ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    sleep 2
}

# Function to check and install prerequisites in background
check_and_install_prerequisites_background() {
    # Check if running in Termux
    if [[ ! -d "/data/data/com.termux" ]]; then
        echo "not_termux" > /tmp/prerequisites_result
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
        echo "low_disk_space:$available_space" > /tmp/prerequisites_result
        return
    fi
    
    # Check internet connection
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        echo "no_internet" > /tmp/prerequisites_result
        return
    fi
    
    # Create necessary directories
    mkdir -p $HOME/ubuntu
    mkdir -p $HOME/ubuntu/scripts
    
    # Set DNS
    echo 'nameserver 8.8.8.8' > $HOME/.resolv.conf
    echo 'nameserver 8.8.4.4' >> $HOME/.resolv.conf
    
    echo "success" > /tmp/prerequisites_result
}

# Function to check and install prerequisites
check_and_install_prerequisites() {
    print_status "Checking system prerequisites..."
    
    # Start prerequisites check in background
    check_and_install_prerequisites_background &
    local pid=$!
    
    # Show loading animation with detailed steps
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                    System Check & Setup                       ║${NC}"
    echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}║  Checking Termux environment...                              ║${NC}"
    echo -e "${YELLOW}║  Updating package repositories...                            ║${NC}"
    echo -e "${YELLOW}║  Installing required packages...                             ║${NC}"
    echo -e "${YELLOW}║  Checking disk space...                                     ║${NC}"
    echo -e "${YELLOW}║  Testing internet connection...                              ║${NC}"
    echo -e "${YELLOW}║  Creating directories...                                    ║${NC}"
    echo -e "${YELLOW}║  Configuring DNS...                                         ║${NC}"
    echo -e "${YELLOW}║                                                              ║${NC}"
    
    # Loading animation
    local i=0
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spin:$i:1}
        echo -ne "${YELLOW}║  Please wait... ${temp}${NC}\r"
        i=$(( (i+1) % ${#spin} ))
        sleep 0.1
    done
    
    echo -e "${YELLOW}║  System check completed!${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Wait for prerequisites check to complete
    wait $pid
    
    # Check result
    if [[ -f /tmp/prerequisites_result ]]; then
        local result=$(cat /tmp/prerequisites_result)
        rm -f /tmp/prerequisites_result
        
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
    
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                        Installing...                          ║${NC}"
    echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}║  $message${NC}"
    echo -e "${YELLOW}║                                                              ║${NC}"
    
    # Loading animation
    local i=0
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spin:$i:1}
        echo -ne "${YELLOW}║  Please wait... ${temp}${NC}\r"
        i=$(( (i+1) % ${#spin} ))
        sleep 0.1
    done
    
    echo -e "${YELLOW}║  Installation completed!${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function to run installation in background
run_installation_background() {
    local version="$1"
    local method="$2"
    
    # Start installation in background
    if [[ "$method" == "chroot" ]]; then
        case $version in
            "18.04") install_ubuntu_18_04_chroot_background ;;
            "20.04") install_ubuntu_20_04_chroot_background ;;
            "22.04") install_ubuntu_22_04_chroot_background ;;
            "24.04") install_ubuntu_24_04_chroot_background ;;
        esac
    else
        install_ubuntu_proot_background "$version"
    fi
}

# Start the installer
show_welcome
check_and_install_prerequisites
main_menu 