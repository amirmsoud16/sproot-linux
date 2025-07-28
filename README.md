# Ubuntu Chroot Installer for Termux

[View Project on GitHub](https://github.com/amirmsoud16/ubuntu-chroot-pk-)

## 🚀 Ubuntu Installer for Termux

A complete and easy Ubuntu installer for Termux using shell scripts.

## 📥 Download Methods

### 🎯 Project Page
[https://github.com/amirmsoud16/ubuntu-chroot-pk-](https://github.com/amirmsoud16/ubuntu-chroot-pk-)

## 📋 Prerequisites (install)

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

###🎯After installation

#🎯fixer net and install tools ubuntu
```
wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/ubuntu-setup.sh
chmod +x ubuntu-setup.sh
```
```
#run to Ubuntu
ubuntu18  # یا ubuntu20, ubuntu22, ubuntu24
```
```
# rub fixer
./ubuntu-setup.sh
```
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

## 📊 Minimum Requirements

| Item          | Minimum | Recommended |
| ------------- | ------- | ----------- |
| **RAM**       | 2GB     | 4GB+        |
| **Disk Space**| 4GB     | 8GB+        |
| **Android**   | 7.0+    | 10.0+       |
| **Architecture**| ARM64  | ARM64       |

## 🎨 Interface Features

- ✅ **Colored interface** with clear messages
- ✅ **Interactive menu** with easy options
- ✅ **Auto system check**
- ✅ **Auto package installation**
- ✅ **Helpful messages** for each step

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
