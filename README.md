# Ubuntu روی اندروید 🐧

نصب آسان Ubuntu 22.04 روی اندروید با ایزولاسیون کامل.

## 🚀 نصب سریع

### مرحله 1: Clone کردن repository
```bash
# Clone کردن از GitHub
git clone https://github.com/amirmsoud16/ubuntu-chroot-pk-.git
cd ubuntu-chroot-pk-

# بررسی فایل‌ها
ls -la
# باید این فایل‌ها را ببینید:
# setup_ubuntu_android.sh
# install_ubuntu.sh
# ubuntu_manager.sh
```

### مرحله 2: تایید فایل‌ها
```bash
# دادن مجوز اجرا
chmod +x setup_ubuntu_android.sh
chmod +x install_ubuntu.sh
chmod +x ubuntu_manager.sh

# بررسی مجوزهای اجرا
ls -la *.sh
```

### مرحله 3: آماده‌سازی
```bash
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
