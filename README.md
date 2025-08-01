# Ubuntu روی اندروید 🐧

نصب آسان Ubuntu 22.04 روی اندروید با ایزولاسیون کامل.

## 🚀 نصب سریع

### مرحله 1: دانلود فایل‌ها
```bash
# دانلود از GitHub
wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/setup_ubuntu_android.sh
wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/install_ubuntu.sh
wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/ubuntu_manager.sh
```

### مرحله 2: انتقال به اندروید
```bash
# انتقال فایل‌ها
adb push setup_ubuntu_android.sh /sdcard/
adb push install_ubuntu.sh /sdcard/
adb push ubuntu_manager.sh /sdcard/
```

### مرحله 3: آماده‌سازی
```bash
adb shell
cd /sdcard
chmod +x *.sh
./setup_ubuntu_android.sh
```

### مرحله 4: نصب
```bash
su
./install_ubuntu.sh
```

### مرحله 5: استفاده
```bash
su
./ubuntu_manager.sh
```

## 📋 منوی مدیریت

```
1. ورود به Ubuntu
2. نصب پکیج
3. به‌روزرسانی سیستم
4. نمایش وضعیت
5. پاکسازی
6. حذف کامل
7. راهنما
0. خروج
```

## ⚠️ پیش‌نیازها

- اندروید با دسترسی Root
- حداقل 2GB فضای آزاد
- اتصال اینترنت

## 🔧 دستورات مفید

### داخل Ubuntu:
```bash
sudo apt-get install nginx    # نصب وب سرور
sudo apt-get update           # به‌روزرسانی
exit                         # خروج
```

### خارج از Ubuntu:
```bash
./ubuntu_manager.sh           # منوی مدیریت
/data/local/ubuntu/enter.sh  # ورود مستقیم
```

## 🐛 عیب‌یابی

### خطای دسترسی:
```bash
su
chmod +x *.sh
```

### خطای فضای دیسک:
```bash
df -h
# حداقل 2GB نیاز است
```

### حذف کامل:
```bash
rm -rf /data/local/ubuntu
```

---

**نکته:** این محیط برای توسعه و تست طراحی شده است. 🎉 