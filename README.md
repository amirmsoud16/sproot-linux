# 🐧 Ubuntu Chroot & Proot Installer for Termux

> **نصب آسان Ubuntu در Termux با یک کلیک!**

[![GitHub](https://img.shields.io/badge/GitHub-Repository-blue?style=flat&logo=github)](https://github.com/amirmsoud16/ubuntu-chroot-pk-)
[![Termux](https://img.shields.io/badge/Termux-Compatible-green?style=flat&logo=android)](https://termux.dev/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-18.04%20%7C%2020.04%20%7C%2022.04%20%7C%2024.04-orange?style=flat&logo=ubuntu)](https://ubuntu.com/)

---

## 🚀 نصب سریع
### مرحله 1: نصب پیشنیاز ها 
```bash
apt update -y
apt upgrade -y
```

```bash
apt install -y wget curl git nano vim tar proot
```
### مرحله 2: اجرا 
```bash
wget https://raw.githubusercontent.com/amirmsoud16/ubuntu-chroot-pk-/main/install.sh
chmod +x install.sh
./install.sh
```

## 📋 مراحل کامل نصب

### 1️⃣ **نصب Ubuntu**

```
┌─ Ubuntu Chroot & Proot Installer ─┐
│ 1. System Check                    │
│ 2. Install Ubuntu               │
│ 3. Remove Ubuntu                   │
│ 4. Exit                            │
└────────────────────────────────────┘
```
## 🎯 دستورات دسترسی سریع

| دستور | توضیح |

# ورود به عنوان root (بار اول بدون رمز)
```
ubuntu(18.or.20.or.22.or.24)
```
# اجرای setup اولیه-
```
./ubuntu-root-setup.sh
```
# خروج از محیط root
```
exit
```
# ورود به عنوان user (جایگزین username با نام کاربری خود)
```
ubuntu(18.or.20.or.22.or.24)-username
```
# اجرای setup ابزارها
```
./ubuntu-tools-setup.sh
```
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
# در منو گزینه 2 را انتخاب کنید
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
echo "Thanks for using Ubuntu Chroot Installer!"
```

---

## 📄 لایسنس

این پروژه تحت لایسنس MIT منتشر شده است.

---

**ساخته شده با ❤️ برای جامعه Termux** 
