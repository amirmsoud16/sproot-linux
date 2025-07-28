#!/bin/bash

# Ubuntu Chroot Installer - Quick Setup Script
# پروژه گیت‌هاب: https://github.com/amirmsoud16/ubuntu-chroot-pk-

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  Ubuntu Chroot Installer${NC}"
echo -e "${BLUE}  گیت‌هاب: https://github.com/amirmsoud16/ubuntu-chroot-pk-${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Check if running in Termux
if [[ ! -d "/data/data/com.termux" ]]; then
    echo -e "${RED}Error: This script must be run in Termux!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Termux environment detected${NC}"

# Update Termux
echo -e "${YELLOW}Updating Termux packages...${NC}"
pkg update -y

# Install required packages
echo -e "${YELLOW}Installing required packages...${NC}"
pkg install wget curl proot tar git nano vim -y

# Download the installer
echo -e "${YELLOW}Downloading Ubuntu Chroot installer...${NC}"
wget -O ubuntu_chroot_installer.sh https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/ubuntu_chroot_installer.sh

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✓ Installer downloaded successfully${NC}"
    
    # Make executable
    chmod +x ubuntu_chroot_installer.sh
    
    echo -e "${GREEN}✓ Installer is ready to run${NC}"
    echo ""
    echo -e "${YELLOW}To start the installer, run:${NC}"
    echo -e "${BLUE}./ubuntu_chroot_installer.sh${NC}"
    echo ""
    
    # Ask if user wants to run now
    read -p "Do you want to run the installer now? (y/N): " run_now
    if [[ "$run_now" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Starting Ubuntu Chroot installer...${NC}"
        ./ubuntu_chroot_installer.sh
    else
        echo -e "${YELLOW}You can run the installer later with: ./ubuntu_chroot_installer.sh${NC}"
    fi
else
    echo -e "${RED}Failed to download installer${NC}"
    exit 1
fi 