# Ubuntu Desktop on Termux
# اوبونتو دسکتاپ روی ترماکس

Complete Ubuntu 24.04 desktop environment installation on Termux with XFCE4, VNC server, Persian fonts and themes.

نصب کامل محیط دسکتاپ اوبونتو 24.04 روی ترماکس با XFCE4، سرور VNC، فونت‌های فارسی و تم‌ها.

## Features / ویژگی‌ها

- ✅ Ubuntu 24.04 LTS (Noble Numbat)
- ✅ XFCE4 Desktop Environment
- ✅ VNC Server for remote desktop access
- ✅ Persian/Arabic fonts support
- ✅ Modern themes (Arc-Dark, Papirus icons)
- ✅ Development tools (VS Code, Git, Python, Node.js)
- ✅ Multimedia support (VLC, GIMP, LibreOffice)
- ✅ Dual keyboard layout (US/Persian)

## Requirements / پیش‌نیازها

- Android device with Termux installed
- Minimum 4GB free storage space
- Stable internet connection
- VNC Viewer app (for desktop access)

- دستگاه اندروید با ترماکس نصب‌شده
- حداقل ۴ گیگابایت فضای خالی
- اتصال اینترنت پایدار
- اپلیکیشن VNC Viewer (برای دسترسی به دسکتاپ)

## Installation / نصب

### Step 1: Termux Setup / مرحله ۱: راه‌اندازی ترماکس

```bash
chmod +x 01_setup_termux.sh
./01_setup_termux.sh
```

This script will:
- Update Termux packages
- Install required tools (proot, wget, etc.)
- Download Ubuntu 24.04 rootfs
- Create Ubuntu startup script
- Set up directory structure

این اسکریپت:
- پکیج‌های ترماکس را به‌روزرسانی می‌کند
- ابزارهای مورد نیاز را نصب می‌کند (proot، wget و غیره)
- rootfs اوبونتو 24.04 را دانلود می‌کند
- اسکریپت راه‌اندازی اوبونتو را می‌سازد
- ساختار دایرکتوری را راه‌اندازی می‌کند

### Step 2: User Configuration / مرحله ۲: پیکربندی کاربر

```bash
chmod +x 02_setup_user.sh
./02_setup_user.sh
```

This script will:
- Configure Ubuntu system
- Create user account with sudo access
- Install essential packages
- Set up development environment
- Configure locales and timezone

این اسکریپت:
- سیستم اوبونتو را پیکربندی می‌کند
- حساب کاربری با دسترسی sudo می‌سازد
- پکیج‌های ضروری را نصب می‌کند
- محیط توسعه را راه‌اندازی می‌کند
- زبان و منطقه زمانی را تنظیم می‌کند

### Step 3: Desktop Installation / مرحله ۳: نصب دسکتاپ

```bash
chmod +x 03_install_desktop.sh
./03_install_desktop.sh
```

This script will:
- Install XFCE4 desktop environment
- Configure VNC server
- Install Persian/Arabic fonts
- Set up themes and icons
- Install applications (Firefox, LibreOffice, etc.)

این اسکریپت:
- محیط دسکتاپ XFCE4 را نصب می‌کند
- سرور VNC را پیکربندی می‌کند
- فونت‌های فارسی/عربی را نصب می‌کند
- تم‌ها و آیکون‌ها را راه‌اندازی می‌کند
- برنامه‌ها را نصب می‌کند (فایرفاکس، لیبره‌آفیس و غیره)

## Usage / استفاده

### Starting Ubuntu / راه‌اندازی اوبونتو

```bash
# Start as root / راه‌اندازی به عنوان روت
ubuntu

# Start as user / راه‌اندازی به عنوان کاربر
ubuntu-user
```

### VNC Desktop Access / دسترسی به دسکتاپ VNC

```bash
# Start VNC server / راه‌اندازی سرور VNC
start-vnc

# Stop VNC server / توقف سرور VNC
stop-vnc
```

**VNC Connection Details:**
- Address: `localhost:5901`
- Password: `vnc123`

**جزئیات اتصال VNC:**
- آدرس: `localhost:5901`
- رمز عبور: `vnc123`

### User Credentials / اطلاعات کاربری

- Username: `user`
- Password: `user123`
- Sudo access: Yes (no password required)

- نام کاربری: `user`
- رمز عبور: `user123`
- دسترسی sudo: بله (بدون نیاز به رمز عبور)

## Keyboard Layout / چیدمان کیبورد

- Default: US English
- Secondary: Persian/Farsi
- Switch: `Alt + Shift`

- پیش‌فرض: انگلیسی آمریکایی
- ثانویه: فارسی
- تغییر: `Alt + Shift`

## Installed Applications / برنامه‌های نصب‌شده

### Desktop Environment / محیط دسکتاپ
- XFCE4 Desktop
- Thunar File Manager
- XFCE Terminal
- Mousepad Text Editor

### Internet & Communication / اینترنت و ارتباطات
- Firefox Web Browser
- Thunderbird Email Client

### Office & Productivity / اداری و بهره‌وری
- LibreOffice Suite
- Document Viewer
- Calculator

### Development / توسعه
- Visual Studio Code
- Git
- Python 3 + pip
- Node.js + npm
- Build tools (gcc, make, cmake)

### Multimedia / چندرسانه‌ای
- VLC Media Player
- GIMP Image Editor
- Ristretto Image Viewer
- Parole Media Player
- Audacity Audio Editor

## Themes & Appearance / تم‌ها و ظاهر

- **Theme:** Arc-Dark
- **Icons:** Papirus-Dark
- **Font:** Ubuntu (with Persian support)
- **Cursor:** Default

## Troubleshooting / عیب‌یابی

### VNC Connection Issues / مشکلات اتصال VNC

```bash
# Check VNC server status / بررسی وضعیت سرور VNC
ubuntu-user -c "vncserver -list"

# Restart VNC server / راه‌اندازی مجدد سرور VNC
stop-vnc
start-vnc
```

### Storage Space / فضای ذخیره‌سازی

```bash
# Check disk usage / بررسی استفاده از دیسک
df -h $HOME/ubuntu-chroot

# Clean package cache / پاکسازی کش پکیج‌ها
ubuntu -c "apt autoremove && apt autoclean"
```

### Permission Issues / مشکلات مجوز

```bash
# Fix ownership / اصلاح مالکیت
ubuntu -c "chown -R user:user /home/user"
```

## File Locations / مکان فایل‌ها

- Ubuntu Root: `$HOME/ubuntu-chroot/ubuntu`
- User Home: `$HOME/ubuntu-chroot/home`
- Scripts: `$HOME/ubuntu-chroot/scripts`
- Termux Home (inside Ubuntu): `/termux-home`

## Uninstallation / حذف نصب

```bash
# Remove Ubuntu installation / حذف نصب اوبونتو
rm -rf $HOME/ubuntu-chroot
rm $PREFIX/bin/ubuntu
rm $PREFIX/bin/ubuntu-user
rm $PREFIX/bin/start-vnc
rm $PREFIX/bin/stop-vnc
```

## Support / پشتیبانی

For issues and questions, please create an issue in the repository.

برای مشکلات و سوالات، لطفاً در مخزن issue ایجاد کنید.

---

**Note:** This installation requires approximately 4GB of storage space and may take 30-60 minutes depending on your internet connection.

**توجه:** این نصب تقریباً ۴ گیگابایت فضای ذخیره‌سازی نیاز دارد و بسته به سرعت اینترنت شما ممکن است ۳۰ تا ۶۰ دقیقه طول بکشد.
