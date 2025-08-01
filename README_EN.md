# Ubuntu on Android - Easy Installation 🐧

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Android](https://img.shields.io/badge/Platform-Android-green.svg)](https://www.android.com/)
[![Ubuntu: 22.04](https://img.shields.io/badge/Ubuntu-22.04-orange.svg)](https://ubuntu.com/)

A simple and secure way to install Ubuntu 22.04 on Android with complete isolation.

## ✨ Features

- **Easy Installation** - Only 2 steps
- **Complete Isolation** - Secure and separate from Android system
- **Simple Menu** - Easy management
- **Lightweight Ubuntu** - Using minbase variant
- **SD Card Access** - Android files accessible
- **Root Required** - Safe and controlled environment

## 🚀 Installation

### Step 1: Preparation (without root)
```bash
# Transfer files to Android
adb push setup_ubuntu_android.sh /sdcard/
adb push ubuntu_manager.sh /sdcard/

# Run preparation
adb shell
cd /sdcard
chmod +x setup_ubuntu_android.sh
./setup_ubuntu_android.sh
```

### Step 2: Installation (with root)
```bash
# Get root access
su

# Run installation
cd /sdcard/ubuntu-setup
./install_ubuntu.sh
```

## 🛠️ Usage

### Enter Ubuntu:
```bash
su
./ubuntu_manager.sh
# Select option 1
```

### Or directly:
```bash
su
/data/local/ubuntu/enter.sh
```

## 📋 Management Menu

```
1. Enter Ubuntu
2. Install Package
3. Update System
4. Show Status
5. Clean System
6. Remove Completely
7. Help
0. Exit
```

## 📦 Pre-installed Packages

- **sudo** - Administrative access
- **vim** - Text editor
- **nano** - Simple editor
- **curl** - File downloader
- **wget** - File downloader
- **git** - Version control
- **python3** - Programming language

## 🔧 Useful Commands

### Inside Ubuntu:
```bash
sudo apt-get install nginx    # Install web server
sudo apt-get update           # Update package list
sudo apt-get upgrade          # Update system
exit                         # Exit
```

### Outside Ubuntu:
```bash
./ubuntu_manager.sh           # Management menu
/data/local/ubuntu/enter.sh  # Direct entry
```

## 📁 File Structure

```
/data/local/ubuntu/          # Main Ubuntu path
├── enter.sh                 # Entry script
├── mount.sh                 # Mount script
├── unmount.sh               # Unmount script
└── [Ubuntu system files]

/sdcard/ubuntu-setup/        # Installation files
├── install_ubuntu.sh        # Installation script
└── [Temporary files]
```

## ⚠️ Requirements

### Prerequisites:
- Android with Root access
- Minimum 2GB free space
- Internet connection

### Installation Time:
- About 10-15 minutes
- Depends on internet speed

### Security:
- Completely isolated environment
- Changes don't affect Android system

## 🐛 Troubleshooting

### Permission Error:
```bash
su
chmod +x *.sh
```

### Disk Space Error:
```bash
df -h
# Minimum 2GB required
```

### Network Error:
```bash
echo "nameserver 8.8.8.8" > /data/local/ubuntu/etc/resolv.conf
```

### Complete Removal:
```bash
rm -rf /data/local/ubuntu
rm -rf /sdcard/ubuntu-setup
```

## 📞 Support

For bug reports:
1. Check all prerequisites are met
2. Verify internet connection
3. Check disk space
4. Use latest version of scripts

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Ubuntu team for the amazing distribution
- Android community for root access methods
- Linux chroot technology

---

**Note:** This environment is designed for development and testing purposes. 🎉

## 📊 Project Stats

![GitHub stars](https://img.shields.io/github/stars/yourusername/ubuntu-android)
![GitHub forks](https://img.shields.io/github/forks/yourusername/ubuntu-android)
![GitHub issues](https://img.shields.io/github/issues/yourusername/ubuntu-android)
![GitHub pull requests](https://img.shields.io/github/issues-pr/yourusername/ubuntu-android) 