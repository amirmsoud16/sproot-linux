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
sudo apt install dbus-x11 -y

# Install GNOME Desktop and essential components
echo "=== Installing GNOME Desktop with Windows 11 theme... ==="
sudo apt install -y --no-install-recommends \
    ubuntu-desktop-minimal \
    gnome-shell-extension-prefs \
    gnome-tweaks \
    gnome-software \
    gnome-software-common \
    gnome-software-plugin-flatpak \
    gnome-shell-extensions \
    gnome-shell-extension-ubuntu-dock \
    gnome-shell-extension-appindicator \
    tigervnc-standalone-server \
    tigervnc-common \
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
    gvfs-backends

# Install Windows 11 theme components
echo "=== Installing Windows 11 theme... ==="
sudo apt install -y --no-install-recommends \
    gnome-shell-extension-dashtodock \
    gnome-shell-extension-desktop-icons-ng \
    gnome-shell-extension-appindicator

# Create VNC configuration
echo "=== Configuring VNC server... ==="
mkdir -p ~/.vnc

# Create xstartup file for GNOME
cat > ~/.vnc/xstartup << 'EOL'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_SESSION_TYPE=x11
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
export XDG_CONFIG_DIRS=/etc/xdg/xdg-ubuntu:/etc/xdg
export XDG_DATA_DIRS=/usr/share/ubuntu:/usr/local/share:/usr/share:/var/lib/snapd/desktop

exec /usr/bin/gnome-session --session=ubuntu
EOL

chmod +x ~/.vnc/xstartup

# Set VNC password (default: password)
echo -e "password\npassword\nn" | vncpasswd >/dev/null 2>&1

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

# Configure GNOME settings
echo "=== Configuring GNOME desktop... ==="
# Set Windows 11 like layout
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
gsettings set org.gnome.desktop.wm.preferences theme 'Yaru-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Yaru'
gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'
gsettings set org.gnome.desktop.interface font-name 'Ubuntu 11'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Ubuntu Bold 11'

# Configure dock
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 32
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true

# Configure window controls
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

# Configure keyboard layout for Persian/English
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ir')]"
gsettings set org.gnome.desktop.input-sources xkb-options "['grp:alt_shift_toggle']"

# Enable file sharing
echo "=== Configuring file sharing... ==="
sudo systemctl enable --now smbd
sudo systemctl enable --now nmbd

# Clean up
echo "=== Cleaning up... ==="
sudo apt autoremove -y
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*

echo ""
echo "=== GNOME Desktop with Windows 11 Theme Installation Complete! ==="
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
