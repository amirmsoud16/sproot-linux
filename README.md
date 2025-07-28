# Ubuntu Chroot Installer for Termux

[مشاهده پروژه در گیت‌هاب](https://github.com/amirmsoud16/ubuntu-chroot-pk-)

## 🚀 نصب کننده اوبونتو برای ترماکس

یک نصب کننده کامل و آسان برای اوبونتو روی ترماکس با استفاده از اسکریپت‌های شل.

---

## 📥 لینک دانلود مستقیم از گیت‌هاب

- صفحه پروژه: [https://github.com/amirmsoud16/ubuntu-chroot-pk-](https://github.com/amirmsoud16/ubuntu-chroot-pk-)
- دانلود نصب‌کننده اصلی:
  ```bash
  wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/ubuntu_chroot_installer.sh
  chmod +x ubuntu_chroot_installer.sh
  ./ubuntu_chroot_installer.sh
  ```
- دانلود اسکریپت نصب خودکار:
  ```bash
  wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/install.sh
  chmod +x install.sh
  ./install.sh
  ```

---

## 📋 پیش‌نیازها (Prerequisites)

### 1️⃣ نصب ترماکس
```bash
# دانلود و نصب Termux از F-Droid
# https://f-droid.org/en/packages/com.termux/
```

### 2️⃣ به‌روزرسانی ترماکس
```bash
pkg update -y
pkg upgrade -y
```

### 3️⃣ نصب پکیج‌های مورد نیاز
```bash
# نصب ابزارهای مورد نیاز
pkg install wget curl proot tar git nano vim -y
```

---

## 🚀 نحوه اجرا

### روش 1: دانلود و اجرای مستقیم از گیت‌هاب
```bash
wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/ubuntu_chroot_installer.sh
chmod +x ubuntu_chroot_installer.sh
./ubuntu_chroot_installer.sh
```

### روش 2: استفاده از اسکریپت نصب خودکار
```bash
wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/install.sh
chmod +x install.sh
./install.sh
```

---

## 🎯 ویژگی‌های برنامه

### ✅ بررسی و آماده‌سازی سیستم
- بررسی محیط ترماکس
- بررسی فضای دیسک (حداقل 4GB)
- بررسی اتصال اینترنت
- نصب خودکار پکیج‌های مورد نیاز
- تنظیم DNS و مجوزها
- آماده‌سازی دایرکتوری اوبونتو

### ✅ نصب اوبونتو
- انتخاب نوع نصب (Chroot/Proot)
- انتخاب نسخه اوبونتو (18.04, 20.04, 22.04, 24.04)
- نصب خودکار LXDE دسکتاپ
- تنظیم VNC Server
- ایجاد اسکریپت‌های کمکی

### ✅ حذف کامل
- حذف تمام فایل‌های اوبونتو
- پاکسازی متغیرهای محیطی
- حذف فایل‌های اضافی

### ✅ دسترسی به اوبونتو
- دسترسی مستقیم (ترمینال)
- دسترسی VNC (گرافیکی)
- نصب LXDE دسکتاپ
- تنظیم VNC سرور

---

## 📱 پشتیبانی از دستگاه‌ها

### ✅ دستگاه‌های روت شده
- **نوع نصب:** Chroot
- **عملکرد:** عالی
- **سازگاری:** کامل
- **ویژگی‌ها:** تمام قابلیت‌ها

### ✅ دستگاه‌های غیر روت
- **نوع نصب:** Proot
- **عملکرد:** متوسط
- **سازگاری:** محدود
- **ویژگی‌ها:** پایه

---

## 🔄 دسترسی مجدد به اوبونتو

### بعد از نصب و خروج از ترماکس، برای دسترسی مجدد:

#### روش 1: دسترسی مستقیم
```bash
cd ~/ubuntu
./start-ubuntu.sh
```

#### روش 2: دسترسی با VNC (برای رابط گرافیکی)
```bash
vncserver :1 -geometry 1280x720 -depth 24
cd ~/ubuntu
./start-ubuntu-vnc.sh
```

#### روش 3: دسترسی سریع
```bash
echo 'alias ubuntu="cd ~/ubuntu && ./start-ubuntu.sh"' >> ~/.bashrc
source ~/.bashrc
ubuntu
```

#### روش 4: دسترسی با دسکتاپ گرافیکی
```bash
cd ~/ubuntu
./install-lxde.sh
./setup-vnc.sh
vncserver :1 -geometry 1280x720 -depth 24
# اتصال با VNC Viewer به localhost:5901
```

### 📱 دسترسی از خارج ترماکس:

#### استفاده از VNC Viewer:
1. **نصب VNC Viewer** روی گوشی
2. **اتصال به:** `localhost:5901`
3. **رمز عبور:** رمزی که هنگام setup-vnc تنظیم کردید

#### استفاده از Termux:API:
```bash
pkg install termux-api
termux-open-url vnc://localhost:5901
```

---

## 🔧 عیب‌یابی (Troubleshooting)

### مشکل: فایل start-ubuntu.sh پیدا نمی‌شود
```bash
ls -la ~/ubuntu/
./ubuntu_chroot_installer.sh
```

### مشکل: خطای مجوز
```bash
chmod +x ~/ubuntu/*.sh
chmod 755 ~/ubuntu
```

### مشکل: VNC کار نمی‌کند
```bash
vncserver -kill :1
vncserver :1 -geometry 1280x720 -depth 24
ps aux | grep vnc
```

### مشکل: فضای دیسک کم
```bash
pkg clean
apt clean
```

### مشکل: اتصال اینترنت
```bash
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
echo 'nameserver 8.8.4.4' >> /etc/resolv.conf
```

---

## 📊 حداقل نیازمندی‌ها

| مورد          | حداقل | پیشنهادی |
| ------------- | ----- | -------- |
| **رم**        | 2GB   | 4GB+     |
| **فضای دیسک** | 4GB   | 8GB+     |
| **اندروید**   | 7.0+  | 10.0+    |
| **معماری**    | ARM64 | ARM64    |

---

## 🎨 ویژگی‌های رابط کاربری

- ✅ **رابط رنگی** با پیام‌های واضح
- ✅ **منوی تعاملی** با گزینه‌های آسان
- ✅ **بررسی خودکار** سیستم
- ✅ **نصب خودکار** پکیج‌های مورد نیاز
- ✅ **پیام‌های راهنما** برای هر مرحله

---

## 📋 دستورات مفید

```bash
ls -la ~/ubuntu/
cat ~/ubuntu/ubuntu.log
cd ~/ubuntu && rm -rf tmp/*
cd ~/ubuntu && ./post-install.sh
```

---

## 📞 پشتیبانی

### گزارش مشکل
اگر با مشکلی مواجه شدید:
1. ابتدا پیش‌نیازها را بررسی کنید
2. لاگ‌های برنامه را بررسی کنید
3. مشکل را در Issues گزارش دهید

### مشارکت
برای مشارکت در توسعه:
1. Fork کنید
2. Branch جدید ایجاد کنید
3. تغییرات را commit کنید
4. Pull Request ارسال کنید

---

## 📄 لایسنس

این پروژه تحت لایسنس MIT منتشر شده است.

---

## 🙏 تشکر

از تمام کسانی که در توسعه این پروژه مشارکت کرده‌اند تشکر می‌کنیم.

---

**نکته مهم:** قبل از اجرای برنامه، حتماً تمام پیش‌نیازها را نصب کنید تا با مشکل مواجه نشوید. 