#!/bin/bash

# Script 3: KDE Plasma Desktop Environment Installation
# This script installs and configures KDE Plasma desktop with VNC support

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
sudo apt install -y --no-install-recommends apt-utils

# Install essential packages first
echo_section "Installing essential packages"
sudo apt install -y --no-install-recommends \
    dbus-x11 \
    x11-xserver-utils \
    x11-utils \
    x11-xkb-utils \
    xorg

# Install KDE Plasma and VNC components
echo_section "Installing KDE Plasma Desktop and VNC"
sudo apt install -y --no-install-recommends \
    kde-plasma-desktop \
    kde-standard \
    sddm \
    tigervnc-standalone-server \
    tigervnc-common \
    tigervnc-xorg-extension \
    tigervnc-viewer \
    xfonts-base \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-scalable \
    fonts-noto \
    fonts-farsiweb \
    fonts-liberation \
    fonts-dejavu \
    ubuntu-restricted-extras \
    vlc \
    samba \
    samba-common \
    gvfs-backends \
    language-pack-fa \
    language-pack-kde-fa \
    kde-config-gtk-style \
    kde-config-screenlocker \
    kde-config-sddm \
    xserver-xorg-core \
    xserver-xorg-video-dummy \
    xserver-xorg-input-libinput

# Set system language to Persian
export LANGUAGE=fa_IR.UTF-8
export LANG=fa_IR.UTF-8
export LC_ALL=fa_IR.UTF-8

# Generate Persian locale
echo_section "Generating Persian locale"
sudo locale-gen fa_IR.UTF-8

# Configure VNC server
echo_section "Configuring VNC server"
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup << 'EOL'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Set environment variables
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
export XDG_SESSION_DESKTOP=KDE
export XDG_CONFIG_DIRS=/etc/xdg/xdg-kde-plasma:/etc/xdg
export XDG_DATA_DIRS=/usr/share/kde-plasma:/usr/local/share:/usr/share

# Start KDE Plasma
exec /usr/bin/startplasma-x11 > ~/.vnc/plasma-startup.log 2>&1
EOL

chmod +x ~/.vnc/xstartup

# Set VNC server configuration
cat > ~/.vnc/config << 'EOL'
geometry=1920x1080
depth=24
localhost=no
securitytypes=vncauth,tlsvnc
EOL

# Configure KDE settings
echo_section "Configuring KDE Plasma desktop"
# Create config directory if it doesn't exist
mkdir -p ~/.config

# Set Persian keyboard layout
cat > ~/.config/kcminputrc << 'EOL'
[Keyboard]
Layout=us,ir
LayoutList=us,ir
Options=grp:alt_shift_toggle
ResetOldOptions=true
EOL

# Set KDE theme to Breeze Dark
cat > ~/.config/kdeglobals << 'EOL'
[KDE]
ColorScheme=BreezeDark
LookAndFeelPackage=org.kde.breezedark.desktop
widgetStyle=Breeze
EOL

# Enable file sharing
echo_section "Configuring file sharing"
sudo systemctl enable --now smbd
sudo systemctl enable --now nmbd

# Clean up
echo_section "Cleaning up"
sudo apt autoremove -y
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*

# Final completion message
echo ""
echo "=== KDE Plasma Desktop Installation Complete! ==="
echo ""
echo "To start VNC server: vncserver :1"
echo "To stop VNC server:  vncserver -kill :1"
echo ""
echo "Connect with VNC viewer to: $(hostname -I | awk '{print $1}'):5901"
echo ""
echo "File sharing is enabled. You can access shared folders from other devices."
echo ""
