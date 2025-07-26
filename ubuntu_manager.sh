#!/data/data/com.termux/files/usr/bin/bash

# Ubuntu Manager for Termux
# Unified script for installing and managing Ubuntu on Termux

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_menu() {
    echo -e "${CYAN}$1${NC}"
}

# Check if running on Termux
if [ ! -d "/data/data/com.termux" ]; then
    print_error "This script must be run on Termux!"
    exit 1
fi

# Check if device is rooted
if ! command -v su >/dev/null 2>&1; then
    print_error "This script requires a rooted device for chroot!"
    print_error "Please root your device first."
    exit 1
fi

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    print_error "This script must be run as root for chroot!"
    print_error "Please run: su -c './ubuntu_manager.sh'"
    exit 1
fi

# Function to install Ubuntu
install_ubuntu() {
    print_header "Installing Ubuntu on Termux"
    
    # Update Termux
    print_info "Updating Termux packages..."
    pkg update -y
    pkg upgrade -y
    
    # Install required packages
print_info "Installing required packages..."
pkg install -y curl tar xz-utils pulseaudio tigervnc
    
    # Create Ubuntu directory
    UBUNTU_DIR="$HOME/ubuntu"
    print_info "Creating Ubuntu directory..."
    mkdir -p "$UBUNTU_DIR"
    cd "$UBUNTU_DIR"
    
    # Download Ubuntu rootfs
    print_info "Downloading Ubuntu rootfs..."
    if ! curl -L -o ubuntu-rootfs.tar.xz "https://github.com/AndronixApp/AndronixOrigin/raw/master/Rootfs/Ubuntu/ubuntu-rootfs.tar.xz"; then
        print_error "Failed to download Ubuntu rootfs"
        exit 1
    fi
    
    # Extract Ubuntu rootfs
    print_info "Extracting Ubuntu rootfs..."
    if ! tar -xf ubuntu-rootfs.tar.xz; then
        print_error "Failed to extract Ubuntu rootfs"
        exit 1
    fi
    rm ubuntu-rootfs.tar.xz
    
    # Create Ubuntu command script
    print_info "Creating Ubuntu command script..."
    cat > "$HOME/ubuntu" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

UBUNTU_DIR="$HOME/ubuntu"

start_vnc() {
    cd "$UBUNTU_DIR"
    vncserver -localhost no -geometry 1280x720
    echo "VNC server started on :1"
    echo "Connect to: $(hostname -I | awk '{print $1}'):5901"
}

stop_vnc() {
    vncserver -kill :1 2>/dev/null || true
    echo "VNC server stopped"
}

start_desktop() {
    cd "$UBUNTU_DIR"
    if ! pgrep -f "vncserver.*:1" > /dev/null; then
        start_vnc
    fi
    
    chroot . /bin/bash -c "
        export DISPLAY=:1
        export PULSE_SERVER=127.0.0.1
        # Check if desktop packages are installed
        if command -v startxfce4 >/dev/null 2>&1; then
            startxfce4 &
        else
            echo 'Desktop packages not installed. Run: ./init-ubuntu.sh'
        fi
        tail -f /dev/null
    "
}

start_cli() {
    cd "$UBUNTU_DIR"
    chroot . /bin/bash
}

case "$1" in
    "desktop"|"gui"|"vnc")
        start_desktop
        ;;
    "stop"|"kill")
        stop_vnc
        ;;
    "cli"|"shell")
        start_cli
        ;;
    "help"|"-h"|"--help")
        echo "Usage: ubuntu [desktop|cli|stop|help]"
        ;;
    *)
        start_desktop
        ;;
esac
EOF

    chmod +x "$HOME/ubuntu"
    
    # Create initialization script
    print_info "Creating initialization script..."
    cat > "$UBUNTU_DIR/init-ubuntu.sh" << 'EOF'
#!/bin/bash
echo "Initializing Ubuntu..."

# Update package lists
echo "Updating package lists..."
apt update

# Install desktop environment and VNC
echo "Installing desktop environment..."
apt install -y xfce4 xfce4-goodies tightvncserver dbus-x11

# Install additional useful packages
echo "Installing additional packages..."
apt install -y firefox-esr gedit gimp vlc

# Configure VNC
echo "Configuring VNC..."
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup << 'VNC_EOF'
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
VNC_EOF

chmod +x ~/.vnc/xstartup

# Set up environment
echo "Setting up environment..."
echo 'export DISPLAY=:1' >> ~/.bashrc
echo 'export PULSE_SERVER=127.0.0.1' >> ~/.bashrc

echo "Ubuntu initialization completed!"
echo "You can now use 'ubuntu' command to start Ubuntu with desktop."
EOF

    chmod +x "$UBUNTU_DIR/init-ubuntu.sh"
    
    # Create service script
    print_info "Creating service script..."
    cat > "$HOME/ubuntu-service" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
case "$1" in
    "start")
        nohup "$HOME/ubuntu" desktop > "$HOME/ubuntu.log" 2>&1 &
        echo "Ubuntu service started"
        ;;
    "stop")
        pkill -f "proot.*ubuntu" || true
        "$HOME/ubuntu" stop
        echo "Ubuntu service stopped"
        ;;
    "status")
        if pgrep -f "proot.*ubuntu" > /dev/null; then
            echo "Ubuntu service is running"
        else
            echo "Ubuntu service is not running"
        fi
        ;;
    *)
        echo "Usage: ubuntu-service {start|stop|status}"
        ;;
esac
EOF

    chmod +x "$HOME/ubuntu-service"
    
    # Add to PATH
    print_info "Adding to PATH..."
    echo 'export PATH="$HOME:$PATH"' >> "$HOME/.bashrc"
    
    # Create desktop shortcut
    print_info "Creating desktop shortcut..."
    mkdir -p "$HOME/.shortcuts"
    cat > "$HOME/.shortcuts/Ubuntu" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd "$HOME"
./ubuntu desktop
EOF

    chmod +x "$HOME/.shortcuts/Ubuntu"
    
    print_header "Installation Complete!"
    print_info "Ubuntu has been installed successfully!"
    echo ""
    print_info "Usage:"
    echo "  ubuntu              - Start Ubuntu with desktop"
    echo "  ubuntu cli          - Start Ubuntu command line"
    echo "  ubuntu stop         - Stop VNC server"
    echo "  ubuntu help         - Show help"
    echo ""
    print_info "First time setup:"
    echo "  1. Run: ubuntu cli"
    echo "  2. Inside Ubuntu, run: ./init-ubuntu.sh"
    echo "  3. Exit Ubuntu and run: ubuntu desktop"
    echo ""
    print_info "VNC port: 5901"
    
    echo ""
    read -p "Press Enter to return to menu..."
    show_menu
}

# Function to uninstall Ubuntu
uninstall_ubuntu() {
    print_header "Uninstalling Ubuntu from Termux"
    
    # Stop Ubuntu service if running
print_info "Stopping Ubuntu service..."
if pgrep -f "chroot.*ubuntu" > /dev/null; then
    pkill -f "chroot.*ubuntu" 2>/dev/null || true
    print_info "Ubuntu service stopped"
else
    print_info "No Ubuntu service running"
fi
    
    # Stop VNC server if running
    print_info "Stopping VNC server..."
    if pgrep -f "vncserver" > /dev/null; then
        vncserver -kill :1 2>/dev/null || true
        print_info "VNC server stopped"
    else
        print_info "No VNC server running"
    fi
    
    # Remove Ubuntu files
    print_info "Removing Ubuntu files..."
    
    # Remove Ubuntu directory
    if [ -d "$HOME/ubuntu" ]; then
        rm -rf "$HOME/ubuntu"
        print_info "Removed Ubuntu directory"
    else
        print_info "Ubuntu directory not found"
    fi
    
    # Remove Ubuntu command script
    if [ -f "$HOME/ubuntu" ]; then
        rm "$HOME/ubuntu"
        print_info "Removed Ubuntu command script"
    else
        print_info "Ubuntu command script not found"
    fi
    
    # Remove Ubuntu service script
    if [ -f "$HOME/ubuntu-service" ]; then
        rm "$HOME/ubuntu-service"
        print_info "Removed Ubuntu service script"
    else
        print_info "Ubuntu service script not found"
    fi
    
    # Remove desktop shortcut
    if [ -f "$HOME/.shortcuts/Ubuntu" ]; then
        rm "$HOME/.shortcuts/Ubuntu"
        print_info "Removed desktop shortcut"
    else
        print_info "Desktop shortcut not found"
    fi
    
    # Remove Ubuntu log file
    if [ -f "$HOME/ubuntu.log" ]; then
        rm "$HOME/ubuntu.log"
        print_info "Removed Ubuntu log file"
    else
        print_info "Ubuntu log file not found"
    fi
    
    # Remove VNC configuration
    if [ -d "$HOME/.vnc" ]; then
        rm -rf "$HOME/.vnc"
        print_info "Removed VNC configuration"
    else
        print_info "VNC configuration not found"
    fi
    
    # Clean up PATH (remove ubuntu from PATH)
    print_info "Cleaning up PATH..."
    if [ -f "$HOME/.bashrc" ]; then
        # Remove the PATH line that was added
        sed -i '/export PATH="$HOME:$PATH"/d' "$HOME/.bashrc"
        print_info "Cleaned up PATH configuration"
    fi
    
    print_header "Uninstallation Complete!"
    print_info "Ubuntu has been completely removed from your system."
    echo ""
    print_info "Removed items:"
    echo "  ✅ Ubuntu rootfs directory"
    echo "  ✅ Ubuntu command script"
    echo "  ✅ Ubuntu service script"
    echo "  ✅ Desktop shortcut"
    echo "  ✅ VNC configuration"
    echo "  ✅ Log files"
    echo "  ✅ PATH modifications"
    echo ""
    print_warn "Note: Termux packages (curl, etc.) were not removed."
    print_warn "If you want to remove them too, run: pkg remove curl tar xz-utils pulseaudio tigervnc"
    echo ""
    print_info "Thank you for using Ubuntu on Termux!"
    
    echo ""
    read -p "Press Enter to return to menu..."
    show_menu
}

# Function to check Ubuntu status
check_status() {
    print_header "Ubuntu Status Check"
    
    if [ -d "$HOME/ubuntu" ]; then
        print_info "✅ Ubuntu is installed"
        
        if pgrep -f "chroot.*ubuntu" > /dev/null; then
            print_info "✅ Ubuntu service is running"
        else
            print_info "❌ Ubuntu service is not running"
        fi
        
        if pgrep -f "vncserver" > /dev/null; then
            print_info "✅ VNC server is running"
        else
            print_info "❌ VNC server is not running"
        fi
        
        if [ -f "$HOME/ubuntu" ]; then
            print_info "✅ Ubuntu command script is available"
        else
            print_info "❌ Ubuntu command script is missing"
        fi
        
        UBUNTU_SIZE=$(du -sh "$HOME/ubuntu" 2>/dev/null | cut -f1 || echo "Unknown")
        print_info "📁 Ubuntu installation size: $UBUNTU_SIZE"
        
    else
        print_info "❌ Ubuntu is not installed"
    fi
    
    echo ""
    read -p "Press Enter to return to menu..."
    show_menu
}

# Function to show interactive menu
show_menu() {
    clear
    print_header "Ubuntu Manager for Termux"
    echo ""
    print_menu "Please select an option:"
    echo ""
    echo "  1) Install Ubuntu"
    echo "  2) Uninstall Ubuntu"
    echo "  3) Check Status"
    echo "  4) Help"
    echo "  5) Exit"
    echo ""
    read -p "Enter your choice (1-5): " choice
    
    case $choice in
        1)
            install_ubuntu
            ;;
        2)
            uninstall_ubuntu
            ;;
        3)
            check_status
            ;;
        4)
            show_help
            ;;
        5)
            print_info "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid choice. Please try again."
            sleep 2
            show_menu
            ;;
    esac
}

# Function to show help
show_help() {
    print_header "Ubuntu Manager Help"
    echo ""
    print_menu "Usage: $0 [OPTION]"
    echo ""
    print_menu "Options:"
    echo "  install, i     Install Ubuntu on Termux"
    echo "  uninstall, u   Uninstall Ubuntu from Termux"
    echo "  status, s      Check Ubuntu installation status"
    echo "  help, h        Show this help message"
    echo "  menu, m        Show interactive menu"
    echo ""
    print_menu "Examples:"
    echo "  $0 install     - Install Ubuntu"
    echo "  $0 uninstall   - Remove Ubuntu"
    echo "  $0 status      - Check status"
    echo "  $0 menu        - Show interactive menu"
    echo ""
    print_menu "After installation:"
    echo "  ubuntu         - Start Ubuntu with desktop"
    echo "  ubuntu cli     - Start Ubuntu command line"
    echo "  ubuntu stop    - Stop VNC server"
    echo "  ubuntu help    - Show Ubuntu help"
    echo ""
    read -p "Press Enter to return to menu..."
    show_menu
}

# Main script logic
case "${1:-}" in
    "install"|"i")
        install_ubuntu
        ;;
    "uninstall"|"u")
        uninstall_ubuntu
        ;;
    "status"|"s")
        check_status
        ;;
    "menu"|"m"|"help"|"h"|"-h"|"--help"|"")
        show_menu
        ;;
    *)
        print_error "Unknown option: $1"
        echo ""
        show_help
        exit 1
        ;;
esac 