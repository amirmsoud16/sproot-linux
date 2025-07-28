#!/bin/bash
# Ubuntu 22.04 proot installer for Termux
set -e

pkg install proot-distro -y

echo "[INFO] Installing Ubuntu 22.04 (proot-distro)..."
proot-distro install ubuntu-22.04

echo "[SUCCESS] Ubuntu 22.04 (proot) is installed."
echo "برای ورود به اوبونتو پروت:"
echo "proot-distro login ubuntu-22.04" 