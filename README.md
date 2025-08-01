# Ubuntu روی اندروید - نصب آسان 🐧

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Android](https://img.shields.io/badge/Platform-Android-green.svg)](https://www.android.com/)
[![Ubuntu: 22.04](https://img.shields.io/badge/Ubuntu-22.04-orange.svg)](https://ubuntu.com/)

این پروژه Ubuntu 22.04 را روی اندروید با ایزولاسیون کامل نصب می‌کند.

## ✨ ویژگی‌ها

- **نصب آسان** - فقط 2 مرحله
- **ایزولاسیون کامل** - امن و جدا از سیستم اندروید
- **منوی ساده** - مدیریت آسان
- **Ubuntu سبک** - استفاده از minbase
- **دسترسی SD Card** - فایل‌های اندروید قابل دسترسی

## 🚀 نصب سریع از GitHub

### روش 1: دانلود مستقیم
```bash
# دانلود فایل‌ها از GitHub
wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/setup_ubuntu_android.sh
wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/ubuntu_manager.sh

# انتقال به اندروید
adb push setup_ubuntu_android.sh /sdcard/
adb push ubuntu_manager.sh /sdcard/
```

### روش 2: Clone کامل
```bash
# Clone کردن repository
git clone https://github.com/amirmsoud16/ubuntu-chroot-pk-.git
cd ubuntu-chroot-pk-

# انتقال فایل‌ها به اندروید
adb push setup_ubuntu_android.sh /sdcard/
adb push ubuntu_manager.sh /sdcard/
```

### روش 3: دانلود ZIP
1. به [GitHub Repository](https://github.com/amirmsoud16/ubuntu-chroot-pk-) بروید
2. روی **Code** کلیک کنید
3. **Download ZIP** را انتخاب کنید
4. فایل‌های `setup_ubuntu_android.sh` و `ubuntu_manager.sh` را استخراج کنید
5. با ADB انتقال دهید

## 📱 مراحل نصب

### مرحله 1: آماده‌سازی (بدون root)
```bash
# ورود به اندروید
adb shell
cd /sdcard

# دادن مجوز اجرا
chmod +x setup_ubuntu_android.sh
chmod +x ubuntu_manager.sh

# اجرای آماده‌سازی
./setup_ubuntu_android.sh
```

### مرحله 2: نصب (با root)
```bash
# دسترسی root
su

# اجرای نصب
cd /sdcard/ubuntu-setup
./install_ubuntu.sh
```

## 🛠️ استفاده

### ورود به Ubuntu:
```bash
su
./ubuntu_manager.sh
# گزینه 1 را انتخاب کنید
```

### یا مستقیم:
```bash
su
/data/local/ubuntu/enter.sh
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

## 📦 پکیج‌های آماده

- **sudo** - دسترسی مدیریتی
- **vim** - ویرایشگر متن
- **nano** - ویرایشگر ساده
- **curl** - دانلود فایل
- **wget** - دانلود فایل
- **git** - کنترل نسخه
- **python3** - زبان برنامه‌نویسی

## 🔧 دستورات مفید

### داخل Ubuntu:
```bash
sudo apt-get install nginx    # نصب وب سرور
sudo apt-get update           # به‌روزرسانی لیست
sudo apt-get upgrade          # به‌روزرسانی سیستم
exit                         # خروج
```

### خارج از Ubuntu:
```bash
./ubuntu_manager.sh           # منوی مدیریت
/data/local/ubuntu/enter.sh  # ورود مستقیم
```

## 📁 ساختار فایل‌ها

```
/data/local/ubuntu/          # مسیر اصلی Ubuntu
├── enter.sh                 # اسکریپت ورود
├── mount.sh                 # اسکریپت mount
├── unmount.sh               # اسکریپت unmount
└── [فایل‌های سیستم Ubuntu]

/sdcard/ubuntu-setup/        # فایل‌های نصب
├── install_ubuntu.sh        # اسکریپت نصب
└── [فایل‌های موقت]
```

## ⚠️ نکات مهم

### پیش‌نیازها:
- اندروید با دسترسی Root
- حداقل 2GB فضای آزاد
- اتصال اینترنت

### زمان نصب:
- حدود 10-15 دقیقه
- بستگی به سرعت اینترنت دارد

### امنیت:
- محیط کاملاً ایزوله
- تغییرات روی اندروید تأثیر نمی‌گذارد

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

### خطای شبکه:
```bash
echo "nameserver 8.8.8.8" > /data/local/ubuntu/etc/resolv.conf
```

### حذف کامل:
```bash
rm -rf /data/local/ubuntu
rm -rf /sdcard/ubuntu-setup
```

## 📞 پشتیبانی

برای گزارش مشکلات:
1. بررسی کنید که همه پیش‌نیازها برآورده شده
2. اتصال اینترنت را بررسی کنید
3. فضای دیسک را بررسی کنید
4. از آخرین نسخه اسکریپت‌ها استفاده کنید

## 🤝 مشارکت

1. Repository را Fork کنید
2. شاخه جدید بسازید (`git checkout -b feature/AmazingFeature`)
3. تغییرات را Commit کنید (`git commit -m 'Add some AmazingFeature'`)
4. به شاخه Push کنید (`git push origin feature/AmazingFeature`)
5. Pull Request باز کنید

## 📄 لایسنس

این پروژه تحت لایسنس MIT منتشر شده است - برای جزئیات فایل [LICENSE](LICENSE) را ببینید.

## 🙏 تشکر

- تیم Ubuntu برای توزیع فوق‌العاده
- جامعه اندروید برای روش‌های دسترسی root
- تکنولوژی Linux chroot

---

**نکته:** این محیط برای توسعه و تست طراحی شده است. 🎉

## 📊 آمار پروژه

![GitHub stars](https://img.shields.io/github/stars/amirmsoud16/ubuntu-chroot-pk-)
![GitHub forks](https://img.shields.io/github/forks/amirmsoud16/ubuntu-chroot-pk-)
![GitHub issues](https://img.shields.io/github/issues/amirmsoud16/ubuntu-chroot-pk-)
![GitHub pull requests](https://img.shields.io/github/issues-pr/amirmsoud16/ubuntu-chroot-pk-) 