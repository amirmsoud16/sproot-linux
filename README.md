# Ubuntu Installer for Linux (Root Required)

A powerful Ubuntu installer for Linux distributions that uses real chroot for maximum performance and compatibility.

## 🚀 Features

- **Real chroot** - Full root access and performance
- **Interactive Menu** - User-friendly menu-driven interface
- **VNC Support** - Remote desktop access via VNC
- **Complete Management** - Install, uninstall, and status checking
- **XFCE Desktop** - Lightweight desktop environment
- **Service Management** - Start/stop Ubuntu as a service

## ⚠️ Requirements

**🔴 IMPORTANT: Root Access Required!**

### 💻 **System Requirements:**
- **Linux distribution** with apt package manager (Ubuntu, Debian, etc.)
- **Root access** with working `sudo` or `su` command
- **At least 4GB RAM** (recommended)
- **At least 5GB free storage** (Ubuntu + packages + cache)

### 🌐 **Network Requirements:**
- **Stable internet connection** (WiFi recommended)
- **Download speed:** At least 1 Mbps
- **Total download:** ~2.5GB (Ubuntu rootfs + packages)

### 🔧 **Software Requirements:**
- **apt package manager** available
- **curl, tar, xz-utils** packages
- **VNC Viewer** for desktop access (optional but recommended)

## ⚡ Quick Start

**For experienced users - One command installation:**

```bash
# Install prerequisites and run installer
sudo apt update -y && sudo apt upgrade -y && sudo apt install -y curl proot tar xz-utils pulseaudio tigervnc-standalone-server git && git clone https://github.com/amirmsoud16/ubuntu-chroot-pk-.git && cd ubuntu-chroot-pk- && chmod +x ubuntu_installer.sh && sudo ./ubuntu_installer.sh
```

## 🛠️ Installation

### 🔧 **Step 1: Install Prerequisites**
```bash
# Update system packages
sudo apt update -y && sudo apt upgrade -y

# Install required packages
sudo apt install -y curl proot tar xz-utils pulseaudio tigervnc-standalone-server git

# Install additional useful packages
sudo apt install -y wget nano vim
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
# Run with sudo (recommended method)
sudo ./ubuntu_installer.sh

# Or with su
su -c './ubuntu_installer.sh'
```

### ✅ **Step 4: Verify Installation**
```bash
# Check if Ubuntu is installed
sudo ./ubuntu_installer.sh status

# Test Ubuntu command
ubuntu help
```

## 🎯 Usage

### Interactive Menu Mode (Recommended)
```bash
sudo ./ubuntu_installer.sh
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
sudo ./ubuntu_installer.sh install

# Uninstall Ubuntu
sudo ./ubuntu_installer.sh uninstall

# Check status
sudo ./ubuntu_installer.sh status

# Show help
sudo ./ubuntu_installer.sh help
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
$HOME/ubuntu/
```

## 🔧 What Gets Installed

### System Packages
- `curl` - Download manager
- `tar` - Archive utility
- `xz-utils` - Compression
- `pulseaudio` - Audio support
- `tigervnc-standalone-server` - VNC server

### Ubuntu Packages
- `xfce4` - Desktop environment
- `xfce4-goodies` - Additional XFCE tools
- `tightvncserver` - VNC server (installed inside Ubuntu)
- `dbus-x11` - Desktop bus
- `firefox-esr` - Web browser
- `gedit` - Text editor
- `gimp` - Image editor
- `vlc` - Media player

## 🗂️ Files Created

- `$HOME/ubuntu/` - Ubuntu rootfs directory
- `$HOME/ubuntu` - Ubuntu command script
- `$HOME/ubuntu-service` - Service management script
- `$HOME/.shortcuts/Ubuntu` - Desktop shortcut
- `$HOME/.vnc/` - VNC configuration

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
- Ubuntu logs: `$HOME/ubuntu.log`
- VNC logs: `$HOME/.vnc/`

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