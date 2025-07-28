#!/bin/bash
# Ubuntu Chroot GUI Installer Runner
# برای اجرای رابط گرافیکی نصب اوبونتو

echo "Ubuntu Chroot GUI Installer"
echo "==========================="
echo ""

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo "Error: This script must be run in Termux!"
    exit 1
fi

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "Installing Python3..."
    pkg install python -y
fi

# Check if tkinter is available
if ! python3 -c "import tkinter" &> /dev/null; then
    echo "Installing tkinter..."
    pkg install python-tkinter -y
fi

# Check if required packages are installed
echo "Checking required packages..."
pkg install wget curl proot tar -y

# Check if GUI script exists
if [ ! -f "ubuntu_chroot_gui.py" ]; then
    echo "Error: ubuntu_chroot_gui.py not found!"
    echo "Please make sure the GUI script is in the current directory."
    exit 1
fi

# Make GUI script executable
chmod +x ubuntu_chroot_gui.py

# Set display for GUI (if needed)
export DISPLAY=:0

# Run the GUI installer
echo "Starting Ubuntu Chroot GUI Installer..."
echo "A graphical interface will open with 4 options:"
echo "1. System Check"
echo "2. Install Ubuntu"
echo "3. Remove Ubuntu"
echo "4. Exit"
echo ""

# Try to run GUI first
if python3 ubuntu_chroot_gui.py; then
    echo "GUI installer completed successfully!"
else
    echo ""
    echo "GUI failed to start. Trying console mode..."
    echo ""
    
    # Check if console version exists
    if [ -f "ubuntu_chroot_console.py" ]; then
        echo "Starting console mode installer..."
        python3 ubuntu_chroot_console.py
    else
        echo "Console version not found. Please check your installation."
        echo "You can try running the GUI manually:"
        echo "python3 ubuntu_chroot_gui.py"
    fi
fi

echo ""
echo "GUI installer completed!" 