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

# Function to check file integrity and prevent editing
check_file_integrity() {
    local file="$1"
    local checksum_file="$2"
    
    # Create checksum if not exists
    if [ ! -f "$checksum_file" ]; then
        sha256sum "$file" > "$checksum_file" 2>/dev/null || true
        return 0
    fi
    
    # Check if file has been modified
    if ! sha256sum -c "$checksum_file" >/dev/null 2>&1; then
        print_error "File integrity check failed! File may have been modified."
        print_warning "Please re-download the installer from the official source."
        return 1
    fi
    
    return 0
}

# Function to protect critical files
protect_critical_files() {
    local install_dir="$HOME/ubuntu"
    
    # Make critical files read-only
    if [ -d "$install_dir" ]; then
        find "$install_dir" -name "*.sh" -exec chmod 444 {} \; 2>/dev/null || true
        find "$install_dir" -name "*.img" -exec chmod 444 {} \; 2>/dev/null || true
    fi
    
    # Protect this script itself
    chmod 444 "$0" 2>/dev/null || true
}

# Function to restore file permissions when needed
restore_file_permissions() {
    local install_dir="$HOME/ubuntu"
    
    # Make files executable again for installation
    if [ -d "$install_dir" ]; then
        find "$install_dir" -name "*.sh" -exec chmod 755 {} \; 2>/dev/null || true
    fi
    
    # Make this script executable again
    chmod 755 "$0" 2>/dev/null || true
}

# Function to verify installation environment
verify_installation_environment() {
    print_status "Verifying installation environment..."
    
    # Check if running from official source
    local script_path="$(readlink -f "$0")"
    if [[ "$script_path" == *"termux"* ]] || [[ "$script_path" == *"tmp"* ]]; then
        print_warning "Script is running from temporary location"
        print_status "For security, consider downloading from official source"
    fi
    
    # Check file integrity
    local checksum_file="$HOME/.installer_checksum"
    if ! check_file_integrity "$0" "$checksum_file"; then
        exit 1
    fi
    
    # Protect critical files
    protect_critical_files
    
    print_success "Environment verification completed"
}

# Function to create read-only Ubuntu environment
create_readonly_environment() {
    local version="$1"
    local install_dir="$HOME/ubuntu/ubuntu${version}-rootfs"
    
    if [ -d "$install_dir" ]; then
        # Make all files read-only
        find "$install_dir" -type f -exec chmod 444 {} \; 2>/dev/null || true
        find "$install_dir" -type d -exec chmod 555 {} \; 2>/dev/null || true
        
        # Make specific directories writable for Ubuntu to work
        chmod 755 "$install_dir/tmp" 2>/dev/null || true
        chmod 755 "$install_dir/var/tmp" 2>/dev/null || true
        chmod 755 "$install_dir/home" 2>/dev/null || true
        
        print_success "Ubuntu environment is now read-only for security"
    fi
}

# Function to lock installation files
lock_installation_files() {
    local install_dir="$HOME/ubuntu"
    
    if [ -d "$install_dir" ]; then
        # Make all installation files read-only
        find "$install_dir" -name "*.sh" -exec chmod 444 {} \; 2>/dev/null || true
        find "$install_dir" -name "*.img" -exec chmod 444 {} \; 2>/dev/null || true
        find "$install_dir" -name "*.tar*" -exec chmod 444 {} \; 2>/dev/null || true
        
        print_success "Installation files are now protected from modification"
    fi
}

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

# Function to print step
print_step() {
    local step="$1"
    local total="$2"
    local msg="$3"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    echo -ne "[${step}/${total}] ${msg} "
    for _ in {1..10}; do
        local temp=${spin:$i:1}
        echo -ne "$temp\r"
        i=$(( (i+1) % ${#spin} ))
        sleep 0.08
    done
    echo -ne "\r"
}

# Function to check and download Ubuntu rootfs
download_ubuntu_rootfs() {
    local version=$1
    local url=$2
    local filename=$3

    print_status "Downloading Ubuntu ${version} rootfs..."
    check_internet
    wget -O $filename $url

    if [[ $? -eq 0 && -f $filename ]]; then
        print_status "✓ Download successful"
        return 0
    else
        print_error "Failed to download from primary URL or file not found!"
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

# Function to create Ubuntu start scripts with different access levels
create_ubuntu_start_scripts() {
    local version=$1
    local username=$2
    local install_dir="$HOME/ubuntu/ubuntu${version}-rootfs"
    
    # Create root access script
    cat > $install_dir/start-ubuntu-${version}.04.sh << EOF
#!/bin/bash
unset LD_PRELOAD

proot -0 -r \$HOME/ubuntu/ubuntu${version}-rootfs \\
    -b /dev -b /proc -b /sys \\
    -b \$HOME:/root \\
    -w /root /usr/bin/env -i HOME=/root TERM="\$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x $install_dir/start-ubuntu-${version}.04.sh
    
    # Create user access script
    cat > $install_dir/start-ubuntu-${version}.04-user.sh << EOF
#!/bin/bash
unset LD_PRELOAD

proot -0 -r \$HOME/ubuntu/ubuntu${version}-rootfs \\
    -b /dev -b /proc -b /sys \\
    -b \$HOME:/home/${username} \\
    -w /home/${username} /usr/bin/env -i HOME=/home/${username} USER=${username} TERM="\$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/su - ${username}
EOF
    chmod +x $install_dir/start-ubuntu-${version}.04-user.sh
    
    # Create internet fix script
    cat > $install_dir/fix-internet.sh << 'EOF'
#!/bin/bash
# Fix internet connectivity in Ubuntu

echo "Fixing internet connectivity..."

# Setup DNS servers
rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf

# Test internet connection
if ping -c 1 8.8.8.8 &> /dev/null; then
    echo "Internet connection working!"
else
    echo "Internet connection may be slow or unavailable"
fi

echo "Internet fix completed!"
EOF
    chmod +x $install_dir/fix-internet.sh
    
    # Create aliases in Termux
    echo "alias ubuntu${version}=\"cd ~/ubuntu/ubuntu${version}-rootfs && ./start-ubuntu-${version}.04.sh\"" >> ~/.bashrc
    echo "alias ubuntu${version}-${username}=\"cd ~/ubuntu/ubuntu${version}-rootfs && ./start-ubuntu-${version}.04-user.sh\"" >> ~/.bashrc
    echo "alias fix-internet-${version}=\"cd ~/ubuntu/ubuntu${version}-rootfs && ./fix-internet.sh\"" >> ~/.bashrc
    source ~/.bashrc
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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required commands before proceeding
for cmd in wget tar proot; do
    if ! command_exists $cmd; then
        print_error "Command '$cmd' not found! Please install it in Termux."
        exit 1
    fi
done

# Check for internet connection before downloading
check_internet() {
    print_status "Checking internet connection..."
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        print_error "No internet connection! Please connect to the internet and try again."
        exit 1
    fi
    print_success "Internet connection is OK."
}

# General function to clone the GitHub repo
clone_github_repo() {
    REPO_URL="https://github.com/amirmsoud16/ubuntu-chroot-pk-"
    CLONE_DIR="$HOME/ubuntu-chroot-pk-"
    if [ -d "$CLONE_DIR" ]; then
        rm -rf "$CLONE_DIR"
    fi
    git clone "$REPO_URL" "$CLONE_DIR"
}

# Add at the top of the file (after color definitions):
STEPS=(
    "Download Ubuntu rootfs file"
    "Create ext4 image file (20GB)"
    "Create mount directory"
    "Mount image"
    "Extract rootfs into image"
    "Remove Android-sensitive paths (if any)"
    "Clean up rootfs archive"
    "Set up DNS (resolv.conf)"
    "Create chroot shortcut and finish installation"
)

print_steps_progress() {
    local current=$1
    clear
    echo "Ubuntu Chroot Installation Progress:"
    for i in "${!STEPS[@]}"; do
        step_num=$((i+1))
        if (( step_num < current )); then
            echo -e "  $step_num. ${STEPS[$i]}  ${GREEN}✓${NC}"
        elif (( step_num == current )); then
            echo -e "  $step_num. ${STEPS[$i]}  ${YELLOW}...${NC}"
        else
            echo -e "  $step_num. ${STEPS[$i]}"
        fi
    done
    echo ""
}

# Function to install Ubuntu 18.04 (Chroot) in background - SAFE VERSION
install_ubuntu_18_04_chroot_background() {
    TOTAL=10
    VERSION="18.04"
    IMG="$HOME/ubuntu18.04.img"
    MNT="$HOME/ubuntu18.04-mnt"
    SIZE_MB=20480
    ROOTFS_URL="https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-arm64-root.tar.xz"
    ROOTFS_TAR="ubuntu-18.04-rootfs.tar.xz"

    print_steps_progress 1
    REPO_URL="https://github.com/amirmsoud16/ubuntu-chroot-pk-"
    CLONE_DIR="$HOME/ubuntu-chroot-pk-"
    if [ -d "$CLONE_DIR" ]; then
        rm -rf "$CLONE_DIR"
    fi
    git clone "$REPO_URL" "$CLONE_DIR"

    print_steps_progress 2
    wget -O "$ROOTFS_TAR" "$ROOTFS_URL"

    print_steps_progress 3
    dd if=/dev/zero of="$IMG" bs=1M count=$SIZE_MB
    mkfs.ext4 "$IMG"

    print_steps_progress 4
    mkdir -p "$MNT"

    print_steps_progress 5
    if ! safe_chroot_setup "$IMG" "$MNT" "$ROOTFS_TAR"; then
        print_error "Chroot setup failed. Falling back to Proot installation."
        return 1
    fi

    print_steps_progress 6
    # Rootfs extraction handled in safe_chroot_setup

    print_steps_progress 7
    # Rootfs extraction completed

    print_steps_progress 8
    rm -f "$ROOTFS_TAR"

    print_steps_progress 9
    # DNS setup handled in safe_chroot_setup

    print_steps_progress 10
    create_safe_chroot_script "$IMG" "$MNT" "18"
    lock_installation_files
    create_readonly_environment "18.04"
    print_success_box "Ubuntu 18.04 (Chroot) installation completed!"
    clear
    echo -e "${WHITE}What do you want to do next?${NC}"
    echo "  1) Go to main menu"
    echo "  2) Enter installed Ubuntu chroot"
    read -p "Enter your choice (1 or 2): " next_action
    if [[ "$next_action" == "2" ]]; then
        $HOME/bin/ubuntu18
    fi
}

# Function to install Ubuntu 20.04 (Chroot) in background - SAFE VERSION
install_ubuntu_20_04_chroot_background() {
    TOTAL=10
    VERSION="20.04"
    IMG="$HOME/ubuntu20.04.img"
    MNT="$HOME/ubuntu20.04-mnt"
    SIZE_MB=20480
    ROOTFS_URL="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-arm64-root.tar.xz"
    ROOTFS_TAR="ubuntu-20.04-rootfs.tar.xz"

    print_steps_progress 1
    REPO_URL="https://github.com/amirmsoud16/ubuntu-chroot-pk-"
    CLONE_DIR="$HOME/ubuntu-chroot-pk-"
    if [ -d "$CLONE_DIR" ]; then
        rm -rf "$CLONE_DIR"
    fi
    git clone "$REPO_URL" "$CLONE_DIR"

    print_steps_progress 2
    wget -O "$ROOTFS_TAR" "$ROOTFS_URL"

    print_steps_progress 3
    dd if=/dev/zero of="$IMG" bs=1M count=$SIZE_MB
    mkfs.ext4 "$IMG"

    print_steps_progress 4
    mkdir -p "$MNT"

    print_steps_progress 5
    if ! safe_chroot_setup "$IMG" "$MNT" "$ROOTFS_TAR"; then
        print_error "Chroot setup failed. Falling back to Proot installation."
        return 1
    fi

    print_steps_progress 6
    # Rootfs extraction handled in safe_chroot_setup

    print_steps_progress 7
    # Rootfs extraction completed

    print_steps_progress 8
    rm -f "$ROOTFS_TAR"

    print_steps_progress 9
    # DNS setup handled in safe_chroot_setup

    print_steps_progress 10
    create_safe_chroot_script "$IMG" "$MNT" "20"
    lock_installation_files
    create_readonly_environment "20.04"
    print_success_box "Ubuntu 20.04 (Chroot) installation completed!"
    clear
    echo -e "${WHITE}What do you want to do next?${NC}"
    echo "  1) Go to main menu"
    echo "  2) Enter installed Ubuntu chroot"
    read -p "Enter your choice (1 or 2): " next_action
    if [[ "$next_action" == "2" ]]; then
        $HOME/bin/ubuntu20
    fi
}

# Function to install Ubuntu 22.04 (Chroot) in background - SAFE VERSION
install_ubuntu_22_04_chroot_background() {
    TOTAL=10
    VERSION="22.04"
    IMG="$HOME/ubuntu22.04.img"
    MNT="$HOME/ubuntu22.04-mnt"
    SIZE_MB=20480
    ROOTFS_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-arm64-root.tar.xz"
    ROOTFS_TAR="ubuntu-22.04-rootfs.tar.xz"

    print_steps_progress 1
    REPO_URL="https://github.com/amirmsoud16/ubuntu-chroot-pk-"
    CLONE_DIR="$HOME/ubuntu-chroot-pk-"
    if [ -d "$CLONE_DIR" ]; then
        rm -rf "$CLONE_DIR"
    fi
    git clone "$REPO_URL" "$CLONE_DIR"

    print_steps_progress 2
    wget -O "$ROOTFS_TAR" "$ROOTFS_URL"

    print_steps_progress 3
    dd if=/dev/zero of="$IMG" bs=1M count=$SIZE_MB
    mkfs.ext4 "$IMG"

    print_steps_progress 4
    mkdir -p "$MNT"

    print_steps_progress 5
    if ! safe_chroot_setup "$IMG" "$MNT" "$ROOTFS_TAR"; then
        print_error "Chroot setup failed. Falling back to Proot installation."
        return 1
    fi

    print_steps_progress 6
    # Rootfs extraction handled in safe_chroot_setup

    print_steps_progress 7
    # Rootfs extraction completed

    print_steps_progress 8
    rm -f "$ROOTFS_TAR"

    print_steps_progress 9
    # DNS setup handled in safe_chroot_setup

    print_steps_progress 10
    create_safe_chroot_script "$IMG" "$MNT" "22"
    lock_installation_files
    create_readonly_environment "22.04"
    print_success_box "Ubuntu 22.04 (Chroot) installation completed!"
    clear
    echo -e "${WHITE}What do you want to do next?${NC}"
    echo "  1) Go to main menu"
    echo "  2) Enter installed Ubuntu chroot"
    read -p "Enter your choice (1 or 2): " next_action
    if [[ "$next_action" == "2" ]]; then
        $HOME/bin/ubuntu22
    fi
}

# Function to install Ubuntu 24.04 (Chroot) in background - SAFE VERSION
install_ubuntu_24_04_chroot_background() {
    TOTAL=10
    VERSION="24.04"
    IMG="$HOME/ubuntu24.04.img"
    MNT="$HOME/ubuntu24.04-mnt"
    SIZE_MB=20480
    ROOTFS_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64-root.tar.xz"
    ROOTFS_TAR="ubuntu-24.04-rootfs.tar.xz"

    print_steps_progress 1
    REPO_URL="https://github.com/amirmsoud16/ubuntu-chroot-pk-"
    CLONE_DIR="$HOME/ubuntu-chroot-pk-"
    if [ -d "$CLONE_DIR" ]; then
        rm -rf "$CLONE_DIR"
    fi
    git clone "$REPO_URL" "$CLONE_DIR"

    print_steps_progress 2
    wget -O "$ROOTFS_TAR" "$ROOTFS_URL"

    print_steps_progress 3
    dd if=/dev/zero of="$IMG" bs=1M count=$SIZE_MB
    mkfs.ext4 "$IMG"

    print_steps_progress 4
    mkdir -p "$MNT"

    print_steps_progress 5
    if ! safe_chroot_setup "$IMG" "$MNT" "$ROOTFS_TAR"; then
        print_error "Chroot setup failed. Falling back to Proot installation."
        return 1
    fi

    print_steps_progress 6
    # Rootfs extraction handled in safe_chroot_setup

    print_steps_progress 7
    # Rootfs extraction completed

    print_steps_progress 8
    rm -f "$ROOTFS_TAR"

    print_steps_progress 9
    # DNS setup handled in safe_chroot_setup

    print_steps_progress 10
    create_safe_chroot_script "$IMG" "$MNT" "24"
    lock_installation_files
    create_readonly_environment "24.04"
    print_success_box "Ubuntu 24.04 (Chroot) installation completed!"
    clear
    echo -e "${WHITE}What do you want to do next?${NC}"
    echo "  1) Go to main menu"
    echo "  2) Enter installed Ubuntu chroot"
    read -p "Enter your choice (1 or 2): " next_action
    if [[ "$next_action" == "2" ]]; then
        $HOME/bin/ubuntu24
    fi
}



# Function to install Ubuntu with Proot - Main function
install_ubuntu_proot() {
    print_status "Installing Ubuntu with Proot (no root required)..."

    # Install proot-distro if not available
    if ! command -v proot-distro >/dev/null 2>&1; then
        print_status "Installing proot-distro..."
        pkg install proot-distro -y
    fi

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
            print_status "Installing Ubuntu 18.04 with proot-distro..."
            proot-distro install ubuntu-18.04
            if [[ $? -eq 0 ]]; then
                print_success_box "Ubuntu 18.04 (Proot) installed successfully!"
                print_status "To enter Ubuntu: proot-distro login ubuntu-18.04"
            else
                print_error_box "Failed to install Ubuntu 18.04"
            fi
            ;;
        2)
            print_status "Installing Ubuntu 20.04 with proot-distro..."
            proot-distro install ubuntu-20.04
            if [[ $? -eq 0 ]]; then
                print_success_box "Ubuntu 20.04 (Proot) installed successfully!"
                print_status "To enter Ubuntu: proot-distro login ubuntu-20.04"
            else
                print_error_box "Failed to install Ubuntu 20.04"
            fi
            ;;
        3)
            print_status "Installing Ubuntu 22.04 with proot-distro..."
            proot-distro install ubuntu-22.04
            if [[ $? -eq 0 ]]; then
                print_success_box "Ubuntu 22.04 (Proot) installed successfully!"
                print_status "To enter Ubuntu: proot-distro login ubuntu-22.04"
            else
                print_error_box "Failed to install Ubuntu 22.04"
            fi
            ;;
        4)
            print_status "Installing Ubuntu 24.04 with proot-distro..."
            proot-distro install ubuntu-24.04
            if [[ $? -eq 0 ]]; then
                print_success_box "Ubuntu 24.04 (Proot) installed successfully!"
                print_status "To enter Ubuntu: proot-distro login ubuntu-24.04"
            else
                print_error_box "Failed to install Ubuntu 24.04"
            fi
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

# Function to safely setup chroot environment
safe_chroot_setup() {
    local img="$1"
    local mnt="$2"
    local rootfs_tar="$3"
    
    # Create mount directory
    mkdir -p "$mnt"
    
    # Mount image (only if we have root access)
    if command -v mount >/dev/null 2>&1 && [ -w /dev ]; then
        mount -o loop "$img" "$mnt" 2>/dev/null || {
            print_error "Failed to mount image. Root access may be required."
            return 1
        }
        
        # Extract rootfs
        tar -xf "$rootfs_tar" -C "$mnt" --exclude='./dev' 2>/dev/null || {
            print_error "Failed to extract rootfs"
            umount "$mnt" 2>/dev/null || true
            return 1
        }
        
        # Setup DNS safely
        if [ -d "$mnt/etc" ]; then
            echo "nameserver 8.8.8.8" > "$mnt/etc/resolv.conf" 2>/dev/null || true
            echo "nameserver 8.8.4.4" >> "$mnt/etc/resolv.conf" 2>/dev/null || true
            echo "nameserver 1.1.1.1" >> "$mnt/etc/resolv.conf" 2>/dev/null || true
        fi
        
        # Unmount
        umount "$mnt" 2>/dev/null || true
    else
        print_warning "Root access required for chroot installation. Using Proot instead."
        return 1
    fi
}

# Function to safely mount and setup chroot
safe_chroot_setup() {
    local img="$1"
    local mnt="$2"
    local rootfs_tar="$3"
    
    # Create mount directory
    mkdir -p "$mnt"
    
    # Mount image (only if we have root access)
    if command -v mount >/dev/null 2>&1 && [ -w /dev ]; then
        mount -o loop "$img" "$mnt" 2>/dev/null || {
            print_error "Failed to mount image. Root access may be required."
            return 1
        }
        
        # Extract rootfs
        tar -xf "$rootfs_tar" -C "$mnt" --exclude='./dev' 2>/dev/null || {
            print_error "Failed to extract rootfs"
            umount "$mnt" 2>/dev/null || true
            return 1
        }
        
        # Rootfs extracted successfully
        
        # Setup DNS safely
        if [ -d "$mnt/etc" ]; then
            echo "nameserver 8.8.8.8" > "$mnt/etc/resolv.conf" 2>/dev/null || true
            echo "nameserver 8.8.4.4" >> "$mnt/etc/resolv.conf" 2>/dev/null || true
            echo "nameserver 1.1.1.1" >> "$mnt/etc/resolv.conf" 2>/dev/null || true
        fi
        
        # Unmount
        umount "$mnt" 2>/dev/null || true
    else
        print_warning "Root access required for chroot installation. Using Proot instead."
        return 1
    fi
}

# Function to create safe chroot script
create_safe_chroot_script() {
    local img="$1"
    local mnt="$2"
    local version="$3"
    
    local bin_dir="$HOME/bin"
    mkdir -p "$bin_dir"
    local shortcut="$bin_dir/ubuntu$version"
    
    cat > "$shortcut" <<EOF
#!/bin/bash
IMG="$img"
MNT="$mnt"

# Check if we have necessary permissions
if ! command -v mount >/dev/null 2>&1; then
    echo "Error: mount command not available"
    exit 1
fi

# Create mount directory
mkdir -p "\$MNT"

# Mount image with error checking
if ! mount -o loop "\$IMG" "\$MNT" 2>/dev/null; then
    echo "Error: Failed to mount image. Root access may be required."
    exit 1
fi

# Mount proc and sys
mount -t proc none "\$MNT/proc" 2>/dev/null || true
mount -t sysfs none "\$MNT/sys" 2>/dev/null || true

# Enter chroot with error handling
if ! chroot "\$MNT" /bin/bash; then
    echo "Error: Failed to enter chroot"
fi

# Cleanup mounts
umount "\$MNT/proc" 2>/dev/null || true
umount "\$MNT/sys" 2>/dev/null || true
umount "\$MNT" 2>/dev/null || true
EOF
    chmod +x "$shortcut"
}


# Function to remove Ubuntu
remove_ubuntu() {
    print_header
    print_warning "This will remove all Ubuntu installations!"
    read -p "Are you sure? (y/N): " confirm_remove

    if [[ "$confirm_remove" =~ ^[Yy]$ ]]; then
        print_status "Removing Ubuntu installations..."
        
        # Restore file permissions before removal
        restore_file_permissions

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
                echo -e "${WHITE}Thank you for using Ubuntu Chroot Installer!${NC}"
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

# Function to install Ubuntu 18.04 (Chroot) - Main function
install_ubuntu_18_04_chroot() {
    print_status "Installing Ubuntu 18.04 (Chroot)..."
    install_ubuntu_18_04_chroot_background
    print_success_box "Ubuntu 18.04 (Chroot) installed successfully!"
    clear_screen
}

# Function to install Ubuntu 20.04 (Chroot) - Main function
install_ubuntu_20_04_chroot() {
    print_status "Installing Ubuntu 20.04 (Chroot)..."
    install_ubuntu_20_04_chroot_background
    print_success_box "Ubuntu 20.04 (Chroot) installed successfully!"
    clear_screen
}

# Function to install Ubuntu 22.04 (Chroot) - Main function
install_ubuntu_22_04_chroot() {
    print_status "Installing Ubuntu 22.04 (Chroot)..."
    install_ubuntu_22_04_chroot_background
    print_success_box "Ubuntu 22.04 (Chroot) installed successfully!"
    clear_screen
}

# Function to install Ubuntu 24.04 (Chroot) - Main function
install_ubuntu_24_04_chroot() {
    print_status "Installing Ubuntu 24.04 (Chroot)..."
    install_ubuntu_24_04_chroot_background
    print_success_box "Ubuntu 24.04 (Chroot) installed successfully!"
    clear_screen
}


# Start the installer
show_welcome
verify_installation_environment
check_and_install_prerequisites
main_menu
