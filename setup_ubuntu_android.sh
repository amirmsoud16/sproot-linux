#!/bin/bash

# Ubuntu Android Setup - Pre-Root Script
# اسکریپت آماده‌سازی قبل از دسترسی root

echo "🐧 Ubuntu Android Setup - مرحله اول"
echo "=================================="
echo ""

# Check if we're on Android
if [ -f "/system/build.prop" ]; then
    echo "✅ سیستم اندروید تشخیص داده شد"
    ANDROID_VERSION=$(grep "ro.build.version.release" /system/build.prop | cut -d'=' -f2)
    echo "📱 نسخه اندروید: $ANDROID_VERSION"
else
    echo "⚠️  به نظر می‌رسد این سیستم اندروید نیست"
fi

echo ""
echo "📋 بررسی پیش‌نیازها:"

# Check available space
AVAILABLE_SPACE=$(df /data 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
AVAILABLE_SPACE_GB=$((AVAILABLE_SPACE / 1024 / 1024))

if [ $AVAILABLE_SPACE_GB -lt 2 ]; then
    echo "❌ فضای آزاد کمتر از 2GB است"
    echo "💡 حداقل 2GB فضای آزاد نیاز است"
    exit 1
else
    echo "✅ فضای آزاد: ${AVAILABLE_SPACE_GB}GB"
fi

# Check internet connection
echo "🌐 بررسی اتصال اینترنت..."
if ping -c 1 8.8.8.8 &> /dev/null; then
    echo "✅ اتصال اینترنت برقرار است"
else
    echo "❌ اتصال اینترنت برقرار نیست"
    echo "💡 لطفاً اتصال اینترنت را بررسی کنید"
    exit 1
fi

echo ""
echo "📦 بررسی ابزارهای مورد نیاز..."

# Check for essential tools
TOOLS=("wget" "curl" "tar" "gzip")
MISSING_TOOLS=()

for tool in "${TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        MISSING_TOOLS+=($tool)
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo "⚠️  ابزارهای زیر یافت نشدند: ${MISSING_TOOLS[*]}"
    echo "💡 لطفاً ابتدا این ابزارها را نصب کنید"
    exit 1
else
    echo "✅ همه ابزارهای مورد نیاز موجود هستند"
fi

echo ""
echo "📁 ایجاد پوشه‌های موقت..."
mkdir -p /sdcard/ubuntu-setup
mkdir -p /sdcard/ubuntu-setup/scripts
mkdir -p /sdcard/ubuntu-setup/downloads

echo "✅ پوشه‌های موقت ایجاد شدند"

echo ""
echo "📥 دانلود اسکریپت‌های نصب..."

# Create the main installation script
cat > /sdcard/ubuntu-setup/install_ubuntu.sh << 'EOF'
#!/bin/bash

# Ubuntu Android Installer - Post-Root Script
# اسکریپت نصب بعد از دسترسی root

set -e

# Configuration
CHROOT_DIR="/data/local/ubuntu"
UBUNTU_VERSION="22.04"
UBUNTU_CODENAME="jammy"
ARCH="amd64"
MIRROR="http://archive.ubuntu.com/ubuntu"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check root access
if [[ $EUID -ne 0 ]]; then
    print_error "این اسکریپت باید با دسترسی root اجرا شود"
    echo "💡 دستور: su && ./install_ubuntu.sh"
    exit 1
fi

print_status "شروع نصب Ubuntu $UBUNTU_VERSION..."

# Install debootstrap if not available
if ! command -v debootstrap &> /dev/null; then
    print_status "نصب debootstrap..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y debootstrap
    elif command -v pkg &> /dev/null; then
        pkg install debootstrap
    else
        print_error "نمی‌توان debootstrap را نصب کرد"
        exit 1
    fi
fi

# Create chroot directory
print_status "ایجاد پوشه‌های chroot..."
mkdir -p "$CHROOT_DIR"
mkdir -p "$CHROOT_DIR/proc"
mkdir -p "$CHROOT_DIR/sys"
mkdir -p "$CHROOT_DIR/dev"
mkdir -p "$CHROOT_DIR/tmp"
mkdir -p "$CHROOT_DIR/mnt/sdcard"

# Install Ubuntu base system
print_status "نصب سیستم پایه Ubuntu..."
print_warning "این مرحله ممکن است 10-15 دقیقه طول بکشد..."

debootstrap --arch=$ARCH --variant=minbase $UBUNTU_CODENAME "$CHROOT_DIR" $MIRROR

if [ $? -eq 0 ]; then
    print_status "Ubuntu با موفقیت نصب شد"
else
    print_error "خطا در نصب Ubuntu"
    exit 1
fi

# Configure chroot
print_status "تنظیم chroot..."

# Copy DNS
cp /etc/resolv.conf "$CHROOT_DIR/etc/resolv.conf" 2>/dev/null || true

# Create sources.list
cat > "$CHROOT_DIR/etc/apt/sources.list" << 'SOURCES'
deb http://archive.ubuntu.com/ubuntu jammy main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu jammy-security main restricted universe multiverse
SOURCES

# Mount for package installation
mount -t proc /proc "$CHROOT_DIR/proc"
mount -t sysfs /sys "$CHROOT_DIR/sys"
mount -o bind /dev "$CHROOT_DIR/dev"

# Install essential packages
print_status "نصب پکیج‌های ضروری..."
chroot "$CHROOT_DIR" apt-get update
chroot "$CHROOT_DIR" apt-get install -y sudo vim nano curl wget git python3

# Create user
chroot "$CHROOT_DIR" useradd -m -s /bin/bash android
echo "android ALL=(ALL) NOPASSWD:ALL" | chroot "$CHROOT_DIR" tee /etc/sudoers.d/android

# Unmount
umount "$CHROOT_DIR/dev"
umount "$CHROOT_DIR/sys"
umount "$CHROOT_DIR/proc"

# Create management scripts
print_status "ایجاد اسکریپت‌های مدیریت..."

# Mount script
cat > "$CHROOT_DIR/mount.sh" << 'MOUNT'
#!/bin/bash
mount -t proc /proc /data/local/ubuntu/proc
mount -t sysfs /sys /data/local/ubuntu/sys
mount -o bind /dev /data/local/ubuntu/dev
mount -o bind /sdcard /data/local/ubuntu/mnt/sdcard
echo "✅ Ubuntu mount شد"
MOUNT

# Unmount script
cat > "$CHROOT_DIR/unmount.sh" << 'UNMOUNT'
#!/bin/bash
umount /data/local/ubuntu/mnt/sdcard 2>/dev/null || true
umount /data/local/ubuntu/dev 2>/dev/null || true
umount /data/local/ubuntu/sys 2>/dev/null || true
umount /data/local/ubuntu/proc 2>/dev/null || true
echo "✅ Ubuntu unmount شد"
UNMOUNT

# Enter script
cat > "$CHROOT_DIR/enter.sh" << 'ENTER'
#!/bin/bash
/data/local/ubuntu/mount.sh
echo "🐧 ورود به Ubuntu..."
echo "💡 برای خروج 'exit' تایپ کنید"
echo ""
chroot /data/local/ubuntu /bin/bash
/data/local/ubuntu/unmount.sh
ENTER

chmod +x "$CHROOT_DIR/mount.sh"
chmod +x "$CHROOT_DIR/unmount.sh"
chmod +x "$CHROOT_DIR/enter.sh"

print_status "نصب کامل شد!"
echo ""
echo "📋 نحوه استفاده:"
echo "   ورود به Ubuntu:"
echo "   su"
echo "   /data/local/ubuntu/enter.sh"
echo ""
echo "📁 مسیر نصب: $CHROOT_DIR"
echo "💾 دسترسی SD Card: /mnt/sdcard"
echo "👤 کاربر: android (با sudo)"
EOF

chmod +x /sdcard/ubuntu-setup/install_ubuntu.sh

echo "✅ اسکریپت نصب دانلود شد"

echo ""
echo "🎯 مرحله اول کامل شد!"
echo ""
echo "📋 مراحل بعدی:"
echo "1. دسترسی root بگیرید: su"
echo "2. به پوشه setup بروید: cd /sdcard/ubuntu-setup"
echo "3. اسکریپت نصب را اجرا کنید: ./install_ubuntu.sh"
echo ""
echo "⏳ زمان تقریبی نصب: 10-15 دقیقه"
echo "💾 فضای مورد نیاز: حدود 1.5GB"
echo ""
echo "💡 نکات مهم:"
echo "- اتصال اینترنت باید برقرار باشد"
echo "- دستگاه نباید در حالت sleep برود"
echo "- در صورت خطا، دوباره تلاش کنید"
echo ""
echo "🚀 آماده برای مرحله بعدی!" 