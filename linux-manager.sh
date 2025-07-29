#!/bin/bash

# =============================================================================
# Linux Manager - Multi-Distribution Manager with SPROOT COMPLETE
# =============================================================================
# Description: Install and manage multiple Linux distributions using SPROOT
# Author: Custom Ubuntu Setup
# Version: 1.0
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPROOT_SCRIPT="$SCRIPT_DIR/sproot-complete.sh"
MANAGER_VERSION="1.0"
DISTROS_DIR="$HOME/linux-distros"

# Print functions
print_header() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    LINUX MANAGER                              ║${NC}"
    echo -e "${CYAN}║              Multi-Distribution Manager                       ║${NC}"
    echo -e "${CYAN}║                    Version $MANAGER_VERSION                          ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_menu_option() {
    echo -e "${WHITE}$1${NC} $2"
}

print_separator() {
    echo -e "${CYAN}──────────────────────────────────────────────────────────────────${NC}"
}

# Linux distributions configuration
declare -A DISTROS=(
    # Ubuntu Family
    ["ubuntu18"]="Ubuntu 18.04 LTS|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu/ubuntu-18.04-rootfs.tar.xz|ubuntu18-rootfs"
    ["ubuntu20"]="Ubuntu 20.04 LTS|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu/ubuntu-20.04-rootfs.tar.xz|ubuntu20-rootfs"
    ["ubuntu22"]="Ubuntu 22.04 LTS|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu/ubuntu-22.04-rootfs.tar.xz|ubuntu22-rootfs"
    ["ubuntu23"]="Ubuntu 23.04|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu/ubuntu-23.04-rootfs.tar.xz|ubuntu23-rootfs"
    ["ubuntu24"]="Ubuntu 24.04 LTS|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Ubuntu/ubuntu-24.04-rootfs.tar.xz|ubuntu24-rootfs"
    
    # Debian Family
    ["debian10"]="Debian 10 (Buster)|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Debian/debian-10-rootfs.tar.xz|debian10-rootfs"
    ["debian11"]="Debian 11 (Bullseye)|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Debian/debian-11-rootfs.tar.xz|debian11-rootfs"
    ["debian12"]="Debian 12 (Bookworm)|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Debian/debian-12-rootfs.tar.xz|debian12-rootfs"
    
    # Security & Penetration Testing
    ["kali"]="Kali Linux 2023|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Kali/kali-2023-rootfs.tar.xz|kali-rootfs"
    ["kali2024"]="Kali Linux 2024|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Kali/kali-2024-rootfs.tar.xz|kali2024-rootfs"
    ["parrot"]="Parrot OS|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Parrot/parrot-rootfs.tar.xz|parrot-rootfs"
    ["blackarch"]="BlackArch Linux|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/BlackArch/blackarch-rootfs.tar.xz|blackarch-rootfs"
    
    # Rolling Release
    ["arch"]="Arch Linux|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Arch/arch-rootfs.tar.xz|arch-rootfs"
    ["manjaro"]="Manjaro Linux|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Manjaro/manjaro-rootfs.tar.xz|manjaro-rootfs"
    ["endeavouros"]="EndeavourOS|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/EndeavourOS/endeavouros-rootfs.tar.xz|endeavouros-rootfs"
    
    # Enterprise & Server
    ["centos7"]="CentOS 7|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/CentOS/centos-7-rootfs.tar.xz|centos7-rootfs"
    ["centos8"]="CentOS 8|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/CentOS/centos-8-rootfs.tar.xz|centos8-rootfs"
    ["rocky8"]="Rocky Linux 8|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Rocky/rocky-8-rootfs.tar.xz|rocky8-rootfs"
    ["rocky9"]="Rocky Linux 9|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Rocky/rocky-9-rootfs.tar.xz|rocky9-rootfs"
    ["alma8"]="AlmaLinux 8|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Alma/alma-8-rootfs.tar.xz|alma8-rootfs"
    ["alma9"]="AlmaLinux 9|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Alma/alma-9-rootfs.tar.xz|alma9-rootfs"
    
    # Fedora Family
    ["fedora35"]="Fedora 35|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Fedora/fedora-35-rootfs.tar.xz|fedora35-rootfs"
    ["fedora36"]="Fedora 36|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Fedora/fedora-36-rootfs.tar.xz|fedora36-rootfs"
    ["fedora37"]="Fedora 37|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Fedora/fedora-37-rootfs.tar.xz|fedora37-rootfs"
    ["fedora38"]="Fedora 38|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Fedora/fedora-38-rootfs.tar.xz|fedora38-rootfs"
    ["fedora39"]="Fedora 39|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Fedora/fedora-39-rootfs.tar.xz|fedora39-rootfs"
    ["fedora40"]="Fedora 40|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Fedora/fedora-40-rootfs.tar.xz|fedora40-rootfs"
    
    # Lightweight & Minimal
    ["alpine"]="Alpine Linux|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Alpine/alpine-rootfs.tar.xz|alpine-rootfs"
    ["void"]="Void Linux|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Void/void-rootfs.tar.xz|void-rootfs"
    ["slackware"]="Slackware Linux|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Slackware/slackware-rootfs.tar.xz|slackware-rootfs"
    
    # Development & Programming
    ["opensuse"]="openSUSE Leap|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/openSUSE/opensuse-leap-rootfs.tar.xz|opensuse-rootfs"
    ["tumbleweed"]="openSUSE Tumbleweed|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/openSUSE/opensuse-tumbleweed-rootfs.tar.xz|tumbleweed-rootfs"
    ["gentoo"]="Gentoo Linux|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Gentoo/gentoo-rootfs.tar.xz|gentoo-rootfs"
    
    # Specialized
    ["nixos"]="NixOS|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/NixOS/nixos-rootfs.tar.xz|nixos-rootfs"
    ["guix"]="GNU Guix|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Guix/guix-rootfs.tar.xz|guix-rootfs"
    ["clear"]="Clear Linux|https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Rootfs/Clear/clear-rootfs.tar.xz|clear-rootfs"
)

# Function to check SPROOT script
check_sproot_script() {
    if [[ ! -f "$SPROOT_SCRIPT" ]]; then
        print_error "SPROOT Complete script not found: $SPROOT_SCRIPT"
        print_info "Please make sure sproot-complete.sh is in the same directory"
        return 1
    fi
    
    if [[ ! -x "$SPROOT_SCRIPT" ]]; then
        print_warning "Making SPROOT script executable..."
        chmod +x "$SPROOT_SCRIPT"
    fi
    
    return 0
}

# Function to show main menu
show_main_menu() {
    clear
    print_header
    
    echo -e "${WHITE}Main Menu:${NC}"
    echo ""
    print_menu_option "1." "Install Linux Distribution"
    print_menu_option "2." "Manage Installed Distributions"
    print_menu_option "3." "Start Linux Environment"
    print_menu_option "4." "System Status & Information"
    print_menu_option "5." "Help & Documentation"
    print_menu_option "6." "Exit"
    echo ""
    print_separator
    echo -e "${YELLOW}Select an option (1-6):${NC} "
}

# Function to show distribution selection menu
show_distro_menu() {
    clear
    print_header
    
    echo -e "${WHITE}Available Linux Distributions:${NC}"
    echo ""
    
    local counter=1
    for distro in "${!DISTROS[@]}"; do
        local info="${DISTROS[$distro]}"
        local name=$(echo "$info" | cut -d'|' -f1)
        print_menu_option "$counter." "$name"
        ((counter++))
    done
    
    print_menu_option "$counter." "Back to Main Menu"
    echo ""
    print_separator
    echo -e "${YELLOW}Select a distribution (1-$counter):${NC} "
}

# Function to get distribution info
get_distro_info() {
    local index="$1"
    local counter=1
    
    for distro in "${!DISTROS[@]}"; do
        if [[ $counter -eq $index ]]; then
            echo "$distro"
            return 0
        fi
        ((counter++))
    done
    
    return 1
}

# Function to install distribution
install_distribution() {
    local distro="$1"
    local info="${DISTROS[$distro]}"
    local name=$(echo "$info" | cut -d'|' -f1)
    local url=$(echo "$info" | cut -d'|' -f2)
    local rootfs_name=$(echo "$info" | cut -d'|' -f3)
    local rootfs_path="$DISTROS_DIR/$distro/$rootfs_name"
    
    clear
    print_header
    echo -e "${WHITE}Installing $name...${NC}"
    echo ""
    
    # Create distribution directory
    mkdir -p "$DISTROS_DIR/$distro"
    cd "$DISTROS_DIR/$distro"
    
    # Download rootfs
    print_info "Downloading $name rootfs..."
    if wget -O "${distro}-rootfs.tar.xz" "$url"; then
        print_success "$name rootfs downloaded successfully"
    else
        print_error "Failed to download $name rootfs"
        return 1
    fi
    
    # Extract rootfs
    print_info "Extracting $name rootfs..."
    if tar -xf "${distro}-rootfs.tar.xz"; then
        print_success "$name rootfs extracted successfully"
    else
        print_error "Failed to extract $name rootfs"
        return 1
    fi
    
    # Create essential directories
    mkdir -p "$rootfs_path/proc"
    mkdir -p "$rootfs_path/sys"
    mkdir -p "$rootfs_path/dev"
    mkdir -p "$rootfs_path/dev/pts"
    
    # Create startup script
    cat > "$DISTROS_DIR/start-$distro.sh" << EOF
#!/bin/bash

# $name Startup Script
ROOTFS="$rootfs_path"

# Check if rootfs exists
if [[ ! -d "\$ROOTFS" ]]; then
    echo "$name not installed. Please install it first."
    exit 1
fi

# Start with SPROOT Complete
"$SPROOT_SCRIPT" -r "\$ROOTFS" start
EOF
    
    chmod +x "$DISTROS_DIR/start-$distro.sh"
    print_success "$name startup script created: $DISTROS_DIR/start-$distro.sh"
    
    # Clean up
    rm -f "${distro}-rootfs.tar.xz"
    
    print_success "$name installed successfully!"
    echo ""
    echo -e "${YELLOW}To start $name:${NC}"
    echo "  ./start-$distro.sh"
    echo ""
}

# Function to show installed distributions
show_installed_distros() {
    clear
    print_header
    
    echo -e "${WHITE}Installed Linux Distributions:${NC}"
    echo ""
    
    if [[ ! -d "$DISTROS_DIR" ]]; then
        print_warning "No distributions installed"
        echo "Install a distribution first"
        return
    fi
    
    local counter=1
    local found=false
    
    for distro in "${!DISTROS[@]}"; do
        local info="${DISTROS[$distro]}"
        local name=$(echo "$info" | cut -d'|' -f1)
        local rootfs_name=$(echo "$info" | cut -d'|' -f3)
        local rootfs_path="$DISTROS_DIR/$distro/$rootfs_name"
        
        if [[ -d "$rootfs_path" ]]; then
            found=true
            local size=$(du -sh "$rootfs_path" 2>/dev/null | cut -f1)
            print_menu_option "$counter." "$name (Size: $size)"
            ((counter++))
        fi
    done
    
    if [[ "$found" == false ]]; then
        print_warning "No distributions installed"
        echo "Install a distribution first"
    else
        print_menu_option "$counter." "Back to Main Menu"
    fi
    
    echo ""
    print_separator
    echo -e "${YELLOW}Select an option (1-$counter):${NC} "
}

# Function to manage distributions
manage_distributions() {
    clear
    print_header
    
    echo -e "${WHITE}Distribution Management:${NC}"
    echo ""
    print_menu_option "1." "List Installed Distributions"
    print_menu_option "2." "Remove Distribution"
    print_menu_option "3." "Backup Distribution"
    print_menu_option "4." "Restore Distribution"
    print_menu_option "5." "Back to Main Menu"
    echo ""
    print_separator
    echo -e "${YELLOW}Select an option (1-5):${NC} "
}

# Function to remove distribution
remove_distribution() {
    clear
    print_header
    
    echo -e "${WHITE}Remove Distribution:${NC}"
    echo ""
    
    local counter=1
    local distros_list=()
    
    for distro in "${!DISTROS[@]}"; do
        local info="${DISTROS[$distro]}"
        local name=$(echo "$info" | cut -d'|' -f1)
        local rootfs_name=$(echo "$info" | cut -d'|' -f3)
        local rootfs_path="$DISTROS_DIR/$distro/$rootfs_name"
        
        if [[ -d "$rootfs_path" ]]; then
            distros_list+=("$distro")
            print_menu_option "$counter." "$name"
            ((counter++))
        fi
    done
    
    if [[ ${#distros_list[@]} -eq 0 ]]; then
        print_warning "No distributions installed"
        return
    fi
    
    print_menu_option "$counter." "Back to Main Menu"
    echo ""
    print_separator
    echo -e "${YELLOW}Select distribution to remove (1-$counter):${NC} "
    
    read -r choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#distros_list[@]} ]]; then
        local selected_distro="${distros_list[$((choice-1))]}"
        local info="${DISTROS[$selected_distro]}"
        local name=$(echo "$info" | cut -d'|' -f1)
        
        print_warning "This will remove $name completely!"
        echo -e "${YELLOW}Are you sure? (y/n):${NC} "
        read -r confirm
        
        if [[ "$confirm" == "y" ]]; then
            print_info "Removing $name..."
            rm -rf "$DISTROS_DIR/$selected_distro"
            rm -f "$DISTROS_DIR/start-$selected_distro.sh"
            print_success "$name removed successfully"
        else
            print_info "Removal cancelled"
        fi
    fi
}

# Function to start Linux environment
start_linux_environment() {
    clear
    print_header
    
    echo -e "${WHITE}Start Linux Environment:${NC}"
    echo ""
    
    local counter=1
    local distros_list=()
    
    for distro in "${!DISTROS[@]}"; do
        local info="${DISTROS[$distro]}"
        local name=$(echo "$info" | cut -d'|' -f1)
        local rootfs_name=$(echo "$info" | cut -d'|' -f3)
        local rootfs_path="$DISTROS_DIR/$distro/$rootfs_name"
        
        if [[ -d "$rootfs_path" ]]; then
            distros_list+=("$distro")
            print_menu_option "$counter." "$name"
            ((counter++))
        fi
    done
    
    if [[ ${#distros_list[@]} -eq 0 ]]; then
        print_warning "No distributions installed"
        echo "Install a distribution first"
        return
    fi
    
    print_menu_option "$counter." "Back to Main Menu"
    echo ""
    print_separator
    echo -e "${YELLOW}Select distribution to start (1-$counter):${NC} "
    
    read -r choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#distros_list[@]} ]]; then
        local selected_distro="${distros_list[$((choice-1))]}"
        local info="${DISTROS[$selected_distro]}"
        local name=$(echo "$info" | cut -d'|' -f1)
        
        print_info "Starting $name..."
        "$DISTROS_DIR/start-$selected_distro.sh"
    fi
}

# Function to show system status
show_system_status() {
    clear
    print_header
    
    echo -e "${WHITE}System Status & Information:${NC}"
    echo ""
    
    # Check SPROOT script
    if [[ -f "$SPROOT_SCRIPT" ]]; then
        print_success "SPROOT Complete script found"
    else
        print_error "SPROOT Complete script not found"
    fi
    
    # Check distributions directory
    if [[ -d "$DISTROS_DIR" ]]; then
        print_success "Distributions directory exists: $DISTROS_DIR"
    else
        print_warning "Distributions directory not found: $DISTROS_DIR"
    fi
    
    # List installed distributions
    echo ""
    echo -e "${YELLOW}Installed Distributions:${NC}"
    local installed_count=0
    
    for distro in "${!DISTROS[@]}"; do
        local info="${DISTROS[$distro]}"
        local name=$(echo "$info" | cut -d'|' -f1)
        local rootfs_name=$(echo "$info" | cut -d'|' -f3)
        local rootfs_path="$DISTROS_DIR/$distro/$rootfs_name"
        
        if [[ -d "$rootfs_path" ]]; then
            local size=$(du -sh "$rootfs_path" 2>/dev/null | cut -f1)
            print_success "✓ $name (Size: $size)"
            ((installed_count++))
        fi
    done
    
    if [[ $installed_count -eq 0 ]]; then
        print_warning "No distributions installed"
    fi
    
    # System information
    echo ""
    echo -e "${YELLOW}System Information:${NC}"
    echo "OS: $(uname -s)"
    echo "Architecture: $(uname -m)"
    echo "Kernel: $(uname -r)"
    echo "Available Space: $(df -h . | tail -1 | awk '{print $4}')"
    echo "Proot Available: $(command -v proot &>/dev/null && echo "Yes" || echo "No")"
}

# Function to show help
show_help() {
    clear
    print_header
    
    echo -e "${WHITE}Help & Documentation:${NC}"
    echo ""
    print_menu_option "1." "Linux Manager Usage"
    print_menu_option "2." "Available Distributions"
    print_menu_option "3." "SPROOT Complete Information"
    print_menu_option "4." "Troubleshooting"
    print_menu_option "5." "About Linux Manager"
    print_menu_option "6." "Back to Main Menu"
    echo ""
    print_separator
    echo -e "${YELLOW}Select an option (1-6):${NC} "
}

# Function to handle help options
handle_help_options() {
    local option="$1"
    
    case "$option" in
        1)
            print_info "Linux Manager Usage:"
            echo ""
            echo "Linux Manager allows you to install and manage multiple"
            echo "Linux distributions using SPROOT Complete technology."
            echo ""
            echo "Features:"
            echo "• Install multiple Linux distributions"
            echo "• Manage installed distributions"
            echo "• Start any distribution easily"
            echo "• Backup and restore distributions"
            echo "• No root access required"
            ;;
        2)
            print_info "Available Distributions:"
            echo ""
            for distro in "${!DISTROS[@]}"; do
                local info="${DISTROS[$distro]}"
                local name=$(echo "$info" | cut -d'|' -f1)
                echo "• $name"
            done
            ;;
        3)
            print_info "SPROOT Complete Information:"
            echo ""
            echo "SPROOT Complete is the core engine that provides:"
            echo "• Full Ubuntu simulation without root"
            echo "• Systemd, Snap, Services support"
            echo "• Enhanced security and isolation"
            echo "• Complete system access simulation"
            ;;
        4)
            print_info "Troubleshooting:"
            echo ""
            echo "Common Issues:"
            echo ""
            echo "1. Download failed:"
            echo "   Check internet connection"
            echo ""
            echo "2. Extraction failed:"
            echo "   Ensure enough disk space"
            echo ""
            echo "3. SPROOT script not found:"
            echo "   Make sure sproot-complete.sh is in the same directory"
            echo ""
            echo "4. Permission denied:"
            echo "   chmod +x sproot-complete.sh"
            ;;
        5)
            print_info "About Linux Manager:"
            echo ""
            echo "Linux Manager v$MANAGER_VERSION"
            echo "Multi-Distribution Manager"
            echo ""
            echo "Features:"
            echo "• Multiple Linux distributions"
            echo "• Easy installation and management"
            echo "• SPROOT Complete integration"
            echo "• User-friendly interface"
            echo ""
            echo "Author: Custom Ubuntu Setup"
            ;;
        *)
            print_error "Invalid option"
            ;;
    esac
}

# Function to handle main menu
handle_main_menu() {
    local choice="$1"
    
    case "$choice" in
        1)
            show_distro_menu
            read -r distro_choice
            
            local distro_count=${#DISTROS[@]}
            if [[ "$distro_choice" =~ ^[0-9]+$ ]] && [[ $distro_choice -ge 1 ]] && [[ $distro_choice -le $distro_count ]]; then
                local selected_distro=$(get_distro_info "$distro_choice")
                if [[ -n "$selected_distro" ]]; then
                    install_distribution "$selected_distro"
                fi
            elif [[ "$distro_choice" == $((distro_count + 1)) ]]; then
                return
            else
                print_error "Invalid option"
            fi
            ;;
        2)
            manage_distributions
            read -r manage_choice
            
            case "$manage_choice" in
                1)
                    show_installed_distros
                    read -r
                    ;;
                2)
                    remove_distribution
                    ;;
                3|4)
                    print_info "Backup/Restore feature coming soon..."
                    ;;
                5)
                    return
                    ;;
                *)
                    print_error "Invalid option"
                    ;;
            esac
            ;;
        3)
            start_linux_environment
            ;;
        4)
            show_system_status
            echo ""
            echo -e "${GREEN}Press Enter to continue...${NC}"
            read -r
            ;;
        5)
            show_help
            read -r help_choice
            handle_help_options "$help_choice"
            ;;
        6)
            print_success "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid option. Please select 1-6."
            ;;
    esac
}

# Function to show welcome screen
show_welcome() {
    clear
    print_header
    
    echo -e "${WHITE}Welcome to Linux Manager!${NC}"
    echo ""
    echo -e "${CYAN}This tool allows you to install and manage multiple${NC}"
    echo -e "${CYAN}Linux distributions using SPROOT Complete technology.${NC}"
    echo ""
    echo -e "${YELLOW}Features:${NC}"
    echo "• Install multiple Linux distributions"
    echo "• Manage installed distributions"
    echo "• Start any distribution easily"
    echo "• No root access required"
    echo "• Enhanced security with SPROOT"
    echo ""
    echo -e "${GREEN}Press Enter to continue...${NC}"
    read -r
}

# Main function
main() {
    # Check if SPROOT script exists
    if ! check_sproot_script; then
        exit 1
    fi
    
    # Show welcome screen
    show_welcome
    
    # Main menu loop
    while true; do
        show_main_menu
        read -r choice
        
        if [[ "$choice" =~ ^[1-6]$ ]]; then
            handle_main_menu "$choice"
        else
            print_error "Invalid option. Please select 1-6."
        fi
        
        echo ""
        echo -e "${GREEN}Press Enter to continue...${NC}"
        read -r
    done
}

# Run main function
main "$@" 