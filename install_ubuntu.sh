#!/data/data/com.termux/files/usr/bin/bash

# Ubuntu Installer for Termux
# Simple and reliable installation script

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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

# Check if running on Termux
if [ ! -d "/data/data/com.termux" ]; then
    print_error "This script must be run on Termux!"
    exit 1
fi

print_header "Ubuntu Installer for Termux"

# Update Termux
print_info "Updating Termux packages..."
pkg update -y
pkg upgrade -y

# Install required packages
print_info "Installing required packages..."
pkg install -y curl proot tar xz-utils pulseaudio

# Install VNC (try different repositories)
print_info "Installing VNC server..."
if ! pkg install -y tigervnc 2>/dev/null; then
    print_warn "tigervnc not available in current repository"
    print_warn "Ubuntu will work in command line mode only"
fi

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
    
    proot -0 -r . -b /dev -b /proc -b /sys -b /data -b /storage -b /sdcard -w /root \
        /bin/bash -c "
        export DISPLAY=:1
        export PULSE_SERVER=127.0.0.1
        startxfce4 &
        tail -f /dev/null
    "
}

start_cli() {
    cd "$UBUNTU_DIR"
    proot -0 -r . -b /dev -b /proc -b /sys -b /data -b /storage -b /sdcard -w /root /bin/bash
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
apt update
apt install -y xfce4 xfce4-goodies tightvncserver dbus-x11
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup << 'VNC_EOF'
#!/bin/bash
startxfce4 &
VNC_EOF
chmod +x ~/.vnc/xstartup
echo 'export DISPLAY=:1' >> ~/.bashrc
echo 'export PULSE_SERVER=127.0.0.1' >> ~/.bashrc
echo "Ubuntu initialization completed!"
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