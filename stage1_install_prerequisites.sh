#!/bin/bash

# Stage 1: Install prerequisites and download Ubuntu

echo "=== Stage 1: Installing prerequisites and downloading Ubuntu ==="

# Create required directories
echo "Creating required directories..."
mkdir -p $HOME/chroot
mkdir -p $HOME/chroot/ubuntu
mkdir -p $HOME/chroot/scripts
mkdir -p $HOME/chroot/home
mkdir -p $HOME/chroot/home/user_data

# Install prerequisites
echo "Installing prerequisites..."

# Check and install proot
if ! command -v proot &> /dev/null; then
    echo "Installing proot..."
    pkg install proot -y
fi

# Check and install wget
if ! command -v wget &> /dev/null; then
    echo "Installing wget..."
    pkg install wget -y
fi

# Check and install tar
if ! command -v tar &> /dev/null; then
    echo "Installing tar..."
    pkg install tar -y
fi

# Check and install xz
if ! command -v xz &> /dev/null; then
    echo "Installing xz..."
    pkg install xz-utils -y
fi

# Download Ubuntu
echo "Downloading Ubuntu..."
cd $HOME/chroot

# Download Ubuntu Cloud .xz for ARM64
wget -O ubuntu-rootfs.tar.xz https://cloud-images.ubuntu.com/releases/20.04/release/ubuntu-20.04-server-cloudimg-arm64.tar.xz

# Check download success
if [ ! -f ubuntu-rootfs.tar.xz ]; then
    echo "Error downloading Ubuntu"
    exit 1
fi

echo "Extracting Ubuntu..."
tar -xf ubuntu-rootfs.tar.xz -C ubuntu/

# Clean up downloaded file
echo "Cleaning up downloaded file..."
rm ubuntu-rootfs.tar.xz

# Set comprehensive permissions
echo "Setting comprehensive permissions..."

# Set directory permissions
chmod 755 $HOME/chroot
chmod 755 $HOME/chroot/ubuntu
chmod 755 $HOME/chroot/scripts
chmod 755 $HOME/chroot/home
chmod 755 $HOME/chroot/home/user_data

# Set ownership (if possible)
if command -v chown &> /dev/null; then
    echo "Setting ownership..."
    chown -R root:root $HOME/chroot/ubuntu 2>/dev/null || true
    chown -R root:root $HOME/chroot/scripts 2>/dev/null || true
    chown -R root:root $HOME/chroot/home 2>/dev/null || true
fi

# Set specific permissions for Ubuntu system files
echo "Setting Ubuntu system permissions..."
find $HOME/chroot/ubuntu -type d -exec chmod 755 {} \; 2>/dev/null || true
find $HOME/chroot/ubuntu -type f -exec chmod 644 {} \; 2>/dev/null || true

# Set executable permissions for important files
echo "Setting executable permissions..."
find $HOME/chroot/ubuntu -name "*.sh" -exec chmod 755 {} \; 2>/dev/null || true
find $HOME/chroot/ubuntu -name "*.py" -exec chmod 755 {} \; 2>/dev/null || true
find $HOME/chroot/ubuntu -name "*.pl" -exec chmod 755 {} \; 2>/dev/null || true

# Set permissions for system directories
if [ -d "$HOME/chroot/ubuntu/bin" ]; then
    chmod 755 $HOME/chroot/ubuntu/bin
    find $HOME/chroot/ubuntu/bin -type f -exec chmod 755 {} \; 2>/dev/null || true
fi

if [ -d "$HOME/chroot/ubuntu/sbin" ]; then
    chmod 755 $HOME/chroot/ubuntu/sbin
    find $HOME/chroot/ubuntu/sbin -type f -exec chmod 755 {} \; 2>/dev/null || true
fi

if [ -d "$HOME/chroot/ubuntu/usr/bin" ]; then
    chmod 755 $HOME/chroot/ubuntu/usr/bin
    find $HOME/chroot/ubuntu/usr/bin -type f -exec chmod 755 {} \; 2>/dev/null || true
fi

if [ -d "$HOME/chroot/ubuntu/usr/sbin" ]; then
    chmod 755 $HOME/chroot/ubuntu/usr/sbin
    find $HOME/chroot/ubuntu/usr/sbin -type f -exec chmod 755 {} \; 2>/dev/null || true
fi

# Set permissions for library directories
if [ -d "$HOME/chroot/ubuntu/lib" ]; then
    chmod 755 $HOME/chroot/ubuntu/lib
    find $HOME/chroot/ubuntu/lib -type f -exec chmod 644 {} \; 2>/dev/null || true
fi

if [ -d "$HOME/chroot/ubuntu/usr/lib" ]; then
    chmod 755 $HOME/chroot/ubuntu/usr/lib
    find $HOME/chroot/ubuntu/usr/lib -type f -exec chmod 644 {} \; 2>/dev/null || true
fi

# Set permissions for configuration files
if [ -d "$HOME/chroot/ubuntu/etc" ]; then
    chmod 755 $HOME/chroot/ubuntu/etc
    find $HOME/chroot/ubuntu/etc -type f -exec chmod 644 {} \; 2>/dev/null || true
fi

# Set permissions for home directory
if [ -d "$HOME/chroot/ubuntu/home" ]; then
    chmod 755 $HOME/chroot/ubuntu/home
    find $HOME/chroot/ubuntu/home -type d -exec chmod 755 {} \; 2>/dev/null || true
    find $HOME/chroot/ubuntu/home -type f -exec chmod 644 {} \; 2>/dev/null || true
fi

# Set permissions for temporary directories
if [ -d "$HOME/chroot/ubuntu/tmp" ]; then
    chmod 1777 $HOME/chroot/ubuntu/tmp
fi

if [ -d "$HOME/chroot/ubuntu/var/tmp" ]; then
    chmod 1777 $HOME/chroot/ubuntu/var/tmp
fi

# Set permissions for log directories
if [ -d "$HOME/chroot/ubuntu/var/log" ]; then
    chmod 755 $HOME/chroot/ubuntu/var/log
fi

echo "Permissions set successfully"

echo "=== Stage 1 completed ==="
echo ""
echo "Proceed to stage 2" 
