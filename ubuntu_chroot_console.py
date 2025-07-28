#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Ubuntu Chroot Console Installer for Termux
Console interface for Ubuntu chroot installation when GUI is not available
Compatible with Poco X3 Pro and other Android devices
"""

import os
import sys
import subprocess
import time
from pathlib import Path

class UbuntuChrootConsole:
    def __init__(self):
        self.ubuntu_dir = Path.home() / "ubuntu"
        self.colors = {
            'green': '\033[92m',
            'red': '\033[91m',
            'yellow': '\033[93m',
            'blue': '\033[94m',
            'bold': '\033[1m',
            'end': '\033[0m'
        }
    
    def print_colored(self, message, color='white'):
        """Print colored message"""
        color_code = self.colors.get(color, '')
        print(f"{color_code}{message}{self.colors['end']}")
    
    def print_header(self):
        """Print application header"""
        print("\n" + "="*60)
        self.print_colored("Ubuntu Chroot Console Installer for Termux", 'bold')
        self.print_colored("رابط متنی نصب اوبونتو روی ترماکس", 'blue')
        print("="*60)
    
    def detect_device_info(self):
        """Detect device information"""
        print("\n🔍 در حال تشخیص اطلاعات دستگاه...")
        
        device_info = {}
        
        try:
            # CPU architecture
            result = subprocess.run("uname -m", shell=True, capture_output=True, text=True)
            device_info['architecture'] = result.stdout.strip()
            
            # Device model
            result = subprocess.run("getprop ro.product.model", shell=True, capture_output=True, text=True)
            device_info['model'] = result.stdout.strip()
            
            # Android version
            result = subprocess.run("getprop ro.build.version.release", shell=True, capture_output=True, text=True)
            device_info['android_version'] = result.stdout.strip()
            
            # RAM info
            result = subprocess.run("cat /proc/meminfo | grep MemTotal", shell=True, capture_output=True, text=True)
            if result.stdout.strip():
                mem_kb = int(result.stdout.strip().split()[1])
                device_info['ram_gb'] = round(mem_kb / 1024 / 1024, 1)
            else:
                device_info['ram_gb'] = "Unknown"
            
            # Root status
            device_info['rooted'] = os.path.exists("/system/bin/su") or os.path.exists("/system/xbin/su")
            
            # Disk space
            statvfs = os.statvfs("/data")
            device_info['free_space_gb'] = round((statvfs.f_frsize * statvfs.f_bavail) / (1024**3), 1)
            
            return device_info
            
        except Exception as e:
            print(f"خطا در تشخیص اطلاعات دستگاه: {e}")
            return {
                'architecture': 'Unknown',
                'model': 'Unknown',
                'android_version': 'Unknown',
                'ram_gb': 'Unknown',
                'rooted': False,
                'free_space_gb': 0
            }
    
    def check_system(self):
        """Perform comprehensive system check"""
        print("\n🔍 در حال بررسی سیستم...")
        
        device_info = self.detect_device_info()
        
        print(f"\n📱 اطلاعات دستگاه:")
        print(f"   • معماری: {device_info['architecture']}")
        print(f"   • مدل: {device_info['model']}")
        print(f"   • اندروید: {device_info['android_version']}")
        print(f"   • رم: {device_info['ram_gb']} GB")
        print(f"   • فضای آزاد: {device_info['free_space_gb']} GB")
        print(f"   • روت: {'بله' if device_info['rooted'] else 'خیر'}")
        
        # Check Termux environment
        if os.path.exists("/data/data/com.termux"):
            self.print_colored("✓ محیط ترماکس یافت شد", 'green')
        else:
            self.print_colored("✗ محیط ترماکس یافت نشد", 'red')
            return False
        
        # Check internet connection
        try:
            result = subprocess.run(["ping", "-c", "1", "8.8.8.8"], capture_output=True, timeout=5)
            if result.returncode == 0:
                self.print_colored("✓ اتصال اینترنت موجود است", 'green')
            else:
                self.print_colored("✗ اتصال اینترنت مشکل دارد", 'red')
        except:
            self.print_colored("✗ اتصال اینترنت مشکل دارد", 'red')
        
        # Check required packages
        packages = ["wget", "curl", "proot", "tar"]
        missing_packages = []
        
        for pkg in packages:
            try:
                result = subprocess.run(["which", pkg], capture_output=True)
                if result.returncode == 0:
                    self.print_colored(f"✓ {pkg} نصب شده است", 'green')
                else:
                    missing_packages.append(pkg)
            except:
                missing_packages.append(pkg)
        
        if missing_packages:
            self.print_colored(f"⚠ پکیج‌های زیر نصب نیستند: {', '.join(missing_packages)}", 'yellow')
        else:
            self.print_colored("✓ تمام پکیج‌های مورد نیاز نصب هستند", 'green')
        
        # Check Ubuntu installation
        if self.ubuntu_dir.exists():
            self.print_colored("✓ اوبونتو قبلاً نصب شده است", 'green')
        else:
            self.print_colored("ℹ اوبونتو نصب نشده است", 'blue')
        
        print("\n✅ بررسی سیستم کامل شد!")
        return True
    
    def show_installation_options(self):
        """Show installation options"""
        print("\n📦 انتخاب نوع نصب:")
        print("1. نصب Chroot (پیشنهادی برای دستگاه‌های روت)")
        print("   • عملکرد بهتر")
        print("   • نیاز به روت")
        print("   • سازگاری بیشتر")
        print()
        print("2. نصب Proot (برای دستگاه‌های غیر روت)")
        print("   • بدون نیاز به روت")
        print("   • عملکرد متوسط")
        print("   • سازگاری محدود")
        
        while True:
            choice = input("\nانتخاب کنید (1 یا 2): ").strip()
            if choice == "1":
                return "chroot"
            elif choice == "2":
                return "proot"
            else:
                print("لطفاً 1 یا 2 وارد کنید.")
    
    def show_ubuntu_versions(self):
        """Show Ubuntu version options"""
        print("\n🐧 انتخاب نسخه اوبونتو:")
        print("1. Ubuntu 24.04 LTS (جدیدترین)")
        print("2. Ubuntu 22.04 LTS (پیشنهادی)")
        print("3. Ubuntu 20.04 LTS (پایدار)")
        print("4. Ubuntu 18.04 LTS (قدیمی)")
        
        versions = {
            "1": "24.04",
            "2": "22.04",
            "3": "20.04",
            "4": "18.04"
        }
        
        while True:
            choice = input("\nانتخاب کنید (1-4): ").strip()
            if choice in versions:
                return versions[choice]
            else:
                print("لطفاً عدد 1 تا 4 وارد کنید.")
    
    def install_ubuntu(self, install_type, ubuntu_version):
        """Install Ubuntu with selected options"""
        print(f"\n🚀 شروع نصب اوبونتو {ubuntu_version} ({install_type})...")
        
        # Confirm installation
        confirm = input(f"\nآیا می‌خواهید اوبونتو {ubuntu_version} ({install_type}) را نصب کنید؟ (y/N): ").strip().lower()
        if confirm not in ['y', 'yes']:
            print("نصب لغو شد.")
            return False
        
        print(f"\n⏳ نصب در حال انجام است... (10-20 دقیقه)")
        
        try:
            # Step 1: Update Termux
            print("مرحله 1: به‌روزرسانی ترماکس...")
            result = subprocess.run("pkg update -y", shell=True, capture_output=True, text=True)
            if result.returncode != 0:
                self.print_colored("خطا در به‌روزرسانی ترماکس", 'red')
                return False
            self.print_colored("✓ ترماکس به‌روزرسانی شد", 'green')
            
            # Step 2: Install required packages
            print("مرحله 2: نصب پکیج‌های مورد نیاز...")
            packages = ["wget", "curl", "tar", "git", "nano", "vim"]
            
            if install_type == "proot":
                packages.append("proot")
            else:
                packages.append("proot-distro")
            
            for pkg in packages:
                print(f"نصب {pkg}...")
                result = subprocess.run(f"pkg install {pkg} -y", shell=True, capture_output=True, text=True)
                if result.returncode != 0:
                    self.print_colored(f"خطا در نصب {pkg}", 'red')
                    return False
            self.print_colored("✓ پکیج‌های مورد نیاز نصب شدند", 'green')
            
            # Step 3: Create Ubuntu directory
            print("مرحله 3: ایجاد دایرکتوری اوبونتو...")
            self.ubuntu_dir.mkdir(exist_ok=True)
            (self.ubuntu_dir / "rootfs").mkdir(exist_ok=True)
            (self.ubuntu_dir / "scripts").mkdir(exist_ok=True)
            self.print_colored("✓ دایرکتوری اوبونتو ایجاد شد", 'green')
            
            # Step 4: Download Ubuntu script
            print("مرحله 4: دانلود اسکریپت اوبونتو...")
            
            if install_type == "chroot":
                script_url = f"https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Installer/Ubuntu/ubuntu-{ubuntu_version}.sh"
            else:
                script_url = f"https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Installer/Ubuntu/ubuntu-{ubuntu_version}-proot.sh"
            
            script_path = self.ubuntu_dir / f"ubuntu-{ubuntu_version}-{install_type}.sh"
            
            result = subprocess.run(f"curl -L -o {script_path} {script_url}", shell=True, capture_output=True, text=True)
            if result.returncode != 0:
                self.print_colored("خطا در دانلود اسکریپت اوبونتو", 'red')
                return False
            
            subprocess.run(f"chmod +x {script_path}", shell=True)
            self.print_colored("✓ اسکریپت اوبونتو دانلود شد", 'green')
            
            # Step 5: Install Ubuntu
            print(f"مرحله 5: نصب اوبونتو {ubuntu_version} ({install_type})...")
            os.chdir(self.ubuntu_dir)
            result = subprocess.run(f"./ubuntu-{ubuntu_version}-{install_type}.sh", shell=True, capture_output=True, text=True)
            if result.returncode != 0:
                self.print_colored("خطا در نصب اوبونتو", 'red')
                return False
            self.print_colored("✓ اوبونتو نصب شد", 'green')
            
            # Step 6: Setup environment variables
            print("مرحله 6: تنظیم متغیرهای محیطی...")
            bashrc_path = Path.home() / ".bashrc"
            env_vars = [
                f"export UBUNTU_VERSION={ubuntu_version}",
                f"export INSTALL_TYPE={install_type}",
                "export DISPLAY=:0",
                "export PULSE_SERVER=127.0.0.1",
                "export VNC_DISPLAY=:1"
            ]
            
            with open(bashrc_path, 'a') as f:
                for var in env_vars:
                    f.write(f"{var}\n")
            self.print_colored("✓ متغیرهای محیطی تنظیم شدند", 'green')
            
            # Step 7: Create additional scripts
            print("مرحله 7: ایجاد اسکریپت‌های کمکی...")
            self.create_additional_scripts(install_type, ubuntu_version)
            self.print_colored("✓ اسکریپت‌های کمکی ایجاد شدند", 'green')
            
            self.print_colored(f"\n🎉 نصب اوبونتو {ubuntu_version} ({install_type}) کامل شد!", 'green')
            print(f"\nبرای شروع:")
            print("cd ~/ubuntu")
            print("./start-ubuntu.sh")
            
            return True
            
        except Exception as e:
            self.print_colored(f"خطا در نصب: {e}", 'red')
            return False
    
    def create_additional_scripts(self, install_type="chroot", ubuntu_version="22.04"):
        """Create additional helper scripts"""
        # LXDE installation script
        lxde_script = f"""#!/bin/bash
echo "نصب LXDE دسکتاپ برای اوبونتو {ubuntu_version}..."
apt update
apt install lxde-core lxde lxde-common lxde-icon-theme tightvncserver firefox-esr geany leafpad -y
echo "LXDE نصب شد!"
"""
        
        lxde_path = self.ubuntu_dir / "install-lxde.sh"
        with open(lxde_path, 'w') as f:
            f.write(lxde_script)
        os.chmod(lxde_path, 0o755)
        
        # VNC setup script
        vnc_script = f"""#!/bin/bash
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
xrdb $HOME/.Xresources
startlxde &
EOF
chmod +x ~/.vnc/xstartup
vncpasswd
echo "VNC تنظیم شد!"
"""
        
        vnc_path = self.ubuntu_dir / "setup-vnc.sh"
        with open(vnc_path, 'w') as f:
            f.write(vnc_script)
        os.chmod(vnc_path, 0o755)
        
        # Post-install script
        post_script = f"""#!/bin/bash
echo "تنظیمات پس از نصب اوبونتو {ubuntu_version} ({install_type})..."
apt update && apt upgrade -y
apt install sudo nano vim git wget curl htop -y
echo "تنظیمات پس از نصب کامل شد!"
"""
        
        post_path = self.ubuntu_dir / "post-install.sh"
        with open(post_path, 'w') as f:
            f.write(post_script)
        os.chmod(post_path, 0o755)
    
    def remove_ubuntu(self):
        """Remove Ubuntu completely"""
        confirm = input("\nآیا می‌خواهید اوبونتو را کاملاً حذف کنید؟ (y/N): ").strip().lower()
        if confirm not in ['y', 'yes']:
            print("حذف لغو شد.")
            return False
        
        print("\n🗑️ در حال حذف اوبونتو...")
        
        try:
            if self.ubuntu_dir.exists():
                import shutil
                shutil.rmtree(self.ubuntu_dir)
                self.print_colored("✓ دایرکتوری اوبونتو حذف شد", 'green')
            else:
                print("دایرکتوری اوبونتو یافت نشد")
            
            # Remove environment variables from .bashrc
            bashrc_path = Path.home() / ".bashrc"
            if bashrc_path.exists():
                with open(bashrc_path, 'r') as f:
                    lines = f.readlines()
                
                # Remove Ubuntu-related environment variables
                filtered_lines = []
                for line in lines:
                    if any(var in line for var in ["DISPLAY=:0", "PULSE_SERVER=127.0.0.1", "VNC_DISPLAY=:1", "UBUNTU_VERSION=", "INSTALL_TYPE="]):
                        continue
                    filtered_lines.append(line)
                
                with open(bashrc_path, 'w') as f:
                    f.writelines(filtered_lines)
                
                self.print_colored("✓ متغیرهای محیطی حذف شدند", 'green')
            
            self.print_colored("✅ حذف اوبونتو کامل شد!", 'green')
            return True
            
        except Exception as e:
            self.print_colored(f"خطا در حذف: {e}", 'red')
            return False
    
    def run(self):
        """Run the console application"""
        self.print_header()
        
        # Check if running in Termux
        if not os.path.exists("/data/data/com.termux"):
            self.print_colored("خطا: این اسکریپت باید در ترماکس اجرا شود!", 'red')
            return
        
        while True:
            print("\n" + "-"*40)
            print("منوی اصلی:")
            print("1. بررسی سیستم")
            print("2. نصب اوبونتو")
            print("3. حذف کامل اوبونتو")
            print("4. خروج")
            print("-"*40)
            
            choice = input("\nانتخاب کنید (1-4): ").strip()
            
            if choice == "1":
                self.check_system()
                
            elif choice == "2":
                install_type = self.show_installation_options()
                ubuntu_version = self.show_ubuntu_versions()
                self.install_ubuntu(install_type, ubuntu_version)
                
            elif choice == "3":
                self.remove_ubuntu()
                
            elif choice == "4":
                print("\n👋 خروج از برنامه...")
                break
                
            else:
                print("❌ انتخاب نامعتبر. لطفاً 1-4 وارد کنید.")

def main():
    """Main function"""
    app = UbuntuChrootConsole()
    app.run()

if __name__ == "__main__":
    main() 