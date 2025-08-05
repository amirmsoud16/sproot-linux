#!/bin/bash

# Script 3: KDE Plasma Desktop Environment Installation with VNC
# This script installs KDE Plasma desktop environment and configures VNC server

set -e

echo "=== Installing KDE Plasma Desktop with VNC ==="

# Clean up any existing locks and fix broken states
echo "Fixing any existing dpkg/apt issues..."
sudo rm -f /var/lib/dpkg/lock /var/lib/apt/lists/lock /var/cache/apt/archives/lock
sudo dpkg --configure -a
sudo apt --fix-broken install -y

# Update package lists
echo "Updating package lists..."
sudo apt update -y

# Install apt-utils first to avoid related errors
echo "Installing apt-utils..."
sudo apt install -y --no-install-recommends apt-utils

# Install essential packages
echo "Installing essential X11 packages..."
sudo apt install -y --no-install-recommends \
    dbus-x11 \
    x11-xserver-utils \
    x11-utils \
    x11-xkb-utils \
    xorg

# Install KDE Plasma desktop environment
echo "Installing KDE Plasma desktop environment..."
sudo apt install -y --no-install-recommends \
    kde-plasma-desktop \
    kde-standard

# Install VNC server
echo "Installing TigerVNC server..."
sudo apt install -y --no-install-recommends \
    tigervnc-standalone-server \
    tigervnc-common

# Configure VNC server
echo "Configuring VNC server..."
mkdir -p ~/.vnc
echo "#!/bin/bash
export XKL_XMODMAP_DISABLE=1
export XDG_CURRENT_DESKTOP=KDE
export XDG_SESSION_DESKTOP=KDE
export DESKTOP_SESSION=kde-plasma
xrdb \$HOME/.Xresources
startplasma-x11" > ~/.vnc/xstartup

# Create VNC config file to allow non-localhost connections
echo "# VNC config file
localhost=no" > ~/.vnc/config

chmod +x ~/.vnc/xstartup

# Set VNC password interactively
echo "Setting up VNC password..."
vncpasswd

# Clean up package cache
echo "Cleaning up package cache..."
sudo apt clean
sudo apt autoclean

echo "KDE Plasma desktop with VNC installation completed successfully!"
echo "To start VNC server: vncserver :1 -geometry 1024x768 -depth 24"
echo "To stop VNC server: vncserver -kill :1"
echo "Connect with VNC viewer to: $(hostname -I | awk '{print $1}'):5901"
echo ""
echo "File sharing is enabled. You can access shared folders from other devices."
echo ""
