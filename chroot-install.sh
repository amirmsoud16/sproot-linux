#!/bin/bash

# chroot-install.sh - Standard Chroot Environment Installer
# This script installs and configures a standard chroot environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
DEFAULT_CHROOT_DIR="/opt/chroot"
DEFAULT_DISTRO="ubuntu"
DEFAULT_RELEASE="jammy"
DEFAULT_ARCH="amd64"

# Function to print colored output
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

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -d, --dir DIR          Chroot directory (default: $DEFAULT_CHROOT_DIR)"
    echo "  -t, --distro DISTRO    Distribution (ubuntu, debian, centos, fedora)"
    echo "  -r, --release RELEASE  Release version (default: $DEFAULT_RELEASE)"
    echo "  -a, --arch ARCH        Architecture (default: $DEFAULT_ARCH)"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Install Ubuntu Jammy in default location"
    echo "  $0 -d /home/user/chroot -t debian    # Install Debian in custom location"
    echo "  $0 -t ubuntu -r focal                # Install Ubuntu Focal"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
}

# Function to check required commands
check_dependencies() {
    local missing_deps=()
    
    case $DISTRO in
        ubuntu|debian)
            if ! command -v debootstrap &> /dev/null; then
                missing_deps+=("debootstrap")
            fi
            ;;
        centos|fedora)
            if ! command -v yum &> /dev/null && ! command -v dnf &> /dev/null; then
                missing_deps+=("yum or dnf")
            fi
            ;;
    esac
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_info "Please install the required packages first"
        exit 1
    fi
}

# Function to install dependencies
install_dependencies() {
    print_info "Installing dependencies..."
    
    if command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y debootstrap schroot
    elif command -v yum &> /dev/null; then
        yum install -y yum-utils
    elif command -v dnf &> /dev/null; then
        dnf install -y dnf-utils
    else
        print_error "Unsupported package manager"
        exit 1
    fi
}

# Function to create chroot directory
create_chroot_dir() {
    print_info "Creating chroot directory: $CHROOT_DIR"
    
    if [[ -d "$CHROOT_DIR" ]]; then
        print_warning "Directory $CHROOT_DIR already exists"
        read -p "Do you want to continue? This may overwrite existing data. (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled"
            exit 0
        fi
    fi
    
    mkdir -p "$CHROOT_DIR"
}

# Function to install Ubuntu/Debian chroot
install_ubuntu_debian() {
    print_info "Installing $DISTRO $RELEASE ($ARCH) chroot environment..."
    
    local mirror
    case $DISTRO in
        ubuntu)
            mirror="http://archive.ubuntu.com/ubuntu"
            ;;
        debian)
            mirror="http://deb.debian.org/debian"
            ;;
    esac
    
    debootstrap --arch="$ARCH" "$RELEASE" "$CHROOT_DIR" "$mirror"
    
    if [[ $? -eq 0 ]]; then
        print_success "Base system installed successfully"
    else
        print_error "Failed to install base system"
        exit 1
    fi
}

# Function to install CentOS/Fedora chroot
install_centos_fedora() {
    print_info "Installing $DISTRO chroot environment..."
    
    # This is a simplified approach - in production, you might want to use mock or other tools
    print_warning "CentOS/Fedora chroot installation requires additional setup"
    print_info "Creating basic directory structure..."
    
    mkdir -p "$CHROOT_DIR"/{bin,boot,dev,etc,home,lib,lib64,mnt,opt,proc,root,run,sbin,sys,tmp,usr,var}
    
    # Copy essential files
    cp /etc/resolv.conf "$CHROOT_DIR/etc/"
    cp /etc/hosts "$CHROOT_DIR/etc/"
    
    print_info "Please manually configure the $DISTRO environment or use specialized tools like mock"
}

# Function to configure the chroot environment
configure_chroot() {
    print_info "Configuring chroot environment..."
    
    # Mount essential filesystems
    mount_filesystems
    
    # Copy DNS configuration
    cp /etc/resolv.conf "$CHROOT_DIR/etc/resolv.conf"
    cp /etc/hosts "$CHROOT_DIR/etc/hosts"
    
    # Configure sources.list for Ubuntu/Debian
    if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
        configure_apt_sources
    fi
    
    # Update package database
    case $DISTRO in
        ubuntu|debian)
            chroot "$CHROOT_DIR" apt-get update
            chroot "$CHROOT_DIR" apt-get install -y locales
            ;;
    esac
    
    # Configure locales
    configure_locales
    
    # Install essential packages
    install_essential_packages
    
    print_success "Chroot environment configured successfully"
}

# Function to mount essential filesystems
mount_filesystems() {
    print_info "Mounting essential filesystems..."
    
    mount --bind /dev "$CHROOT_DIR/dev"
    mount --bind /dev/pts "$CHROOT_DIR/dev/pts"
    mount --bind /proc "$CHROOT_DIR/proc"
    mount --bind /sys "$CHROOT_DIR/sys"
    mount --bind /tmp "$CHROOT_DIR/tmp"
    
    print_success "Filesystems mounted"
}

# Function to unmount filesystems
unmount_filesystems() {
    print_info "Unmounting filesystems..."
    
    umount "$CHROOT_DIR/tmp" 2>/dev/null || true
    umount "$CHROOT_DIR/sys" 2>/dev/null || true
    umount "$CHROOT_DIR/proc" 2>/dev/null || true
    umount "$CHROOT_DIR/dev/pts" 2>/dev/null || true
    umount "$CHROOT_DIR/dev" 2>/dev/null || true
    
    print_success "Filesystems unmounted"
}

# Function to configure APT sources
configure_apt_sources() {
    print_info "Configuring APT sources..."
    
    case $DISTRO in
        ubuntu)
            cat > "$CHROOT_DIR/etc/apt/sources.list" << EOF
deb http://archive.ubuntu.com/ubuntu $RELEASE main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu $RELEASE-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu $RELEASE-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu $RELEASE-security main restricted universe multiverse
EOF
            ;;
        debian)
            cat > "$CHROOT_DIR/etc/apt/sources.list" << EOF
deb http://deb.debian.org/debian $RELEASE main contrib non-free
deb http://deb.debian.org/debian $RELEASE-updates main contrib non-free
deb http://security.debian.org/debian-security $RELEASE-security main contrib non-free
EOF
            ;;
    esac
}

# Function to configure locales
configure_locales() {
    print_info "Configuring locales..."
    
    case $DISTRO in
        ubuntu|debian)
            echo "en_US.UTF-8 UTF-8" > "$CHROOT_DIR/etc/locale.gen"
            chroot "$CHROOT_DIR" locale-gen
            chroot "$CHROOT_DIR" update-locale LANG=en_US.UTF-8
            ;;
    esac
}

# Function to install essential packages
install_essential_packages() {
    print_info "Installing essential packages..."
    
    case $DISTRO in
        ubuntu|debian)
            chroot "$CHROOT_DIR" apt-get install -y \
                vim \
                nano \
                curl \
                wget \
                git \
                build-essential \
                sudo \
                bash-completion
            ;;
    esac
}

# Function to create entry script
create_entry_script() {
    print_info "Creating chroot entry script..."
    
    cat > "$CHROOT_DIR/../enter-chroot.sh" << EOF
#!/bin/bash
# Entry script for chroot environment

CHROOT_DIR="$CHROOT_DIR"

# Check if running as root
if [[ \$EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Mount filesystems if not already mounted
if ! mountpoint -q "\$CHROOT_DIR/proc"; then
    mount --bind /dev "\$CHROOT_DIR/dev"
    mount --bind /dev/pts "\$CHROOT_DIR/dev/pts"
    mount --bind /proc "\$CHROOT_DIR/proc"
    mount --bind /sys "\$CHROOT_DIR/sys"
    mount --bind /tmp "\$CHROOT_DIR/tmp"
fi

# Enter chroot
echo "Entering chroot environment at \$CHROOT_DIR"
chroot "\$CHROOT_DIR" /bin/bash

# Cleanup function
cleanup() {
    echo "Cleaning up..."
    umount "\$CHROOT_DIR/tmp" 2>/dev/null || true
    umount "\$CHROOT_DIR/sys" 2>/dev/null || true
    umount "\$CHROOT_DIR/proc" 2>/dev/null || true
    umount "\$CHROOT_DIR/dev/pts" 2>/dev/null || true
    umount "\$CHROOT_DIR/dev" 2>/dev/null || true
}

# Set trap for cleanup
trap cleanup EXIT
EOF

    chmod +x "$CHROOT_DIR/../enter-chroot.sh"
    print_success "Entry script created at $CHROOT_DIR/../enter-chroot.sh"
}

# Function to show completion message
show_completion() {
    print_success "Chroot installation completed successfully!"
    echo ""
    print_info "Chroot directory: $CHROOT_DIR"
    print_info "Distribution: $DISTRO $RELEASE ($ARCH)"
    echo ""
    print_info "To enter the chroot environment:"
    echo "  sudo $CHROOT_DIR/../enter-chroot.sh"
    echo ""
    print_info "To manually enter the chroot:"
    echo "  sudo chroot $CHROOT_DIR /bin/bash"
    echo ""
    print_warning "Remember to unmount filesystems when done:"
    echo "  sudo umount $CHROOT_DIR/{tmp,sys,proc,dev/pts,dev}"
}

# Main function
main() {
    # Parse command line arguments
    CHROOT_DIR="$DEFAULT_CHROOT_DIR"
    DISTRO="$DEFAULT_DISTRO"
    RELEASE="$DEFAULT_RELEASE"
    ARCH="$DEFAULT_ARCH"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dir)
                CHROOT_DIR="$2"
                shift 2
                ;;
            -t|--distro)
                DISTRO="$2"
                shift 2
                ;;
            -r|--release)
                RELEASE="$2"
                shift 2
                ;;
            -a|--arch)
                ARCH="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate distribution
    case $DISTRO in
        ubuntu|debian|centos|fedora)
            ;;
        *)
            print_error "Unsupported distribution: $DISTRO"
            print_info "Supported distributions: ubuntu, debian, centos, fedora"
            exit 1
            ;;
    esac
    
    print_info "Starting chroot installation..."
    print_info "Distribution: $DISTRO $RELEASE ($ARCH)"
    print_info "Chroot directory: $CHROOT_DIR"
    echo ""
    
    # Check prerequisites
    check_root
    install_dependencies
    check_dependencies
    
    # Create and configure chroot
    create_chroot_dir
    
    case $DISTRO in
        ubuntu|debian)
            install_ubuntu_debian
            ;;
        centos|fedora)
            install_centos_fedora
            ;;
    esac
    
    configure_chroot
    create_entry_script
    
    # Cleanup
    unmount_filesystems
    
    show_completion
}

# Trap to ensure cleanup on exit
trap 'unmount_filesystems 2>/dev/null || true' EXIT

# Run main function
main "$@"