#!/data/data/com.termux/files/usr/bin/bash

# Ubuntu Installer for Termux - Single File
# Install Ubuntu with desktop environment and VNC server
# Run with: curl -s https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/ubuntu_installer.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to download file with retry
download_file() {
    local url="$1"
    local output="$2"
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        if command -v curl >/dev/null 2>&1; then
            if curl -L --connect-timeout 30 --max-time 300 -o "$output" "$url" 2>/dev/null; then
                return 0
            fi
        else
            print_error "curl is not available. Please install it first:"
            print_error "pkg install curl"
            exit 1
        fi
        
        retry_count=$((retry_count + 1))
        print_warning "Download failed (attempt $retry_count/$max_retries), retrying in 5 seconds..."
        sleep 5
    done
    
    print_error "Failed to download after $max_retries attempts: $url"
    return 1
}

# Check if running on Termux
if [ ! -d "/data/data/com.termux" ]; then
    print_error "This script must be run on Termux!"
    exit 1
fi

print_header "Ubuntu Installer for Termux"
print_status "Starting Ubuntu installation with desktop environment..."

# Update Termux packages and install essential tools
print_status "Updating Termux packages and installing essential tools..."
pkg update -y
pkg upgrade -y

# Set up repository if needed
print_status "Setting up Termux repository..."
# Try different repositories automatically
REPOSITORIES=(
    "https://packages.termux.dev/apt/termux-main"
    "https://grimler.se/termux-packages-24"
    "https://mirror.quantum5.ca/termux/termux-main"
)

REPO_NAMES=(
    "Termux Official"
    "Grimler (Europe)"
    "Quantum5 (Canada)"
)

WORKING_REPO=""

for i in "${!REPOSITORIES[@]}"; do
    REPO_URL="${REPOSITORIES[$i]}"
    REPO_NAME="${REPO_NAMES[$i]}"
    
    print_status "Testing $REPO_NAME..."
    
    # Set repository
    echo "deb $REPO_URL stable main" > $PREFIX/etc/apt/sources.list
    
    # Test if repository works with timeout
    print_status "Testing $REPO_NAME connection..."
    if timeout 60 pkg update >/dev/null 2>&1; then
        print_status "✅ $REPO_NAME is working!"
        WORKING_REPO="$REPO_NAME"
        break
    else
        print_warning "❌ $REPO_NAME failed or timeout, trying next..."
        sleep 3
    fi
done

if [ -z "$WORKING_REPO" ]; then
    print_error "All repositories failed. Please check your internet connection."
    exit 1
fi

print_status "Using repository: $WORKING_REPO"

# Install essential packages
print_status "Installing essential packages..."
pkg install -y curl proot tar xz-utils pulseaudio

# Install desktop packages with repository switching
print_status "Installing desktop packages..."

# Switch to Termux Official repository for desktop packages
print_status "Switching to Termux Official repository for desktop packages..."
echo "deb https://packages.termux.dev/apt/termux-main stable main" > $PREFIX/etc/apt/sources.list
pkg update

# Try to install with pkg first
if pkg install -y tigervnc xfce4 xfce4-terminal 2>/dev/null; then
    print_status "✅ Desktop packages installed successfully with pkg!"
else
    print_warning "pkg installation failed, trying alternative methods..."
    
    # Try installing just tigervnc
    if pkg install -y tigervnc 2>/dev/null; then
        print_status "✅ tigervnc installed successfully!"
    else
        print_warning "tigervnc not available, Ubuntu will work in command line mode only."
    fi
    
    # Try installing xfce4-terminal separately
    if pkg install -y xfce4-terminal 2>/dev/null; then
        print_status "✅ xfce4-terminal installed successfully!"
    else
        print_warning "xfce4-terminal not available."
    fi
    
    # Try installing xfce4 separately
    if pkg install -y xfce4 2>/dev/null; then
        print_status "✅ xfce4 installed successfully!"
    else
        print_warning "xfce4 not available, will use basic desktop."
    fi
fi

# Switch back to working repository for other operations
print_status "Switching back to working repository..."
echo "deb $REPO_URL stable main" > $PREFIX/etc/apt/sources.list
pkg update

print_status "Desktop packages installation completed!"

# Create Ubuntu directory
UBUNTU_DIR="$HOME/ubuntu"
print_status "Creating Ubuntu directory at $UBUNTU_DIR"
mkdir -p "$UBUNTU_DIR"

# Download Ubuntu rootfs
print_status "Downloading Ubuntu 22.04 rootfs..."
cd "$UBUNTU_DIR"

# Try different sources for Ubuntu rootfs
UBUNTU_SOURCES=(
    "https://github.com/AndronixApp/AndronixOrigin/raw/master/Rootfs/Ubuntu/ubuntu-rootfs.tar.xz"
    "https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu/ubuntu-rootfs.tar.xz"
)

UBUNTU_DOWNLOADED=false
for source in "${UBUNTU_SOURCES[@]}"; do
    print_status "Trying to download from: $source"
    if download_file "$source" "ubuntu-rootfs.tar.xz"; then
        print_status "✅ Ubuntu rootfs downloaded successfully!"
        UBUNTU_DOWNLOADED=true
        break
    else
        print_warning "❌ Download failed from this source, trying next..."
    fi
done

if [ "$UBUNTU_DOWNLOADED" = false ]; then
    print_error "Failed to download Ubuntu rootfs from all sources."
    print_error "Please check your internet connection and try again."
    exit 1
fi

# Extract Ubuntu rootfs
print_status "Extracting Ubuntu rootfs..."
tar -xf ubuntu-rootfs.tar.xz
rm ubuntu-rootfs.tar.xz

# Create Ubuntu startup script
print_status "Creating Ubuntu startup script..."
cat > "$HOME/ubuntu" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# Ubuntu startup script for Termux
UBUNTU_DIR="$HOME/ubuntu"

# Function to start VNC server
start_vnc() {
    echo "Starting VNC server..."
    cd "$UBUNTU_DIR"
    vncserver -localhost no -geometry 1280x720
    echo "VNC server started on :1"
    echo "Connect using VNC viewer to: $(hostname -I | awk '{print $1}'):5901"
}

# Function to stop VNC server
stop_vnc() {
    echo "Stopping VNC server..."
    vncserver -kill :1 2>/dev/null || true
    echo "VNC server stopped"
}

# Function to start Ubuntu with desktop
start_ubuntu_desktop() {
    cd "$UBUNTU_DIR"
    echo "Starting Ubuntu with desktop environment..."
    
    # Start VNC server if not running
    if ! pgrep -f "vncserver.*:1" > /dev/null; then
        start_vnc
    fi
    
    # Start Ubuntu with desktop
    proot -0 -r . -b /dev -b /proc -b /sys -b /data -b /storage -b /sdcard -w /root \
        /bin/bash -c "
        export DISPLAY=:1
        export PULSE_SERVER=127.0.0.1
        export XDG_RUNTIME_DIR=/tmp/runtime-root
        mkdir -p /tmp/runtime-root
        chmod 700 /tmp/runtime-root
        
        # Start XFCE desktop
        startxfce4 &
        
        # Keep the session alive
        tail -f /dev/null
    "
}

# Function to start Ubuntu without desktop
start_ubuntu_cli() {
    cd "$UBUNTU_DIR"
    echo "Starting Ubuntu command line..."
    proot -0 -r . -b /dev -b /proc -b /sys -b /data -b /storage -b /sdcard -w /root /bin/bash
}

# Check command line arguments
case "$1" in
    "desktop"|"gui"|"vnc")
        start_ubuntu_desktop
        ;;
    "stop"|"kill")
        stop_vnc
        ;;
    "cli"|"shell")
        start_ubuntu_cli
        ;;
    "help"|"-h"|"--help")
        echo "Ubuntu for Termux - Usage:"
        echo "  ubuntu              - Start Ubuntu with desktop (default)"
        echo "  ubuntu desktop      - Start Ubuntu with desktop"
        echo "  ubuntu cli          - Start Ubuntu command line only"
        echo "  ubuntu stop         - Stop VNC server"
        echo "  ubuntu help         - Show this help"
        ;;
    *)
        start_ubuntu_desktop
        ;;
esac
EOF

# Make the script executable
chmod +x "$HOME/ubuntu"

# Create Ubuntu initialization script
print_status "Creating Ubuntu initialization script..."
cat > "$UBUNTU_DIR/init-ubuntu.sh" << 'EOF'
#!/bin/bash

# Ubuntu initialization script
echo "Initializing Ubuntu environment..."

# Update package lists
apt update

# Install desktop environment and VNC
apt install -y xfce4 xfce4-goodies tightvncserver dbus-x11

# Install additional useful packages
apt install -y firefox-esr gedit gimp vlc

# Configure VNC
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup << 'VNC_EOF'
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
VNC_EOF

chmod +x ~/.vnc/xstartup

# Set up environment
echo 'export DISPLAY=:1' >> ~/.bashrc
echo 'export PULSE_SERVER=127.0.0.1' >> ~/.bashrc

echo "Ubuntu initialization completed!"
echo "You can now use 'ubuntu' command to start Ubuntu with desktop."
EOF

# Make initialization script executable
chmod +x "$UBUNTU_DIR/init-ubuntu.sh"

# Create service management script
print_status "Creating service management script..."
cat > "$HOME/ubuntu-service" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# Ubuntu service management script
UBUNTU_DIR="$HOME/ubuntu"

case "$1" in
    "start")
        echo "Starting Ubuntu service..."
        nohup "$HOME/ubuntu" desktop > "$HOME/ubuntu.log" 2>&1 &
        echo "Ubuntu service started. Check ubuntu.log for details."
        ;;
    "stop")
        echo "Stopping Ubuntu service..."
        pkill -f "proot.*ubuntu" || true
        "$HOME/ubuntu" stop
        echo "Ubuntu service stopped."
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
print_status "Adding scripts to PATH..."
echo 'export PATH="$HOME:$PATH"' >> "$HOME/.bashrc"

# Create desktop shortcut
print_status "Creating desktop shortcut..."
mkdir -p "$HOME/.shortcuts"
cat > "$HOME/.shortcuts/Ubuntu" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd "$HOME"
./ubuntu desktop
EOF

chmod +x "$HOME/.shortcuts/Ubuntu"

print_header "Installation Complete!"
print_status "Ubuntu has been installed successfully!"
echo ""
print_status "Usage:"
echo "  ubuntu              - Start Ubuntu with desktop"
echo "  ubuntu cli          - Start Ubuntu command line only"
echo "  ubuntu stop         - Stop VNC server"
echo "  ubuntu help         - Show help"
echo ""
print_status "First time setup:"
echo "  1. Run: ubuntu cli"
echo "  2. Inside Ubuntu, run: ./init-ubuntu.sh"
echo "  3. Exit Ubuntu and run: ubuntu desktop"
echo ""
print_warning "Make sure to run the initialization script first time!"
print_status "VNC viewer will be needed to connect to the desktop."
print_status "Default VNC port: 5901" 