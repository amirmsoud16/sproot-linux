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
- **Termux app** installed from F-Droid or GitHub
- **Internet connection** for downloading Ubuntu rootfs (~2GB)
- **At least 3GB free storage** (Ubuntu + packages)
- **VNC Viewer app** for desktop access (optional but recommended)

### 🔧 Install Prerequisites:
```bash
# Update Termux packages
pkg update && pkg upgrade

# Install required packages
pkg install -y curl tar xz-utils pulseaudio tigervnc

# Install Git (for cloning repository)
pkg install -y git
```

## 🛠️ Installation

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/ubuntu-manager-termux.git
cd ubuntu-manager-termux
```

2. **Make the script executable:**
```bash
chmod +x ubuntu_manager.sh
```

3. **Run the manager as root:**
```bash
su -c './ubuntu_manager.sh'
```

## 🎯 Usage

### Interactive Menu Mode (Recommended)
```bash
su -c './ubuntu_manager.sh'
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
su -c './ubuntu_manager.sh install'

# Uninstall Ubuntu
su -c './ubuntu_manager.sh uninstall'

# Check status
su -c './ubuntu_manager.sh status'

# Show help
su -c './ubuntu_manager.sh help'
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
ubuntu-manager-termux/
├── ubuntu_manager.sh      # Main manager script
├── install_ubuntu.sh      # Original installer (legacy)
├── ubuntu_uninstaller.sh  # Original uninstaller (legacy)
├── LICENSE               # License file
└── README.md            # This file
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
- Check status: `su -c './ubuntu_manager.sh status'`
- Reinstall: `su -c './ubuntu_manager.sh uninstall && ./ubuntu_manager.sh install'`

**Permission Denied**
- Make script executable: `chmod +x ubuntu_manager.sh`
- Run as root: `su -c './ubuntu_manager.sh'`

### Logs
- Ubuntu logs: `~/ubuntu.log`
- VNC logs: `~/.vnc/`

## 🤝 Contributing

1. Fork the repository
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

## 📞 Support

If you encounter any issues:
1. Check the troubleshooting section
2. Search existing issues
3. Create a new issue with detailed information

---

**⭐ Star this repository if it helped you!** 