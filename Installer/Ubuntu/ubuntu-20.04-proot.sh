#!/bin/bash
# Ubuntu 20.04 proot installer for Termux
set -e

pkg install proot-distro -y

echo "[INFO] Installing Ubuntu 20.04 (proot-distro)..."
proot-distro install ubuntu-20.04

echo "[SUCCESS] Ubuntu 20.04 (proot) is installed."
echo "برای ورود به اوبونتو پروت:"
echo "proot-distro login ubuntu-20.04" 