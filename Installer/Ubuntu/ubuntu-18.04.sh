#!/bin/bash
# Ubuntu 18.04 rootfs installer for Termux (arm64)
set -e

INSTALL_DIR=$HOME/ubuntu18-rootfs
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

ROOTFS_URL="https://partner-images.canonical.com/core/bionic/current/ubuntu-bionic-core-cloudimg-arm64-root.tar.gz"

echo "[INFO] Downloading Ubuntu 18.04 rootfs..."
wget -O ubuntu-18.04-rootfs.tar.gz $ROOTFS_URL

echo "[INFO] Extracting rootfs..."
proot --link2symlink tar -xf ubuntu-18.04-rootfs.tar.gz --exclude='./dev'

cat > start-ubuntu.sh <<EOF
#!/bin/bash
unset LD_PRELOAD
proot -0 -r \$HOME/ubuntu18-rootfs -b /dev -b /proc -b /sys -b /data/data/com.termux/files/home:/root -w /root /usr/bin/env -i HOME=/root TERM="\$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
chmod +x start-ubuntu.sh

echo "[SUCCESS] Ubuntu 18.04 rootfs is ready."
echo "برای ورود به اوبونتو:"
echo "cd \$HOME/ubuntu18-rootfs && ./start-ubuntu.sh" 