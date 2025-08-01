# Android Chroot Installation

This project includes 3 stages for installing and setting up chroot on Android.

## Installation Stages

### 2️⃣ Update Termux

```bash
apt update -y
apt upgrade -y
```

### 3️⃣ Install Required Packages
```bash
apt install wget curl proot tar git nano vim -y tsu unzip e2fsprogs
```
```bash
git clone https://github.com/amirmsoud16/ubuntu-chroot-pk-.git
cd ubuntu-chroot-pk-
```
### Stage 1: Install prerequisites and download Ubuntu

```bash
chmod +x stage1_install_prerequisites.sh
./stage1_install_prerequisites.sh
```

This stage includes:
- Creating required directories
- Installing prerequisites (proot, wget, tar, xz-utils)
- Downloading and extracting Ubuntu 20.04 Cloud Image for ARM64

### Stage 2: Manual chroot execution

After completing stage 1, run these commands manually:

```bash
# Mount required file systems
mount -t proc proc /data/local/chroot/ubuntu/proc
mount -t sysfs sysfs /data/local/chroot/ubuntu/sys
mount -o bind /dev /data/local/chroot/ubuntu/dev
mount -t devpts devpts /data/local/chroot/ubuntu/dev/pts
mount -t tmpfs tmpfs /data/local/chroot/ubuntu/tmp
```
```
chroot /data/local/chroot/ubuntu /bin/bash
```

This stage includes:
- Mounting required file systems (/proc, /sys, /dev, /dev/pts, /tmp)
- Manual chroot execution

### Stage 3: Mounting scripts and access setup

```bash
chmod +x stage3_mount_and_setup.sh
./stage3_mount_and_setup.sh
```

This stage includes:
- Creating ubuntu shortcut for easy chroot entry
- Creating script for installing prerequisites in chroot environment

## Created Scripts

After running stage 3, the following scripts are created:

1. **`/data/local/bin/ubuntu`** - Quick shortcut for entering chroot
2. **`/data/local/chroot/scripts/install_chroot_prerequisites.sh`** - Install prerequisites in chroot

## Usage

### 1. Enter chroot
```bash
su
ubuntu
```

### 2. Install prerequisites in chroot environment
```bash
# In chroot environment
/data/local/chroot/scripts/install_chroot_prerequisites.sh
```

### 3. Exit chroot
```bash
# In chroot environment
exit
```

## Features

- ✅ Automatic prerequisite installation
- ✅ Automatic Ubuntu Cloud Image download and extraction
- ✅ Automatic file system mounting
- ✅ Access to internal user storage at `/data/local/chroot/home/user_data`
- ✅ Easy management shortcut
- ✅ Complete prerequisite installation in chroot environment
- ✅ Complete uninstall process

## Directory Structure

All files are stored in `/data/local/chroot/`:
- `/data/local/chroot/ubuntu/` - Ubuntu system files
- `/data/local/chroot/scripts/` - Management scripts
- `/data/local/chroot/home/user_data/` - Internal user storage mount point

## System Requirements

- Android with root access (only for stage 2)
- Minimum 2GB free space
- Internet connection for Ubuntu Cloud Image download

## Important Notes

1. **Root Access**: Only stage 2 requires root access
2. **Disk Space**: Minimum 2GB free space required
3. **Internet Connection**: Required for Ubuntu Cloud Image download
4. **Security**: Chroot creates a separate environment but still requires caution
5. **Complete Uninstall**: Running `uninstall.sh` removes all files and directories

## Troubleshooting

### Issue: Root access error
```bash
# Check root access
id
# If uid is not 0, use su
su
```

### Issue: Ubuntu download error
```bash
# Check internet connection
ping google.com
# Check disk space
df -h
```

### Issue: Mount error
```bash
# Check directory existence
ls -la /data/local/chroot/
# Check mount points
mount | grep chroot
```

## Uninstall

To completely remove chroot and all related files:

```bash
su
chmod +x uninstall.sh
./uninstall.sh
```

This will remove:
- All Ubuntu files and directories
- All scripts and shortcuts
- All mount points
- Internal storage mount points

## Support

For reporting issues or requesting new features, please create an issue.

---

**Note**: These scripts are designed for educational and development use. Use in production environments requires additional security reviews. 


