#!/bin/bash

# Script 3: Optimized Desktop Environment Installation
# This script installs a minimal but complete XFCE desktop environment

set -e

# Set faster APT settings
echo 'APT::Acquire::Retries "3";' | sudo tee /etc/apt/apt.conf.d/80-retries
echo 'APT::Install-Recommends "false";' | sudo tee -a /etc/apt/apt.conf.d/80-retries

# Clean up any existing locks and fix broken states
echo "=== Fixing any existing dpkg/apt issues... ==="
sudo rm -f /var/lib/dpkg/lock /var/lib/apt/lists/lock /var/cache/apt/archives/lock
sudo dpkg --configure -a
sudo apt --fix-broken install -y

# Update package lists
echo "=== Updating package lists... ==="
sudo apt update -y
sudo apt install -y --no-install-recommends apt-utils

# Install everything in one go to minimize download/install time
echo "=== Installing all required packages... ==="
sudo apt install -y --no-install-recommends \
    xfce4 xfce4-goodies xfce4-terminal \
    thunar mousepad ristretto parole \
    firefox \
    tightvncserver xfonts-base xfonts-75dpi xfonts-100dpi \
    fonts-liberation fonts-dejavu fonts-noto fonts-noto-color-emoji \
    fonts-farsiweb fonts-kacst \
    arc-theme \
    ubuntu-restricted-extras vlc

# Clean up to save space
echo "=== Cleaning up... ==="
sudo apt autoremove -y
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*

# Configure VNC server
echo "=== Configuring VNC server... ==="
mkdir -p ~/.vnc

# Create xstartup file
cat > ~/.vnc/xstartup << 'EOL'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_RUNTIME_DIR="/tmp/runtime-$(whoami)"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"
startxfce4 &
EOL

chmod +x ~/.vnc/xstartup

# Set VNC password (default: password)
echo -e "password\npassword\nn" | vncpasswd >/dev/null 2>&1

# Create VNC start/stop scripts
cat > ~/start-vnc.sh << 'EOL'
#!/bin/bash
vncserver -geometry 1280x720 -localhost no :1
EOL

cat > ~/stop-vnc.sh << 'EOL'
#!/bin/bash
vncserver -kill :1 2>/dev/null
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
EOL

chmod +x ~/start-vnc.sh ~/stop-vnc.sh

# Configure XFCE settings
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml

# Set Persian keyboard layout
cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/keyboard.xml << 'EOL'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="keyboard" version="1.0">
  <property name="Default" type="empty">
    <property name="Numlock" type="bool" value="false"/>
    <property name="Compose" type="string" value=""/>
    <property name="RepeatDelay" type="int" value="500"/>
    <property name="RepeatRate" type="int" value="20"/>
  </property>
  <property name="Layout" type="empty">
    <property name="Default" type="empty">
      <property name="XkbDisable" type="bool" value="false"/>
      <property name="XkbLayout" type="string" value="us,ir"/>
      <property name="XkbVariant" type="string" value=","/>
      <property name="XkbOptions" type="string" value="grp:alt_shift_toggle"/>
    </property>
  </property>
</channel>
EOL

# Set theme preferences
cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'EOL'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Arc-Dark"/>
    <property name="IconThemeName" type="string" value="Papirus-Dark"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI" type="int" value="96"/>
    <property name="Antialias" type="int" value="1"/>
    <property name="Hinting" type="int" value="1"/>
    <property name="HintStyle" type="string" value="hintfull"/>
    <property name="RGBA" type="string" value="rgb"/>
  </property>
</channel>
EOL

# Create desktop entry for VNC autostart
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/vnc.desktop << 'EOL'
[Desktop Entry]
Type=Application
Name=Start VNC Server
Exec=/bin/bash -c 'sleep 5 && $HOME/start-vnc.sh'
StartupNotify=false
EOL

# Set proper permissions
chmod 700 ~/.vnc
chmod 600 ~/.vnc/passwd

# Completion message
echo ""
echo "=== Installation Complete! ==="
echo ""
echo "To start VNC server: ~/start-vnc.sh"
echo "To stop VNC server:  ~/stop-vnc.sh"
echo ""
echo "Connect with VNC viewer to: <YOUR_DEVICE_IP>:5901"
echo "Default VNC password: password"
echo ""
echo "You can change the VNC password by running: vncpasswd"
echo ""
echo "The system will automatically start VNC on login."
echo "To disable auto-start, remove: ~/.config/autostart/vnc.desktop"
echo ""
    <property name="IconThemeName" type="string" value="Papirus-Dark"/>
    <property name="DoubleClickTime" type="int" value="400"/>
    <property name="DoubleClickDistance" type="int" value="5"/>
    <property name="DndDragThreshold" type="int" value="8"/>
    <property name="CursorBlink" type="bool" value="true"/>
    <property name="CursorBlinkTime" type="int" value="1200"/>
    <property name="SoundThemeName" type="string" value="default"/>
    <property name="EnableEventSounds" type="bool" value="false"/>
    <property name="EnableInputFeedbackSounds" type="bool" value="false"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI" type="int" value="96"/>
    <property name="Antialias" type="int" value="1"/>
    <property name="Hinting" type="int" value="1"/>
    <property name="HintStyle" type="string" value="hintslight"/>
    <property name="RGBA" type="string" value="rgb"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="CanChangeAccels" type="bool" value="false"/>
    <property name="ColorPalette" type="string" value="black:white:gray50:red:purple:blue:light blue:green:yellow:orange:lavender:brown:goldenrod4:dodger blue:pink:light green:gray10:gray30:gray75:gray90"/>
    <property name="FontName" type="string" value="Ubuntu 10"/>
    <property name="MonospaceFontName" type="string" value="Ubuntu Mono 11"/>
    <property name="IconSizes" type="string" value=""/>
    <property name="KeyThemeName" type="string" value=""/>
    <property name="ToolbarStyle" type="string" value="icons"/>
    <property name="ToolbarIconSize" type="int" value="3"/>
    <property name="MenuImages" type="bool" value="true"/>
    <property name="ButtonImages" type="bool" value="true"/>
    <property name="MenuBarAccel" type="string" value="F10"/>
    <property name="CursorThemeName" type="string" value=""/>
    <property name="CursorThemeSize" type="int" value="0"/>
    <property name="DecorationLayout" type="string" value="menu:minimize,maximize,close"/>
  </property>
</channel>
THEME_XML

USER_SETUP

# Clean package cache with sudo
echo "Cleaning package cache..."
echo "پاکسازی کش پکیج‌ها..."
sudo apt autoremove -y
sudo apt autoclean

echo ""
echo "=== Desktop Installation Complete! ==="
echo ""
echo "To start VNC server, run:"
echo "vncserver :1 -geometry 1024x768 -depth 24"
echo ""
echo "To stop VNC server, run:"
echo "vncserver -kill :1"

echo "VNC server stopped"
EOF

chmod +x $PREFIX/bin/stop-vnc

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
