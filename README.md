# Ubuntu Chroot Installer for Termux

[View Project on GitHub](https://github.com/amirmsoud16/ubuntu-chroot-pk-)

## 🚀 Ubuntu Installer for Termux

A complete and easy Ubuntu installer for Termux using shell scripts.

---

## 📥 Download Methods

### 🎯 Project Page
[https://github.com/amirmsoud16/ubuntu-chroot-pk-](https://github.com/amirmsoud16/ubuntu-chroot-pk-)

### 📦 Method 1: Direct Download (Recommended)
```bash
# Download the complete installer
wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/install.sh
chmod +x install.sh
./install.sh
```

### 📦 Method 2: Git Clone (Complete)
```bash
apt install git -y
git clone https://github.com/amirmsoud16/ubuntu-chroot-pk-.git
cd ubuntu-chroot-pk-
./install.sh
```

---

## 📋 Prerequisites

### 1️⃣ Install Termux
```bash
# Download and install Termux from F-Droid
# https://f-droid.org/en/packages/com.termux/
```

### 2️⃣ Update Termux
```bash
apt update -y
apt upgrade -y
```

### 3️⃣ Install Required Packages
```bash
# Install required tools
apt install wget curl proot tar git nano vim -y
```

---

## 🚀 How to Run

### Quick Start
```bash
wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/install.sh
chmod +x install.sh
./install.sh
```

---

## 🎯 Features

### ✅ System Check & Preparation
- Check Termux environment
- Check disk space (minimum 4GB)
- Check internet connection
- Auto-install required packages
- Set DNS and permissions
- Prepare Ubuntu directory

### ✅ Install Ubuntu
- Choose installation method (Chroot/Proot)
- Choose Ubuntu version (18.04, 20.04, 22.04, 24.04)
- Auto-install LXDE desktop
- Setup VNC Server
- Create helper scripts
- Auto-fix symbolic links for better compatibility

### ✅ Complete Removal
- Remove all Ubuntu files
- Clean environment variables
- Remove extra files

### ✅ Access Ubuntu
- Direct access (terminal)
- VNC access (graphical)
- Install LXDE desktop
- Setup VNC server

### ✅ Fix Chroot Links
- Check symbolic links status
- Fix broken symbolic links
- Repair common system links (python, gcc, vim, etc.)
- Auto-fix during installation

---

## 📱 Device Support

### ✅ Rooted Devices
- **Installation Type:** Chroot
- **Performance:** Excellent
- **Compatibility:** Full
- **Features:** All capabilities

### ✅ Non-Rooted Devices
- **Installation Type:** Proot
- **Performance:** Medium
- **Compatibility:** Limited
- **Features:** Basic

---

## 🔧 Fix Chroot Symbolic Links

### If you encounter issues with broken symbolic links in chroot installations:

#### Method 1: Using the Installer
```bash
./install.sh
# Select option 3: Fix Chroot Links
# Choose to check status or fix links
```

#### Method 2: Check Links Status
```bash
./install.sh
# Select option 3: Fix Chroot Links
# Select option 1: Check links status
# Choose specific Ubuntu version to check
```

#### Method 3: Fix All Installations
```bash
./install.sh
# Select option 3: Fix Chroot Links
# Select option 2: Fix all chroot installations
```

#### Method 4: Fix Specific Installation
```bash
./install.sh
# Select option 3: Fix Chroot Links
# Select option 3: Fix specific chroot installation
# Enter Ubuntu version (e.g., 22.04)
```

### Common Links Fixed:
- `/bin/sh` → `/bin/bash`
- `/usr/bin/python` → `/usr/bin/python3`
- `/usr/bin/python2` → `/usr/bin/python3`
- `/usr/bin/gcc` → `/usr/bin/gcc-{version}`
- `/usr/bin/g++` → `/usr/bin/g++-{version}`
- `/usr/bin/vi` → `/usr/bin/vim.tiny`
- `/usr/bin/vim` → `/usr/bin/vim.tiny`
- `/usr/bin/editor` → `/usr/bin/nano`
- `/usr/bin/awk` → `/usr/bin/gawk`
- `/usr/bin/more` → `/usr/bin/less`

## 🔄 Re-access Ubuntu

### After installation and exiting Termux, to re-access:

#### Method 1: Direct Access
```bash
cd ~/ubuntu
./start-ubuntu.sh
```

#### Method 2: VNC Access (for graphical interface)
```bash
vncserver :1 -geometry 1280x720 -depth 24
cd ~/ubuntu
./start-ubuntu-vnc.sh
```

#### Method 3: Quick Access
```bash
echo 'alias ubuntu="cd ~/ubuntu && ./start-ubuntu.sh"' >> ~/.bashrc
source ~/.bashrc
ubuntu
```

#### Method 4: Graphical Desktop Access
```bash
cd ~/ubuntu
./install-lxde.sh
./setup-vnc.sh
vncserver :1 -geometry 1280x720 -depth 24
# Connect with VNC Viewer to localhost:5901
```

### 📱 Access from outside Termux:

#### Using VNC Viewer:
1. **Install VNC Viewer** on your phone
2. **Connect to:** `localhost:5901`
3. **Password:** The password you set during setup-vnc

#### Using Termux:API:
```bash
pkg install termux-api
termux-open-url vnc://localhost:5901
```

---

## 🔧 Troubleshooting

### Problem: start-ubuntu.sh not found
```bash
ls -la ~/ubuntu/
./install.sh
```

### Problem: Permission error
```bash
chmod +x ~/ubuntu/*.sh
chmod 755 ~/ubuntu
```

### Problem: VNC not working
```bash
vncserver -kill :1
vncserver :1 -geometry 1280x720 -depth 24
ps aux | grep vnc
```

### Problem: Low disk space
```bash
pkg clean
apt clean
```

### Problem: Internet connection
```bash
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
echo 'nameserver 8.8.4.4' >> /etc/resolv.conf
```

### Problem: Broken symbolic links in chroot
```bash
# Use the built-in fix tool
./install.sh
# Select option 3: Fix Chroot Links
# Choose to fix all or specific installation
```

---

## 📊 Minimum Requirements

| Item          | Minimum | Recommended |
| ------------- | ------- | ----------- |
| **RAM**       | 2GB     | 4GB+        |
| **Disk Space**| 4GB     | 8GB+        |
| **Android**   | 7.0+    | 10.0+       |
| **Architecture**| ARM64  | ARM64       |

---

## 🎨 Interface Features

- ✅ **Colored interface** with clear messages
- ✅ **Interactive menu** with easy options
- ✅ **Auto system check**
- ✅ **Auto package installation**
- ✅ **Helpful messages** for each step

---

## 📋 Useful Commands

```bash
ls -la ~/ubuntu/
cat ~/ubuntu/ubuntu.log
cd ~/ubuntu && rm -rf tmp/*
cd ~/ubuntu && ./post-install.sh
```

---

## 📞 Support

### Report Issues
If you encounter a problem:
1. First check the prerequisites
2. Check the program logs
3. Report the issue in Issues

### Contribute
To contribute to development:
1. Fork the project
2. Create a new branch
3. Commit your changes
4. Send a Pull Request

---

## 📄 License

This project is released under the MIT License.

---

## 🙏 Thanks

Thanks to everyone who contributed to the development of this project.

---

**Important Note:** Before running the program, make sure to install all prerequisites to avoid problems. 
