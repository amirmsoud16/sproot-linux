# Ubuntu Manager for Termux

A unified script for installing and managing Ubuntu on Termux with VNC support.

## 🚀 Features

- **Easy Installation** - One-click Ubuntu installation on Termux
- **Interactive Menu** - User-friendly menu-driven interface
- **VNC Support** - Remote desktop access via VNC
- **Complete Management** - Install, uninstall, and status checking
- **XFCE Desktop** - Lightweight desktop environment
- **Service Management** - Start/stop Ubuntu as a service

## 📋 Requirements

**⚠️ Important Prerequisites:**
- **Rooted Android device** (essential for chroot functionality)
- **Linux distribution with apt** (Ubuntu, Debian, etc.)
- **Internet connection** for downloading Ubuntu rootfs (~2GB)
- **At least 3GB free storage** (Ubuntu + packages)
- **VNC Viewer app** for desktop access (optional but recommended)

### 🔧 Install Prerequisites:
```bash
# Update system packages
apt update && apt upgrade

# Install required packages
apt install -y curl tar xz-utils pulseaudio tigervnc-standalone-server

# Install Git (for cloning repository)
apt install -y git
```

**⚠️ Important:** Make sure you're running this on a Linux distribution with apt support.

## 🛠️ Installation

1. **Clone the repository:**
```bash
git clone https://github.com/amirmsoud16/ubuntu-chroot-pk-.git
cd ubuntu-chroot-pk-
```

2. **Make the script executable:**
```bash
chmod +x ubuntu_manager.sh
```

3. **Run the manager as root:**
```bash
# Direct execution
sudo ./ubuntu_manager.sh

# Or with su
su -c './ubuntu_manager.sh'
```

## 🎯 Usage

### Interactive Menu Mode (Recommended)
```bash
sudo ./ubuntu_manager.sh
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
sudo ./ubuntu_manager.sh install

# Uninstall Ubuntu
sudo ./ubuntu_manager.sh uninstall

# Check status
sudo ./ubuntu_manager.sh status

# Show help
sudo ./ubuntu_manager.sh help
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

## 📁 Project Structure

```
ubuntu-chroot-pk-/
├── ubuntu_manager.sh      # Main manager script
├── LICENSE               # License file
├── CONTRIBUTING.md       # Contribution guidelines
├── CHANGELOG.md          # Version history
├── SECURITY.md           # Security policy
├── .gitignore           # Git ignore rules
└── README.md            # This file
```

## 🔧 What Gets Installed

### System Packages
- `curl` - Download manager
- `tar` - Archive utility
- `xz-utils` - Compression
- `pulseaudio` - Audio support
- `tigervnc-standalone-server` - VNC server for remote desktop

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

- `~/ubuntu/` - Ubuntu rootfs directory
- `~/ubuntu` - Ubuntu command script
- `~/ubuntu-service` - Service management script
- `~/.shortcuts/Ubuntu` - Desktop shortcut
- `~/.vnc/` - VNC configuration

## 🚨 Troubleshooting

### Common Issues

**VNC Connection Failed**
- Check if VNC server is running: `vncserver -list`
- Restart VNC: `vncserver -kill :1 && vncserver -localhost no`

**Ubuntu Won't Start**
- Check status: `sudo ./ubuntu_manager.sh status`
- Reinstall: `sudo ./ubuntu_manager.sh uninstall && ./ubuntu_manager.sh install`

**Permission Denied**
- Make script executable: `chmod +x ubuntu_manager.sh`
- Run as root: `sudo ./ubuntu_manager.sh`

**apt: command not found**
- Make sure you're running on a Linux distribution with apt support
- Install Ubuntu, Debian, or similar distribution

### Logs
- Ubuntu logs: `~/ubuntu.log`
- VNC logs: `~/.vnc/`

## 🤝 Contributing

1. Fork the repository: [https://github.com/amirmsoud16/ubuntu-chroot-pk-](https://github.com/amirmsoud16/ubuntu-chroot-pk-)
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

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