#!/bin/bash

# Wine Installation Script
# This script installs Wine and all necessary drivers for running lightweight Windows software and games

set -e

# Function to print section headers
echo_section() {
    echo "=== $1 ==="
}

# Clean up any existing locks and fix broken states
echo_section "Fixing any existing dpkg/apt issues"
sudo rm -f /var/lib/dpkg/lock /var/lib/apt/lists/lock /var/cache/apt/archives/lock
sudo dpkg --configure -a
sudo apt --fix-broken install -y

# Update package lists
echo_section "Updating package lists"
sudo apt update -y

# Install apt-utils first
echo_section "Installing apt-utils"
sudo apt install -y --no-install-recommends apt-utils

# Install Wine and all necessary drivers/components
echo_section "Installing Wine and all drivers"
sudo apt install -y --no-install-recommends \
    wine \
    wine32 \
    wine64 \
    libwine \
    fonts-wine \
    wine-binfmt \
    cabextract \
    libgl1 \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libglu1 \
    libglu1-mesa \
    libasound2 \
    libasound2-plugins \
    alsa-utils \
    alsa-oss \
    pulseaudio \
    pulseaudio-utils \
    x11-utils \
    x11-apps \
    x11-xserver-utils \
    libx11-6 \
    libx11-xcb1 \
    libxext6 \
    libxrender1 \
    libxrandr2 \
    libxinerama1 \
    libxi6 \
    libxcursor1 \
    libxxf86vm1 \
    libxss1 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxi-dev \
    libxcursor-dev \
    libxxf86vm-dev \
    libxss-dev \
    libxcomposite-dev \
    libxdamage-dev \
    libxfixes-dev

# Install additional graphics libraries for better compatibility
echo_section "Installing additional graphics libraries"
sudo apt install -y --no-install-recommends \
    libvulkan1 \
    libvulkan-dev \
    vulkan-tools \
    mesa-vulkan-drivers \
    mesa-vulkan-drivers:i386 \
    libvkd3d1 \
    libvkd3d-dev \
    libvkd3d-demos

# Install additional audio libraries
echo_section "Installing additional audio libraries"
sudo apt install -y --no-install-recommends \
    libopenal1 \
    libopenal-dev \
    libsndio7.0 \
    libsndio-dev

# Install additional utilities for Windows software compatibility
echo_section "Installing Windows compatibility utilities"
sudo apt install -y --no-install-recommends \
    winbind \
    libgnutls30 \
    libgnutls30:i386 \
    dosbox \
    dos2unix \
    unix2dos

# Configure Wine
echo_section "Configuring Wine"
# Create Wine directory and configuration files
mkdir -p ~/.wine

# Set up 32-bit and 64-bit Wine prefixes
export WINEARCH=win64
export WINEPREFIX=~/.wine

# Initialize Wine
wineboot --init

echo ""
echo "=== Wine Installation Complete! ==="
echo ""
echo "Wine has been installed with all necessary drivers for running"
echo "lightweight Windows software and games."
echo ""
echo "To run a Windows application or game, use:"
echo "  wine /path/to/application.exe"
echo ""
echo "For 32-bit applications, you might need to create a separate prefix:"
echo "  WINEARCH=win32 WINEPREFIX=~/.wine32 winecfg"
echo ""
echo "Additional tools installed:"
echo "  - DOSBox (for DOS games)"
echo "  - winbind (Windows integration)"
echo "  - libgnutls (security protocol support)"
echo ""
