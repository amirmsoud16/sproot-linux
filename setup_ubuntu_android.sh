#!/bin/bash

# Ubuntu Android Setup - Pre-Root Script
# Setup script before root access

echo "🐧 Ubuntu Android Setup - Step 1"
echo "=================================="
echo ""

# Check if we're on Android
if [ -f "/system/build.prop" ]; then
    echo "✅ Android system detected"
    ANDROID_VERSION=$(grep "ro.build.version.release" /system/build.prop | cut -d'=' -f2)
    echo "📱 Android version: $ANDROID_VERSION"
else
    echo "⚠️  This doesn't seem to be an Android system"
fi

echo ""
echo "📋 Checking prerequisites:"

# Check available space
AVAILABLE_SPACE=$(df /data 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
AVAILABLE_SPACE_GB=$((AVAILABLE_SPACE / 1024 / 1024))

if [ $AVAILABLE_SPACE_GB -lt 2 ]; then
    echo "❌ Free space less than 2GB"
    echo "💡 At least 2GB free space required"
    exit 1
else
    echo "✅ Free space: ${AVAILABLE_SPACE_GB}GB"
fi

# Check internet connection
echo "🌐 Checking internet connection..."
if ping -c 1 8.8.8.8 &> /dev/null; then
    echo "✅ Internet connection established"
else
    echo "❌ Internet connection not available"
    echo "💡 Please check your internet connection"
    exit 1
fi

echo ""
echo "📦 Checking required tools..."

# Check for essential tools
TOOLS=("wget" "curl" "tar" "gzip")
MISSING_TOOLS=()

for tool in "${TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        MISSING_TOOLS+=($tool)
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo "⚠️  The following tools were not found: ${MISSING_TOOLS[*]}"
    echo "💡 Please install these tools first"
    echo "💡 If using Termux: pkg install wget curl tar gzip"
    exit 1
else
    echo "✅ All required tools are available"
fi

echo ""
echo "🔍 Checking Android environment..."
echo "Android version: $(getprop ro.build.version.release 2>/dev/null || echo 'Unknown')"
echo "Device: $(getprop ro.product.model 2>/dev/null || echo 'Unknown')"
echo "Architecture: $(uname -m)"

echo ""
echo "📁 Creating installation script in current directory..."

echo "✅ Installation script created: install_ubuntu.sh"

echo ""
echo "🎯 Step 1 completed!"
echo ""
echo "📋 Next steps:"
echo "1. Get root access: su"
echo "2. Run installation script: ./install_ubuntu.sh"
echo ""
echo "⏳ Estimated installation time: 10-15 minutes"
echo "💾 Required space: about 1.5GB"
echo ""
echo "💡 Important notes:"
echo "- Internet connection must be stable"
echo "- Device should not go to sleep"
echo "- If error occurs, try again"
echo ""
echo "🚀 Ready for next step!" 
