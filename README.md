# 🐧 Ubuntu Installer for Termux

> **نصب آسان Ubuntu در Termux با یک کلیک!**

## 🚀 نصب سریع

### مرحله 1: دانلود
```bash
wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/install.sh
```

### مرحله 2: اجرا
```bash
bash install.sh
```

### مرحله 3: انتخاب
- گزینه `1` را انتخاب کنید (Install Ubuntu)
- گزینه `2` را انتخاب کنید (Chroot)
- ورژن مورد نظر را انتخاب کنید

---

## 📋 مراحل کامل نصب

### 1️⃣ **نصب Ubuntu**
```bash
# دانلود و اجرا
wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/install.sh
bash install.sh
```

### 2️⃣ **انتخاب در منو**
```
Ubuntu Installer for Termux
Modern & Beautiful Setup

Available Options:
  1. 🚀 Install Ubuntu (Background Operation)
  2. 🗑️  Remove Ubuntu (Clean Uninstall)
  3. 📖 Installation Guide (Step by Step)
  4. 🔧 System Check (Prerequisites)
  5. ❌ Exit (Goodbye)
```

### 3️⃣ **انتخاب روش نصب**
```
🚀 Ubuntu Installation Menu

Select Installation Method:
  1. 🐧 Proot-Distro (Recommended - Easy)
  2. 🔧 Chroot (Advanced - Auto Setup Scripts)
  3. ↩️  Return to Main Menu
```

### 4️⃣ **انتخاب ورژن**
```
🔧 Chroot Installation

Select Ubuntu Version:
  1. 🐧 Ubuntu 18.04 LTS (Bionic Beaver)
  2. 🐧 Ubuntu 20.04 LTS (Focal Fossa)
  3. 🐧 Ubuntu 22.04 LTS (Jammy Jellyfish)
  4. 🐧 Ubuntu 24.04 LTS (Noble Numbat)
  5. ↩️  Return to Installation Menu
```

### 5️⃣ **راه‌اندازی اولیه**
```bash
# ورود به محیط Ubuntu
cd ~/ubuntu/ubuntu18-rootfs
proot -0 -r . -b /dev -b /proc -b /sys -w /root /bin/bash

# اجرای setup اولیه (در محیط Ubuntu)
./ubuntu-root-setup.sh

# خروج از Ubuntu
exit

# ورود مجدد به Ubuntu
cd ~/ubuntu/ubuntu18-rootfs
proot -0 -r . -b /dev -b /proc -b /sys -w /root /bin/bash

# نصب ابزارها (در محیط Ubuntu)
./ubuntu-tools-setup.sh
```

**نکته مهم:** اسکریپت‌های `ubuntu-root-setup.sh` و `ubuntu-tools-setup.sh` به صورت خودکار در دایرکتوری Ubuntu ساخته می‌شوند. شما فقط باید وارد محیط Ubuntu شوید و آنها را اجرا کنید.

**شورت‌کات‌های آسان:**
```bash
# بعد از نصب، می‌توانید از این دستورات استفاده کنید:
ubuntu18        # ورود به Ubuntu 18.04 به عنوان root
ubuntu18-user   # ورود به Ubuntu 18.04 به عنوان کاربر
ubuntu18-setup  # اجرای root setup
ubuntu18-tools  # اجرای tools setup
```

---

## 🎯 دستورات دسترسی سریع

| دستور | توضیح |
|-------|-------|
| `ubuntu18` | ورود به Ubuntu 18.04 به عنوان root |
| `ubuntu18-user` | ورود به Ubuntu 18.04 به عنوان کاربر |
| `ubuntu18-setup` | اجرای root setup |
| `ubuntu18-tools` | اجرای tools setup |
| `cd ~/ubuntu/ubuntu18-rootfs && proot -0 -r . -b /dev -b /proc -b /sys -w /root /bin/bash` | ورود دستی به محیط Ubuntu |
| `./ubuntu-root-setup.sh` | اجرای root setup (در Ubuntu) |
| `./ubuntu-tools-setup.sh` | اجرای tools setup (در Ubuntu) |
| `fix-internet-18` | رفع مشکل اینترنت |

---

## 📦 ابزارهای نصب شده

### 🔧 **ابزارهای اصلی**
- Python 3 + pip
- Node.js + npm
- Git + GitHub CLI
- GCC + Make
- Vim + Nano

### 🌐 **ابزارهای شبکه**
- curl + wget
- nmap + tcpdump
- netcat + telnet

### 🛠️ **ابزارهای توسعه**
- Docker + Podman
- AWS CLI + Azure CLI
- VS Code + Vim
- Jupyter + Flask

---

## ⚙️ ویژگی‌ها

### ✅ **نصب آسان**
- یک فایل، همه چیز
- منوی تعاملی
- نصب خودکار

### 🔒 **امنیت بالا**
- Smart Root Password
- Sudo بدون رمز برای کاربر
- محیط ایزوله

### ⚡ **عملکرد عالی**
- Chroot برای سرعت بالا
- Proot برای سازگاری
- بهینه‌سازی کامل

---

## 🆘 رفع مشکلات

### **مشکل: نصب نشد**
```bash
# بررسی فضای دیسک
df -h

# بررسی اینترنت
ping 8.8.8.8

# نصب مجدد
bash install.sh
```

### **مشکل: اینترنت کار نمی‌کند**
```bash
# در محیط Ubuntu
fix-internet-18
```

### **مشکل: دسترسی root**
```bash
# بررسی root status
su

# یا استفاده از Proot
# در منو گزینه 1 را انتخاب کنید
```

---

## 📞 پشتیبانی

- **GitHub Issues**: [گزارش مشکل](https://github.com/amirmsoud16/ubuntu-chroot-pk-/issues)
- **Telegram**: [کانال پشتیبانی](https://t.me/ubuntu_chroot_support)

---

## ⭐ ستاره‌دهی

اگر این پروژه برایتان مفید بود، لطفاً ⭐ بدهید!

```bash
# حمایت از پروژه
echo "Thanks for using Ubuntu Installer!"
```

---

## 📄 لایسنس

این پروژه تحت لایسنس MIT منتشر شده است.

---

**ساخته شده با ❤️ برای جامعه Termux** 
