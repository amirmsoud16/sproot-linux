#!/bin/bash

# Script 3: KDE Plasma Desktop Environment Installation
# This script installs and configures KDE Plasma desktop

set -e

# Clean up any existing locks and fix broken states
echo "=== Fixing any existing dpkg/apt issues... ==="
sudo rm -f /var/lib/dpkg/lock /var/lib/apt/lists/lock /var/cache/apt/archives/lock
sudo dpkg --configure -a
sudo apt --fix-broken install -y

# Update package lists
echo "=== Updating package lists... ==="
sudo apt update -y
sudo apt install -y --no-install-recommends apt-utils

# Install essential packages first
echo "=== Installing essential packages... ==="
sudo apt install -y --no-install-recommends \
    dbus-x11 \
    x11-xserver-utils \
    x11-utils \
    x11-xkb-utils \
    xorg

# Install KDE Plasma and VNC components
echo "=== Installing KDE Plasma Desktop and VNC... ==="
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
sudo locale-gen fa_IR.UTF-8
sudo update-locale LANG=fa_IR.UTF-8

# Create VNC configuration
echo "=== Configuring VNC server... ==="
mkdir -p ~/.vnc

# Create xstartup file for KDE
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

# Set VNC password (default: password)
echo -e "password\npassword\nn" | vncpasswd >/dev/null 2>&1

# Create VNC server config
mkdir -p ~/.vnc
cat > ~/.vnc/config << 'EOL'
# VNC Server Configuration
desktop=KDE Plasma
geometry=1920x1080
depth=24
localhost=no
securitytypes=vncauth,tlsvnc
EOL

# Create VNC start/stop scripts
cat > ~/start-vnc.sh << 'EOL'
#!/bin/bash
vncserver -geometry 1920x1080 -depth 24 -localhost no :1
echo "VNC server started at 1920x1080 resolution"
echo "Connect with VNC viewer to: $(hostname -I | awk '{print $1}'):5901"
EOL

cat > ~/stop-vnc.sh << 'EOL'
#!/bin/bash
vncserver -kill :1 2>/dev/null
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
echo "VNC server stopped"
EOL

chmod +x ~/start-vnc.sh ~/stop-vnc.sh

# Configure KDE settings
echo "=== Configuring KDE Plasma desktop... ==="
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
echo "=== Configuring file sharing... ==="
sudo systemctl enable --now smbd
sudo systemctl enable --now nmbd

# Create VNC autostart entry
echo "=== Configuring VNC autostart... ==="
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/vnc.desktop << 'EOL'
[Desktop Entry]
Name=VNC Server
Exec=/home/user/start-vnc.sh
Type=Application
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOL

# Clean up
echo "=== Cleaning up... ==="
sudo apt autoremove -y
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*

echo ""
echo "=== KDE Plasma Desktop Installation Complete! ==="
echo ""
echo "To start VNC server: ~/start-vnc.sh"
echo "To stop VNC server:  ~/stop-vnc.sh"
echo ""
echo "Connect with VNC viewer to: $(hostname -I | awk '{print $1}'):5901"
echo "Default VNC password: password"
echo ""
echo "You can change the VNC password by running: vncpasswd"
echo ""
echo "File sharing is enabled. You can access shared folders from other devices."
echo ""
echo "The system will automatically start VNC on login."
echo "To disable auto-start, remove: ~/.config/autostart/vnc.desktop"
echo ""
# Clean up
echo "=== Cleaning up... ==="
sudo apt autoremove -y
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*

echo ""
echo "=== KDE Plasma Desktop Installation Complete! ==="
echo ""
echo "To start VNC server: ~/start-vnc.sh"
echo "To stop VNC server:  ~/stop-vnc.sh"
echo ""
echo "Connect with VNC viewer to: $(hostname -I | awk '{print $1}'):5901"
echo "Default VNC password: password"
echo ""
echo "You can change the VNC password by running: vncpasswd"
echo ""
echo "File sharing is enabled. You can access shared folders from other devices."
echo ""
echo "The system will automatically start VNC on login."

echo ""
echo "=== Desktop Environment Setup Complete! ==="
echo ""
echo "Available commands:"
echo "  proot-distro login ubuntu           - Login as root"
echo "  proot-distro login ubuntu --user user - Login as user"
echo "  start-vnc   - Start VNC server"
echo "  stop-vnc    - Stop VNC server"
echo ""
echo "VNC Connection Details:"
echo "  Address: localhost:5901"
echo "  Password: vnc123"
echo ""
echo "Desktop Environment: XFCE4 with Arc-Dark theme"
echo "Keyboard Layout: US/Persian (Alt+Shift to switch)"
