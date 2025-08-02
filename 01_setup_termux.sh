#!/bin/bash

# Script 1: Termux Setup for Ubuntu Installation using proot-distro

set -e

echo "=== Termux Setup for Ubuntu Installation ==="
echo ""

# Update Termux packages
echo "Updating Termux packages..."
pkg update -y && pkg upgrade -y

# Install proot-distro
echo "Installing proot-distro..."
pkg install -y proot-distro

# List available distributions
echo "Available distributions:"
proot-distro list

# Install Ubuntu
echo "Installing Ubuntu..."
proot-distro install ubuntu

# Create shortcuts
echo "Creating Ubuntu shortcuts..."

# Create ubuntu shortcut (root login)
cat > $PREFIX/bin/ubuntu << 'EOF'
#!/bin/bash
proot-distro login ubuntu
EOF

chmod +x $PREFIX/bin/ubuntu

# Create ubuntu-user shortcut (user login)
cat > $PREFIX/bin/ubuntu-user << 'EOF'
#!/bin/bash
proot-distro login ubuntu --user user
EOF

chmod +x $PREFIX/bin/ubuntu-user

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Ubuntu installed successfully with proot-distro"
echo ""
echo "Available shortcuts:"
echo "  ubuntu      - Login as root"
echo "  ubuntu-user - Login as user (after user setup)"
echo ""
echo "Next step: Run 02_setup_user.sh to configure system"
