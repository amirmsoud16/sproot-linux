#!/data/data/com.termux/files/usr/bin/bash

# =============================================================================
# Ubuntu Chroot Installer for Android
# Based on: https://ivonblog.com/en-us/posts/termux-chroot-ubuntu/
# 
# Features:
# - Real chroot environment (not proot)
# - XFCE4 and KDE desktop support
# - Hardware acceleration with virglrenderer
# - SSH service support
# - One-click startup with Termux Widget
# - Complete management system
# =============================================================================

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Paths
CHROOT_PATH="/data/local/tmp/chrootubuntu"
STARTUP_SCRIPT="/data/local/tmp/startu.sh"
WIDGET_SCRIPT="$HOME/.shortcuts/start_chrootubuntu.sh"
UBUNTU_VERSION="24.04.2"
UBUNTU_CODENAME="noble"

# URLs
UBUNTU_ROOTFS_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/${UBUNTU_CODENAME}/release/ubuntu-base-${UBUNTU_VERSION}-base-arm64.tar.gz"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Check if running as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        print_error "This script must be run as root!"
        print_error "Please run: su -c './ubuntu_chroot_installer.sh'"
        exit 1
    fi
}

# Check hardware requirements
check_hardware() {
    print_step "Checking hardware requirements..."
    
    # Check RAM
    local ram_gb=$(free -g | awk '/^Mem:/{print $2}' 2>/dev/null || echo "0")
    if [ "$ram_gb" -lt 6 ]; then
        print_warn "RAM: ${ram_gb}GB (Recommended: 6GB+)"
    else
        print_info "RAM: ${ram_gb}GB ✓"
    fi
    
    # Check storage
    local storage_gb=$(df -BG /data 2>/dev/null | awk 'NR==2{print $4}' | sed 's/G//' || echo "0")
    if [ "$storage_gb" -lt 10 ]; then
        print_warn "Storage: ${storage_gb}GB (Recommended: 10GB+)"
    else
        print_info "Storage: ${storage_gb}GB ✓"
    fi
    
    # Check if device is rooted
    if ! command -v su >/dev/null 2>&1; then
        print_error "Device is not rooted! This script requires root access."
        exit 1
    fi
    
    print_success "Hardware check completed"
}

# Install required packages
install_packages() {
    print_step "Installing required packages..."
    
    # Update package list
    pkg update -y || print_warn "Package update failed, continuing..."
    
    # Install essential packages
    pkg install -y tsu pulseaudio busybox || print_warn "Some packages failed to install"
    
    # Install additional packages for better experience
    pkg install -y wget curl tar xz-utils || print_warn "Some packages failed to install"
    
    print_success "Packages installation completed"
}

# Download Ubuntu rootfs
download_ubuntu() {
    print_step "Downloading Ubuntu ${UBUNTU_VERSION} rootfs..."
    
    # Create chroot directory
    mkdir -p "$CHROOT_PATH"
    cd "$CHROOT_PATH" || {
        print_error "Failed to change to chroot directory"
        exit 1
    }
    
    # Download Ubuntu rootfs
    if [ ! -f "ubuntu-base-${UBUNTU_VERSION}-base-arm64.tar.gz" ]; then
        print_info "Downloading from: $UBUNTU_ROOTFS_URL"
        if ! busybox wget "$UBUNTU_ROOTFS_URL"; then
            print_error "Failed to download Ubuntu rootfs"
            print_error "Please check your internet connection and try again"
            exit 1
        fi
    else
        print_info "Ubuntu rootfs already downloaded"
    fi
    
    print_success "Ubuntu rootfs downloaded"
}

# Extract and setup Ubuntu
setup_ubuntu() {
    print_step "Setting up Ubuntu environment..."
    
    cd "$CHROOT_PATH" || {
        print_error "Failed to change to chroot directory"
        exit 1
    }
    
    # Extract Ubuntu rootfs
    if [ ! -d "etc" ]; then
        print_info "Extracting Ubuntu rootfs..."
        if ! tar xpvf "ubuntu-base-${UBUNTU_VERSION}-base-arm64.tar.gz" --numeric-owner; then
            print_error "Failed to extract Ubuntu rootfs"
            exit 1
        fi
    else
        print_info "Ubuntu rootfs already extracted"
    fi
    
    # Create necessary directories
    mkdir -p sdcard dev/shm
    
    print_success "Ubuntu environment setup completed"
}

# Create startup script
create_startup_script() {
    print_step "Creating startup script..."
    
    cat > "$STARTUP_SCRIPT" << 'EOF'
#!/bin/sh

# Ubuntu Chroot Startup Script
# Based on: https://ivonblog.com/en-us/posts/termux-chroot-ubuntu/

# The path of Ubuntu rootfs
UBUNTUPATH="/data/local/tmp/chrootubuntu"

# Check if chroot directory exists
if [ ! -d "$UBUNTUPATH" ]; then
    echo "Error: Ubuntu chroot directory not found!"
    echo "Please run the installer first."
    exit 1
fi

# Fix setuid issue
busybox mount -o remount,dev,suid /data

# Mount necessary filesystems
busybox mount --bind /dev $UBUNTUPATH/dev
busybox mount --bind /sys $UBUNTUPATH/sys
busybox mount --bind /proc $UBUNTUPATH/proc
busybox mount -t devpts devpts $UBUNTUPATH/dev/pts

# /dev/shm for Electron apps
busybox mount -t tmpfs -o size=256M tmpfs $UBUNTUPATH/dev/shm

# Mount sdcard
busybox mount --bind /sdcard $UBUNTUPATH/sdcard

# Mount tmp directory
busybox mount --bind $PREFIX/tmp $UBUNTUPATH/tmp

# chroot into Ubuntu
busybox chroot $UBUNTUPATH /bin/su - root

# Note: Unmounting is commented out for desktop environment
# Uncomment the following lines if you don't want desktop environment
#busybox umount $UBUNTUPATH/dev/shm
#busybox umount $UBUNTUPATH/dev/pts
#busybox umount $UBUNTUPATH/dev
#busybox umount $UBUNTUPATH/proc
#busybox umount $UBUNTUPATH/sys
#busybox umount $UBUNTUPATH/sdcard
#busybox umount $UBUNTUPATH/tmp
EOF
    
    chmod +x "$STARTUP_SCRIPT"
    print_success "Startup script created: $STARTUP_SCRIPT"
}

# Create desktop startup script
create_desktop_startup_script() {
    print_step "Creating desktop startup script..."
    
    # Create shortcuts directory
    mkdir -p "$HOME/.shortcuts" || {
        print_warn "Failed to create shortcuts directory"
        return 1
    }
    
    cat > "$WIDGET_SCRIPT" << 'EOF'
#!/bin/bash

# Ubuntu Desktop Startup Script
# This script starts Ubuntu with desktop environment

# Kill all old processes
killall -9 termux-x11 Xwayland pulseaudio virgl_test_server_android termux-wake-lock 2>/dev/null || true

# Start Termux X11
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity

# Mount tmp directory
sudo busybox mount --bind $PREFIX/tmp /data/local/tmp/chrootubuntu/tmp

# Start X11 server
XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :0 -ac &

sleep 3

# Start Pulse Audio
pulseaudio --start --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1

# Start virgl server for hardware acceleration
virgl_test_server_android &

# Execute chroot Ubuntu script with desktop
su -c "sh /data/local/tmp/startu.sh"
EOF
    
    chmod +x "$WIDGET_SCRIPT"
    print_success "Desktop startup script created: $WIDGET_SCRIPT"
}

# Initialize Ubuntu system
initialize_ubuntu() {
    print_step "Initializing Ubuntu system..."
    
    # Check if startup script exists
    if [ ! -f "$STARTUP_SCRIPT" ]; then
        print_error "Startup script not found. Please run the installer again."
        exit 1
    fi
    
    # Start Ubuntu for first time setup
    print_info "Starting Ubuntu for first time setup..."
    sh "$STARTUP_SCRIPT" << 'EOF'
# Fix DNS resolution
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "127.0.0.1 localhost" > /etc/hosts

# Fix apt warnings
groupadd -g 3003 aid_inet
groupadd -g 3004 aid_net_raw
groupadd -g 1003 aid_graphics
usermod -g 3003 -G 3003,3004 -a _apt
usermod -G 3003 -a root

# Update system
apt update
apt upgrade -y

# Install essential packages
apt install -y vim net-tools sudo git locales

# Setup timezone (change as needed)
ln -sf /usr/share/zoneinfo/Asia/Tehran /etc/localtime

# Create user
groupadd storage
groupadd wheel
useradd -m -g users -G wheel,audio,video,storage,aid_inet -s /bin/bash user
echo "user:ubuntu123" | chpasswd

# Add user to sudoers
echo "user ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Generate locales
locale-gen en_US.UTF-8
locale-gen fa_IR.UTF-8

# Set default locale
echo "LANG=en_US.UTF-8" > /etc/default/locale

exit
EOF
    
    print_success "Ubuntu system initialized"
}

# Install desktop environment
install_desktop() {
    print_step "Installing desktop environment..."
    
    local desktop_choice="$1"
    
    # Check if startup script exists
    if [ ! -f "$STARTUP_SCRIPT" ]; then
        print_error "Startup script not found. Please run the installer again."
        exit 1
    fi
    
    sh "$STARTUP_SCRIPT" << EOF
# Switch to user
su user
cd ~

# Install desktop environment
if [ "$desktop_choice" = "xfce" ]; then
    sudo apt install -y xubuntu-desktop
    sudo update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal
    echo "Desktop command: startxfce4"
elif [ "$desktop_choice" = "kde" ]; then
    sudo apt install -y kubuntu-desktop
    sudo update-alternatives --set x-terminal-emulator /usr/bin/konsole
    echo "Desktop command: startplasma-x11"
fi

# Install additional software
sudo apt install -y firefox-esr gedit gimp vlc

# Disable snapd
sudo apt autopurge snapd
echo "Package: snapd" | sudo tee /etc/apt/preferences.d/nosnap.pref
echo "Pin: release a=*" | sudo tee -a /etc/apt/preferences.d/nosnap.pref
echo "Pin-Priority: -10" | sudo tee -a /etc/apt/preferences.d/nosnap.pref

exit
EOF
    
    print_success "Desktop environment installed: $desktop_choice"
}

# Setup SSH service
setup_ssh() {
    print_step "Setting up SSH service..."
    
    # Check if startup script exists
    if [ ! -f "$STARTUP_SCRIPT" ]; then
        print_error "Startup script not found. Please install Ubuntu first."
        exit 1
    fi
    
    sh "$STARTUP_SCRIPT" << 'EOF'
# Install SSH
apt install -y openssh-client openssh-server

# Change root password
echo "root:ubuntu123" | chpasswd

# Create SSH directory
mkdir -p /run/sshd

# Start SSH service
/usr/sbin/sshd -D &

# Get IP address
echo "SSH IP Address:"
ifconfig | grep "inet " | grep -v 127.0.0.1

exit
EOF
    
    print_success "SSH service configured"
}

# Create desktop startup command
create_desktop_command() {
    local desktop_choice="$1"
    
    print_step "Creating desktop startup command..."
    
    # Create desktop startup script
    cat > "$STARTUP_SCRIPT" << EOF
#!/bin/sh

# Ubuntu Chroot Startup Script with Desktop
UBUNTUPATH="/data/local/tmp/chrootubuntu"

# Fix setuid issue
busybox mount -o remount,dev,suid /data

# Mount necessary filesystems
busybox mount --bind /dev \$UBUNTUPATH/dev
busybox mount --bind /sys \$UBUNTUPATH/sys
busybox mount --bind /proc \$UBUNTUPATH/proc
busybox mount -t devpts devpts \$UBUNTUPATH/dev/pts
busybox mount -t tmpfs -o size=256M tmpfs \$UBUNTUPATH/dev/shm
busybox mount --bind /sdcard \$UBUNTUPATH/sdcard
busybox mount --bind \$PREFIX/tmp \$UBUNTUPATH/tmp

# Start desktop environment
if [ "$desktop_choice" = "xfce" ]; then
    busybox chroot \$UBUNTUPATH /bin/su - user -c "export DISPLAY=:0 PULSE_SERVER=tcp:127.0.0.1:4713 && dbus-launch --exit-with-session startxfce4"
elif [ "$desktop_choice" = "kde" ]; then
    busybox chroot \$UBUNTUPATH /bin/su - user -c "export DISPLAY=:0 PULSE_SERVER=tcp:127.0.0.1:4713 && dbus-launch --exit-with-session startplasma-x11"
fi
EOF
    
    chmod +x "$STARTUP_SCRIPT"
    print_success "Desktop startup command created"
}

# Show status
show_status() {
    print_header "Ubuntu Chroot Status"
    
    if [ -d "$CHROOT_PATH" ]; then
        print_info "Ubuntu chroot directory: $CHROOT_PATH"
        print_info "Startup script: $STARTUP_SCRIPT"
        print_info "Widget script: $WIDGET_SCRIPT"
        
        if [ -f "$STARTUP_SCRIPT" ]; then
            print_success "✓ Startup script exists"
        else
            print_error "✗ Startup script missing"
        fi
        
        if [ -f "$WIDGET_SCRIPT" ]; then
            print_success "✓ Widget script exists"
        else
            print_error "✗ Widget script missing"
        fi
        
        # Check if desktop is installed
        if [ -d "$CHROOT_PATH/usr/share/xfce4" ]; then
            print_info "Desktop: XFCE4 installed"
        elif [ -d "$CHROOT_PATH/usr/share/kde" ]; then
            print_info "Desktop: KDE installed"
        else
            print_info "Desktop: Not installed"
        fi
        
    else
        print_error "Ubuntu chroot not installed"
    fi
}

# Uninstall Ubuntu
uninstall_ubuntu() {
    print_header "Uninstalling Ubuntu Chroot"
    
    # Check if Ubuntu is installed
    if [ ! -d "$CHROOT_PATH" ]; then
        print_error "Ubuntu chroot is not installed."
        return 1
    fi
    
    print_warn "This will completely remove Ubuntu chroot!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Stop any running processes
        killall -9 termux-x11 Xwayland pulseaudio virgl_test_server_android 2>/dev/null || true
        
        # Unmount if mounted
        if mountpoint -q "$CHROOT_PATH/dev/shm" 2>/dev/null; then
            busybox umount "$CHROOT_PATH/dev/shm" 2>/dev/null || true
        fi
        if mountpoint -q "$CHROOT_PATH/dev/pts" 2>/dev/null; then
            busybox umount "$CHROOT_PATH/dev/pts" 2>/dev/null || true
        fi
        if mountpoint -q "$CHROOT_PATH/dev" 2>/dev/null; then
            busybox umount "$CHROOT_PATH/dev" 2>/dev/null || true
        fi
        if mountpoint -q "$CHROOT_PATH/proc" 2>/dev/null; then
            busybox umount "$CHROOT_PATH/proc" 2>/dev/null || true
        fi
        if mountpoint -q "$CHROOT_PATH/sys" 2>/dev/null; then
            busybox umount "$CHROOT_PATH/sys" 2>/dev/null || true
        fi
        if mountpoint -q "$CHROOT_PATH/sdcard" 2>/dev/null; then
            busybox umount "$CHROOT_PATH/sdcard" 2>/dev/null || true
        fi
        if mountpoint -q "$CHROOT_PATH/tmp" 2>/dev/null; then
            busybox umount "$CHROOT_PATH/tmp" 2>/dev/null || true
        fi
        
        # Remove files
        rm -rf "$CHROOT_PATH"
        rm -f "$STARTUP_SCRIPT"
        rm -f "$WIDGET_SCRIPT"
        
        print_success "Ubuntu chroot uninstalled successfully"
    else
        print_info "Uninstallation cancelled"
    fi
}

# Show help
show_help() {
    print_header "Ubuntu Chroot Installer Help"
    
    echo -e "${WHITE}Usage:${NC}"
    echo "  ./ubuntu_chroot_installer.sh [COMMAND]"
    echo
    echo -e "${WHITE}Commands:${NC}"
    echo "  install [xfce|kde]  - Install Ubuntu with desktop environment"
    echo "  cli                 - Install Ubuntu command line only"
    echo "  ssh                 - Setup SSH service"
    echo "  status              - Show installation status"
    echo "  uninstall           - Remove Ubuntu chroot"
    echo "  help                - Show this help message"
    echo
    echo -e "${WHITE}Examples:${NC}"
    echo "  ./ubuntu_chroot_installer.sh install xfce"
    echo "  ./ubuntu_chroot_installer.sh install kde"
    echo "  ./ubuntu_chroot_installer.sh cli"
    echo "  ./ubuntu_chroot_installer.sh status"
    echo
    echo -e "${WHITE}After Installation:${NC}"
    echo "  1. Install Termux Widget for one-click startup"
    echo "  2. Run: sh /data/local/tmp/startu.sh"
    echo "  3. For desktop: Use the widget script"
    echo
    echo -e "${WHITE}SSH Access:${NC}"
    echo "  IP: Check with 'ifconfig' in Ubuntu"
    echo "  User: root"
    echo "  Password: ubuntu123"
    echo
    echo -e "${WHITE}Desktop Access:${NC}"
    echo "  Install Termux X11 app"
    echo "  Use the widget script for one-click startup"
}

# Interactive menu
interactive_menu() {
    while true; do
        print_header "Ubuntu Chroot Installer"
        echo
        echo "1) Install Ubuntu with XFCE4"
        echo "2) Install Ubuntu with KDE"
        echo "3) Install Ubuntu CLI only"
        echo "4) Setup SSH service"
        echo "5) Check status"
        echo "6) Uninstall Ubuntu"
        echo "7) Help"
        echo "8) Exit"
        echo
        read -p "Choose an option (1-8): " choice
        
        case $choice in
            1)
                install_ubuntu "xfce"
                ;;
            2)
                install_ubuntu "kde"
                ;;
            3)
                install_ubuntu "cli"
                ;;
            4)
                setup_ssh
                ;;
            5)
                show_status
                ;;
            6)
                uninstall_ubuntu
                ;;
            7)
                show_help
                ;;
            8)
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please choose 1-8."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Install Ubuntu
install_ubuntu() {
    local desktop_choice="$1"
    
    print_header "Installing Ubuntu Chroot"
    
    # Check requirements
    check_root
    check_hardware
    
    # Install packages
    install_packages
    
    # Download and setup Ubuntu
    download_ubuntu
    setup_ubuntu
    
    # Create scripts
    create_startup_script
    create_desktop_startup_script
    
    # Initialize Ubuntu
    initialize_ubuntu
    
    # Install desktop if requested
    if [ "$desktop_choice" != "cli" ]; then
        install_desktop "$desktop_choice"
        create_desktop_command "$desktop_choice"
    fi
    
    print_header "Installation Complete!"
    print_success "Ubuntu chroot installed successfully!"
    echo
    print_info "Next steps:"
    echo "1. Install Termux Widget for one-click startup"
    echo "2. Install Termux X11 for desktop environment"
    echo "3. Run: sh /data/local/tmp/startu.sh"
    echo "4. For desktop: Use the widget script"
    echo
    print_info "Default credentials:"
    echo "  User: root"
    echo "  Password: ubuntu123"
    echo "  Desktop user: user"
    echo "  Desktop password: ubuntu123"
}

# Main function
main() {
    case "${1:-}" in
        "install")
            if [ -z "${2:-}" ]; then
                print_error "Please specify desktop environment: xfce, kde, or cli"
                exit 1
            fi
            install_ubuntu "$2"
            ;;
        "cli")
            install_ubuntu "cli"
            ;;
        "ssh")
            setup_ssh
            ;;
        "status")
            show_status
            ;;
        "uninstall")
            uninstall_ubuntu
            ;;
        "help")
            show_help
            ;;
        "")
            interactive_menu
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@" 