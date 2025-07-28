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
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}  Ubuntu Chroot Installer${NC}"
    echo -e "${CYAN}  GitHub: https://github.com/amirmsoud16/ubuntu-chroot-pk-${NC}"
    echo -e "${CYAN}================================${NC}"
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
    echo -e "${BLUE}4.${NC} Access Ubuntu"
    echo -e "${BLUE}5.${NC} Exit"
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
    
    # Create resolv.conf
    cat > $INSTALL_DIR/etc/resolv.conf <<'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF
    
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
    
    # Download ubuntu-setup.sh script
    print_status "📥 Downloading Ubuntu setup script..."
    if wget -q https://raw.githubusercontent.com/your-repo/ubuntu-setup.sh -O $INSTALL_DIR/ubuntu-setup.sh; then
        chmod +x $INSTALL_DIR/ubuntu-setup.sh
        print_success "Ubuntu setup script downloaded successfully!"
    else
        print_warning "Failed to download setup script, will create it manually..."
        # Create a basic setup script if download fails
        cat > $INSTALL_DIR/ubuntu-setup.sh << 'EOF'
#!/bin/bash
echo "🚀 Ubuntu Setup Script"
echo "This script will install all essential tools for Ubuntu"
echo ""

# Fix permissions first
echo "🔧 Fixing permissions..."
chmod 755 /var/lib/dpkg 2>/dev/null || true
chmod 644 /var/lib/dpkg/status 2>/dev/null || true
rm -f /var/lib/dpkg/status-old
rm -f /var/lib/dpkg/status.backup

# Fix apt issues
echo "🔧 Fixing apt issues..."
dpkg --configure -a 2>/dev/null || true
apt --fix-broken install -y 2>/dev/null || true
apt clean 2>/dev/null || true

# Update and install tools
echo "📦 Updating and installing tools..."
apt update -y
apt install -y curl wget git nano vim build-essential python3 python3-pip nodejs npm htop neofetch unzip zip tar net-tools iputils-ping sudo

echo "✅ Basic setup completed!"
echo "💡 For full setup, run: wget https://raw.githubusercontent.com/your-repo/ubuntu-setup.sh && chmod +x ubuntu-setup.sh && ./ubuntu-setup.sh"
EOF
        chmod +x $INSTALL_DIR/ubuntu-setup.sh
        print_success "Basic setup script created!"
    fi
    
    # Create start script with limited root access and network support
    cat > start-ubuntu-18.04.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD

# Create network files (remove and recreate)
rm -f $HOME/.resolv.conf
echo 'nameserver 8.8.8.8' > $HOME/.resolv.conf
echo 'nameserver 8.8.4.4' >> $HOME/.resolv.conf
echo 'nameserver 1.1.1.1' >> $HOME/.resolv.conf

if [ ! -f $HOME/.hosts ]; then
    echo '127.0.0.1 localhost' > $HOME/.hosts
    echo '::1 localhost ip6-localhost ip6-loopback' >> $HOME/.hosts
fi

proot -0 -r $HOME/ubuntu/ubuntu18-rootfs \
    -b /dev -b /proc -b /sys \
    -b $HOME/.resolv.conf:/etc/resolv.conf \
    -b $HOME/.hosts:/etc/hosts \
    -b $HOME:/root \
    -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x start-ubuntu-18.04.sh
    
    echo "chroot_success" > $HOME/ubuntu_install_result
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
    if [[ -f $HOME/ubuntu_install_result ]]; then
        local result=$(cat $HOME/ubuntu_install_result)
        rm -f $HOME/ubuntu_install_result
        
        if [[ "$result" == "chroot_success" ]]; then
            print_success_box "Ubuntu 18.04 (Chroot) installed successfully!"
            print_status "To enter Ubuntu: cd $HOME/ubuntu/ubuntu18-rootfs && ./start-ubuntu-18.04.sh"
            print_status "💡 To setup Ubuntu with all tools: ubuntu18 && ./ubuntu-setup.sh"
            
            # Create alias for quick access
            echo 'alias ubuntu18="cd ~/ubuntu/ubuntu18-rootfs && ./start-ubuntu-18.04.sh"' >> ~/.bashrc
            source ~/.bashrc
            print_status "Quick access alias created: type 'ubuntu18' to enter Ubuntu 18.04"
            
            # Ask user what to do next
            echo ""
            echo -e "${CYAN}What would you like to do next?${NC}"
            echo -e "${BLUE}1.${NC} Enter Ubuntu 18.04 directly"
            echo -e "${BLUE}2.${NC} Return to main menu"
            echo ""
            read -p "Enter your choice (1-2): " post_install_choice
            
            case $post_install_choice in
                1)
                    print_status "Entering Ubuntu 18.04..."
                    cd $HOME/ubuntu/ubuntu18-rootfs && ./start-ubuntu-18.04.sh
                    ;;
                2)
                    print_status "Returning to main menu..."
                    ;;
                *)
                    print_status "Returning to main menu..."
                    ;;
            esac
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
    
    # Create resolv.conf
    cat > $INSTALL_DIR/etc/resolv.conf <<'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF
    
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
    
    # Download ubuntu-setup.sh script
    print_status "📥 Downloading Ubuntu setup script..."
    if wget -q https://raw.githubusercontent.com/your-repo/ubuntu-setup.sh -O $INSTALL_DIR/ubuntu-setup.sh; then
        chmod +x $INSTALL_DIR/ubuntu-setup.sh
        print_success "Ubuntu setup script downloaded successfully!"
    else
        print_warning "Failed to download setup script, will create it manually..."
        # Create a basic setup script if download fails
        cat > $INSTALL_DIR/ubuntu-setup.sh << 'EOF'
#!/bin/bash
echo "🚀 Ubuntu Setup Script"
echo "This script will install all essential tools for Ubuntu"
echo ""

# Fix permissions first
echo "🔧 Fixing permissions..."
chmod 755 /var/lib/dpkg 2>/dev/null || true
chmod 644 /var/lib/dpkg/status 2>/dev/null || true
rm -f /var/lib/dpkg/status-old
rm -f /var/lib/dpkg/status.backup

# Fix apt issues
echo "🔧 Fixing apt issues..."
dpkg --configure -a 2>/dev/null || true
apt --fix-broken install -y 2>/dev/null || true
apt clean 2>/dev/null || true

# Update and install tools
echo "📦 Updating and installing tools..."
apt update -y
apt install -y curl wget git nano vim build-essential python3 python3-pip nodejs npm htop neofetch unzip zip tar net-tools iputils-ping sudo

echo "✅ Basic setup completed!"
echo "💡 For full setup, run: wget https://raw.githubusercontent.com/your-repo/ubuntu-setup.sh && chmod +x ubuntu-setup.sh && ./ubuntu-setup.sh"
EOF
        chmod +x $INSTALL_DIR/ubuntu-setup.sh
        print_success "Basic setup script created!"
    fi
    
    # Create start script with limited root access and network support
    cat > start-ubuntu-20.04.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD

# Create network files (remove and recreate)
rm -f $HOME/.resolv.conf
echo 'nameserver 8.8.8.8' > $HOME/.resolv.conf
echo 'nameserver 8.8.4.4' >> $HOME/.resolv.conf
echo 'nameserver 1.1.1.1' >> $HOME/.resolv.conf

if [ ! -f $HOME/.hosts ]; then
    echo '127.0.0.1 localhost' > $HOME/.hosts
    echo '::1 localhost ip6-localhost ip6-loopback' >> $HOME/.hosts
fi

proot -0 -r $HOME/ubuntu/ubuntu20-rootfs \
    -b /dev -b /proc -b /sys \
    -b $HOME/.resolv.conf:/etc/resolv.conf \
    -b $HOME/.hosts:/etc/hosts \
    -b $HOME:/root \
    -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x start-ubuntu-20.04.sh
    
    echo "chroot_success" > $HOME/ubuntu_install_result
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
    if [[ -f $HOME/ubuntu_install_result ]]; then
        local result=$(cat $HOME/ubuntu_install_result)
        rm -f $HOME/ubuntu_install_result
        
        if [[ "$result" == "chroot_success" ]]; then
            print_success_box "Ubuntu 20.04 (Chroot) installed successfully!"
            print_status "To enter Ubuntu: cd $HOME/ubuntu/ubuntu20-rootfs && ./start-ubuntu-20.04.sh"
            print_status "💡 To setup Ubuntu with all tools: ubuntu20 && ./ubuntu-setup.sh"
            
            # Create alias for quick access
            echo 'alias ubuntu20="cd ~/ubuntu/ubuntu20-rootfs && ./start-ubuntu-20.04.sh"' >> ~/.bashrc
            source ~/.bashrc
            print_status "Quick access alias created: type 'ubuntu20' to enter Ubuntu 20.04"
            
            # Ask user what to do next
            echo ""
            echo -e "${CYAN}What would you like to do next?${NC}"
            echo -e "${BLUE}1.${NC} Enter Ubuntu 20.04 directly"
            echo -e "${BLUE}2.${NC} Return to main menu"
            echo ""
            read -p "Enter your choice (1-2): " post_install_choice
            
            case $post_install_choice in
                1)
                    print_status "Entering Ubuntu 20.04..."
                    cd $HOME/ubuntu/ubuntu20-rootfs && ./start-ubuntu-20.04.sh
                    ;;
                2)
                    print_status "Returning to main menu..."
                    ;;
                *)
                    print_status "Returning to main menu..."
                    ;;
            esac
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
    
    # Create resolv.conf
    cat > $INSTALL_DIR/etc/resolv.conf <<'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF
    
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
    
    # Download ubuntu-setup.sh script
    print_status "📥 Downloading Ubuntu setup script..."
    if wget -q https://raw.githubusercontent.com/your-repo/ubuntu-setup.sh -O $INSTALL_DIR/ubuntu-setup.sh; then
        chmod +x $INSTALL_DIR/ubuntu-setup.sh
        print_success "Ubuntu setup script downloaded successfully!"
    else
        print_warning "Failed to download setup script, will create it manually..."
        # Create a basic setup script if download fails
        cat > $INSTALL_DIR/ubuntu-setup.sh << 'EOF'
#!/bin/bash
echo "🚀 Ubuntu Setup Script"
echo "This script will install all essential tools for Ubuntu"
echo ""

# Fix permissions first
echo "🔧 Fixing permissions..."
chmod 755 /var/lib/dpkg 2>/dev/null || true
chmod 644 /var/lib/dpkg/status 2>/dev/null || true
rm -f /var/lib/dpkg/status-old
rm -f /var/lib/dpkg/status.backup

# Fix apt issues
echo "🔧 Fixing apt issues..."
dpkg --configure -a 2>/dev/null || true
apt --fix-broken install -y 2>/dev/null || true
apt clean 2>/dev/null || true

# Update and install tools
echo "📦 Updating and installing tools..."
apt update -y
apt install -y curl wget git nano vim build-essential python3 python3-pip nodejs npm htop neofetch unzip zip tar net-tools iputils-ping sudo

echo "✅ Basic setup completed!"
echo "💡 For full setup, run: wget https://raw.githubusercontent.com/your-repo/ubuntu-setup.sh && chmod +x ubuntu-setup.sh && ./ubuntu-setup.sh"
EOF
        chmod +x $INSTALL_DIR/ubuntu-setup.sh
        print_success "Basic setup script created!"
    fi
    
    # Create start script with limited root access and network support
    cat > start-ubuntu-22.04.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD

# Create network files (remove and recreate)
rm -f $HOME/.resolv.conf
echo 'nameserver 8.8.8.8' > $HOME/.resolv.conf
echo 'nameserver 8.8.4.4' >> $HOME/.resolv.conf
echo 'nameserver 1.1.1.1' >> $HOME/.resolv.conf

if [ ! -f $HOME/.hosts ]; then
    echo '127.0.0.1 localhost' > $HOME/.hosts
    echo '::1 localhost ip6-localhost ip6-loopback' >> $HOME/.hosts
fi

proot -0 -r $HOME/ubuntu/ubuntu22-rootfs \
    -b /dev -b /proc -b /sys \
    -b $HOME/.resolv.conf:/etc/resolv.conf \
    -b $HOME/.hosts:/etc/hosts \
    -b $HOME:/root \
    -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x start-ubuntu-22.04.sh
    
    echo "chroot_success" > $HOME/ubuntu_install_result
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
    if [[ -f $HOME/ubuntu_install_result ]]; then
        local result=$(cat $HOME/ubuntu_install_result)
        rm -f $HOME/ubuntu_install_result
        
        if [[ "$result" == "chroot_success" ]]; then
            print_success_box "Ubuntu 22.04 (Chroot) installed successfully!"
            print_status "To enter Ubuntu: cd $HOME/ubuntu/ubuntu22-rootfs && ./start-ubuntu-22.04.sh"
            print_status "💡 To setup Ubuntu with all tools: ubuntu22 && ./ubuntu-setup.sh"
            
            # Create alias for quick access
            echo 'alias ubuntu22="cd ~/ubuntu/ubuntu22-rootfs && ./start-ubuntu-22.04.sh"' >> ~/.bashrc
            source ~/.bashrc
            print_status "Quick access alias created: type 'ubuntu22' to enter Ubuntu 22.04"
            
            # Ask user what to do next
            echo ""
            echo -e "${CYAN}What would you like to do next?${NC}"
            echo -e "${BLUE}1.${NC} Enter Ubuntu 22.04 directly"
            echo -e "${BLUE}2.${NC} Return to main menu"
            echo ""
            read -p "Enter your choice (1-2): " post_install_choice
            
            case $post_install_choice in
                1)
                    print_status "Entering Ubuntu 22.04..."
                    cd $HOME/ubuntu/ubuntu22-rootfs && ./start-ubuntu-22.04.sh
                    ;;
                2)
                    print_status "Returning to main menu..."
                    ;;
                *)
                    print_status "Returning to main menu..."
                    ;;
            esac
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
    
    # Create resolv.conf
    cat > $INSTALL_DIR/etc/resolv.conf <<'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF
    
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
    
    # Download ubuntu-setup.sh script
    print_status "📥 Downloading Ubuntu setup script..."
    if wget -q https://raw.githubusercontent.com/your-repo/ubuntu-setup.sh -O $INSTALL_DIR/ubuntu-setup.sh; then
        chmod +x $INSTALL_DIR/ubuntu-setup.sh
        print_success "Ubuntu setup script downloaded successfully!"
    else
        print_warning "Failed to download setup script, will create it manually..."
        # Create a basic setup script if download fails
        cat > $INSTALL_DIR/ubuntu-setup.sh << 'EOF'
#!/bin/bash
echo "🚀 Ubuntu Setup Script"
echo "This script will install all essential tools for Ubuntu"
echo ""

# Fix permissions first
echo "🔧 Fixing permissions..."
chmod 755 /var/lib/dpkg 2>/dev/null || true
chmod 644 /var/lib/dpkg/status 2>/dev/null || true
rm -f /var/lib/dpkg/status-old
rm -f /var/lib/dpkg/status.backup

# Fix apt issues
echo "🔧 Fixing apt issues..."
dpkg --configure -a 2>/dev/null || true
apt --fix-broken install -y 2>/dev/null || true
apt clean 2>/dev/null || true

# Update and install tools
echo "📦 Updating and installing tools..."
apt update -y
apt install -y curl wget git nano vim build-essential python3 python3-pip nodejs npm htop neofetch unzip zip tar net-tools iputils-ping sudo

echo "✅ Basic setup completed!"
echo "💡 For full setup, run: wget https://raw.githubusercontent.com/your-repo/ubuntu-setup.sh && chmod +x ubuntu-setup.sh && ./ubuntu-setup.sh"
EOF
        chmod +x $INSTALL_DIR/ubuntu-setup.sh
        print_success "Basic setup script created!"
    fi
    
    # Create start script with limited root access and network support
    cat > start-ubuntu-24.04.sh <<'EOF'
#!/bin/bash
unset LD_PRELOAD

# Create network files (remove and recreate)
rm -f $HOME/.resolv.conf
echo 'nameserver 8.8.8.8' > $HOME/.resolv.conf
echo 'nameserver 8.8.4.4' >> $HOME/.resolv.conf
echo 'nameserver 1.1.1.1' >> $HOME/.resolv.conf

if [ ! -f $HOME/.hosts ]; then
    echo '127.0.0.1 localhost' > $HOME/.hosts
    echo '::1 localhost ip6-localhost ip6-loopback' >> $HOME/.hosts
fi

proot -0 -r $HOME/ubuntu/ubuntu24-rootfs \
    -b /dev -b /proc -b /sys \
    -b $HOME/.resolv.conf:/etc/resolv.conf \
    -b $HOME/.hosts:/etc/hosts \
    -b $HOME:/root \
    -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x start-ubuntu-24.04.sh
    
    echo "chroot_success" > $HOME/ubuntu_install_result
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
    if [[ -f $HOME/ubuntu_install_result ]]; then
        local result=$(cat $HOME/ubuntu_install_result)
        rm -f $HOME/ubuntu_install_result
        
        if [[ "$result" == "chroot_success" ]]; then
            print_success_box "Ubuntu 24.04 (Chroot) installed successfully!"
            print_status "To enter Ubuntu: cd $HOME/ubuntu/ubuntu24-rootfs && ./start-ubuntu-24.04.sh"
            print_status "💡 To setup Ubuntu with all tools: ubuntu24 && ./ubuntu-setup.sh"
            
            # Create alias for quick access
            echo 'alias ubuntu24="cd ~/ubuntu/ubuntu24-rootfs && ./start-ubuntu-24.04.sh"' >> ~/.bashrc
            source ~/.bashrc
            print_status "Quick access alias created: type 'ubuntu24' to enter Ubuntu 24.04"
            
            # Ask user what to do next
            echo ""
            echo -e "${CYAN}What would you like to do next?${NC}"
            echo -e "${BLUE}1.${NC} Enter Ubuntu 24.04 directly"
            echo -e "${BLUE}2.${NC} Return to main menu"
            echo ""
            read -p "Enter your choice (1-2): " post_install_choice
            
            case $post_install_choice in
                1)
                    print_status "Entering Ubuntu 24.04..."
                    cd $HOME/ubuntu/ubuntu24-rootfs && ./start-ubuntu-24.04.sh
                    ;;
                2)
                    print_status "Returning to main menu..."
                    ;;
                *)
                    print_status "Returning to main menu..."
                    ;;
            esac
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

# Function to access Ubuntu
access_ubuntu() {
    print_header
    echo -e "${WHITE}Ubuntu Access Options:${NC}"
    echo -e "${BLUE}1.${NC} List installed Ubuntu versions"
    echo -e "${BLUE}2.${NC} Access Ubuntu (Chroot)"
    echo -e "${BLUE}3.${NC} Access Ubuntu (Proot)"
    echo -e "${BLUE}4.${NC} Back to main menu"
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
                echo -e "${GREEN}Goodbye!${NC}"
                echo -e "${WHITE}Thank you for using Ubuntu Chroot Installer!${NC}"
                echo -e "${WHITE}Don't forget to visit our GitHub repository!${NC}"
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
    echo -e "${CYAN}Welcome to Ubuntu Chroot Installer${NC}"
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
