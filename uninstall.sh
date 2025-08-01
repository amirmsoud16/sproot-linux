#!/bin/bash

# Chroot uninstall script

echo "=== Chroot Uninstall ==="

# Check root access
if [ "$(id -u)" != "0" ]; then
   echo "This script requires root access"
   echo "Please run with su"
   exit 1
fi

echo "Are you sure you want to uninstall chroot?"
echo "This will remove all chroot files and directories"
echo ""
read -p "Continue? (y/N): " confirm

if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
    echo "Uninstall cancelled"
    exit 0
fi

echo "Starting uninstall..."

# Unmount all chroot-related mount points
echo "Unmounting file systems..."

# Check and unmount mount points
if mountpoint -q $HOME/chroot/home/user_data 2>/dev/null; then
    umount $HOME/chroot/home/user_data
fi

if mountpoint -q $HOME/chroot/ubuntu/tmp 2>/dev/null; then
    umount $HOME/chroot/ubuntu/tmp
fi

if mountpoint -q $HOME/chroot/ubuntu/dev/pts 2>/dev/null; then
    umount $HOME/chroot/ubuntu/dev/pts
fi

if mountpoint -q $HOME/chroot/ubuntu/dev 2>/dev/null; then
    umount $HOME/chroot/ubuntu/dev
fi

if mountpoint -q $HOME/chroot/ubuntu/sys 2>/dev/null; then
    umount $HOME/chroot/ubuntu/sys
fi

if mountpoint -q $HOME/chroot/ubuntu/proc 2>/dev/null; then
    umount $HOME/chroot/ubuntu/proc
fi

# Remove all chroot directories and files
echo "Removing all chroot files and directories..."

if [ -d "$HOME/chroot" ]; then
    rm -rf $HOME/chroot
    echo "Chroot directory and all contents removed"
else
    echo "Chroot directory not found"
fi

# Remove ubuntu shortcut
if [ -f "$PREFIX/bin/ubuntu" ]; then
    rm -f $PREFIX/bin/ubuntu
    echo "Ubuntu shortcut removed"
fi

# Check and remove remaining files
if [ -f "$HOME/chroot" ]; then
    rm -f $HOME/chroot
fi

echo ""
echo "=== Uninstall completed! ==="
echo ""
echo "All chroot files, directories, and shortcuts have been completely removed"
echo ""
echo "To reinstall, run the stage scripts" 
