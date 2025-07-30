#!/bin/bash

# رنگ‌ها و توابع چاپ
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

print_info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_menu()    { echo -e "${WHITE}$1${NC} $2"; }
print_header()  { clear; echo -e "${CYAN}UBUNTU MANAGER${NC}\n-----------------------------"; }

DISTROS_DIR="$HOME/ubuntu-distros"
MANAGER_VERSION="2.0"

UBUNTU_KEYS=("ubuntu18" "ubuntu20" "ubuntu22" "ubuntu23" "ubuntu24")
declare -A DISTROS=(
    ["ubuntu18"]="Ubuntu 18.04 LTS|https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-arm64-root.tar.xz|ubuntu18-rootfs"
    ["ubuntu20"]="Ubuntu 20.04 LTS|https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-arm64-root.tar.xz|ubuntu20-rootfs"
    ["ubuntu22"]="Ubuntu 22.04 LTS|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-arm64-root.tar.xz|ubuntu22-rootfs"
    ["ubuntu23"]="Ubuntu 23.04|https://cloud-images.ubuntu.com/lunar/current/lunar-server-cloudimg-arm64-root.tar.xz|ubuntu23-rootfs"
    ["ubuntu24"]="Ubuntu 24.04 LTS|https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64-root.tar.xz|ubuntu24-rootfs"
)

check_prerequisites() {
    local required_commands=("wget" "tar" "proot")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            print_error "$cmd is not installed. Please install it first."
            exit 1
        fi
    done
    print_success "All prerequisites are satisfied"
}

setup_systemd_simulation() {
    local rootfs="$1"
    mkdir -p "$rootfs/usr/local/sproot/systemd"
    cat > "$rootfs/usr/local/sproot/systemd/systemctl" << 'EOF'
#!/bin/bash
case "$1" in
    start)   echo "Starting service: $2 (simulated)";;
    stop)    echo "Stopping service: $2 (simulated)";;
    restart) echo "Restarting service: $2 (simulated)";;
    enable)  echo "Enabling service: $2 (simulated)";;
    disable) echo "Disabling service: $2 (simulated)";;
    status)  echo "Service: $2 - active (simulated)";;
    *)       echo "Systemctl simulation - Usage: systemctl [start|stop|restart|enable|disable|status] service";;
esac
EOF
    chmod +x "$rootfs/usr/local/sproot/systemd/systemctl"
}

setup_snap_simulation() {
    local rootfs="$1"
    mkdir -p "$rootfs/usr/local/sproot/snap"
    cat > "$rootfs/usr/local/sproot/snap/snap" << 'EOF'
#!/bin/bash
case "$1" in
    install) echo "Installing snap: $2 (simulated)"; mkdir -p /snap/$2/current; echo "Snap $2 installed (simulated)";;
    remove)  echo "Removing snap: $2 (simulated)"; rm -rf /snap/$2; echo "Snap $2 removed (simulated)";;
    list)    echo "Installed snaps (simulated):"; ls /snap/ 2>/dev/null || echo "No snaps installed";;
    *)       echo "Snap simulation - Usage: snap [install|remove|list] package";;
esac
EOF
    chmod +x "$rootfs/usr/local/sproot/snap/snap"
}

setup_services_simulation() {
    local rootfs="$1"
    mkdir -p "$rootfs/usr/local/sproot/services"
    local services=("nginx" "apache2" "mysql" "redis" "postgresql")
    for service in "${services[@]}"; do
        cat > "$rootfs/usr/local/sproot/services/$service" << EOF
#!/bin/bash
case "\$1" in
    start)   echo "Starting $service (simulated)";;
    stop)    echo "Stopping $service (simulated)";;
    restart) echo "Restarting $service (simulated)";;
    status)  echo "$service is running (simulated)";;
    *)       echo "$service service simulation - Usage: $service [start|stop|restart|status]";;
esac
EOF
        chmod +x "$rootfs/usr/local/sproot/services/$service"
    done
}

setup_full_simulation() {
    local rootfs="$1"
    setup_systemd_simulation "$rootfs"
    setup_snap_simulation "$rootfs"
    setup_services_simulation "$rootfs"
    cat > "$rootfs/usr/local/sproot/setup-environment.sh" << 'EOF'
#!/bin/bash
export PATH="/usr/local/sproot/systemd:/usr/local/sproot/snap:/usr/local/sproot/services:$PATH"
alias systemctl='/usr/local/sproot/systemd/systemctl'
alias snap='/usr/local/sproot/snap/snap'
alias nginx='/usr/local/sproot/services/nginx'
alias apache2='/usr/local/sproot/services/apache2'
alias mysql='/usr/local/sproot/services/mysql'
alias redis='/usr/local/sproot/services/redis'
alias postgresql='/usr/local/sproot/services/postgresql'
echo "SPROOT Complete environment ready!"
EOF
    chmod +x "$rootfs/usr/local/sproot/setup-environment.sh"
}

check_ubuntu_tools() {
    local rootfs_path="$1"
    local tools=("dpkg" "apt")
    local missing=0
    for tool in "${tools[@]}"; do
        if [ ! -x "$rootfs_path/usr/bin/$tool" ] && [ ! -x "$rootfs_path/bin/$tool" ]; then
            print_error "$tool is missing in rootfs!"
            missing=1
        fi
    done
    if [ $missing -eq 0 ]; then
        print_success "All primary Ubuntu tools (dpkg, apt) are present in rootfs."
    else
        print_error "Some primary Ubuntu tools are missing in rootfs."
    fi
}

install_ubuntu() {
    local distro="$1"
    local info="${DISTROS[$distro]}"
    local name=$(echo "$info" | cut -d'|' -f1)
    local url=$(echo "$info" | cut -d'|' -f2)
    local rootfs_name=$(echo "$info" | cut -d'|' -f3)
    local rootfs_path="$DISTROS_DIR/$distro/$rootfs_name"

    print_info "Creating directories..."
    mkdir -p "$DISTROS_DIR/$distro"
    mkdir -p "$rootfs_path/proc" "$rootfs_path/sys" "$rootfs_path/dev" "$rootfs_path/dev/pts"

    print_info "Setting permissions..."
    chmod 700 "$DISTROS_DIR/$distro"
    chmod 755 "$rootfs_path"
    chmod 755 "$rootfs_path/proc" "$rootfs_path/sys" "$rootfs_path/dev" "$rootfs_path/dev/pts"

    print_info "Downloading $name rootfs..."
    wget -O "$DISTROS_DIR/$distro/${distro}-rootfs.tar.xz" "$url" || { print_error "Download failed!"; return 1; }

    print_info "Extracting rootfs..."
    tar -xf "$DISTROS_DIR/$distro/${distro}-rootfs.tar.xz" -C "$DISTROS_DIR/$distro" || { print_error "Extraction failed!"; return 1; }

    rm -f "$DISTROS_DIR/$distro/${distro}-rootfs.tar.xz"

    check_ubuntu_tools "$rootfs_path"

    # فیکس اینترنت بعد از نصب
    rm -f "$rootfs_path/etc/resolv.conf"
    echo "nameserver 8.8.8.8" > "$rootfs_path/etc/resolv.conf"
    print_success "Internet fixed for $name (resolv.conf set to 8.8.8.8)."

    print_success "$name installed successfully!"

    setup_full_simulation "$rootfs_path"

    cat > "$DISTROS_DIR/start-$distro.sh" << EOF
#!/bin/bash
proot -r "$rootfs_path" -b /dev -b /proc -b /sys -w /root /bin/bash --login -c 'source /usr/local/sproot/setup-environment.sh; exec /bin/bash'
EOF
    chmod +x "$DISTROS_DIR/start-$distro.sh"
    clear
    print_success "Startup script created: $DISTROS_DIR/start-$distro.sh"

    # افزودن alias به bashrc (اگر وجود نداشته باشد)
    local alias_name="${distro}"
    local alias_cmd="bash ~/ubuntu-distros/start-${distro}.sh"
    if ! grep -q "alias $alias_name=" ~/.bashrc 2>/dev/null; then
        echo "alias $alias_name='$alias_cmd'" >> ~/.bashrc
        print_success "Alias '$alias_name' added to ~/.bashrc"
    fi
}

remove_ubuntu_menu() {
    print_header
    echo "Select Ubuntu to remove:"
    local options=()
    local counter=1
    for key in "${UBUNTU_KEYS[@]}"; do
        local info="${DISTROS[$key]}"
        local name=$(echo "$info" | cut -d'|' -f1)
        local rootfs_name=$(echo "$info" | cut -d'|' -f3)
        local rootfs_path="$DISTROS_DIR/$key/$rootfs_name"
        if [ -d "$rootfs_path" ]; then
            print_menu "$counter." "$name"
            options+=("$key")
            ((counter++))
        fi
    done
    if [ ${#options[@]} -eq 0 ]; then
        print_warning "No Ubuntu versions installed."
        echo "Press Enter to continue..."; read
        clear
        return
    fi
    print_menu "$counter." "Remove All"
    print_menu "$((counter+1))." "Back to Main Menu"
    echo -n "Select Ubuntu to remove (1-$((counter+1))): "
    read -r choice
    if [[ $choice -ge 1 && $choice -le ${#options[@]} ]]; then
        local selected="${options[$((choice-1))]}"
        rm -rf "$DISTROS_DIR/$selected"
        rm -f "$DISTROS_DIR/start-$selected.sh"
        clear
        print_success "Removed $selected."
    elif [[ $choice -eq $counter ]]; then
        rm -rf "$DISTROS_DIR"
        mkdir -p "$DISTROS_DIR"
        clear
        print_success "All Ubuntu installations removed."
    fi
}

show_ubuntu_menu() {
    print_header
    echo "Available Ubuntu Versions:"
    local counter=1
    for key in "${UBUNTU_KEYS[@]}"; do
        local info="${DISTROS[$key]}"
        local name=$(echo "$info" | cut -d'|' -f1)
        print_menu "$counter." "$name"
        ((counter++))
    done
    print_menu "$counter." "Back to Main Menu"
    echo -n "Select Ubuntu version (1-$counter): "
    read -r choice
    if [[ $choice -ge 1 && $choice -le ${#UBUNTU_KEYS[@]} ]]; then
        local selected_distro="${UBUNTU_KEYS[$((choice-1))]}"
        install_ubuntu "$selected_distro"
    fi
}

main_menu() {
    while true; do
        print_header
        print_menu "1." "Install Ubuntu"
        print_menu "2." "Remove Ubuntu"
        print_menu "3." "Exit"
        echo -n "Select an option (1-3): "
        read -r choice
        case $choice in
            1) show_ubuntu_menu ;;
            2) remove_ubuntu_menu ;;
            3) exit 0 ;;
            *) print_error "Invalid option." ;;
        esac
    done
}

check_prerequisites
mkdir -p "$DISTROS_DIR"
main_menu