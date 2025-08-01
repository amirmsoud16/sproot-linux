#!/bin/bash

# Stage 3: Mounting script and access setup with prerequisites

echo "=== Stage 3: Mounting script and access setup ==="

# Check if Ubuntu directory exists
if [ ! -d "$HOME/chroot/ubuntu" ]; then
    echo "Error: Ubuntu directory not found. Please run stage 1 first"
    exit 1
fi

# Create bin directory if it doesn't exist
mkdir -p $PREFIX/bin

# Create ubuntu shortcut
echo "Creating ubuntu shortcut..."

cat > $PREFIX/bin/ubuntu << 'EOF'
#!/bin/bash

# Shortcut for entering chroot

# Check root access
if [ "$(id -u)" != "0" ]; then
   echo "This command requires root access"
   echo "Please run with su"
   exit 1
fi

# Check if Ubuntu directory exists
if [ ! -d "$HOME/chroot/ubuntu" ]; then
    echo "Error: Ubuntu directory not found"
    exit 1
fi

# Automatically mount file systems
echo "Mounting file systems..."

# Mount /proc
mount -t proc proc $HOME/chroot/ubuntu/proc 2>/dev/null

# Mount /sys
mount -t sysfs sysfs $HOME/chroot/ubuntu/sys 2>/dev/null

# Mount /dev
mount -o bind /dev $HOME/chroot/ubuntu/dev 2>/dev/null

# Mount /dev/pts
mount -t devpts devpts $HOME/chroot/ubuntu/dev/pts 2>/dev/null

# Mount /tmp
mount -t tmpfs tmpfs $HOME/chroot/ubuntu/tmp 2>/dev/null

# Mount internal user storage to home
if [ -d "/data/data" ]; then
    mount -o bind /data/data $HOME/chroot/home/user_data 2>/dev/null
fi

echo "Entering chroot environment..."

# Execute chroot
chroot $HOME/chroot/ubuntu /bin/bash

# After exit, automatically unmount
echo "Exiting chroot..."

# Unmount internal user storage
if mountpoint -q $HOME/chroot/home/user_data 2>/dev/null; then
    umount $HOME/chroot/home/user_data
fi

# Unmount /tmp
if mountpoint -q $HOME/chroot/ubuntu/tmp 2>/dev/null; then
    umount $HOME/chroot/ubuntu/tmp
fi

# Unmount /dev/pts
if mountpoint -q $HOME/chroot/ubuntu/dev/pts 2>/dev/null; then
    umount $HOME/chroot/ubuntu/dev/pts
fi

# Unmount /dev
if mountpoint -q $HOME/chroot/ubuntu/dev 2>/dev/null; then
    umount $HOME/chroot/ubuntu/dev
fi

# Unmount /sys
if mountpoint -q $HOME/chroot/ubuntu/sys 2>/dev/null; then
    umount $HOME/chroot/ubuntu/sys
fi

# Unmount /proc
if mountpoint -q $HOME/chroot/ubuntu/proc 2>/dev/null; then
    umount $HOME/chroot/ubuntu/proc
fi

echo "File systems unmounted"
EOF

# Set execute permission for shortcut
chmod +x $PREFIX/bin/ubuntu

# Create script for installing prerequisites in chroot
echo "Creating script for installing prerequisites in chroot..."

cat > $HOME/chroot/scripts/install_chroot_prerequisites.sh << 'EOF'

# مقاوم‌سازی اکسترکت برای ساختارهای مختلف آرشیو (در صورت نیاز به اکسترکت مجدد)
if [ ! -d "$HOME/chroot/ubuntu/bin" ] && [ -d "$HOME/chroot/ubuntu" ]; then
    SUBDIR=$(find "$HOME/chroot/ubuntu" -mindepth 1 -maxdepth 1 -type d | head -n 1)
    if [ -n "$SUBDIR" ]; then
        echo "Moving extracted files from $SUBDIR to $HOME/chroot/ubuntu"
        mv "$SUBDIR"/* "$HOME/chroot/ubuntu/"
        rmdir "$SUBDIR"
    fi
fi

# مقاوم‌سازی اکسترکت برای ساختارهای مختلف آرشیو (در صورت نیاز به اکسترکت مجدد)
if [ ! -d "$HOME/chroot/ubuntu/bin" ] && [ -d "$HOME/chroot/ubuntu" ]; then
    SUBDIR=$(find "$HOME/chroot/ubuntu" -mindepth 1 -maxdepth 1 -type d | head -n 1)
    if [ -n "$SUBDIR" ]; then
        echo "Moving extracted files from $SUBDIR to $HOME/chroot/ubuntu"
        mv "$SUBDIR"/* "$HOME/chroot/ubuntu/"
        rmdir "$SUBDIR"
    fi
fi
#!/bin/bash

# Script for installing prerequisites in chroot

echo "Installing prerequisites in chroot environment..."

# Update package list
apt update

# Install basic prerequisites
apt install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    build-essential \
    python3 \
    python3-pip \
    openssh-server \
    sudo \
    locales \
    tzdata \
    xz-utils

# Set locale
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# Set timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Create new user (optional)
# useradd -m -s /bin/bash ubuntu
# usermod -aG sudo ubuntu

echo "Prerequisites installed"
EOF

# Set execute permission for prerequisites script
chmod +x $HOME/chroot/scripts/install_chroot_prerequisites.sh

echo ""
echo "=== Stage 3 completed ==="
echo ""
echo "Created shortcut:"
echo "1. $PREFIX/bin/ubuntu - Quick command for entering chroot"
echo ""
echo "Prerequisites installation script:"
echo "2. $HOME/chroot/scripts/install_chroot_prerequisites.sh - Install prerequisites in chroot"
echo ""
echo "Usage:"
echo "1. Quick entry to chroot: ubuntu"
echo "2. Install prerequisites in chroot: $HOME/chroot/scripts/install_chroot_prerequisites.sh"
echo ""
echo "Note: Internal user storage is mounted at $HOME/chroot/home/user_data" 
