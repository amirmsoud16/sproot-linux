#!/bin/bash

# Stage 1: Install prerequisites and download Ubuntu

echo "=== Stage 1: Installing prerequisites and downloading Ubuntu ==="

# Create required directories
echo "Creating required directories..."
mkdir -p /data/local/chroot
mkdir -p /data/local/chroot/ubuntu
mkdir -p /data/local/chroot/scripts
mkdir -p /data/local/chroot/home
mkdir -p /data/local/chroot/home/user_data

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
cd /data/local/chroot

# Download Ubuntu Cloud .xz for ARM64
wget -O ubuntu-rootfs.tar.xz https://cloud-images.ubuntu.com/releases/jammy/release-20250725/ubuntu-22.04-server-cloudimg-arm64-root.tar.xz

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
chmod 755 /data/local/chroot
chmod 755 /data/local/chroot/ubuntu
chmod 755 /data/local/chroot/scripts
chmod 755 /data/local/chroot/home
chmod 755 /data/local/chroot/home/user_data

# Set ownership (if possible)
if command -v chown &> /dev/null; then
    echo "Setting ownership..."
    chown -R root:root /data/local/chroot/ubuntu 2>/dev/null || true
    chown -R root:root /data/local/chroot/scripts 2>/dev/null || true
    chown -R root:root /data/local/chroot/home 2>/dev/null || true
fi

# Set specific permissions for Ubuntu system files
echo "Setting Ubuntu system permissions..."
find /data/local/chroot/ubuntu -type d -exec chmod 755 {} \; 2>/dev/null || true
find /data/local/chroot/ubuntu -type f -exec chmod 644 {} \; 2>/dev/null || true

# Set executable permissions for important files
echo "Setting executable permissions..."
find /data/local/chroot/ubuntu -name "*.sh" -exec chmod 755 {} \; 2>/dev/null || true
find /data/local/chroot/ubuntu -name "*.py" -exec chmod 755 {} \; 2>/dev/null || true
find /data/local/chroot/ubuntu -name "*.pl" -exec chmod 755 {} \; 2>/dev/null || true

# Set permissions for system directories
if [ -d "/data/local/chroot/ubuntu/bin" ]; then
    chmod 755 /data/local/chroot/ubuntu/bin
    find /data/local/chroot/ubuntu/bin -type f -exec chmod 755 {} \; 2>/dev/null || true
fi

if [ -d "/data/local/chroot/ubuntu/sbin" ]; then
    chmod 755 /data/local/chroot/ubuntu/sbin
    find /data/local/chroot/ubuntu/sbin -type f -exec chmod 755 {} \; 2>/dev/null || true
fi

if [ -d "/data/local/chroot/ubuntu/usr/bin" ]; then
    chmod 755 /data/local/chroot/ubuntu/usr/bin
    find /data/local/chroot/ubuntu/usr/bin -type f -exec chmod 755 {} \; 2>/dev/null || true
fi

if [ -d "/data/local/chroot/ubuntu/usr/sbin" ]; then
    chmod 755 /data/local/chroot/ubuntu/usr/sbin
    find /data/local/chroot/ubuntu/usr/sbin -type f -exec chmod 755 {} \; 2>/dev/null || true
fi

# Set permissions for library directories
if [ -d "/data/local/chroot/ubuntu/lib" ]; then
    chmod 755 /data/local/chroot/ubuntu/lib
    find /data/local/chroot/ubuntu/lib -type f -exec chmod 644 {} \; 2>/dev/null || true
fi

if [ -d "/data/local/chroot/ubuntu/usr/lib" ]; then
    chmod 755 /data/local/chroot/ubuntu/usr/lib
    find /data/local/chroot/ubuntu/usr/lib -type f -exec chmod 644 {} \; 2>/dev/null || true
fi

# Set permissions for configuration files
if [ -d "/data/local/chroot/ubuntu/etc" ]; then
    chmod 755 /data/local/chroot/ubuntu/etc
    find /data/local/chroot/ubuntu/etc -type f -exec chmod 644 {} \; 2>/dev/null || true
fi

# Set permissions for home directory
if [ -d "/data/local/chroot/ubuntu/home" ]; then
    chmod 755 /data/local/chroot/ubuntu/home
    find /data/local/chroot/ubuntu/home -type d -exec chmod 755 {} \; 2>/dev/null || true
    find /data/local/chroot/ubuntu/home -type f -exec chmod 644 {} \; 2>/dev/null || true
fi

# Set permissions for temporary directories
if [ -d "/data/local/chroot/ubuntu/tmp" ]; then
    chmod 1777 /data/local/chroot/ubuntu/tmp
fi

if [ -d "/data/local/chroot/ubuntu/var/tmp" ]; then
    chmod 1777 /data/local/chroot/ubuntu/var/tmp
fi

# Set permissions for log directories
if [ -d "/data/local/chroot/ubuntu/var/log" ]; then
    chmod 755 /data/local/chroot/ubuntu/var/log
fi

echo "Permissions set successfully"

echo "=== Stage 1 completed ==="
echo ""
echo "Proceed to stage 2" 
