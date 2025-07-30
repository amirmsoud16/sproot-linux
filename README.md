# SPROOT Linux Manager

A powerful Linux distribution manager for Android/Termux that allows you to install and run multiple Linux distributions without root access using SPROOT Complete technology.

## 🌟 Features

- **35+ Linux Distributions** supported
- **No Root Access Required** - Works on non-rooted devices
- **Complete Ubuntu Simulation** with systemd, snap, and services
- **User-Friendly Menu** with clear interface
- **Enhanced Security** with full isolation
- **Easy Installation** and management

## 📱 Supported Distributions

### Ubuntu Family
- Ubuntu 18.04 LTS, 20.04 LTS, 22.04 LTS, 23.04, 24.04 LTS

### Debian Family
- Debian 10 (Buster), 11 (Bullseye), 12 (Bookworm)

### Security & Penetration Testing
- Kali Linux 2023/2024, Parrot OS, BlackArch Linux

### Rolling Release
- Arch Linux, Manjaro Linux, EndeavourOS

### Enterprise & Server
- CentOS 7/8, Rocky Linux 8/9, AlmaLinux 8/9

### Fedora Family
- Fedora 35, 36, 37, 38, 39, 40

### Lightweight & Minimal
- Alpine Linux, Void Linux, Slackware Linux

### Development & Programming
- openSUSE Leap/Tumbleweed, Gentoo Linux

### Specialized
- NixOS, GNU Guix, Clear Linux

## 🚀 Quick Installation

### Prerequisites
```bash
apt update -y apt upgrade -y
```
```
apt install -y git wget proot tar
```

### Install SPROOT Linux Manager
```bash
git clone https://github.com/amirmsoud16/sproot-linux.git
```
```
cd sproot-linux
```
```
chmod +x sproot-complete.sh
chmod +x linux-manager.sh
```
```
./linux-manager.sh
```

## 📖 Usage

### 1. Start Linux Manager
```bash
./linux-manager.sh
```

### 2. Install Distribution
- Select "Install Linux Distribution"
- Choose your preferred distribution
- Wait for download and installation

### 3. Start Linux Environment
- Select "Start Linux Environment"
- Choose installed distribution
- Enjoy your Linux environment!

## 🛠️ Manual Installation

### Install Specific Distribution
```bash
# Install Ubuntu 22.04
./linux-manager.sh

# In menu: Install Linux Distribution → Ubuntu 22.04 LTS
```

### Direct Script Usage
```bash
# Start with SPROOT Complete
./sproot-complete.sh start

# Start with specific options
./sproot-complete.sh -m full start
```

## 🔧 Configuration

### SPROOT Complete Options
```bash
./sproot-complete.sh [OPTIONS] [COMMAND]

Options:
  -r, --rootfs PATH     Root filesystem path
  -u, --user USER       Username
  -s, --shell SHELL     Shell to use
  -m, --mode MODE       Simulation mode: full, systemd, snap, services
  -i, --isolated        Maximum isolation mode
  -d, --debug           Enable debug mode
```

### Simulation Modes
- **full**: Complete Ubuntu simulation (default)
- **systemd**: Systemd services simulation
- **snap**: Snap package simulation
- **services**: System services simulation

## 📊 System Requirements

- **Android**: 7.0+ (API 24+)
- **Termux**: Latest version
- **Storage**: 3GB+ free space
- **RAM**: 2GB+ recommended
- **Internet**: Required for download

## 🔒 Security Features

- **No Root Access**: Works on non-rooted devices
- **Full Isolation**: Complete environment isolation
- **Simulated Services**: Safe systemd/snap simulation
- **Secure Environment**: Enhanced security with SPROOT

## 🐛 Troubleshooting

### Common Issues

**1. Download Failed**
```bash
# Check internet connection
ping google.com

# Try again
./linux-manager.sh
```

**2. Permission Denied**
```bash
# Make scripts executable
chmod +x *.sh
```

**3. Proot Not Found**
```bash
# Install proot
pkg install proot
```

**4. Insufficient Space**
```bash
# Check available space
df -h

# Clean up if needed
rm -rf ~/linux-distros
```

## 📝 Examples

### Install Ubuntu 22.04
```bash
./linux-manager.sh
# Select: Install Linux Distribution → Ubuntu 22.04 LTS
```

### Install Kali Linux
```bash
./linux-manager.sh
# Select: Install Linux Distribution → Kali Linux 2024
```

### Start Installed Distribution
```bash
./linux-manager.sh
# Select: Start Linux Environment → [Your Distribution]
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **SPROOT Complete** - Core technology
- **Andronix** - Rootfs images
- **Termux** - Android terminal emulator
- **Linux Community** - Open source contributions

## 📞 Support

- **GitHub Issues**: [Report Issues](https://github.com/amirmsoud16/sproot-linux/issues)
- **Documentation**: See this README
- **Community**: Linux and Termux communities

---

**⭐ Star this repository if you find it useful!**

**🔗 Repository**: [https://github.com/amirmsoud16/sproot-linux.git](https://github.com/amirmsoud16/sproot-linux.git) 
