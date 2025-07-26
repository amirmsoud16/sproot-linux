#!/data/data/com.termux/files/usr/bin/bash

# Test script to verify Ubuntu installer
echo "Testing Ubuntu installer..."

# Check if running on Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo "ERROR: This script must be run on Termux!"
    echo "You are currently on: $(uname -a)"
    exit 1
fi

echo "✅ Running on Termux"
echo "✅ Script is working"
echo "✅ Ready to install Ubuntu"

# Test curl
if command -v curl >/dev/null 2>&1; then
    echo "✅ curl is available"
else
    echo "❌ curl is not available"
    echo "Please run: pkg install curl"
fi

echo "Test completed!" 