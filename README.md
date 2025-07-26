# 🐧 Ubuntu for Termux

Install Ubuntu with desktop environment on Termux with just one command!

## 🚀 Quick Install

### Step 1: Update Termux packages
```bash
pkg update && pkg upgrade
```

### Step 2: Install curl (if not installed)
```bash
pkg install curl
```

### Step 3: Run the installer
```bash
curl -s https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/install_ubuntu.sh | bash
```

## 📱 Features

- ✅ Ubuntu 22.04 LTS with chroot
- ✅ XFCE Desktop Environment
- ✅ VNC Server for remote desktop access
- ✅ Simple command: `ubuntu` to start
- ✅ Command line and desktop modes
- ✅ Service management
- ✅ Desktop shortcut

## 🎯 One Command Installation

Just copy and paste this command in Termux:

```bash
curl -s https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/install_ubuntu.sh | bash
```

## 📋 Requirements

- Android device with Termux
- Internet connection
- At least 2GB free space
- VNC Viewer app (for desktop access)

## 🔧 First Time Setup

After installation:

1. **Start Ubuntu CLI:**
   ```bash
   ubuntu cli
   ```

2. **Run initialization:**
   ```bash
   ./init-ubuntu.sh
   ```

3. **Exit and start desktop:**
   ```bash
   exit
   ubuntu desktop
   ```

## 🎮 Usage

### Basic Commands

- `ubuntu` - Start Ubuntu with desktop
- `ubuntu cli` - Start Ubuntu command line
- `ubuntu stop` - Stop VNC server
- `ubuntu help` - Show help

### Service Management

- `ubuntu-service start` - Start as background service
- `ubuntu-service stop` - Stop service
- `ubuntu-service status` - Check status

## 🖥️ VNC Connection

1. Install VNC Viewer app
2. Connect to: `your-device-ip:5901`
3. Default resolution: 1280x720

## 📁 File Locations

```
~/ubuntu/           # Ubuntu rootfs
~/ubuntu            # Main command
~/ubuntu-service    # Service manager
~/.shortcuts/Ubuntu # Desktop shortcut
```

## 🛠️ Troubleshooting

### Common Issues

1. **VNC not connecting:**
   ```bash
   ubuntu-service status
   ubuntu stop && ubuntu desktop
   ```

2. **Desktop not starting:**
   ```bash
   ubuntu cli
   ./init-ubuntu.sh
   ```

3. **Permission denied:**
   ```bash
   chmod +x ~/ubuntu
   ```

## 🗑️ Uninstall

### Easy Uninstall (Recommended)
```bash
curl -s https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/ubuntu_uninstaller.sh | bash
```

### Manual Uninstall
```bash
rm -rf ~/ubuntu
rm ~/ubuntu
rm ~/ubuntu-service
rm ~/.shortcuts/Ubuntu
```

## 📊 System Info

- **OS**: Ubuntu 22.04 LTS
- **Desktop**: XFCE
- **VNC Port**: 5901
- **Architecture**: ARM64/x86_64
- **Size**: ~2-3GB

## 🤝 Contributing

Feel free to contribute by:
- Reporting bugs
- Suggesting features
- Improving documentation

## 📄 License

This project is open source and available under the MIT License.

## ⭐ Star This Repo

If this project helped you, please give it a star! ⭐

---

**Made with ❤️ for Termux users** 