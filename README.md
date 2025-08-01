# Ubuntu روی اندروید - نصب آسان 🐧

## 📱 معرفی

این پروژه Ubuntu 22.04 را روی اندروید با ایزولاسیون کامل نصب می‌کند.

## ✨ ویژگی‌ها

- **نصب آسان** - فقط 2 مرحله
- **ایزولاسیون کامل** - امن و جدا از سیستم اندروید
- **منوی ساده** - مدیریت آسان
- **Ubuntu سبک** - استفاده از minbase
- **دسترسی SD Card** - فایل‌های اندروید قابل دسترسی

## 🚀 نصب

### مرحله 1: آماده‌سازی (بدون root)
```bash
# انتقال فایل‌ها به اندروید
adb push setup_ubuntu_android.sh /sdcard/
adb push ubuntu_manager.sh /sdcard/

# اجرای آماده‌سازی
adb shell
cd /sdcard
chmod +x setup_ubuntu_android.sh
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

---

**نکته:** این محیط برای توسعه و تست طراحی شده است. 🎉 