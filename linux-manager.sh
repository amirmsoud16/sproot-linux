#!/bin/bash

# =============================================================================
# Ubuntu Manager - Ubuntu Distribution Manager with SPROOT COMPLETE
# =============================================================================
# Description: Install and manage Ubuntu distributions using SPROOT
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
DISTROS_DIR="$HOME/ubuntu-distros"

# Print functions
print_header() {
    clear
    echo -e "${CYAN}UBUNTU MANAGER${NC}"
    echo -e "${CYAN}Ubuntu Distribution Manager${NC}"
    echo -e "${CYAN}Version $MANAGER_VERSION${NC}"
    echo -e "${CYAN}----------------------------------------${NC}"
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

# Ubuntu distributions configuration
# ترتیب کلیدها را به صورت لیست مشخص می‌کنم تا ترتیب نمایش ثابت باشد
UBUNTU_KEYS=("ubuntu18" "ubuntu20" "ubuntu22" "ubuntu23" "ubuntu24")
declare -A DISTROS=(
    ["ubuntu18"]="Ubuntu 18.04 LTS|https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-arm64-root.tar.xz|ubuntu18-rootfs"
    ["ubuntu20"]="Ubuntu 20.04 LTS|https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-arm64-root.tar.xz|ubuntu20-rootfs"
    ["ubuntu22"]="Ubuntu 22.04 LTS|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-arm64-root.tar.xz|ubuntu22-rootfs"
    ["ubuntu23"]="Ubuntu 23.04|https://cloud-images.ubuntu.com/lunar/current/lunar-server-cloudimg-arm64-root.tar.xz|ubuntu23-rootfs"
    ["ubuntu24"]="Ubuntu 24.04 LTS|https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64-root.tar.xz|ubuntu24-rootfs"
)

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if required commands exist
    local required_commands=("wget" "tar" "proot")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            print_error "$cmd is not installed. Please install it first."
            print_info "Run: pkg install $cmd"
            return 1
        fi
    done
    
    # Check if SPROOT script exists
    if [[ ! -f "$SPROOT_SCRIPT" ]]; then
        print_error "SPROOT Complete script not found: $SPROOT_SCRIPT"
        return 1
    fi
    
    print_success "All prerequisites are satisfied"
    return 0
}

# Function to show main menu
show_main_menu() {
    clear
    print_header
    
    echo -e "${WHITE}Main Menu:${NC}"
    echo ""
    print_menu_option "1." "Install Ubuntu + SPROOT"
    print_menu_option "2." "Remove Ubuntu"
    print_menu_option "3." "Exit"
    echo ""
    print_separator
    echo -e "${YELLOW}Select an option (1-3):${NC} "
}

# Function to show Ubuntu selection menu
show_ubuntu_menu() {
    clear
    print_header
    echo -e "${WHITE}Available Ubuntu Versions:${NC}"
    echo ""
    local counter=1
    for key in "${UBUNTU_KEYS[@]}"; do
        local info="${DISTROS[$key]}"
        local name=$(echo "$info" | cut -d'|' -f1)
        print_menu_option "$counter." "$name"
        ((counter++))
    done
    print_menu_option "$counter." "Back to Main Menu"
    echo ""
    print_separator
    echo -e "${YELLOW}Select Ubuntu version (1-$counter):${NC} "
}

# Function to get Ubuntu info
get_ubuntu_info() {
    local index="$1"
    local counter=1
    for key in "${UBUNTU_KEYS[@]}"; do
        if [[ $counter -eq $index ]]; then
            echo "$key"
            return 0
        fi
        ((counter++))
    done
    return 1
}

# Function to install Ubuntu
install_ubuntu() {
    local distro="$1"
    local info="${DISTROS[$distro]}"
    local name=$(echo "$info" | cut -d'|' -f1)
    local url=$(echo "$info" | cut -d'|' -f2)
    local rootfs_name=$(echo "$info" | cut -d'|' -f3)
    local rootfs_path="$DISTROS_DIR/$distro/$rootfs_name"
    
    clear
    print_header
    echo -e "${WHITE}Installing $name with SPROOT...${NC}"
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

# $name Startup Script with SPROOT
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
    
    # Clean up downloaded file
    rm -f "${distro}-rootfs.tar.xz"
    
    print_success "$name installed successfully with SPROOT!"
    print_info "You can start it using: ./start-$distro.sh"
    
    echo ""
    print_separator
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
}

# Function to remove Ubuntu
remove_ubuntu() {
    clear
    print_header
    
    echo -e "${WHITE}Remove Ubuntu Installation${NC}"
    echo ""
    
    if [[ ! -d "$DISTROS_DIR" ]]; then
        print_warning "No Ubuntu installations found."
        echo ""
        print_separator
        echo -e "${YELLOW}Press Enter to continue...${NC}"
        read -r
        return
    fi
    
    # List installed Ubuntu versions
    local installed=()
    for distro in "${!DISTROS[@]}"; do
        if [[ -d "$DISTROS_DIR/$distro" ]]; then
            local info="${DISTROS[$distro]}"
            local name=$(echo "$info" | cut -d'|' -f1)
            installed+=("$distro|$name")
        fi
    done
    
    if [[ ${#installed[@]} -eq 0 ]]; then
        print_warning "No Ubuntu installations found."
        echo ""
        print_separator
        echo -e "${YELLOW}Press Enter to continue...${NC}"
        read -r
        return
    fi
    
    echo "Installed Ubuntu versions:"
    echo ""
    local counter=1
    for item in "${installed[@]}"; do
        local distro=$(echo "$item" | cut -d'|' -f1)
        local name=$(echo "$item" | cut -d'|' -f2)
        print_menu_option "$counter." "$name"
        ((counter++))
    done
    
    print_menu_option "$counter." "Remove All Ubuntu Installations"
    print_menu_option "$((counter+1))." "Back to Main Menu"
    echo ""
    print_separator
    echo -e "${YELLOW}Select option (1-$((counter+1))):${NC} "
    
    read -r choice
    
    if [[ $choice -eq $counter ]]; then
        # Remove all
        print_warning "Removing all Ubuntu installations..."
        rm -rf "$DISTROS_DIR"
        print_success "All Ubuntu installations removed successfully!"
    elif [[ $choice -eq $((counter+1)) ]]; then
        return
    elif [[ $choice -ge 1 && $choice -le ${#installed[@]} ]]; then
        # Remove specific version
        local selected_item="${installed[$((choice-1))]}"
        local distro=$(echo "$selected_item" | cut -d'|' -f1)
        local name=$(echo "$selected_item" | cut -d'|' -f2)
        
        print_warning "Removing $name..."
        rm -rf "$DISTROS_DIR/$distro"
        rm -f "$DISTROS_DIR/start-$distro.sh"
        print_success "$name removed successfully!"
    else
        print_error "Invalid option"
    fi
    
    echo ""
    print_separator
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
}

# Function to show system status
show_system_status() {
    clear
    print_header
    
    echo -e "${WHITE}System Status & Information${NC}"
    echo ""
    
    print_info "SPROOT Script: $SPROOT_SCRIPT"
    if [[ -f "$SPROOT_SCRIPT" ]]; then
        print_success "✓ Found"
    else
        print_error "✗ Not found"
    fi
    
    print_info "Ubuntu Directory: $DISTROS_DIR"
    if [[ -d "$DISTROS_DIR" ]]; then
        print_success "✓ Found"
        echo ""
        echo "Installed Ubuntu versions:"
        for distro in "${!DISTROS[@]}"; do
            if [[ -d "$DISTROS_DIR/$distro" ]]; then
                local info="${DISTROS[$distro]}"
                local name=$(echo "$info" | cut -d'|' -f1)
                print_success "  ✓ $name"
            fi
        done
    else
        print_warning "✗ No Ubuntu installations found"
    fi
    
    echo ""
    print_separator
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
}

# Main function
main() {
    # Check prerequisites
    if ! check_prerequisites; then
        print_error "Prerequisites check failed. Please install required packages."
        exit 1
    fi
    
    # Create distributions directory
    mkdir -p "$DISTROS_DIR"
    
    while true; do
        show_main_menu
        read -r choice
        
        case $choice in
            1)
                # Install Ubuntu
                show_ubuntu_menu
                read -r ubuntu_choice
                
                local ubuntu_count=${#DISTROS[@]}
                if [[ $ubuntu_choice -eq $((ubuntu_count+1)) ]]; then
                    continue
                elif [[ $ubuntu_choice -ge 1 && $ubuntu_choice -le $ubuntu_count ]]; then
                    local selected_distro=$(get_ubuntu_info "$ubuntu_choice")
                    if [[ -n "$selected_distro" ]]; then
                        install_ubuntu "$selected_distro"
                    else
                        print_error "Invalid Ubuntu version selected"
                        sleep 2
                    fi
                else
                    print_error "Invalid option"
                    sleep 2
                fi
                ;;
            2)
                # Remove Ubuntu
                remove_ubuntu
                ;;
            3)
                # Exit
                clear
                print_header
                echo -e "${GREEN}Thank you for using Ubuntu Manager!${NC}"
                echo ""
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 1-3."
                sleep 2
                ;;
        esac
    done
}

# Run main function
main "$@" 
