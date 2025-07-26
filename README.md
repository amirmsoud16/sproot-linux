# Ubuntu Installation for Termux

This script installs Ubuntu with desktop environment and VNC server on Termux, allowing you to run Ubuntu with just the `ubuntu` command.

## Features

- ✅ Ubuntu 22.04 LTS with chroot
- ✅ XFCE Desktop Environment
- ✅ VNC Server for remote desktop access
- ✅ Simple command: `ubuntu` to start
- ✅ Command line and desktop modes
- ✅ Service management
- ✅ Desktop shortcut

## 🚀 Quick Install (One Command)

```bash
curl -s https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/quick_install.sh | bash
```

## 📥 Manual Installation

1. **Download the script:**
   ```bash
   wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/install_ubuntu_termux.sh
   ```

2. **Make it executable:**
   ```bash
   chmod +x install_ubuntu_termux.sh
   ```

3. **Run the installation:**
   ```bash
   ./install_ubuntu_termux.sh
   ```

## First Time Setup

After installation, you need to initialize Ubuntu:

1. **Start Ubuntu CLI:**
   ```bash
   ubuntu cli
   ```

2. **Run initialization script:**
   ```bash
   ./init-ubuntu.sh
   ```

3. **Exit Ubuntu and start desktop:**
   ```bash
   exit
   ubuntu desktop
   ```

## Usage

### Basic Commands

- `ubuntu` - Start Ubuntu with desktop (default)
- `ubuntu desktop` - Start Ubuntu with desktop environment
- `ubuntu cli` - Start Ubuntu command line only
- `ubuntu stop` - Stop VNC server
- `ubuntu help` - Show help

### Service Management

- `ubuntu-service start` - Start Ubuntu as background service
- `ubuntu-service stop` - Stop Ubuntu service
- `ubuntu-service status` - Check service status

## VNC Connection

1. **Install VNC Viewer** on your device or computer
2. **Connect to:** `your-device-ip:5901`
3. **Default resolution:** 1280x720

## File Structure

```
~/ubuntu/           # Ubuntu rootfs directory
~/ubuntu            # Ubuntu startup script
~/ubuntu-service    # Service management script
~/.shortcuts/Ubuntu # Desktop shortcut
```

## Requirements

- Termux (Android)
- Internet connection for download
- At least 2GB free space
- VNC Viewer app for desktop access

## Troubleshooting

### Common Issues

1. **VNC not connecting:**
   - Check if VNC server is running: `ubuntu-service status`
   - Verify IP address and port 5901
   - Try restarting: `ubuntu stop && ubuntu desktop`

2. **Desktop not starting:**
   - Make sure initialization script was run
   - Check logs: `cat ~/ubuntu.log`

3. **Permission denied:**
   - Ensure scripts are executable: `chmod +x ~/ubuntu`

### Logs

- Ubuntu service logs: `cat ~/ubuntu.log`
- VNC logs: Check `~/.vnc/` directory

## Uninstall

To remove Ubuntu:

```bash
rm -rf ~/ubuntu
rm ~/ubuntu
rm ~/ubuntu-service
rm ~/.shortcuts/Ubuntu
```

## Notes

- The script uses Ubuntu 22.04 LTS
- Desktop environment is XFCE (lightweight)
- VNC server runs on port 5901
- All data is stored in `~/ubuntu/` directory
- The `ubuntu` command is added to your PATH

## Support

If you encounter issues:
1. Check the troubleshooting section
2. Verify all requirements are met
3. Check logs for error messages
4. Ensure proper initialization was completed 