# Ubuntu روی اندروید 🐧

نصب آسان Ubuntu 22.04 روی اندروید با ایزولاسیون کامل.

## 🚀 نصب سریع

### مرحله 1: Clone کردن repository

### 2️⃣ Update Termux

```bash
apt update -y
apt upgrade -y
```

### 3️⃣ Install Required Packages
```bash
apt install wget curl proot tar git nano vim -y tsu
```
```bash
git clone https://github.com/amirmsoud16/ubuntu-chroot-pk-.git
cd ubuntu-chroot-pk-
```
### مرحله 2: تایید فایل‌ها

# مرحله 1
```
chmod +x stage1_install_prerequisites.sh
./stage1_install_prerequisites.sh
```
# مرحله 2 (دستورات در README)
```
su
mount -t proc proc /data/local/chroot/ubuntu/proc
mount -t sysfs sysfs /data/local/chroot/ubuntu/sys
mount -o bind /dev /data/local/chroot/ubuntu/dev
mount -t devpts devpts /data/local/chroot/ubuntu/dev/pts
mount -t tmpfs tmpfs /data/local/chroot/ubuntu/tmp
chroot /data/local/chroot/ubuntu /bin/bash
```
# مرحله در chroot 3
```
chmod +x stage3_mount_and_setup.sh
./stage3_mount_and_setup.sh
```
