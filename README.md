# Ubuntu Chroot Installer for Android

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Android](https://img.shields.io/badge/Platform-Android-green.svg)](https://www.android.com/)
[![Termux](https://img.shields.io/badge/Termux-Supported-blue.svg)](https://termux.com/)

A comprehensive, professional Ubuntu chroot installer for Android devices with Termux. This script provides a complete Ubuntu environment with desktop support, hardware acceleration, and one-click startup capabilities.

## 🌟 Features

- **Real Chroot Environment** - Full root access and maximum performance
- **Multiple Desktop Environments** - XFCE4 and KDE Plasma support
- **Hardware Acceleration** - virglrenderer for OpenGL support
- **SSH Service** - Remote access to Ubuntu environment
- **One-Click Startup** - Termux Widget integration
- **Complete Management** - Install, uninstall, and status checking
- **Professional UI** - Colored output and interactive menus
- **Automatic Setup** - DNS, users, locales, and system configuration

## ⚠️ Requirements

### 🔴 **CRITICAL: Root Access Required!**

This installer uses **real chroot** (not proot) for maximum performance. Root access is mandatory.

### 💻 **Hardware Requirements:**
- **Processor**: Qualcomm Snapdragon 845 or above (recommended)
- **RAM**: 6GB minimum (4GB may work but not recommended)
- **Storage**: 10GB minimum free space
- **Android**: 8.0 (API 26) or higher

### 📱 **Software Requirements:**
- **Rooted Android device**
- **Termux** (from F-Droid recommended)
- **Busybox** (via Magisk module)
- **Termux X11** (for desktop environment)
- **Termux Widget** (for one-click startup)

## 🚀 Quick Start

### **One-Command Installation:**

```bash
# Download and run installer
curl -fsSL https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/ubuntu_chroot_installer.sh | su -c 'bash -s install xfce'
```

### **Manual Installation:**

```bash
# 1. Download the script
wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/ubuntu_chroot_installer.sh

# 2. Make executable
chmod +x ubuntu_chroot_installer.sh

# 3. Run installer
su -c './ubuntu_chroot_installer.sh install xfce'
```

## 📋 Installation Guide

### **Step 1: Prepare Your Device**

1. **Root your Android device** (if not already rooted)
2. **Install Magisk** and flash Busybox module
3. **Install Termux** from F-Droid
4. **Install Termux X11** for desktop support
5. **Install Termux Widget** for one-click startup

### **Step 2: Run the Installer**

```bash
# Interactive mode (recommended)
su -c './ubuntu_chroot_installer.sh'

# Command line mode
su -c './ubuntu_chroot_installer.sh install xfce'  # XFCE4
su -c './ubuntu_chroot_installer.sh install kde'   # KDE Plasma
su -c './ubuntu_chroot_installer.sh cli'           # Command line only
```

### **Step 3: First Boot**

After installation, the script will automatically:
- Configure DNS resolution
- Create user accounts
- Set up locales
- Install essential packages
- Configure desktop environment (if selected)

## 🎯 Usage

### **Interactive Menu Mode**
```bash
su -c './ubuntu_chroot_installer.sh'
```

Choose from:
- **1)** Install Ubuntu with XFCE4
- **2)** Install Ubuntu with KDE
- **3)** Install Ubuntu CLI only
- **4)** Setup SSH service
- **5)** Check status
- **6)** Uninstall Ubuntu
- **7)** Help
- **8)** Exit

### **Command Line Mode**
```bash
# Install with desktop
su -c './ubuntu_chroot_installer.sh install xfce'
su -c './ubuntu_chroot_installer.sh install kde'

# Install CLI only
su -c './ubuntu_chroot_installer.sh cli'

# Setup SSH
su -c './ubuntu_chroot_installer.sh ssh'

# Check status
su -c './ubuntu_chroot_installer.sh status'

# Uninstall
su -c './ubuntu_chroot_installer.sh uninstall'

# Show help
su -c './ubuntu_chroot_installer.sh help'
```

## 🖥️ Desktop Environment

### **Starting Desktop**

#### **Method 1: Widget Script (Recommended)**
1. Add Termux Widget to your home screen
2. Select `start_chrootubuntu.sh`
3. Ubuntu desktop will start automatically

#### **Method 2: Manual Start**
```bash
# Start X11 server
XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :0 -ac &

# Start PulseAudio
pulseaudio --start --exit-idle-time=-1

# Start virgl server
virgl_test_server_android &

# Start Ubuntu desktop
su -c 'sh /data/local/tmp/startu.sh'
```

### **Desktop Environments**

#### **XFCE4 (Lightweight)**
- **Command**: `startxfce4`
- **Size**: ~1.5GB
- **Performance**: Excellent
- **Recommended for**: Older devices

#### **KDE Plasma (Full-featured)**
- **Command**: `startplasma-x11`
- **Size**: ~3GB
- **Performance**: Good
- **Recommended for**: Modern devices

## 🔧 SSH Access

### **Setup SSH Service**
```bash
su -c './ubuntu_chroot_installer.sh ssh'
```

### **Connect via SSH**
```bash
# From your computer
ssh root@[PHONE_IP]

# Default credentials
Username: root
Password: ubuntu123
```

### **Find IP Address**
```bash
# In Ubuntu chroot
ifconfig | grep "inet " | grep -v 127.0.0.1
```

## 📁 File Structure

```
/data/local/tmp/
├── chrootubuntu/          # Ubuntu rootfs
│   ├── etc/
│   ├── usr/
│   ├── home/
│   └── ...
├── startu.sh              # Startup script

$HOME/.shortcuts/
└── start_chrootubuntu.sh  # Widget script
```

## 🔧 Configuration

### **Default Credentials**
- **Root user**: `root` / `ubuntu123`
- **Desktop user**: `user` / `ubuntu123`

### **Timezone Setup**
The script sets timezone to `Asia/Tehran` by default. To change:

```bash
# In Ubuntu chroot
sudo ln -sf /usr/share/zoneinfo/[YOUR_TIMEZONE] /etc/localtime
```

### **Locale Configuration**
- **English**: `en_US.UTF-8`
- **Persian**: `fa_IR.UTF-8`

## 🚨 Troubleshooting

### **Common Issues**

#### **"Device not rooted" Error**
```bash
# Check root access
su -c 'whoami'  # Should return 'root'

# Install Magisk and Busybox
# Then try again
```

#### **"Permission denied" Error**
```bash
# Make script executable
chmod +x ubuntu_chroot_installer.sh

# Run as root
su -c './ubuntu_chroot_installer.sh'
```

#### **Desktop Won't Start**
```bash
# Check if Termux X11 is installed
# Install from: https://github.com/termux/termux-x11

# Check if virglrenderer is installed
pkg install virglrenderer

# Restart X11 server
killall termux-x11
XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :0 -ac &
```

#### **SSH Connection Failed**
```bash
# Check if SSH service is running
ps aux | grep sshd

# Restart SSH service
sudo systemctl restart ssh
# or
sudo /usr/sbin/sshd -D &
```

#### **Out of Storage**
```bash
# Check available space
df -h

# Clean package cache
sudo apt clean
sudo apt autoremove

# Remove old kernels (if any)
sudo apt autoremove --purge
```

### **Performance Optimization**

#### **For Better Performance:**
1. **Close unnecessary apps** before starting Ubuntu
2. **Use XFCE4** instead of KDE on older devices
3. **Increase swap space** if available
4. **Disable animations** in desktop environment

#### **For Better Compatibility:**
1. **Update Termux** to latest version
2. **Install virglrenderer** for hardware acceleration
3. **Use stable Ubuntu version** (24.04 LTS)

## 🔒 Security Notes

### **⚠️ Important Security Considerations:**

1. **Root Access**: This script requires root access and provides full system control
2. **SSH Access**: Default passwords are used - change them after installation
3. **Network Access**: SSH service may expose your device to network access
4. **File Permissions**: Chroot environment has full access to mounted directories

### **Security Recommendations:**

1. **Change default passwords** immediately after installation
2. **Configure firewall** if using SSH
3. **Keep Ubuntu updated** regularly
4. **Use strong passwords** for all accounts
5. **Disable SSH** if not needed

## 📊 System Information

### **What Gets Installed:**

#### **System Packages:**
- `curl`, `wget` - Download utilities
- `tar`, `xz-utils` - Archive utilities
- `pulseaudio` - Audio support
- `busybox` - Essential utilities

#### **Ubuntu Packages:**
- `xfce4` or `kubuntu-desktop` - Desktop environment
- `firefox-esr` - Web browser
- `gedit` - Text editor
- `gimp` - Image editor
- `vlc` - Media player
- `openssh-server` - SSH service
- `sudo`, `vim`, `git` - Development tools

### **Performance Metrics:**
- **Boot Time**: ~30-60 seconds
- **Memory Usage**: 1-2GB (XFCE4), 2-3GB (KDE)
- **Storage Usage**: 5-8GB (depending on desktop)
- **CPU Usage**: 10-30% (idle)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **[Ivon's Blog](https://ivonblog.com/en-us/posts/termux-chroot-ubuntu/)** - Original guide and inspiration
- **[Termux](https://termux.com/)** - Android terminal emulator
- **[Ubuntu](https://ubuntu.com/)** - Linux distribution
- **[XFCE](https://xfce.org/)** - Lightweight desktop environment
- **[KDE](https://kde.org/)** - Plasma desktop environment
- **Android Linux community** - Support and testing

## 📞 Support

### **Getting Help:**

1. **Check the troubleshooting section** above
2. **Search existing issues** on GitHub
3. **Create a new issue** with detailed information:
   - Android version
   - Device model
   - Error messages
   - Steps to reproduce

### **Useful Links:**
- **[Termux Wiki](https://wiki.termux.com/)**
- **[Ubuntu Documentation](https://ubuntu.com/tutorials)**
- **[Android Rooting Guide](https://www.xda-developers.com/root/)**

---

## ⭐ Star This Repository

If this project helped you, please give it a star! It motivates us to continue improving the installer.

## 🔄 Updates

Stay updated with the latest features and improvements:

```bash
# Check for updates
wget -O ubuntu_chroot_installer.sh https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/ubuntu_chroot_installer.sh

# Reinstall with latest version
su -c './ubuntu_chroot_installer.sh uninstall'
su -c './ubuntu_chroot_installer.sh install xfce'
```

---

**🔴 Remember: Root access is required for this installer!**

**📱 Enjoy your Ubuntu experience on Android!** 