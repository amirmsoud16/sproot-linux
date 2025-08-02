#!/bin/bash

# Script 3: Desktop Environment, VNC, Fonts and Themes Installation
# This script is meant to be run inside the Ubuntu proot environment

set -e

echo "=== Desktop Environment Installation ==="
echo ""

echo "=== Installing Desktop Environment ==="

# Update package lists
echo "Updating package lists..."
apt update

# Install XFCE desktop environment
echo "Installing XFCE desktop environment..."
apt install -y \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    thunar \
    mousepad \
    ristretto \
    parole \
    firefox \
    libreoffice

# Install VNC server
echo "Installing VNC server..."
apt install -y \
    tightvncserver \
    xfonts-base \
    xfonts-75dpi \
    xfonts-100dpi

# Install additional fonts
echo "Installing fonts..."
apt install -y \
    fonts-liberation \
    fonts-dejavu \
    fonts-noto \
    fonts-noto-color-emoji \
    fonts-roboto \
    fonts-ubuntu \
    fonts-opensymbol \
    ttf-mscorefonts-installer

# Install Persian/Arabic fonts
echo "Installing Persian/Arabic fonts..."
apt install -y \
    fonts-farsiweb \
    fonts-kacst \
    fonts-khmeros \
    fonts-lao \
    fonts-liberation \
    fonts-thai-tlwg

# Install themes and icons
echo "Installing themes and icons..."
apt install -y \
    arc-theme \
    numix-gtk-theme \
    numix-icon-theme \
    papirus-icon-theme \
    breeze-gtk-theme \
    breeze-icon-theme

# Install multimedia codecs
echo "Installing multimedia codecs..."
apt install -y \
    ubuntu-restricted-extras \
    vlc \
    audacity \
    gimp \
    inkscape

# Install development tools
echo "Installing development tools..."
apt install -y \
    code \
    gedit \
    git \
    curl \
    wget \
    htop \
    neofetch \
    tree \
    zip \
    unzip

# Configure VNC for user
echo "Configuring VNC for user..."

# Switch to user and configure VNC
su - user << 'USER_SETUP'
# Set VNC password with confirmation
while true; do
    echo "Please set a password for VNC access (at least 6 characters):"
    vncpasswd
    if [ $? -eq 0 ]; then
        echo "VNC password set successfully!"
        break
    else
        echo "Failed to set VNC password. Please try again."
    fi
done
chmod 600 ~/.vnc/passwd

# Create VNC startup script
cat > ~/.vnc/xstartup << 'VNC_STARTUP'
#!/bin/bash
xrdb $HOME/.Xresources
xsetroot -solid grey
export XKL_XMODMAP_DISABLE=1
export XDG_CURRENT_DESKTOP="XFCE"
export XDG_MENU_PREFIX="xfce-"
export XDG_RUNTIME_DIR="/tmp/runtime-user"
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR
startxfce4 &
VNC_STARTUP

chmod +x ~/.vnc/xstartup

# Configure XFCE settings
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml

# Set Persian keyboard layout
cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/keyboard.xml << 'KEYBOARD_XML'
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
KEYBOARD_XML

# Set theme preferences
cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'THEME_XML'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Arc-Dark"/>
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

# Clean package cache
echo "Cleaning package cache..."
echo "پاکسازی کش پکیج‌ها..."
apt autoremove -y
apt autoclean

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
