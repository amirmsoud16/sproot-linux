#!/bin/bash
# Ubuntu 18.04 proot installer for Termux
set -e

pkg install proot-distro -y

echo "[INFO] Installing Ubuntu 18.04 (proot-distro)..."
proot-distro install ubuntu-18.04

echo "[SUCCESS] Ubuntu 18.04 (proot) is installed."
echo "برای ورود به اوبونتو پروت:"
echo "proot-distro login ubuntu-18.04" 