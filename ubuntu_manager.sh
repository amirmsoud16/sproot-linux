#!/bin/bash

# Ubuntu Android Manager - Simple Menu
# مدیریت Ubuntu روی اندروید - منوی ساده

CHROOT_DIR="/data/local/ubuntu"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}    Ubuntu Android Manager${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_menu() {
    echo ""
    echo -e "${GREEN}📋 منوی اصلی:${NC}"
    echo "1. ورود به Ubuntu"
    echo "2. نصب پکیج"
    echo "3. به‌روزرسانی سیستم"
    echo "4. نمایش وضعیت"
    echo "5. پاکسازی"
    echo "6. حذف کامل"
    echo "7. راهنما"
    echo "0. خروج"
    echo ""
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}❌ این اسکریپت باید با دسترسی root اجرا شود${NC}"
        echo "💡 دستور: su && ./ubuntu_manager.sh"
        exit 1
    fi
}

check_ubuntu() {
    if [ ! -d "$CHROOT_DIR" ]; then
        echo -e "${RED}❌ Ubuntu نصب نشده است${NC}"
        echo "💡 ابتدا setup_ubuntu_android.sh را اجرا کنید"
        exit 1
    fi
}

enter_ubuntu() {
    echo -e "${GREEN}🐧 ورود به Ubuntu...${NC}"
    "$CHROOT_DIR/enter.sh"
}

install_package() {
    echo -e "${GREEN}📦 نصب پکیج${NC}"
    echo "نام پکیج را وارد کنید:"
    read package_name
    
    if [ -z "$package_name" ]; then
        echo -e "${RED}❌ نام پکیج وارد نشده${NC}"
        return
    fi
    
    echo -e "${YELLOW}🔄 نصب $package_name...${NC}"
    chroot "$CHROOT_DIR" apt-get update
    chroot "$CHROOT_DIR" apt-get install -y "$package_name"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $package_name با موفقیت نصب شد${NC}"
    else
        echo -e "${RED}❌ خطا در نصب $package_name${NC}"
    fi
}

update_system() {
    echo -e "${YELLOW}🔄 به‌روزرسانی سیستم Ubuntu...${NC}"
    chroot "$CHROOT_DIR" apt-get update
    chroot "$CHROOT_DIR" apt-get upgrade -y
    chroot "$CHROOT_DIR" apt-get autoremove -y
    echo -e "${GREEN}✅ سیستم به‌روزرسانی شد${NC}"
}

show_status() {
    echo -e "${BLUE}📊 وضعیت Ubuntu:${NC}"
    echo "مسیر: $CHROOT_DIR"
    
    if [ -d "$CHROOT_DIR" ]; then
        echo -e "${GREEN}✅ Ubuntu نصب شده${NC}"
        
        # Check if mounted
        if mountpoint -q "$CHROOT_DIR/proc" 2>/dev/null; then
            echo -e "${GREEN}✅ Mount شده${NC}"
        else
            echo -e "${YELLOW}❌ Mount نشده${NC}"
        fi
        
        # Show disk usage
        echo "📊 استفاده دیسک:"
        du -sh "$CHROOT_DIR"
        
    else
        echo -e "${RED}❌ Ubuntu نصب نشده${NC}"
    fi
}

clean_system() {
    echo -e "${YELLOW}🧹 پاکسازی سیستم...${NC}"
    chroot "$CHROOT_DIR" apt-get clean
    chroot "$CHROOT_DIR" apt-get autoremove -y
    echo -e "${GREEN}✅ سیستم پاکسازی شد${NC}"
}

remove_ubuntu() {
    echo -e "${RED}⚠️  این کار Ubuntu را کاملاً حذف می‌کند${NC}"
    echo "آیا مطمئن هستید؟ (y/N):"
    read confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🗑️  حذف Ubuntu...${NC}"
        rm -rf "$CHROOT_DIR"
        echo -e "${GREEN}✅ Ubuntu حذف شد${NC}"
    else
        echo -e "${GREEN}✅ عملیات لغو شد${NC}"
    fi
}

show_help() {
    echo -e "${BLUE}📖 راهنما:${NC}"
    echo ""
    echo "🐧 ورود به Ubuntu:"
    echo "   گزینه 1 را انتخاب کنید"
    echo ""
    echo "📦 نصب پکیج:"
    echo "   گزینه 2 را انتخاب کنید و نام پکیج را وارد کنید"
    echo "   مثال: nginx, apache2, python3"
    echo ""
    echo "🔄 به‌روزرسانی:"
    echo "   گزینه 3 را انتخاب کنید"
    echo ""
    echo "📊 وضعیت:"
    echo "   گزینه 4 را انتخاب کنید"
    echo ""
    echo "🧹 پاکسازی:"
    echo "   گزینه 5 را انتخاب کنید"
    echo ""
    echo "🗑️  حذف کامل:"
    echo "   گزینه 6 را انتخاب کنید"
    echo ""
    echo "💡 دستورات مفید داخل Ubuntu:"
    echo "   sudo apt-get install <نام>  # نصب پکیج"
    echo "   sudo apt-get update          # به‌روزرسانی لیست"
    echo "   sudo apt-get upgrade         # به‌روزرسانی سیستم"
    echo "   exit                         # خروج"
}

main_menu() {
    while true; do
        print_header
        print_menu
        
        echo -n "انتخاب کنید (0-7): "
        read choice
        
        case $choice in
            1)
                enter_ubuntu
                ;;
            2)
                install_package
                ;;
            3)
                update_system
                ;;
            4)
                show_status
                ;;
            5)
                clean_system
                ;;
            6)
                remove_ubuntu
                ;;
            7)
                show_help
                ;;
            0)
                echo -e "${GREEN}👋 خروج از برنامه${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ انتخاب نامعتبر${NC}"
                ;;
        esac
        
        echo ""
        echo -n "برای ادامه Enter را فشار دهید..."
        read
        clear
    done
}

# Main execution
check_root
check_ubuntu
main_menu 