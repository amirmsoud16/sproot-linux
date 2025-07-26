#!/data/data/com.termux/files/usr/bin/bash

# Ubuntu Uninstaller for Termux
# Remove Ubuntu and all related files

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

# Check if running on Termux
if [ ! -d "/data/data/com.termux" ]; then
    print_error "This script must be run on Termux!"
    exit 1
fi

print_header "Ubuntu Uninstaller for Termux"

# Stop Ubuntu service if running
print_status "Stopping Ubuntu service..."
if pgrep -f "proot.*ubuntu" > /dev/null; then
    pkill -f "proot.*ubuntu" 2>/dev/null || true
    print_status "Ubuntu service stopped"
else
    print_status "No Ubuntu service running"
fi

# Stop VNC server if running
print_status "Stopping VNC server..."
if pgrep -f "vncserver" > /dev/null; then
    vncserver -kill :1 2>/dev/null || true
    print_status "VNC server stopped"
else
    print_status "No VNC server running"
fi

# Remove Ubuntu files
print_status "Removing Ubuntu files..."

# Remove Ubuntu directory
if [ -d "$HOME/ubuntu" ]; then
    rm -rf "$HOME/ubuntu"
    print_status "Removed Ubuntu directory"
else
    print_status "Ubuntu directory not found"
fi

# Remove Ubuntu command script
if [ -f "$HOME/ubuntu" ]; then
    rm "$HOME/ubuntu"
    print_status "Removed Ubuntu command script"
else
    print_status "Ubuntu command script not found"
fi

# Remove Ubuntu service script
if [ -f "$HOME/ubuntu-service" ]; then
    rm "$HOME/ubuntu-service"
    print_status "Removed Ubuntu service script"
else
    print_status "Ubuntu service script not found"
fi

# Remove desktop shortcut
if [ -f "$HOME/.shortcuts/Ubuntu" ]; then
    rm "$HOME/.shortcuts/Ubuntu"
    print_status "Removed desktop shortcut"
else
    print_status "Desktop shortcut not found"
fi

# Remove Ubuntu log file
if [ -f "$HOME/ubuntu.log" ]; then
    rm "$HOME/ubuntu.log"
    print_status "Removed Ubuntu log file"
else
    print_status "Ubuntu log file not found"
fi

# Remove VNC configuration
if [ -d "$HOME/.vnc" ]; then
    rm -rf "$HOME/.vnc"
    print_status "Removed VNC configuration"
else
    print_status "VNC configuration not found"
fi

# Clean up PATH (remove ubuntu from PATH)
print_status "Cleaning up PATH..."
if [ -f "$HOME/.bashrc" ]; then
    # Remove the PATH line that was added
    sed -i '/export PATH="$HOME:$PATH"/d' "$HOME/.bashrc"
    print_status "Cleaned up PATH configuration"
fi

# Calculate freed space
print_status "Calculating freed space..."
FREED_SPACE=$(du -sh "$HOME/ubuntu" 2>/dev/null | cut -f1 || echo "Unknown")
print_status "Freed space: $FREED_SPACE"

print_header "Uninstallation Complete!"
print_status "Ubuntu has been completely removed from your system."
echo ""
print_status "Removed items:"
echo "  ✅ Ubuntu rootfs directory"
echo "  ✅ Ubuntu command script"
echo "  ✅ Ubuntu service script"
echo "  ✅ Desktop shortcut"
echo "  ✅ VNC configuration"
echo "  ✅ Log files"
echo "  ✅ PATH modifications"
echo ""
print_warning "Note: Termux packages (curl, proot, etc.) were not removed."
print_warning "If you want to remove them too, run: pkg remove curl proot tar xz-utils pulseaudio tigervnc xfce4 xfce4-terminal"
echo ""
print_status "Thank you for using Ubuntu on Termux!" 