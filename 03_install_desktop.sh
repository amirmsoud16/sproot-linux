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

# Create a simple Wine game launcher script
echo_section "Creating Wine game launcher"
cat > ~/wine-game-launcher.sh << 'EOL'
#!/bin/bash

# Wine Game Launcher
# Simple launcher to run Windows games and applications

echo "Wine Game Launcher"
echo "=================="
echo ""
echo "Enter path to Windows executable (game or application):"
read exe_path

echo ""
echo "Select graphics mode:"
echo "1. Normal"
echo "2. Virtual Desktop (1920x1080)"
echo "3. Virtual Desktop (1366x768)"
echo "4. Virtual Desktop (1024x768)"
echo ""
echo "Enter your choice (1-4):"
read mode

# Set graphics mode
export WINEPREFIX=~/.wine
export WINEARCH=win64

case $mode in
    1) 
        # Normal mode
        if [ -f "$exe_path" ]; then
            wine "$exe_path"
        else
            echo "File not found: $exe_path"
        fi
        ;;
    2) 
        # 1920x1080 virtual desktop
        if [ -f "$exe_path" ]; then
            wine explorer /desktop=game,1920x1080 "$exe_path"
        else
            echo "File not found: $exe_path"
        fi
        ;;
    3) 
        # 1366x768 virtual desktop
        if [ -f "$exe_path" ]; then
            wine explorer /desktop=game,1366x768 "$exe_path"
        else
            echo "File not found: $exe_path"
        fi
        ;;
    4) 
        # 1024x768 virtual desktop
        if [ -f "$exe_path" ]; then
            wine explorer /desktop=game,1024x768 "$exe_path"
        else
            echo "File not found: $exe_path"
        fi
        ;;
    *) 
        echo "Invalid choice, running in normal mode"
        if [ -f "$exe_path" ]; then
            wine "$exe_path"
        else
            echo "File not found: $exe_path"
        fi
        ;;
esac
EOL

chmod +x ~/wine-game-launcher.sh

# Create desktop directory if it doesn't exist
DESKTOP_DIR=~/Desktop
mkdir -p "$DESKTOP_DIR"

# Create a single desktop icon for the game launcher
create_wine_desktop_icon() {
    local app_name=$1
    local app_path=$2
    local icon_name=$3
    
    cat > "$DESKTOP_DIR/$app_name.desktop" << EOL
[Desktop Entry]
Name=$app_name
Exec=$app_path
Type=Application
Icon=$icon_name
Comment=Run Windows games and applications with Wine
Categories=Application;Game;
EOL
    
    chmod +x "$DESKTOP_DIR/$app_name.desktop"
    echo "Created desktop icon for $app_name"
}

# Create desktop icon for the game launcher script
create_wine_desktop_icon "Wine Game Launcher" "~/wine-game-launcher.sh" "wine"

# Install additional desktop integration packages
echo_section "Installing desktop integration packages"
sudo apt install -y --no-install-recommends \
    desktop-file-utils \
    xdg-utils

# Update desktop database
echo_section "Updating desktop database"
sudo update-desktop-database

# Install Wine icons
echo_section "Installing Wine icons"
sudo apt install -y --no-install-recommends \
    wine-icon-theme

# Final completion message
echo ""
echo "=== Wine Installation Complete! ==="
echo ""
echo "Wine has been installed with all necessary drivers for running"
echo "Windows games and applications."
echo ""
echo "A desktop icon has been created for the Wine Game Launcher."
echo "Click on it to run your Windows games or applications."
echo ""
echo "To run a Windows application or game manually, use:"
echo "  wine /path/to/application.exe"
echo ""
