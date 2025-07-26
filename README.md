# Ubuntu Installer for Termux (Root Required)

A powerful Ubuntu installer for Termux that uses real chroot for maximum performance and compatibility.

## 🚀 Features

- **Real chroot** - Full root access and performance
- **Interactive Menu** - User-friendly menu-driven interface
- **VNC Support** - Remote desktop access via VNC
- **Complete Management** - Install, uninstall, and status checking
- **XFCE Desktop** - Lightweight desktop environment
- **Service Management** - Start/stop Ubuntu as a service

## ⚠️ Requirements

**🔴 IMPORTANT: Root Access Required!**

### 📱 **Device Requirements:**
- **Rooted Android device** (essential for chroot functionality)
- **Android 7.0+** (API level 24 or higher)
- **ARM64 or x86_64 architecture**
- **At least 4GB RAM** (recommended)
- **At least 5GB free storage** (Ubuntu + packages + cache)

### 📲 **App Requirements:**
- **Termux app** installed from F-Droid (recommended) or GitHub
- **VNC Viewer app** for desktop access (optional but recommended)
- **File Manager** with root access (optional)

### 🌐 **Network Requirements:**
- **Stable internet connection** (WiFi recommended)
- **Download speed:** At least 1 Mbps
- **Total download:** ~2.5GB (Ubuntu rootfs + packages)

### 🔧 **System Requirements:**
- **Root access** with working `su` command
- **Busybox** installed (usually comes with root)
- **Termux packages** updated to latest version

## ⚡ Quick Start

**For experienced users - One command installation:**

```bash
# Install prerequisites and run installer
pkg update -y && pkg upgrade -y && pkg install -y curl proot tar xz-utils pulseaudio tigervnc git && git clone https://github.com/amirmsoud16/ubuntu-chroot-pk-.git && cd ubuntu-chroot-pk- && chmod +x ubuntu_installer.sh && su -c './ubuntu_installer.sh'
```

## 🛠️ Installation

### 🔧 **Step 1: Install Prerequisites**
```bash
# Update Termux packages
pkg update -y && pkg upgrade -y

# Install required packages
pkg install -y curl proot tar xz-utils pulseaudio tigervnc git

# Install additional useful packages
pkg install -y wget nano vim
```

### 📥 **Step 2: Download and Setup**
```bash
# Clone the repository
git clone https://github.com/amirmsoud16/ubuntu-chroot-pk-.git
cd ubuntu-chroot-pk-

# Make script executable
chmod +x ubuntu_installer.sh
```

### 🚀 **Step 3: Run Installation**
```bash
# Run as root (recommended method)
su -c './ubuntu_installer.sh'

# Or if you have sudo access
sudo ./ubuntu_installer.sh
```

### ✅ **Step 4: Verify Installation**
```bash
# Check if Ubuntu is installed
su -c './ubuntu_installer.sh status'

# Test Ubuntu command
ubuntu help
```

## 🎯 Usage

### Interactive Menu Mode (Recommended)
```bash
su -c './ubuntu_installer.sh'
```

This will show an interactive menu with options:
- **1)** Install Ubuntu
- **2)** Uninstall Ubuntu
- **3)** Check Status
- **4)** Help
- **5)** Exit

### Command Line Mode
```bash
# Install Ubuntu
su -c './ubuntu_installer.sh install'

# Uninstall Ubuntu
su -c './ubuntu_installer.sh uninstall'

# Check status
su -c './ubuntu_installer.sh status'

# Show help
su -c './ubuntu_installer.sh help'
```

## 🖥️ After Installation

### First Time Setup
1. Run: `ubuntu cli`
2. Inside Ubuntu, run: `./init-ubuntu.sh`
3. Exit Ubuntu and run: `ubuntu desktop`

### Using Ubuntu
```bash
# Start Ubuntu with desktop (VNC)
ubuntu

# Start Ubuntu command line
ubuntu cli

# Stop VNC server
ubuntu stop

# Show Ubuntu help
ubuntu help
```

### VNC Connection
- **Port:** 5901
- **Connect to:** `your-device-ip:5901`
- **Password:** (set during first run)

## 📁 Installation Path

Ubuntu will be installed to:
```
/data/data/com.termux/files/home/ubuntu/
```

## 🔧 What Gets Installed

### Termux Packages
- `curl` - Download manager
- `tar` - Archive utility
- `xz-utils` - Compression
- `pulseaudio` - Audio support
- `tigervnc` - VNC server for remote desktop

### Ubuntu Packages
- `xfce4` - Desktop environment
- `xfce4-goodies` - Additional XFCE tools
- `tightvncserver` - VNC server
- `dbus-x11` - Desktop bus
- `firefox-esr` - Web browser
- `gedit` - Text editor
- `gimp` - Image editor
- `vlc` - Media player

## 🗂️ Files Created

- `/data/data/com.termux/files/home/ubuntu/` - Ubuntu rootfs directory
- `/data/data/com.termux/files/home/ubuntu` - Ubuntu command script
- `/data/data/com.termux/files/home/ubuntu-service` - Service management script
- `/data/data/com.termux/files/home/.shortcuts/Ubuntu` - Desktop shortcut
- `/data/data/com.termux/files/home/.vnc/` - VNC configuration

## 🚨 Troubleshooting

### Common Issues

**Root Access Required**
- Make sure your device is rooted
- Test root access: `su -c 'whoami'` (should return 'root')
- Run with: `su -c './ubuntu_installer.sh'`

**pkg: command not found**
- Make sure you're running in Termux app
- Install Termux from F-Droid (recommended)
- Don't run in regular terminal or other environments

**Download Failed**
- Check internet connection
- Try again: `su -c './ubuntu_installer.sh install'`
- Use WiFi instead of mobile data

**VNC Connection Failed**
- Check if VNC server is running: `vncserver -list`
- Restart VNC: `vncserver -kill :1 && vncserver -localhost no`
- Install VNC Viewer app

**Ubuntu Won't Start**
- Check status: `su -c './ubuntu_installer.sh status'`
- Reinstall: `su -c './ubuntu_installer.sh uninstall && ./ubuntu_installer.sh install'`
- Check available storage: `df -h`

**Permission Denied**
- Make script executable: `chmod +x ubuntu_installer.sh`
- Run as root: `su -c './ubuntu_installer.sh'`
- Check file permissions: `ls -la ubuntu_installer.sh`

**Out of Storage**
- Free up space: `pkg clean`
- Remove old packages: `pkg autoremove`
- Check storage: `df -h /data/data/com.termux/files/home`

### Logs
- Ubuntu logs: `/data/data/com.termux/files/home/ubuntu.log`
- VNC logs: `/data/data/com.termux/files/home/.vnc/`

## 🔒 Security Note

**⚠️ Warning:** This script requires root access and uses real chroot. This provides:
- **Full system access** within the chroot environment
- **Maximum performance** and compatibility
- **Complete isolation** from the host system
- **Potential security risks** if misused

## 🤝 Contributing

1. Fork the repository: [https://github.com/amirmsoud16/ubuntu-chroot-pk-](https://github.com/amirmsoud16/ubuntu-chroot-pk-)
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Andronix](https://github.com/AndronixApp) for Ubuntu rootfs
- Termux community for Android Linux support
- XFCE team for lightweight desktop environment
- [amirmsoud16](https://github.com/amirmsoud16) for the original project

## 📞 Support

If you encounter any issues:
1. Check the troubleshooting section
2. Search existing issues at [GitHub Issues](https://github.com/amirmsoud16/ubuntu-chroot-pk-/issues)
3. Create a new issue with detailed information

---

**⭐ Star this repository if it helped you!**

**🔴 Remember: Root access is required for this installer!** 