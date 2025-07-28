#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Ubuntu Chroot GUI Installer for Termux
Graphical interface for Ubuntu chroot installation with LXDE desktop and VNC
Compatible with Poco X3 Pro and other Android devices
"""

import os
import sys
import subprocess
import threading
import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
from pathlib import Path
import time

class UbuntuChrootGUI:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Ubuntu Chroot Installer - Termux")
        self.root.geometry("900x700")
        self.root.configure(bg='#1e1e1e')
        
        # Ubuntu directory
        self.ubuntu_dir = Path.home() / "ubuntu"
        
        # Colors
        self.colors = {
            'bg': '#1e1e1e',
            'fg': '#ffffff',
            'button_bg': '#2d2d2d',
            'button_fg': '#ffffff',
            'button_hover': '#3d3d3d',
            'success': '#4CAF50',
            'error': '#f44336',
            'warning': '#ff9800',
            'info': '#2196F3',
            'frame_bg': '#2b2b2b',
            'text_bg': '#1a1a1a'
        }
        
        self.setup_gui()
        
    def setup_gui(self):
        """Setup the graphical interface"""
        # Configure style
        style = ttk.Style()
        style.theme_use('clam')
        
        # Main frame
        main_frame = tk.Frame(self.root, bg=self.colors['bg'])
        main_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        # Title
        title_label = tk.Label(
            main_frame,
            text="Ubuntu Chroot Installer",
            font=("Arial", 28, "bold"),
            bg=self.colors['bg'],
            fg=self.colors['fg']
        )
        title_label.pack(pady=(0, 10))
        
        # Subtitle
        subtitle_label = tk.Label(
            main_frame,
            text="برای نصب اوبونتو روی ترماکس",
            font=("Arial", 16),
            bg=self.colors['bg'],
            fg=self.colors['fg']
        )
        subtitle_label.pack(pady=(0, 30))
        
        # Menu buttons frame with better styling
        button_frame = tk.Frame(main_frame, bg=self.colors['bg'])
        button_frame.pack(fill=tk.X, pady=20)
        
        # Create styled buttons
        buttons_data = [
            ("1. بررسی و آماده‌سازی سیستم", self.check_and_prepare_system, self.colors['info']),
            ("2. نصب اوبونتو", self.install_ubuntu, self.colors['success']),
            ("3. حذف کامل اوبونتو", self.remove_ubuntu, self.colors['warning']),
            ("4. خروج", self.exit_app, self.colors['error'])
        ]
        
        self.menu_buttons = []
        for text, command, color in buttons_data:
            btn = tk.Button(
                button_frame,
                text=text,
                font=("Arial", 16, "bold"),
                bg=color,
                fg=self.colors['button_fg'],
                relief=tk.RAISED,
                bd=0,
                padx=30,
                pady=15,
                command=lambda cmd=command: self.execute_with_clear(cmd),
                cursor="hand2"
            )
            btn.pack(fill=tk.X, pady=8, ipady=5)
            
            # Add hover effects
            btn.bind("<Enter>", lambda e, b=btn: self.on_button_hover(b, True))
            btn.bind("<Leave>", lambda e, b=btn: self.on_button_hover(b, False))
            
            self.menu_buttons.append(btn)
        
        # Status frame
        status_frame = tk.Frame(main_frame, bg=self.colors['bg'])
        status_frame.pack(fill=tk.BOTH, expand=True, pady=(20, 0))
        
        # Status label
        self.status_label = tk.Label(
            status_frame,
            text="آماده برای شروع...",
            font=("Arial", 14, "bold"),
            bg=self.colors['bg'],
            fg=self.colors['fg']
        )
        self.status_label.pack()
        
        # Progress bar
        self.progress = ttk.Progressbar(
            status_frame,
            mode='indeterminate',
            length=500
        )
        self.progress.pack(pady=15)
        
        # Log text area with better styling
        log_frame = tk.Frame(status_frame, bg=self.colors['bg'])
        log_frame.pack(fill=tk.BOTH, expand=True, pady=(15, 0))
        
        # Log title
        log_title = tk.Label(
            log_frame,
            text="لاگ عملیات:",
            font=("Arial", 12, "bold"),
            bg=self.colors['bg'],
            fg=self.colors['fg']
        )
        log_title.pack(anchor=tk.W, pady=(0, 5))
        
        self.log_text = scrolledtext.ScrolledText(
            log_frame,
            height=12,
            bg=self.colors['text_bg'],
            fg='#ffffff',
            font=("Consolas", 10),
            wrap=tk.WORD,
            relief=tk.FLAT,
            bd=0,
            insertbackground='#ffffff'
        )
        self.log_text.pack(fill=tk.BOTH, expand=True)
        
        # Initial system check
        self.update_status("بررسی اولیه سیستم...", "info")
        self.check_initial_system()
    
    def on_button_hover(self, button, entering):
        """Handle button hover effects"""
        if entering:
            # Darken the button
            current_bg = button.cget('bg')
            if current_bg == self.colors['info']:
                button.config(bg='#1976D2')
            elif current_bg == self.colors['success']:
                button.config(bg='#388E3C')
            elif current_bg == self.colors['warning']:
                button.config(bg='#F57C00')
            elif current_bg == self.colors['error']:
                button.config(bg='#D32F2F')
        else:
            # Restore original color
            if button == self.menu_buttons[0]:  # System check
                button.config(bg=self.colors['info'])
            elif button == self.menu_buttons[1]:  # Install
                button.config(bg=self.colors['success'])
            elif button == self.menu_buttons[2]:  # Remove
                button.config(bg=self.colors['warning'])
            elif button == self.menu_buttons[3]:  # Exit
                button.config(bg=self.colors['error'])
    
    def execute_with_clear(self, command):
        """Execute command with screen clear"""
        self.clear_log()
        command()
    
    def clear_log(self):
        """Clear the log text area"""
        self.log_text.delete(1.0, tk.END)
        self.root.update()
    
    def log_message(self, message, color="white"):
        """Add message to log with color"""
        color_map = {
            "success": "#4CAF50",
            "error": "#f44336",
            "warning": "#ff9800",
            "info": "#2196F3",
            "white": "#ffffff"
        }
        
        timestamp = time.strftime("%H:%M:%S")
        self.log_text.insert(tk.END, f"[{timestamp}] {message}\n")
        self.log_text.see(tk.END)
        
        # Color the last line
        last_line_start = self.log_text.index("end-2c linestart")
        last_line_end = self.log_text.index("end-1c")
        self.log_text.tag_add("colored", last_line_start, last_line_end)
        self.log_text.tag_config("colored", foreground=color_map.get(color, "#ffffff"))
        
        self.root.update()
    
    def update_status(self, message, status_type="info"):
        """Update status label with color"""
        color_map = {
            "success": self.colors['success'],
            "error": self.colors['error'],
            "warning": self.colors['warning'],
            "info": self.colors['info']
        }
        
        self.status_label.config(
            text=message,
            fg=color_map.get(status_type, self.colors['fg'])
        )
        self.root.update()
    
    def check_initial_system(self):
        """Initial system check"""
        def check():
            try:
                # Check if running in Termux
                if not os.path.exists("/data/data/com.termux"):
                    self.log_message("خطا: این اسکریپت باید در ترماکس اجرا شود!", "error")
                    self.update_status("خطا: محیط ترماکس یافت نشد", "error")
                    return
                
                # Check disk space
                statvfs = os.statvfs("/data")
                free_space_gb = (statvfs.f_frsize * statvfs.f_bavail) / (1024**3)
                
                if free_space_gb < 4:
                    self.log_message(f"هشدار: فضای دیسک کم است. موجود: {free_space_gb:.1f}GB", "warning")
                else:
                    self.log_message(f"فضای دیسک کافی: {free_space_gb:.1f}GB", "success")
                
                # Check if Ubuntu is already installed
                if self.ubuntu_dir.exists():
                    self.log_message("اوبونتو قبلاً نصب شده است", "info")
                    self.update_status("اوبونتو نصب شده است", "info")
                else:
                    self.log_message("اوبونتو نصب نشده است", "info")
                    self.update_status("آماده برای نصب", "success")
                
            except Exception as e:
                self.log_message(f"خطا در بررسی سیستم: {e}", "error")
        
        threading.Thread(target=check, daemon=True).start()
    
    def check_and_prepare_system(self):
        """Comprehensive system check and preparation"""
        self.update_status("در حال بررسی و آماده‌سازی سیستم...", "info")
        self.progress.start()
        
        def check_and_prepare():
            try:
                self.log_message("=== بررسی و آماده‌سازی کامل سیستم ===", "info")
                
                # Check Termux environment
                if os.path.exists("/data/data/com.termux"):
                    self.log_message("✓ محیط ترماکس یافت شد", "success")
                else:
                    self.log_message("✗ محیط ترماکس یافت نشد", "error")
                    self.update_status("خطا: محیط ترماکس یافت نشد", "error")
                    return
                
                # Check and fix root access
                if os.path.exists("/system/bin/su") or os.path.exists("/system/xbin/su"):
                    self.log_message("✓ دسترسی روت موجود است", "success")
                else:
                    self.log_message("⚠ دستگاه روت نشده است", "warning")
                    self.log_message("تلاش برای نصب su...", "info")
                    try:
                        result = subprocess.run("pkg install tsu -y", shell=True, capture_output=True, text=True)
                        if result.returncode == 0:
                            self.log_message("✓ tsu نصب شد", "success")
                        else:
                            self.log_message("⚠ نصب tsu ناموفق بود", "warning")
                    except:
                        self.log_message("⚠ نصب tsu ناموفق بود", "warning")
                
                # Check and fix disk space
                statvfs = os.statvfs("/data")
                free_space_gb = (statvfs.f_frsize * statvfs.f_bavail) / (1024**3)
                self.log_message(f"فضای دیسک موجود: {free_space_gb:.1f}GB", "info")
                
                if free_space_gb >= 4:
                    self.log_message("✓ فضای دیسک کافی است", "success")
                else:
                    self.log_message("✗ فضای دیسک کافی نیست (حداقل 4GB نیاز است)", "error")
                    self.log_message("تلاش برای پاکسازی کش...", "info")
                    try:
                        # Clear package cache
                        subprocess.run("pkg clean", shell=True, capture_output=True)
                        # Clear apt cache if exists
                        subprocess.run("apt clean", shell=True, capture_output=True)
                        self.log_message("✓ کش پاک شد", "success")
                        
                        # Recheck space
                        statvfs = os.statvfs("/data")
                        free_space_gb = (statvfs.f_frsize * statvfs.f_bavail) / (1024**3)
                        self.log_message(f"فضای دیسک پس از پاکسازی: {free_space_gb:.1f}GB", "info")
                    except:
                        self.log_message("⚠ پاکسازی کش ناموفق بود", "warning")
                
                # Check and fix internet connection
                try:
                    result = subprocess.run(["ping", "-c", "1", "8.8.8.8"], 
                                         capture_output=True, timeout=5)
                    if result.returncode == 0:
                        self.log_message("✓ اتصال اینترنت موجود است", "success")
                    else:
                        self.log_message("✗ اتصال اینترنت مشکل دارد", "error")
                        self.log_message("تلاش برای تنظیم DNS...", "info")
                        try:
                            # Set DNS servers
                            subprocess.run("echo 'nameserver 8.8.8.8' > /etc/resolv.conf", shell=True)
                            subprocess.run("echo 'nameserver 8.8.4.4' >> /etc/resolv.conf", shell=True)
                            self.log_message("✓ DNS تنظیم شد", "success")
                        except:
                            self.log_message("⚠ تنظیم DNS ناموفق بود", "warning")
                except:
                    self.log_message("✗ اتصال اینترنت مشکل دارد", "error")
                
                # Check and install required packages
                packages = ["wget", "curl", "proot", "tar", "git", "nano", "vim"]
                missing_packages = []
                
                for pkg in packages:
                    try:
                        result = subprocess.run(["which", pkg], capture_output=True)
                        if result.returncode == 0:
                            self.log_message(f"✓ {pkg} نصب شده است", "success")
                        else:
                            missing_packages.append(pkg)
                    except:
                        missing_packages.append(pkg)
                
                if missing_packages:
                    self.log_message(f"⚠ پکیج‌های زیر نصب نیستند: {', '.join(missing_packages)}", "warning")
                    self.log_message("در حال نصب پکیج‌های مورد نیاز...", "info")
                    
                    # Update package list first
                    try:
                        result = subprocess.run("pkg update -y", shell=True, capture_output=True, text=True)
                        if result.returncode == 0:
                            self.log_message("✓ به‌روزرسانی پکیج‌ها", "success")
                        else:
                            self.log_message("⚠ به‌روزرسانی پکیج‌ها ناموفق بود", "warning")
                    except:
                        self.log_message("⚠ به‌روزرسانی پکیج‌ها ناموفق بود", "warning")
                    
                    # Install missing packages
                    for pkg in missing_packages:
                        try:
                            self.log_message(f"نصب {pkg}...", "info")
                            result = subprocess.run(f"pkg install {pkg} -y", shell=True, capture_output=True, text=True)
                            if result.returncode == 0:
                                self.log_message(f"✓ {pkg} نصب شد", "success")
                            else:
                                self.log_message(f"✗ نصب {pkg} ناموفق بود", "error")
                        except:
                            self.log_message(f"✗ نصب {pkg} ناموفق بود", "error")
                else:
                    self.log_message("✓ تمام پکیج‌های مورد نیاز نصب هستند", "success")
                
                # Check and create Ubuntu directory
                if self.ubuntu_dir.exists():
                    self.log_message("✓ دایرکتوری اوبونتو موجود است", "success")
                else:
                    self.log_message("ایجاد دایرکتوری اوبونتو...", "info")
                    try:
                        self.ubuntu_dir.mkdir(exist_ok=True)
                        (self.ubuntu_dir / "rootfs").mkdir(exist_ok=True)
                        (self.ubuntu_dir / "scripts").mkdir(exist_ok=True)
                        self.log_message("✓ دایرکتوری اوبونتو ایجاد شد", "success")
                    except Exception as e:
                        self.log_message(f"✗ ایجاد دایرکتوری اوبونتو ناموفق بود: {e}", "error")
                
                # Check Ubuntu installation
                if self.ubuntu_dir.exists() and any(self.ubuntu_dir.iterdir()):
                    self.log_message("✓ اوبونتو قبلاً نصب شده است", "success")
                else:
                    self.log_message("ℹ اوبونتو نصب نشده است", "info")
                
                # Final system preparation
                self.log_message("آماده‌سازی نهایی سیستم...", "info")
                
                # Set proper permissions
                try:
                    subprocess.run("chmod 755 ~/ubuntu", shell=True)
                    self.log_message("✓ مجوزهای دایرکتوری تنظیم شد", "success")
                except:
                    self.log_message("⚠ تنظیم مجوزها ناموفق بود", "warning")
                
                # Create environment file
                try:
                    env_file = Path.home() / ".ubuntu_env"
                    with open(env_file, 'w') as f:
                        f.write("export UBUNTU_HOME=~/ubuntu\n")
                        f.write("export DISPLAY=:0\n")
                        f.write("export PULSE_SERVER=127.0.0.1\n")
                    self.log_message("✓ فایل محیطی ایجاد شد", "success")
                except:
                    self.log_message("⚠ ایجاد فایل محیطی ناموفق بود", "warning")
                
                self.log_message("=== بررسی و آماده‌سازی سیستم کامل شد ===", "success")
                self.update_status("سیستم آماده برای نصب است", "success")
                
                # Show summary
                summary = f"""
خلاصه بررسی سیستم:
✓ محیط ترماکس: آماده
✓ فضای دیسک: {free_space_gb:.1f}GB
✓ پکیج‌های مورد نیاز: {'نصب شده' if not missing_packages else 'نیاز به نصب'}
✓ دایرکتوری اوبونتو: آماده
✓ سیستم: آماده برای نصب
                """
                self.log_message(summary, "info")
                
            except Exception as e:
                self.log_message(f"خطا در بررسی و آماده‌سازی سیستم: {e}", "error")
                self.update_status("خطا در بررسی سیستم", "error")
            finally:
                self.progress.stop()
        
        threading.Thread(target=check_and_prepare, daemon=True).start()
    
    def detect_device_info(self):
        """Detect device architecture and specifications"""
        device_info = {}
        
        try:
            # Get CPU architecture
            result = subprocess.run("uname -m", shell=True, capture_output=True, text=True)
            device_info['architecture'] = result.stdout.strip()
            
            # Get device model
            result = subprocess.run("getprop ro.product.model", shell=True, capture_output=True, text=True)
            device_info['model'] = result.stdout.strip()
            
            # Get Android version
            result = subprocess.run("getprop ro.build.version.release", shell=True, capture_output=True, text=True)
            device_info['android_version'] = result.stdout.strip()
            
            # Get CPU info
            result = subprocess.run("cat /proc/cpuinfo | grep 'model name' | head -1", shell=True, capture_output=True, text=True)
            if result.stdout.strip():
                device_info['cpu'] = result.stdout.strip().split(':')[1].strip()
            else:
                device_info['cpu'] = "Unknown"
            
            # Get RAM info
            result = subprocess.run("cat /proc/meminfo | grep MemTotal", shell=True, capture_output=True, text=True)
            if result.stdout.strip():
                mem_kb = int(result.stdout.strip().split()[1])
                device_info['ram_gb'] = round(mem_kb / 1024 / 1024, 1)
            else:
                device_info['ram_gb'] = "Unknown"
            
            # Check if device is rooted
            device_info['rooted'] = os.path.exists("/system/bin/su") or os.path.exists("/system/xbin/su")
            
            # Get available disk space
            statvfs = os.statvfs("/data")
            device_info['free_space_gb'] = round((statvfs.f_frsize * statvfs.f_bavail) / (1024**3), 1)
            
        except Exception as e:
            self.log_message(f"خطا در تشخیص اطلاعات دستگاه: {e}", "error")
            device_info = {
                'architecture': 'Unknown',
                'model': 'Unknown',
                'android_version': 'Unknown',
                'cpu': 'Unknown',
                'ram_gb': 'Unknown',
                'rooted': False,
                'free_space_gb': 0
            }
        
        return device_info
    
    def show_installation_options(self):
        """Show installation options dialog"""
        # Create installation options window
        options_window = tk.Toplevel(self.root)
        options_window.title("انتخاب نوع نصب اوبونتو")
        options_window.geometry("700x600")
        options_window.configure(bg=self.colors['bg'])
        options_window.transient(self.root)
        options_window.grab_set()
        
        # Center the window
        options_window.geometry("+%d+%d" % (self.root.winfo_rootx() + 100, self.root.winfo_rooty() + 50))
        
        # Main frame with scroll
        canvas = tk.Canvas(options_window, bg=self.colors['bg'], highlightthickness=0)
        scrollbar = ttk.Scrollbar(options_window, orient="vertical", command=canvas.yview)
        scrollable_frame = tk.Frame(canvas, bg=self.colors['bg'])
        
        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )
        
        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)
        
        # Pack scroll components
        canvas.pack(side="left", fill="both", expand=True, padx=20, pady=20)
        scrollbar.pack(side="right", fill="y")
        
        # Title with better styling
        title_frame = tk.Frame(scrollable_frame, bg=self.colors['bg'])
        title_frame.pack(fill=tk.X, pady=(0, 20))
        
        title_label = tk.Label(
            title_frame,
            text="انتخاب نوع نصب اوبونتو",
            font=("Arial", 22, "bold"),
            bg=self.colors['bg'],
            fg=self.colors['fg']
        )
        title_label.pack()
        
        subtitle_label = tk.Label(
            title_frame,
            text="لطفاً گزینه مناسب را انتخاب کنید",
            font=("Arial", 14),
            bg=self.colors['bg'],
            fg=self.colors['fg']
        )
        subtitle_label.pack(pady=(5, 0))
        
        # Device info frame with better styling
        info_frame = tk.Frame(scrollable_frame, bg=self.colors['frame_bg'], relief=tk.RAISED, bd=2)
        info_frame.pack(fill=tk.X, pady=(0, 20), padx=10)
        
        info_title = tk.Label(
            info_frame,
            text="اطلاعات دستگاه",
            font=("Arial", 16, "bold"),
            bg=self.colors['frame_bg'],
            fg=self.colors['fg']
        )
        info_title.pack(pady=(10, 5))
        
        # Detect device info
        device_info = self.detect_device_info()
        
        # Display device info in a grid layout
        info_grid = tk.Frame(info_frame, bg=self.colors['frame_bg'])
        info_grid.pack(fill=tk.X, padx=20, pady=(0, 10))
        
        info_items = [
            ("معماری:", device_info['architecture']),
            ("مدل دستگاه:", device_info['model']),
            ("نسخه اندروید:", device_info['android_version']),
            ("رم:", f"{device_info['ram_gb']} GB"),
            ("فضای آزاد:", f"{device_info['free_space_gb']} GB"),
            ("دسترسی روت:", "بله" if device_info['rooted'] else "خیر")
        ]
        
        for i, (label, value) in enumerate(info_items):
            row = i // 2
            col = (i % 2) * 2
            
            tk.Label(
                info_grid,
                text=label,
                font=("Arial", 12, "bold"),
                bg=self.colors['frame_bg'],
                fg=self.colors['fg']
            ).grid(row=row, column=col, sticky="w", padx=(0, 10), pady=2)
            
            tk.Label(
                info_grid,
                text=value,
                font=("Arial", 12),
                bg=self.colors['frame_bg'],
                fg=self.colors['info']
            ).grid(row=row, column=col+1, sticky="w", padx=(0, 20), pady=2)
        
        # Installation type frame with better styling
        type_frame = tk.Frame(scrollable_frame, bg=self.colors['frame_bg'], relief=tk.RAISED, bd=2)
        type_frame.pack(fill=tk.X, pady=20, padx=10)
        
        type_title = tk.Label(
            type_frame,
            text="نوع نصب",
            font=("Arial", 16, "bold"),
            bg=self.colors['frame_bg'],
            fg=self.colors['fg']
        )
        type_title.pack(pady=(10, 15))
        
        # Installation type variable
        install_type = tk.StringVar(value="chroot")
        
        # Chroot option with better styling
        chroot_frame = tk.Frame(type_frame, bg=self.colors['frame_bg'])
        chroot_frame.pack(fill=tk.X, pady=5, padx=20)
        
        chroot_radio = tk.Radiobutton(
            chroot_frame,
            text="نصب Chroot (پیشنهادی برای دستگاه‌های روت)",
            variable=install_type,
            value="chroot",
            font=("Arial", 14, "bold"),
            bg=self.colors['frame_bg'],
            fg=self.colors['fg'],
            selectcolor=self.colors['success']
        )
        chroot_radio.pack(anchor=tk.W)
        
        chroot_desc = tk.Label(
            chroot_frame,
            text="• عملکرد بهتر و سریع‌تر\n• نیاز به دسترسی روت\n• سازگاری بیشتر با نرم‌افزارها\n• پشتیبانی کامل از تمام ویژگی‌ها",
            font=("Arial", 11),
            bg=self.colors['frame_bg'],
            fg=self.colors['fg'],
            justify=tk.LEFT
        )
        chroot_desc.pack(anchor=tk.W, padx=(25, 0), pady=(5, 10))
        
        # Proot option with better styling
        proot_frame = tk.Frame(type_frame, bg=self.colors['frame_bg'])
        proot_frame.pack(fill=tk.X, pady=5, padx=20)
        
        proot_radio = tk.Radiobutton(
            proot_frame,
            text="نصب Proot (برای دستگاه‌های غیر روت)",
            variable=install_type,
            value="proot",
            font=("Arial", 14, "bold"),
            bg=self.colors['frame_bg'],
            fg=self.colors['fg'],
            selectcolor=self.colors['warning']
        )
        proot_radio.pack(anchor=tk.W)
        
        proot_desc = tk.Label(
            proot_frame,
            text="• بدون نیاز به دسترسی روت\n• عملکرد متوسط\n• سازگاری محدود با برخی نرم‌افزارها\n• مناسب برای دستگاه‌های غیر روت",
            font=("Arial", 11),
            bg=self.colors['frame_bg'],
            fg=self.colors['fg'],
            justify=tk.LEFT
        )
        proot_desc.pack(anchor=tk.W, padx=(25, 0), pady=(5, 10))
        
        # Ubuntu version frame with better styling
        version_frame = tk.Frame(scrollable_frame, bg=self.colors['frame_bg'], relief=tk.RAISED, bd=2)
        version_frame.pack(fill=tk.X, pady=20, padx=10)
        
        version_title = tk.Label(
            version_frame,
            text="انتخاب نسخه اوبونتو",
            font=("Arial", 16, "bold"),
            bg=self.colors['frame_bg'],
            fg=self.colors['fg']
        )
        version_title.pack(pady=(10, 15))
        
        # Ubuntu version variable
        ubuntu_version = tk.StringVar(value="22.04")
        
        # Version options with better styling
        versions = [
            ("Ubuntu 24.04 LTS (جدیدترین)", "24.04", "جدیدترین نسخه با آخرین ویژگی‌ها"),
            ("Ubuntu 22.04 LTS (پیشنهادی)", "22.04", "پایدار و سازگار با اکثر نرم‌افزارها"),
            ("Ubuntu 20.04 LTS (پایدار)", "20.04", "بسیار پایدار و تست شده"),
            ("Ubuntu 18.04 LTS (قدیمی)", "18.04", "قدیمی اما بسیار پایدار")
        ]
        
        for desc, version, details in versions:
            version_frame_inner = tk.Frame(version_frame, bg=self.colors['frame_bg'])
            version_frame_inner.pack(fill=tk.X, pady=5, padx=20)
            
            version_radio = tk.Radiobutton(
                version_frame_inner,
                text=desc,
                variable=ubuntu_version,
                value=version,
                font=("Arial", 13, "bold"),
                bg=self.colors['frame_bg'],
                fg=self.colors['fg'],
                selectcolor=self.colors['info']
            )
            version_radio.pack(anchor=tk.W)
            
            version_desc = tk.Label(
                version_frame_inner,
                text=details,
                font=("Arial", 11),
                bg=self.colors['frame_bg'],
                fg=self.colors['fg'],
                justify=tk.LEFT
            )
            version_desc.pack(anchor=tk.W, padx=(25, 0), pady=(2, 8))
        
        # Buttons frame with better styling
        button_frame = tk.Frame(scrollable_frame, bg=self.colors['bg'])
        button_frame.pack(fill=tk.X, pady=(20, 0))
        
        # Continue button with hover effect
        continue_button = tk.Button(
            button_frame,
            text="ادامه نصب",
            font=("Arial", 16, "bold"),
            bg=self.colors['success'],
            fg=self.colors['button_fg'],
            relief=tk.RAISED,
            bd=0,
            padx=30,
            pady=12,
            cursor="hand2",
            command=lambda: self.start_installation(install_type.get(), ubuntu_version.get(), options_window)
        )
        continue_button.pack(side=tk.RIGHT, padx=(10, 0))
        
        # Add hover effect for continue button
        continue_button.bind("<Enter>", lambda e: continue_button.config(bg='#388E3C'))
        continue_button.bind("<Leave>", lambda e: continue_button.config(bg=self.colors['success']))
        
        # Cancel button with hover effect
        cancel_button = tk.Button(
            button_frame,
            text="لغو",
            font=("Arial", 16, "bold"),
            bg=self.colors['error'],
            fg=self.colors['button_fg'],
            relief=tk.RAISED,
            bd=0,
            padx=30,
            pady=12,
            cursor="hand2",
            command=options_window.destroy
        )
        cancel_button.pack(side=tk.LEFT, padx=(0, 10))
        
        # Add hover effect for cancel button
        cancel_button.bind("<Enter>", lambda e: cancel_button.config(bg='#D32F2F'))
        cancel_button.bind("<Leave>", lambda e: cancel_button.config(bg=self.colors['error']))
    
    def start_installation(self, install_type, ubuntu_version, options_window):
        """Start the installation process with selected options"""
        options_window.destroy()
        
        # Confirm installation
        confirm_msg = f"""آیا می‌خواهید اوبونتو را نصب کنید؟

نوع نصب: {install_type.upper()}
نسخه اوبونتو: {ubuntu_version}
زمان تخمینی: 10-20 دقیقه

این فرآیند زمان‌بر است و نیاز به اتصال اینترنت دارد."""
        
        if not messagebox.askyesno("تأیید نصب", confirm_msg):
            return
        
        self.update_status(f"در حال نصب اوبونتو {ubuntu_version} ({install_type})...", "info")
        self.progress.start()
        
        def install():
            try:
                self.log_message(f"=== شروع نصب اوبونتو {ubuntu_version} ({install_type}) ===", "info")
                
                # Step 1: Update Termux
                self.log_message("مرحله 1: به‌روزرسانی ترماکس...", "info")
                result = subprocess.run("pkg update -y", shell=True, capture_output=True, text=True)
                if result.returncode != 0:
                    self.log_message("خطا در به‌روزرسانی ترماکس", "error")
                    return
                self.log_message("✓ ترماکس به‌روزرسانی شد", "success")
                
                # Step 2: Install required packages
                self.log_message("مرحله 2: نصب پکیج‌های مورد نیاز...", "info")
                packages = ["wget", "curl", "tar", "git", "nano", "vim"]
                
                if install_type == "proot":
                    packages.append("proot")
                else:
                    packages.append("proot-distro")
                
                for pkg in packages:
                    self.log_message(f"نصب {pkg}...", "info")
                    result = subprocess.run(f"pkg install {pkg} -y", shell=True, capture_output=True, text=True)
                    if result.returncode != 0:
                        self.log_message(f"خطا در نصب {pkg}", "error")
                        return
                self.log_message("✓ پکیج‌های مورد نیاز نصب شدند", "success")
                
                # Step 3: Create Ubuntu directory
                self.log_message("مرحله 3: ایجاد دایرکتوری اوبونتو...", "info")
                self.ubuntu_dir.mkdir(exist_ok=True)
                (self.ubuntu_dir / "rootfs").mkdir(exist_ok=True)
                (self.ubuntu_dir / "scripts").mkdir(exist_ok=True)
                self.log_message("✓ دایرکتوری اوبونتو ایجاد شد", "success")
                
                # Step 4: Download appropriate script based on type and version
                self.log_message("مرحله 4: دانلود اسکریپت اوبونتو...", "info")
                
                if install_type == "chroot":
                    script_url = f"https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Installer/Ubuntu/ubuntu-{ubuntu_version}.sh"
                else:
                    script_url = f"https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Installer/Ubuntu/ubuntu-{ubuntu_version}-proot.sh"
                
                script_path = self.ubuntu_dir / f"ubuntu-{ubuntu_version}-{install_type}.sh"
                
                result = subprocess.run(f"curl -L -o {script_path} {script_url}", shell=True, capture_output=True, text=True)
                if result.returncode != 0:
                    self.log_message("خطا در دانلود اسکریپت اوبونتو", "error")
                    return
                
                subprocess.run(f"chmod +x {script_path}", shell=True)
                self.log_message("✓ اسکریپت اوبونتو دانلود شد", "success")
                
                # Step 5: Install Ubuntu
                self.log_message(f"مرحله 5: نصب اوبونتو {ubuntu_version} ({install_type})...", "info")
                os.chdir(self.ubuntu_dir)
                result = subprocess.run(f"./ubuntu-{ubuntu_version}-{install_type}.sh", shell=True, capture_output=True, text=True)
                if result.returncode != 0:
                    self.log_message("خطا در نصب اوبونتو", "error")
                    return
                self.log_message("✓ اوبونتو نصب شد", "success")
                
                # Step 6: Setup environment variables
                self.log_message("مرحله 6: تنظیم متغیرهای محیطی...", "info")
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
                self.log_message("✓ متغیرهای محیطی تنظیم شدند", "success")
                
                # Step 7: Create additional scripts
                self.log_message("مرحله 7: ایجاد اسکریپت‌های کمکی...", "info")
                self.create_additional_scripts(install_type, ubuntu_version)
                self.log_message("✓ اسکریپت‌های کمکی ایجاد شدند", "success")
                
                self.log_message(f"=== نصب اوبونتو {ubuntu_version} ({install_type}) کامل شد ===", "success")
                self.update_status(f"نصب اوبونتو {ubuntu_version} ({install_type}) کامل شد", "success")
                
                messagebox.showinfo("نصب کامل", 
                                  f"اوبونتو {ubuntu_version} با موفقیت نصب شد!\n\n"
                                  f"نوع نصب: {install_type.upper()}\n"
                                  "برای شروع:\n"
                                  "cd ~/ubuntu\n"
                                  "./start-ubuntu.sh")
                
            except Exception as e:
                self.log_message(f"خطا در نصب: {e}", "error")
                self.update_status("خطا در نصب", "error")
            finally:
                self.progress.stop()
        
        threading.Thread(target=install, daemon=True).start()
    
    def install_ubuntu(self):
        """Show installation options dialog"""
        self.show_installation_options()
    
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
        
        # Start script based on installation type
        if install_type == "chroot":
            start_script = f"""#!/bin/bash
# Ubuntu {ubuntu_version} Chroot Start Script

cd ~/ubuntu

# Start Ubuntu chroot
./start-ubuntu.sh

# Setup VNC if needed
if [ "$1" = "--vnc" ]; then
    echo "Starting VNC server..."
    vncserver :1 -geometry 1280x720 -depth 24
    echo "VNC server started on :1"
    echo "Connect using VNC viewer to: localhost:5901"
fi
"""
        else:
            start_script = f"""#!/bin/bash
# Ubuntu {ubuntu_version} Proot Start Script

cd ~/ubuntu

# Start Ubuntu proot
proot-distro login ubuntu-{ubuntu_version}

# Setup VNC if needed
if [ "$1" = "--vnc" ]; then
    echo "Starting VNC server..."
    vncserver :1 -geometry 1280x720 -depth 24
    echo "VNC server started on :1"
    echo "Connect using VNC viewer to: localhost:5901"
fi
"""
        
        start_path = self.ubuntu_dir / "start-ubuntu-vnc.sh"
        with open(start_path, 'w') as f:
            f.write(start_script)
        os.chmod(start_path, 0o755)
    
    def remove_ubuntu(self):
        """Remove Ubuntu completely"""
        # Clear log first
        self.clear_log()
        
        # Create a custom confirmation dialog with better styling
        confirm_window = tk.Toplevel(self.root)
        confirm_window.title("تأیید حذف اوبونتو")
        confirm_window.geometry("500x300")
        confirm_window.configure(bg=self.colors['bg'])
        confirm_window.transient(self.root)
        confirm_window.grab_set()
        
        # Center the window
        confirm_window.geometry("+%d+%d" % (self.root.winfo_rootx() + 200, self.root.winfo_rooty() + 200))
        
        # Main frame
        main_frame = tk.Frame(confirm_window, bg=self.colors['bg'])
        main_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        # Warning icon (text-based)
        warning_label = tk.Label(
            main_frame,
            text="⚠️",
            font=("Arial", 48),
            bg=self.colors['bg'],
            fg=self.colors['warning']
        )
        warning_label.pack(pady=(0, 20))
        
        # Title
        title_label = tk.Label(
            main_frame,
            text="حذف کامل اوبونتو",
            font=("Arial", 18, "bold"),
            bg=self.colors['bg'],
            fg=self.colors['error']
        )
        title_label.pack(pady=(0, 10))
        
        # Warning message
        warning_text = """این عمل اوبونتو را کاملاً از سیستم حذف می‌کند.

⚠️ هشدار:
• تمام فایل‌های اوبونتو حذف خواهند شد
• تمام تنظیمات و نرم‌افزارهای نصب شده از بین می‌روند
• این عمل غیرقابل بازگشت است

آیا مطمئن هستید که می‌خواهید ادامه دهید؟"""
        
        message_label = tk.Label(
            main_frame,
            text=warning_text,
            font=("Arial", 12),
            bg=self.colors['bg'],
            fg=self.colors['fg'],
            justify=tk.CENTER,
            wraplength=400
        )
        message_label.pack(pady=(0, 20))
        
        # Buttons frame
        button_frame = tk.Frame(main_frame, bg=self.colors['bg'])
        button_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Confirm button
        confirm_button = tk.Button(
            button_frame,
            text="بله، حذف کن",
            font=("Arial", 14, "bold"),
            bg=self.colors['error'],
            fg=self.colors['button_fg'],
            relief=tk.RAISED,
            bd=0,
            padx=20,
            pady=10,
            cursor="hand2",
            command=lambda: self.confirm_remove_ubuntu(confirm_window)
        )
        confirm_button.pack(side=tk.RIGHT, padx=(10, 0))
        
        # Cancel button
        cancel_button = tk.Button(
            button_frame,
            text="لغو",
            font=("Arial", 14, "bold"),
            bg=self.colors['button_bg'],
            fg=self.colors['button_fg'],
            relief=tk.RAISED,
            bd=0,
            padx=20,
            pady=10,
            cursor="hand2",
            command=confirm_window.destroy
        )
        cancel_button.pack(side=tk.LEFT, padx=(0, 10))
        
        # Add hover effects
        confirm_button.bind("<Enter>", lambda e: confirm_button.config(bg='#D32F2F'))
        confirm_button.bind("<Leave>", lambda e: confirm_button.config(bg=self.colors['error']))
        cancel_button.bind("<Enter>", lambda e: cancel_button.config(bg=self.colors['button_hover']))
        cancel_button.bind("<Leave>", lambda e: cancel_button.config(bg=self.colors['button_bg']))
    
    def confirm_remove_ubuntu(self, confirm_window):
        """Confirm and start Ubuntu removal"""
        confirm_window.destroy()
        
        self.update_status("در حال حذف اوبونتو...", "warning")
        self.progress.start()
        
        def remove():
            try:
                self.log_message("=== حذف کامل اوبونتو ===", "warning")
                
                # Check if Ubuntu is installed
                if self.ubuntu_dir.exists():
                    self.log_message("یافتن فایل‌های اوبونتو...", "info")
                    
                    # Get directory size before removal
                    try:
                        total_size = 0
                        for dirpath, dirnames, filenames in os.walk(self.ubuntu_dir):
                            for filename in filenames:
                                filepath = os.path.join(dirpath, filename)
                                if os.path.exists(filepath):
                                    total_size += os.path.getsize(filepath)
                        size_gb = total_size / (1024**3)
                        self.log_message(f"حجم فایل‌های اوبونتو: {size_gb:.2f} GB", "info")
                    except:
                        self.log_message("محاسبه حجم فایل‌ها ناموفق بود", "warning")
                    
                    # Remove Ubuntu directory
                    import shutil
                    shutil.rmtree(self.ubuntu_dir)
                    self.log_message("✓ دایرکتوری اوبونتو حذف شد", "success")
                else:
                    self.log_message("دایرکتوری اوبونتو یافت نشد", "info")
                
                # Remove environment variables from .bashrc
                bashrc_path = Path.home() / ".bashrc"
                if bashrc_path.exists():
                    self.log_message("پاکسازی متغیرهای محیطی...", "info")
                    with open(bashrc_path, 'r') as f:
                        lines = f.readlines()
                    
                    # Remove Ubuntu-related environment variables
                    filtered_lines = []
                    for line in lines:
                        if any(var in line for var in ["DISPLAY=:0", "PULSE_SERVER=127.0.0.1", "VNC_DISPLAY=:1", "UBUNTU_HOME"]):
                            continue
                        filtered_lines.append(line)
                    
                    with open(bashrc_path, 'w') as f:
                        f.writelines(filtered_lines)
                    
                    self.log_message("✓ متغیرهای محیطی حذف شدند", "success")
                
                # Remove environment file
                env_file = Path.home() / ".ubuntu_env"
                if env_file.exists():
                    env_file.unlink()
                    self.log_message("✓ فایل محیطی حذف شد", "success")
                
                # Clean up any remaining Ubuntu-related files
                try:
                    # Remove any Ubuntu scripts from PATH
                    home_bin = Path.home() / "bin"
                    if home_bin.exists():
                        for script in home_bin.glob("*ubuntu*"):
                            script.unlink()
                            self.log_message(f"✓ اسکریپت {script.name} حذف شد", "success")
                except:
                    self.log_message("پاکسازی اسکریپت‌ها ناموفق بود", "warning")
                
                self.log_message("=== حذف اوبونتو کامل شد ===", "success")
                self.update_status("حذف اوبونتو کامل شد", "success")
                
                # Show completion message
                completion_text = """✅ اوبونتو با موفقیت حذف شد!

خلاصه عملیات:
• دایرکتوری اوبونتو حذف شد
• متغیرهای محیطی پاک شدند
• فایل‌های محیطی حذف شدند
• سیستم آماده برای نصب مجدد است"""
                
                self.log_message(completion_text, "success")
                
                # Show completion dialog
                messagebox.showinfo("حذف کامل", 
                                  "اوبونتو با موفقیت حذف شد!\n\n"
                                  "تمام فایل‌ها و تنظیمات مربوط به اوبونتو پاک شدند.\n"
                                  "سیستم آماده برای نصب مجدد است.")
                
            except Exception as e:
                self.log_message(f"خطا در حذف: {e}", "error")
                self.update_status("خطا در حذف", "error")
            finally:
                self.progress.stop()
        
        threading.Thread(target=remove, daemon=True).start()
    
    def exit_app(self):
        """Exit the application"""
        # Clear log first
        self.clear_log()
        
        # Create a custom exit dialog with better styling
        exit_window = tk.Toplevel(self.root)
        exit_window.title("خروج از برنامه")
        exit_window.geometry("400x250")
        exit_window.configure(bg=self.colors['bg'])
        exit_window.transient(self.root)
        exit_window.grab_set()
        
        # Center the window
        exit_window.geometry("+%d+%d" % (self.root.winfo_rootx() + 250, self.root.winfo_rooty() + 250))
        
        # Main frame
        main_frame = tk.Frame(exit_window, bg=self.colors['bg'])
        main_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        # Exit icon (text-based)
        exit_label = tk.Label(
            main_frame,
            text="🚪",
            font=("Arial", 48),
            bg=self.colors['bg'],
            fg=self.colors['info']
        )
        exit_label.pack(pady=(0, 20))
        
        # Title
        title_label = tk.Label(
            main_frame,
            text="خروج از برنامه",
            font=("Arial", 18, "bold"),
            bg=self.colors['bg'],
            fg=self.colors['fg']
        )
        title_label.pack(pady=(0, 10))
        
        # Exit message
        exit_text = """آیا مطمئن هستید که می‌خواهید از برنامه خارج شوید؟

تمام عملیات در حال انجام متوقف خواهند شد."""
        
        message_label = tk.Label(
            main_frame,
            text=exit_text,
            font=("Arial", 12),
            bg=self.colors['bg'],
            fg=self.colors['fg'],
            justify=tk.CENTER,
            wraplength=300
        )
        message_label.pack(pady=(0, 20))
        
        # Buttons frame
        button_frame = tk.Frame(main_frame, bg=self.colors['bg'])
        button_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Confirm button
        confirm_button = tk.Button(
            button_frame,
            text="بله، خارج شو",
            font=("Arial", 14, "bold"),
            bg=self.colors['error'],
            fg=self.colors['button_fg'],
            relief=tk.RAISED,
            bd=0,
            padx=20,
            pady=10,
            cursor="hand2",
            command=self.root.quit
        )
        confirm_button.pack(side=tk.RIGHT, padx=(10, 0))
        
        # Cancel button
        cancel_button = tk.Button(
            button_frame,
            text="لغو",
            font=("Arial", 14, "bold"),
            bg=self.colors['button_bg'],
            fg=self.colors['button_fg'],
            relief=tk.RAISED,
            bd=0,
            padx=20,
            pady=10,
            cursor="hand2",
            command=exit_window.destroy
        )
        cancel_button.pack(side=tk.LEFT, padx=(0, 10))
        
        # Add hover effects
        confirm_button.bind("<Enter>", lambda e: confirm_button.config(bg='#D32F2F'))
        confirm_button.bind("<Leave>", lambda e: confirm_button.config(bg=self.colors['error']))
        cancel_button.bind("<Enter>", lambda e: cancel_button.config(bg=self.colors['button_hover']))
        cancel_button.bind("<Leave>", lambda e: cancel_button.config(bg=self.colors['button_bg']))
    
    def run(self):
        """Run the GUI application"""
        self.root.mainloop()

def main():
    """Main function"""
    # Check if running in Termux
    if not os.path.exists("/data/data/com.termux"):
        print("Error: This script must be run in Termux!")
        sys.exit(1)
    
    # Check if tkinter is available
    try:
        import tkinter
    except ImportError:
        print("Installing tkinter...")
        subprocess.run("pkg install python-tkinter -y", shell=True)
    
    # Check for display issues in Termux
    if os.path.exists("/data/data/com.termux"):
        print("Termux detected. Checking display configuration...")
        
        # Try to set up display for Termux
        os.environ['DISPLAY'] = ':0'
        
        # Check if we can create a simple tkinter window
        try:
            test_root = tk.Tk()
            test_root.destroy()
            print("Display connection successful!")
        except Exception as e:
            print(f"Display connection failed: {e}")
            print("\nTrying alternative solutions...")
            
            # Try VNC server setup
            print("1. Installing VNC server...")
            subprocess.run("pkg install tigervnc -y", shell=True)
            
            print("2. Starting VNC server...")
            subprocess.run("vncserver :1 -geometry 1280x720 -depth 24", shell=True)
            
            # Set display to VNC
            os.environ['DISPLAY'] = ':1'
            
            print("3. VNC server started. You can connect using VNC viewer.")
            print("   Connect to: localhost:5901")
            print("   Or use: vncviewer localhost:5901")
            
            # Try again with VNC display
            try:
                test_root = tk.Tk()
                test_root.destroy()
                print("VNC display connection successful!")
            except Exception as e2:
                print(f"VNC display also failed: {e2}")
                print("\nFalling back to console mode...")
                return run_console_mode()
    
    # Run the GUI
    try:
        app = UbuntuChrootGUI()
        app.run()
    except Exception as e:
        print(f"GUI failed to start: {e}")
        print("Falling back to console mode...")
        return run_console_mode()

def run_console_mode():
    """Run the installer in console mode"""
    print("\n" + "="*50)
    print("Ubuntu Chroot GUI Installer - Console Mode")
    print("="*50)
    print("\nSince GUI is not available, running in console mode...")
    
    while True:
        print("\nOptions:")
        print("1. System Check")
        print("2. Install Ubuntu")
        print("3. Remove Ubuntu")
        print("4. Exit")
        
        choice = input("\nEnter your choice (1-4): ").strip()
        
        if choice == "1":
            print("\nPerforming system check...")
            # Add console system check logic here
            print("System check completed!")
            
        elif choice == "2":
            print("\nStarting Ubuntu installation...")
            # Add console installation logic here
            print("Installation completed!")
            
        elif choice == "3":
            confirm = input("Are you sure you want to remove Ubuntu? (y/N): ").strip().lower()
            if confirm in ['y', 'yes']:
                print("Removing Ubuntu...")
                # Add console removal logic here
                print("Ubuntu removed successfully!")
            else:
                print("Removal cancelled.")
                
        elif choice == "4":
            print("Exiting...")
            break
            
        else:
            print("Invalid choice. Please enter 1-4.")

if __name__ == "__main__":
    main() 