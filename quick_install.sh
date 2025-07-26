#!/data/data/com.termux/files/usr/bin/bash

# Quick Ubuntu Installer for Termux
# Run this with: curl -s https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/quick_install.sh | bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

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

print_header "Quick Ubuntu Installer for Termux"
print_status "Downloading and installing Ubuntu..."

# Download the main installer
print_status "Downloading installer script..."
curl -s -o /tmp/install_ubuntu_termux.sh https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/install_ubuntu_termux.sh

# Make it executable
chmod +x /tmp/install_ubuntu_termux.sh

# Run the installer
print_status "Running Ubuntu installer..."
/tmp/install_ubuntu_termux.sh

# Clean up
rm /tmp/install_ubuntu_termux.sh

print_header "Installation Complete!"
print_status "Ubuntu has been installed successfully!"
echo ""
print_status "Next steps:"
echo "  1. Run: ubuntu cli"
echo "  2. Inside Ubuntu, run: ./init-ubuntu.sh"
echo "  3. Exit Ubuntu and run: ubuntu desktop"
echo ""
print_status "Quick start command: ubuntu" 