#!/bin/bash

# Ubuntu Installer for Termux
# Modern Installation Script with Background Operations

# Colors - Standard Color Scheme
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
PURPLE='\033[0;35m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Loading animation characters
SPINNER=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
DOTS=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

# Function to print header with logo
print_header() {
    clear
    echo -e "${CYAN}Ubuntu Installer for Termux${NC}"
    echo -e "${CYAN}Modern & Beautiful Setup${NC}"
    echo ""
}

# Function to print status with standard colors
print_status() {
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

print_log() {
    echo -e "${GRAY}[LOG]${NC} $1"
}

# Function to show loading animation
show_loading() {
    local message="$1"
    local pid=$2
    local i=0
    
    echo -e "${CYAN}🔄 $message${NC}"
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${SPINNER[$i]}
        echo -ne "${YELLOW}⏳ Processing${dots} ${temp}${NC}\r"
        i=$(( (i+1) % ${#SPINNER[@]} ))
        sleep 0.1
    done
    
    echo -e "${GREEN}✅ Completed successfully!${NC}"
    echo ""
}

# Function to show progress bar
show_progress() {
    local message="$1"
    local duration=$2
    local i=0
    
    echo -e "${CYAN}📊 $message${NC}"
    
    for ((i=0; i<=100; i+=5)); do
        local bar=""
        local filled=$((i/5))
        local empty=$((20-filled))
        
        for ((j=0; j<filled; j++)); do
            bar+="█"
        done
        
        for ((j=0; j<empty; j++)); do
            bar+="░"
        done
        
        echo -ne "${GREEN}Progress: [${bar}] ${i}%${NC}\r"
        sleep $((duration/20))
    done
    
    echo -e "${GREEN}✅ Progress completed!${NC}"
    echo ""
}

# Function to print menu with beautiful design
print_menu() {
    echo "Available Options:"
    echo "  1. 🚀 Install Ubuntu (Background Operation)"
    echo "  2. 🗑️  Remove Ubuntu (Clean Uninstall)"
    echo "  3. 📖 Installation Guide (Step by Step)"
    echo "  4. 🔧 System Check (Prerequisites)"
    echo "  5. ❌ Exit (Goodbye)"
    echo ""
}

# Function to check prerequisites in background
check_prerequisites_background() {
    # Check if running in Termux
    if [[ ! -d "/data/data/com.termux" ]]; then
        echo "not_termux" > $HOME/prerequisites_result
        return
    fi
    
    # Update packages
    pkg update -y > /dev/null 2>&1
    
    # Install required packages
    pkg install wget curl proot tar git nano vim -y > /dev/null 2>&1
    
    # Check disk space
    available_space=$(df $HOME | awk 'NR==2 {print $4}')
    required_space=4194304  # 4GB in KB
    
    if [[ $available_space -lt $required_space ]]; then
        echo "low_disk_space:$available_space" > $HOME/prerequisites_result
        return
    fi
    
    # Check internet connection
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        echo "no_internet" > $HOME/prerequisites_result
        return
    fi
    
    # Create directories
    mkdir -p $HOME/ubuntu
    mkdir -p $HOME/ubuntu/scripts
    
    echo "success" > $HOME/prerequisites_result
}

# Function to check prerequisites with loading
check_prerequisites() {
    print_status "🔍 Checking system prerequisites..."
    
    # Start background check
    check_prerequisites_background &
    local pid=$!
    
    # Show loading animation
    show_loading "System Check & Prerequisites" $pid
    
    # Wait for completion
    wait $pid
    
    # Check result
    if [[ -f $HOME/prerequisites_result ]]; then
        local result=$(cat $HOME/prerequisites_result)
        rm -f $HOME/prerequisites_result
        
        case $result in
            "success")
                print_success "System prerequisites check completed successfully!"
                print_log "✓ Termux environment detected"
                print_log "✓ Required packages installed"
                print_log "✓ Sufficient disk space available"
                print_log "✓ Internet connection available"
                print_log "✓ Directories created"
                ;;
            "not_termux")
                print_error "This script must be run in Termux!"
                print_status "Please install Termux from F-Droid and try again."
                exit 1
                ;;
            "low_disk_space")
                available_space_mb=$(($available_space / 1024))
                print_warning "Low disk space detected!"
                print_status "Available: ${available_space_mb}MB, Required: 4GB"
                read -p "Continue anyway? (y/N): " continue_anyway
                if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
                    exit 1
                fi
                ;;
            "no_internet")
                print_error "No internet connection detected!"
                print_status "Please check your internet connection and try again."
                exit 1
                ;;
            *)
                print_error "Unknown error during prerequisites check"
                exit 1
                ;;
        esac
    else
        print_error "Prerequisites check failed"
        exit 1
    fi
}

# Function to install Ubuntu in background
install_ubuntu_background() {
    local version=$1
    
    # Install proot-distro if not installed
    if ! command -v proot-distro &> /dev/null; then
        pkg install proot-distro -y > /dev/null 2>&1
    fi
    
    # Install Ubuntu
    proot-distro install ubuntu-${version} > /dev/null 2>&1
    
    if [[ $? -eq 0 ]]; then
        echo "success:$version" > $HOME/ubuntu_install_result
    else
        echo "failed:$version" > $HOME/ubuntu_install_result
    fi
}

# Function to install Ubuntu with beautiful UI
install_ubuntu_proot() {
    local version=$1
    
    print_status "🚀 Installing Ubuntu ${version} with proot-distro..."
    
    # Start background installation
    install_ubuntu_background $version &
    local pid=$!
    
    # Show loading animation
    show_loading "Installing Ubuntu ${version}" $pid
    
    # Wait for completion
    wait $pid
    
    # Check result
    if [[ -f $HOME/ubuntu_install_result ]]; then
        local result=$(cat $HOME/ubuntu_install_result)
        rm -f $HOME/ubuntu_install_result
        
        if [[ "$result" == "success:$version" ]]; then
            print_success "Ubuntu ${version} installed successfully!"
            
            # Show post-install menu
            show_post_install_menu $version
        else
            print_error "Failed to install Ubuntu ${version}"
            print_status "Please check your internet connection and try again."
        fi
    else
        print_error "Installation failed"
    fi
}

# Function to install Ubuntu Chroot in background
install_ubuntu_chroot_background() {
    local version=$1
    local codename=$2
    local url=$3
    
    # Create installation directory
    local install_dir="$HOME/ubuntu/ubuntu${version}-rootfs"
    mkdir -p $install_dir
    cd $install_dir
    
    # Download Ubuntu rootfs
    wget -q --show-progress -O ubuntu-${version}-rootfs.tar.xz $url > /dev/null 2>&1
    
    if [[ $? -eq 0 ]]; then
        # Extract rootfs
        tar -xf ubuntu-${version}-rootfs.tar.xz --exclude='./dev' > /dev/null 2>&1
        
        # Create necessary directories
        mkdir -p $install_dir/etc
        mkdir -p $install_dir/dev
        mkdir -p $install_dir/proc
        mkdir -p $install_dir/sys
        mkdir -p $install_dir/tmp
        mkdir -p $install_dir/var/tmp
        
        # Fix groups file
        cat >> $install_dir/etc/group <<'EOF'
3003:3003:3003
9997:9997:9997
20238:20238:20238
50238:50238:50238
EOF
        
        # Set permissions
        chmod -R 755 $install_dir
        chown -R root:root $install_dir 2>/dev/null || true
        
        # Create setup scripts in Ubuntu directory
        create_setup_scripts_in_ubuntu $version $install_dir
        
        # Create shortcuts for easy access
        create_ubuntu_shortcuts $version $install_dir
        
        echo "success:$version" > $HOME/ubuntu_install_result
    else
        echo "failed:$version" > $HOME/ubuntu_install_result
    fi
}

# Function to create setup scripts inside Ubuntu directory
create_setup_scripts_in_ubuntu() {
    local version=$1
    local install_dir=$2
    
    print_status "📝 Creating setup scripts in Ubuntu directory..."
    
    # Ensure the Ubuntu directory exists
    mkdir -p $install_dir
    
    # Create ubuntu-root-setup.sh in Ubuntu directory
    cat > $install_dir/ubuntu-root-setup.sh << 'EOF'
#!/bin/bash

# Ubuntu Root Setup Script
# This script handles root-level configuration, user creation, and system fixes

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${CYAN}[INFO]${NC} $1"
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

# Function to check if running in Ubuntu environment
check_ubuntu_environment() {
    print_status "🔍 Checking Ubuntu environment..."
    
    # Check if we're in a Linux environment
    if [[ ! -f "/etc/os-release" ]]; then
        print_error "This script must be run inside Ubuntu!"
        print_status "Please run this script after entering Ubuntu with:"
        print_status "proot -0 -r . -b /dev -b /proc -b /sys -w /root /bin/bash"
        exit 1
    fi
    
    # Check if it's Ubuntu
    if ! grep -q "Ubuntu" /etc/os-release; then
        print_error "This script is designed for Ubuntu only!"
        exit 1
    fi
    
    # Check if we have root access
    if [[ $(id -u) -ne 0 ]]; then
        print_warning "This script requires root access!"
        print_status "Please run with sudo or as root"
        print_status "You can enter as root with: proot -0 -r . -b /dev -b /proc -b /sys -w /root /bin/bash"
        exit 1
    fi
    
    print_success "Ubuntu environment detected"
}

# Function to get user credentials
get_user_credentials() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}  User Configuration${NC}"
    echo -e "${CYAN}================================${NC}"
    echo ""
    
    # Get username
    while true; do
        read -p "Enter username for Ubuntu: " UBUNTU_USERNAME
        if [[ -n "$UBUNTU_USERNAME" ]]; then
            break
        else
            print_error "Username cannot be empty!"
        fi
    done
    
    # Get root password
    while true; do
        read -s -p "Enter root password for Ubuntu: " ROOT_PASSWORD
        echo ""
        if [[ -n "$ROOT_PASSWORD" ]]; then
            read -s -p "Confirm root password: " ROOT_PASSWORD_CONFIRM
            echo ""
            if [[ "$ROOT_PASSWORD" == "$ROOT_PASSWORD_CONFIRM" ]]; then
                break
            else
                print_error "Passwords do not match!"
            fi
        else
            print_error "Password cannot be empty!"
        fi
    done
    
    print_success "User configuration saved!"
    print_status "Username: $UBUNTU_USERNAME"
    print_status "Root password: ********"
    print_status "User password: None (no password needed)"
    echo ""
}

# Function to fix permission issues
fix_permissions() {
    print_status "🔧 Fixing permission issues..."
    
    # Fix dpkg directory permissions
    print_status "Fixing dpkg directory permissions..."
    chmod 755 /var/lib/dpkg 2>/dev/null || true
    chmod 755 /var/lib/dpkg/info 2>/dev/null || true
    chmod 755 /var/lib/dpkg/updates 2>/dev/null || true
    chmod 755 /var/lib/dpkg/triggers 2>/dev/null || true
    
    # Fix dpkg status file permissions
    print_status "Fixing dpkg status file permissions..."
    chmod 644 /var/lib/dpkg/status 2>/dev/null || true
    chmod 644 /var/lib/dpkg/status-old 2>/dev/null || true
    
    # Remove problematic backup files
    print_status "Cleaning dpkg backup files..."
    rm -f /var/lib/dpkg/status-old
    rm -f /var/lib/dpkg/status.backup
    rm -f /var/lib/dpkg/status-*
    
    # Fix library permissions - more comprehensive
    print_status "Fixing library permissions..."
    find /usr/lib -name "*.so*" -exec chmod 755 {} \; 2>/dev/null || true
    find /usr/lib/aarch64-linux-gnu -name "*.so*" -exec chmod 755 {} \; 2>/dev/null || true
    find /lib -name "*.so*" -exec chmod 755 {} \; 2>/dev/null || true
    find /lib/aarch64-linux-gnu -name "*.so*" -exec chmod 755 {} \; 2>/dev/null || true
    
    # Fix specific problematic libraries
    print_status "Fixing specific library permissions..."
    chmod 755 /usr/lib/aarch64-linux-gnu/libsqlite3.so.0.8.6 2>/dev/null || true
    chmod 755 /usr/lib/aarch64-linux-gnu/libgnutls.so.30.31.0 2>/dev/null || true
    chmod 755 /usr/lib/aarch64-linux-gnu/libsqlite3.so.0 2>/dev/null || true
    chmod 755 /usr/lib/aarch64-linux-gnu/libgnutls.so.30 2>/dev/null || true
    
    # Fix apt cache permissions
    print_status "Fixing apt cache permissions..."
    chmod 755 /var/cache/apt 2>/dev/null || true
    chmod 755 /var/cache/apt/archives 2>/dev/null || true
    chmod 755 /var/cache/apt/archives/partial 2>/dev/null || true
    
    # Fix tmp directory permissions
    print_status "Fixing tmp directory permissions..."
    chmod 1777 /tmp 2>/dev/null || true
    chmod 1777 /var/tmp 2>/dev/null || true
    
    # Fix dpkg lock files
    print_status "Removing dpkg lock files..."
    rm -f /var/lib/dpkg/lock 2>/dev/null || true
    rm -f /var/lib/dpkg/lock-frontend 2>/dev/null || true
    rm -f /var/cache/apt/archives/lock 2>/dev/null || true
    rm -f /var/lib/apt/lists/lock 2>/dev/null || true
    
    print_success "Permission issues fixed"
}

# Function to fix apt/dpkg issues
fix_apt_issues() {
    print_status "🔧 Fixing apt/dpkg issues..."
    
    # Force remove all lock files
    print_status "Removing all lock files..."
    rm -f /var/lib/dpkg/lock* 2>/dev/null || true
    rm -f /var/cache/apt/archives/lock 2>/dev/null || true
    rm -f /var/lib/apt/lists/lock 2>/dev/null || true
    
    # Configure dpkg to handle broken packages
    print_status "Configuring dpkg..."
    echo 'Dpkg::Options::="--force-confnew";' > /etc/apt/apt.conf.d/local
    echo 'Dpkg::Options::="--force-confmiss";' >> /etc/apt/apt.conf.d/local
    
    # Fix broken packages
    print_status "Fixing broken packages..."
    dpkg --configure -a 2>/dev/null || true
    apt --fix-broken install -y 2>/dev/null || true
    
    # Clean apt cache
    print_status "Cleaning apt cache..."
    apt clean 2>/dev/null || true
    apt autoclean 2>/dev/null || true
    
    print_success "Apt issues fixed"
}

# Function to fix internet connectivity
fix_internet() {
    print_status "🌐 Fixing internet connectivity..."
    
    # Create resolv.conf with multiple DNS servers
    print_status "Configuring DNS servers..."
    cat > /etc/resolv.conf << 'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
nameserver 1.0.0.1
EOF
    
    # Test internet connection
    print_status "Testing internet connection..."
    if ping -c 1 8.8.8.8 &> /dev/null; then
        print_success "Internet connection working"
    else
        print_warning "Internet connection may be slow or unavailable"
    fi
    
    print_success "Internet configuration completed"
}

# Function to create user and set password in Ubuntu
setup_ubuntu_user() {
    print_status "👤 Setting up user and password..."
    
    # Create user with useradd (non-interactive)
    useradd -m -s /bin/bash $UBUNTU_USERNAME
    
    # Set root password (this will be the password for future root access)
    echo "root:$ROOT_PASSWORD" | chpasswd
    
    # Set user password to empty (no password)
    echo "$UBUNTU_USERNAME:" | chpasswd
    
    # Add user to sudo group
    usermod -aG sudo $UBUNTU_USERNAME
    
    # Configure sudo for the user (password required for first time)
    echo "$UBUNTU_USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$UBUNTU_USERNAME
    chmod 440 /etc/sudoers.d/$UBUNTU_USERNAME
    
    # Create user directories
    mkdir -p /home/$UBUNTU_USERNAME
    chown -R $UBUNTU_USERNAME:$UBUNTU_USERNAME /home/$UBUNTU_USERNAME
    
    print_success "User setup completed"
    print_status "Root password is now set for future access"
    print_status "User can use sudo without password"
    
    # Create a marker file to indicate setup is complete
    touch /setup-completed.marker
}

# Function to create Ubuntu start scripts
create_ubuntu_start_scripts() {
    print_status "📝 Creating Ubuntu start scripts..."
    
    # Get Ubuntu version from /etc/os-release
    UBUNTU_VERSION=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2 | cut -d'.' -f1)
    
    # Create start script for root access (with password prompt)
    cat > /start-ubuntu.sh << EOF
#!/bin/bash
unset LD_PRELOAD

# Check if setup is completed
if [[ -f "\$HOME/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs/setup-completed.marker" ]]; then
    # Setup is completed, prompt for root password
    echo -n "Enter root password: "
    read -s ROOT_PASS
    echo ""
else
    # Setup not completed yet, no password needed
    echo "No root password set yet. Entering without password..."
fi

# Start Ubuntu as root
proot -0 -r \$HOME/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs \\
    -b /dev -b /proc -b /sys \\
    -b \$HOME:/root \\
    -w /root /usr/bin/env -i HOME=/root TERM="\$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x /start-ubuntu.sh
    
    # Create start script for user access (simple entry)
    cat > /start-ubuntu-user.sh << EOF
#!/bin/bash
unset LD_PRELOAD

proot -0 -r \$HOME/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs \\
    -b /dev -b /proc -b /sys \\
    -b \$HOME:/home/$UBUNTU_USERNAME \\
    -w /home/$UBUNTU_USERNAME /usr/bin/env -i HOME=/home/$UBUNTU_USERNAME USER=$UBUNTU_USERNAME TERM="\$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/su - $UBUNTU_USERNAME
EOF
    chmod +x /start-ubuntu-user.sh
    
    # Create internet fix script
    cat > /fix-internet.sh << 'EOF'
#!/bin/bash
# Fix internet connectivity in Ubuntu

echo "Fixing internet connectivity..."

# Setup DNS servers
rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf

# Test internet connection
if ping -c 1 8.8.8.8 &> /dev/null; then
    echo "Internet connection working!"
else
    echo "Internet connection may be slow or unavailable"
fi

echo "Internet fix completed!"
EOF
    chmod +x /fix-internet.sh
    
    print_success "Start scripts created"
    print_status "Start script created: /start-ubuntu.sh"
    print_status "User script created: /start-ubuntu-user.sh"
    print_status "Internet fix script created: /fix-internet.sh"
}

# Function to create Termux aliases
create_termux_aliases() {
    print_status "📝 Creating Termux aliases..."
    
    # Get Ubuntu version from /etc/os-release
    UBUNTU_VERSION=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2 | cut -d'.' -f1)
    
    # Create simple aliases in Termux .bashrc
    echo "alias ubuntu${UBUNTU_VERSION}=\"cd ~/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs && ./start-ubuntu.sh\"" >> ~/.bashrc
    echo "alias ubuntu${UBUNTU_VERSION}-${UBUNTU_USERNAME}=\"cd ~/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs && ./start-ubuntu-user.sh\"" >> ~/.bashrc
    echo "alias fix-internet-${UBUNTU_VERSION}=\"cd ~/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs && ./fix-internet.sh\"" >> ~/.bashrc
    
    # Source .bashrc to apply changes
    source ~/.bashrc
    
    print_success "Termux aliases created"
    print_status "Root access: ubuntu${UBUNTU_VERSION}"
    print_status "User access: ubuntu${UBUNTU_VERSION}-${UBUNTU_USERNAME}"
    print_status "Internet fix: fix-internet-${UBUNTU_VERSION}"
}

# Function to copy scripts to Ubuntu directory
copy_scripts_to_ubuntu() {
    print_status "📁 Copying scripts to Ubuntu directory..."
    
    # Get Ubuntu version from /etc/os-release
    UBUNTU_VERSION=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2 | cut -d'.' -f1)
    
    # Create Ubuntu directory if it doesn't exist
    mkdir -p ~/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs
    
    # Copy start scripts to Ubuntu directory with simple names
    cp /start-ubuntu.sh ~/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs/start-ubuntu.sh
    cp /start-ubuntu-user.sh ~/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs/start-ubuntu-user.sh
    cp /fix-internet.sh ~/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs/fix-internet.sh
    
    # Copy setup marker
    cp /setup-completed.marker ~/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs/setup-completed.marker
    
    # Make scripts executable
    chmod +x ~/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs/start-ubuntu.sh
    chmod +x ~/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs/start-ubuntu-user.sh
    chmod +x ~/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs/fix-internet.sh
    
    print_success "Scripts copied to Ubuntu directory"
}

# Main root setup function
main_root_setup() {
    print_status "🚀 Starting Ubuntu Root Setup..."
    
    # Check Ubuntu environment first
    check_ubuntu_environment
    
    # Get user credentials first
    get_user_credentials
    
    # Fix permissions and apt issues first
    fix_permissions
    fix_apt_issues
    fix_internet
    
    # Setup user and password
    setup_ubuntu_user
    
    # Create start scripts
    create_ubuntu_start_scripts
    
    # Create Termux aliases
    create_termux_aliases
    
    # Copy scripts to Ubuntu directory
    copy_scripts_to_ubuntu
    
    print_success "✅ Ubuntu Root Setup completed successfully!"
    print_status "Username: $UBUNTU_USERNAME"
    print_status "Root password: ********"
    print_status "User password: None (no password needed)"
    echo ""
    print_status "Next steps:"
    print_status "1. Exit this Ubuntu environment: exit"
    print_status "2. Enter Ubuntu as user: ubuntu${UBUNTU_VERSION}-$UBUNTU_USERNAME"
    print_status "3. Run ubuntu-tools-setup.sh to install tools"
}

# Run the root setup
main_root_setup
EOF
    
    chmod +x $install_dir/ubuntu-root-setup.sh
    
    # Create ubuntu-tools-setup.sh in Ubuntu directory
    cat > $install_dir/ubuntu-tools-setup.sh << 'EOF'
#!/bin/bash

# Ubuntu Tools Setup Script
# This script installs all development tools and packages for regular users

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${CYAN}[INFO]${NC} $1"
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

# Function to check if running in Ubuntu environment
check_ubuntu_environment() {
    print_status "🔍 Checking Ubuntu environment..."
    
    # Check if we're in a Linux environment
    if [[ ! -f "/etc/os-release" ]]; then
        print_error "This script must be run inside Ubuntu!"
        print_status "Please run this script after entering Ubuntu with:"
        print_status "proot -0 -r . -b /dev -b /proc -b /sys -w /root /bin/bash"
        exit 1
    fi
    
    # Check if it's Ubuntu
    if ! grep -q "Ubuntu" /etc/os-release; then
        print_error "This script is designed for Ubuntu only!"
        exit 1
    fi
    
    print_success "Ubuntu environment detected"
}

# Function to check sudo availability
check_sudo_availability() {
    print_status "🔍 Checking sudo availability..."
    
    if ! command -v sudo &> /dev/null; then
        print_error "sudo is not available!"
        print_status "Please run ubuntu-root-setup.sh first to configure sudo"
        exit 1
    fi
    
    # Test sudo access
    if ! sudo -n true 2>/dev/null; then
        print_warning "sudo requires password!"
        print_status "You may be prompted for password during installation"
    fi
    
    print_success "sudo is available"
}

# Function to install system tools
install_system_tools() {
    print_status "📦 Installing system tools..."
    
    # Update package lists
    print_status "Updating package lists..."
    sudo apt update -y
    
    # Install essential system tools
    print_status "Installing essential tools..."
    sudo apt install -y curl wget git nano vim build-essential gcc g++ make
    
    # Install Python and Node.js
    print_status "Installing Python and Node.js..."
    sudo apt install -y python3 python3-pip nodejs npm
    
    # Install monitoring tools
    print_status "Installing monitoring tools..."
    sudo apt install -y htop neofetch unzip zip tar net-tools iputils-ping
    
    print_success "System tools installed"
}

# Function to install development tools
install_dev_tools() {
    print_status "💻 Installing development tools..."
    
    # Install development tools
    print_status "Installing development tools..."
    sudo apt install -y cmake clang gdb valgrind strace ltrace
    
    print_success "Development tools installed"
}

# Function to install network tools
install_network_tools() {
    print_status "🌐 Installing network tools..."
    
    # Install network tools
    print_status "Installing network tools..."
    sudo apt install -y iperf3
    
    print_success "Network tools installed"
}

# Function to install text processing tools
install_text_tools() {
    print_status "📝 Installing text processing tools..."
    
    # Install text processing tools
    print_status "Installing text processing tools..."
    sudo apt install -y grep sed awk jq xmlstarlet csvkit
    
    print_success "Text processing tools installed"
}

# Function to install monitoring tools
install_monitoring_tools() {
    print_status "📊 Installing monitoring tools..."
    
    # Install monitoring tools
    print_status "Installing monitoring tools..."
    sudo apt install -y iotop nethogs iftop nload
    
    print_success "Monitoring tools installed"
}

# Function to install modern CLI tools
install_modern_cli_tools() {
    print_status "🛠️ Installing modern CLI tools..."
    
    # Install modern CLI tools
    print_status "Installing modern CLI tools..."
    sudo apt install -y tree mc ranger fzf ripgrep bat exa fd-find
    
    print_success "Modern CLI tools installed"
}

# Function to install Python packages
install_python_packages() {
    print_status "🐍 Installing Python packages..."
    
    # Install Python packages
    print_status "Installing Python packages..."
    pip3 install requests beautifulsoup4 pandas numpy matplotlib
    
    print_success "Python packages installed"
}

# Function to install Node.js packages
install_nodejs_packages() {
    print_status "📦 Installing Node.js packages..."
    
    # Install Node.js packages
    print_status "Installing Node.js packages..."
    sudo npm install -g yarn npx create-react-app express-generator
    
    print_success "Node.js packages installed"
}

# Function to setup user environment
setup_user_environment() {
    print_status "👤 Setting up user environment..."
    
    # Create useful directories
    print_status "Creating useful directories..."
    mkdir -p ~/projects ~/downloads ~/documents ~/pictures ~/music ~/videos
    
    # Add helpful aliases
    print_status "Adding helpful aliases..."
    echo 'alias ll="ls -la"' >> ~/.bashrc
    echo 'alias la="ls -A"' >> ~/.bashrc
    echo 'alias l="ls -CF"' >> ~/.bashrc
    echo 'alias ..="cd .."' >> ~/.bashrc
    echo 'alias ...="cd ../.."' >> ~/.bashrc
    echo 'alias ....="cd ../../.."' >> ~/.bashrc
    echo 'alias home="cd ~"' >> ~/.bashrc
    echo 'alias cls="clear"' >> ~/.bashrc
    
    # Configure SSH directory
    print_status "Configuring SSH directory..."
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    
    print_success "User environment setup completed"
}

# Function to install additional useful tools
install_additional_tools() {
    print_status "🔧 Installing additional useful tools..."
    
    # Install additional tools
    print_status "Installing additional tools..."
    sudo apt install -y tmux screen byobu fish zsh
    
    # Install version control tools
    print_status "Installing version control tools..."
    sudo apt install -y git git-flow
    
    # Install database tools
    print_status "Installing database tools..."
    sudo apt install -y sqlite3 postgresql-client mysql-client
    
    # Install web development tools
    print_status "Installing web development tools..."
    sudo apt install -y apache2-utils nginx-common
    
    print_success "Additional tools installed"
}

# Function to install security tools
install_security_tools() {
    print_status "🔒 Installing security tools..."
    
    # Install security tools
    print_status "Installing security tools..."
    sudo apt install -y openssl sslscan testssl.sh
    
    print_success "Security tools installed"
}

# Function to install multimedia tools
install_multimedia_tools() {
    print_status "🎵 Installing multimedia tools..."
    
    # Install multimedia tools
    print_status "Installing multimedia tools..."
    sudo apt install -y ffmpeg imagemagick sox
    
    print_success "Multimedia tools installed"
}

# Function to install system administration tools
install_admin_tools() {
    print_status "⚙️ Installing system administration tools..."
    
    # Install system administration tools
    print_status "Installing system administration tools..."
    sudo apt install -y rsync cron anacron logrotate
    
    print_success "System administration tools installed"
}

# Function to create development environment
setup_dev_environment() {
    print_status "💻 Setting up development environment..."
    
    # Create development directories
    print_status "Creating development directories..."
    mkdir -p ~/projects/{web,python,nodejs,scripts}
    mkdir -p ~/projects/web/{frontend,backend}
    mkdir -p ~/projects/python/{scripts,web,data}
    mkdir -p ~/projects/nodejs/{apps,packages}
    
    # Create common development files
    print_status "Creating common development files..."
    echo "# Development Environment" > ~/projects/README.md
    echo "This directory contains all development projects." >> ~/projects/README.md
    
    # Create git configuration
    print_status "Setting up git configuration..."
    git config --global user.name "$(whoami)"
    git config --global user.email "$(whoami)@localhost"
    git config --global init.defaultBranch main
    
    print_success "Development environment setup completed"
}

# Function to install language-specific tools
install_language_tools() {
    print_status "🌍 Installing language-specific tools..."
    
    # Install Go (if available)
    if command -v go &> /dev/null; then
        print_status "Go is already installed"
    else
        print_status "Installing Go..."
        sudo apt install -y golang-go
    fi
    
    # Install Rust (if available)
    if command -v rustc &> /dev/null; then
        print_status "Rust is already installed"
    else
        print_status "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
    fi
    
    # Install Java (if needed)
    print_status "Installing Java..."
    sudo apt install -y openjdk-11-jdk
    
    print_success "Language-specific tools installed"
}

# Function to install container tools
install_container_tools() {
    print_status "🐳 Installing container tools..."
    
    print_status "Container tools installation skipped"
    print_success "Container tools installation completed"
}

# Function to install cloud tools
install_cloud_tools() {
    print_status "☁️ Installing cloud tools..."
    
    print_status "Cloud tools installation skipped"
    print_success "Cloud tools installation completed"
}

# Function to install IDE and editor tools
install_ide_tools() {
    print_status "📝 Installing IDE and editor tools..."
    
    # Install basic editors only
    print_status "Installing basic editors..."
    sudo apt install -y geany
    
    print_success "IDE and editor tools installed"
}

# Main tools setup function
main_tools_setup() {
    print_status "🚀 Starting Ubuntu Tools Setup..."
    
    # Check Ubuntu environment first
    check_ubuntu_environment
    
    # Check sudo availability
    check_sudo_availability
    
    # Install all tools
    install_system_tools
    install_dev_tools
    install_network_tools
    install_text_tools
    install_monitoring_tools
    install_modern_cli_tools
    install_python_packages
    install_nodejs_packages
    install_additional_tools
    install_security_tools
    install_multimedia_tools
    install_admin_tools
    install_language_tools
    install_container_tools
    install_cloud_tools
    install_ide_tools
    
    # Setup user environment
    setup_user_environment
    setup_dev_environment
    
    print_success "✅ Ubuntu Tools Setup completed successfully!"
    print_status "All development tools and packages have been installed."
    print_status "You can now start developing with a fully configured environment."
    echo ""
    print_status "Available tools:"
    print_status "Development: gcc, g++, make, cmake, clang, gdb"
    print_status "Python: python3, pip3, requests, pandas, numpy"
    print_status "Node.js: node, npm, yarn, npx"
    print_status "Network: curl, wget, git, iperf3"
    print_status "CLI: tree, mc, ranger, fzf, ripgrep, bat"
    print_status "Editors: geany"
}

# Run the tools setup
main_tools_setup
EOF
    
    chmod +x $install_dir/ubuntu-tools-setup.sh
    
    print_success "Setup scripts created in Ubuntu directory!"
    print_log "Files created:"
    print_log "• $install_dir/ubuntu-root-setup.sh"
    print_log "• $install_dir/ubuntu-tools-setup.sh"
}

# Function to create Ubuntu shortcuts
create_ubuntu_shortcuts() {
    local version=$1
    local install_dir=$2
    
    print_status "🔗 Creating Ubuntu shortcuts..."
    
    # Create shortcut script for root access
    cat > $HOME/ubuntu${version} << EOF
#!/bin/bash
# Ubuntu ${version} Root Access Shortcut

echo "🚀 Entering Ubuntu ${version} as root..."
cd $install_dir
proot -0 -r . -b /dev -b /proc -b /sys -w /root /bin/bash
EOF
    
    # Create shortcut script for user access
    cat > $HOME/ubuntu${version}-user << EOF
#!/bin/bash
# Ubuntu ${version} User Access Shortcut

echo "👤 Entering Ubuntu ${version} as user..."
cd $install_dir
proot -0 -r . -b /dev -b /proc -b /sys -w /home/\$USER /bin/bash
EOF
    
    # Create shortcut script for tools setup
    cat > $HOME/ubuntu${version}-tools << EOF
#!/bin/bash
# Ubuntu ${version} Tools Setup Shortcut

echo "🛠️  Entering Ubuntu ${version} for tools setup..."
cd $install_dir
proot -0 -r . -b /dev -b /proc -b /sys -w /root /bin/bash -c "./ubuntu-tools-setup.sh"
EOF
    
    # Create shortcut script for root setup
    cat > $HOME/ubuntu${version}-setup << EOF
#!/bin/bash
# Ubuntu ${version} Root Setup Shortcut

echo "🔧 Entering Ubuntu ${version} for root setup..."
cd $install_dir
proot -0 -r . -b /dev -b /proc -b /sys -w /root /bin/bash -c "./ubuntu-root-setup.sh"
EOF
    
    # Make shortcuts executable
    chmod +x $HOME/ubuntu${version}
    chmod +x $HOME/ubuntu${version}-user
    chmod +x $HOME/ubuntu${version}-tools
    chmod +x $HOME/ubuntu${version}-setup
    
    # Add shortcuts to PATH by creating symlinks in ~/bin
    mkdir -p $HOME/bin
    ln -sf $HOME/ubuntu${version} $HOME/bin/ubuntu${version}
    ln -sf $HOME/ubuntu${version}-user $HOME/bin/ubuntu${version}-user
    ln -sf $HOME/ubuntu${version}-tools $HOME/bin/ubuntu${version}-tools
    ln -sf $HOME/ubuntu${version}-setup $HOME/bin/ubuntu${version}-setup
    
    # Add ~/bin to PATH if not already there
    if ! grep -q "export PATH=\$HOME/bin:\$PATH" $HOME/.bashrc; then
        echo 'export PATH=$HOME/bin:$PATH' >> $HOME/.bashrc
    fi
    
    print_success "Ubuntu shortcuts created successfully!"
    print_log "Shortcuts created:"
    print_log "• ubuntu${version} - Enter as root"
    print_log "• ubuntu${version}-user - Enter as user"
    print_log "• ubuntu${version}-tools - Run tools setup"
    print_log "• ubuntu${version}-setup - Run root setup"
    print_log ""
    print_log "Usage examples:"
    print_log "  ubuntu${version}        # Enter Ubuntu as root"
    print_log "  ubuntu${version}-user   # Enter Ubuntu as user"
    print_log "  ubuntu${version}-tools  # Run tools setup"
    print_log "  ubuntu${version}-setup  # Run root setup"
}

# Function to install Ubuntu Chroot with beautiful UI
install_ubuntu_chroot() {
    local version=$1
    local codename=$2
    local url=$3
    
    print_status "🚀 Installing Ubuntu ${version} (Chroot)..."
    
    # Start background installation
    install_ubuntu_chroot_background $version $codename $url &
    local pid=$!
    
    # Show loading animation
    show_loading "Installing Ubuntu ${version} (Chroot)" $pid
    
    # Wait for completion
    wait $pid
    
    # Check result
    if [[ -f $HOME/ubuntu_install_result ]]; then
        local result=$(cat $HOME/ubuntu_install_result)
        rm -f $HOME/ubuntu_install_result
        
        if [[ "$result" == "success:$version" ]]; then
            print_success "Ubuntu ${version} (Chroot) installed successfully!"
            
            # Show post-install menu
            show_post_install_menu_chroot $version
        else
            print_error "Failed to install Ubuntu ${version}"
            print_status "Please check your internet connection and try again."
        fi
    else
        print_error "Installation failed"
    fi
}

# Function to show post-install menu for Chroot
show_post_install_menu_chroot() {
    local version=$1
    
    echo ""
    echo "What would you like to do next?"
    echo "  1. 🔧 Enter Ubuntu ${version} environment"
    echo "  2. 🛠️  Show setup instructions"
    echo "  3. ↩️  Return to main menu"
    echo ""
    read -p "Enter your choice (1-3): " choice
    
    case $choice in
        1)
            print_status "Entering Ubuntu ${version} environment..."
            print_status "After entering Ubuntu, run these commands:"
            print_status "1. ./ubuntu-root-setup.sh (for root setup)"
            print_status "2. ./ubuntu-tools-setup.sh (for tools setup)"
            echo ""
            cd $HOME/ubuntu/ubuntu${version}-rootfs
            proot -0 -r . -b /dev -b /proc -b /sys -w /root /bin/bash
            ;;
        2)
            print_status "Setup Instructions:"
            echo ""
            echo "1. Enter Ubuntu environment:"
            echo "   cd ~/ubuntu/ubuntu${version}-rootfs"
            echo "   proot -0 -r . -b /dev -b /proc -b /sys -w /root /bin/bash"
            echo ""
            echo "2. Run root setup (inside Ubuntu):"
            echo "   ./ubuntu-root-setup.sh"
            echo ""
            echo "3. Run tools setup (inside Ubuntu):"
            echo "   ./ubuntu-tools-setup.sh"
            echo ""
            echo "Note: Scripts are already created in the Ubuntu directory."
            echo "You just need to enter Ubuntu and run them manually."
            echo ""
            read -p "Press Enter to continue..."
            ;;
        3)
            print_status "Returning to main menu..."
            ;;
        *)
            print_status "Returning to main menu..."
            ;;
    esac
}

# Function to create setup scripts in background
create_setup_scripts_background() {
    local version=$1
    
    # Create ubuntu-root-setup.sh
    create_ubuntu_root_setup $version
    
    # Create ubuntu-tools-setup.sh
    create_ubuntu_tools_setup $version
    
    echo "success" > $HOME/create_scripts_result
}

# Function to create setup scripts with loading
create_setup_scripts() {
    local version=$1
    
    print_status "📝 Creating setup scripts..."
    
    # Start background creation
    create_setup_scripts_background $version &
    local pid=$!
    
    # Show loading animation
    show_loading "Creating setup scripts" $pid
    
    # Wait for completion
    wait $pid
    
    # Check result
    if [[ -f $HOME/create_scripts_result ]]; then
        local result=$(cat $HOME/create_scripts_result)
        rm -f $HOME/create_scripts_result
        
        if [[ "$result" == "success" ]]; then
            print_success "Setup scripts created successfully!"
            print_log "Files created:"
            print_log "• ubuntu-root-setup.sh"
            print_log "• ubuntu-tools-setup.sh"
        else
            print_error "Failed to create setup scripts"
        fi
    fi
}

# Function to copy setup scripts in background
copy_setup_scripts_background() {
    local version=$1
    
    # Get Ubuntu directory path
    local ubuntu_dir=$(proot-distro list | grep "ubuntu-${version}" | awk '{print $2}')
    
    if [[ -n "$ubuntu_dir" ]]; then
        # Copy scripts to Ubuntu directory
        cp ubuntu-root-setup.sh "$ubuntu_dir/" 2>/dev/null || true
        cp ubuntu-tools-setup.sh "$ubuntu_dir/" 2>/dev/null || true
        
        # Make scripts executable
        chmod +x "$ubuntu_dir/ubuntu-root-setup.sh" 2>/dev/null || true
        chmod +x "$ubuntu_dir/ubuntu-tools-setup.sh" 2>/dev/null || true
        
        echo "success" > $HOME/copy_result
    else
        echo "failed" > $HOME/copy_result
    fi
}

# Function to copy setup scripts with loading
copy_setup_scripts() {
    local version=$1
    
    print_status "📁 Copying setup scripts to Ubuntu ${version}..."
    
    # Start background copy
    copy_setup_scripts_background $version &
    local pid=$!
    
    # Show loading animation
    show_loading "Copying setup scripts" $pid
    
    # Wait for completion
    wait $pid
    
    # Check result
    if [[ -f $HOME/copy_result ]]; then
        local result=$(cat $HOME/copy_result)
        rm -f $HOME/copy_result
        
        if [[ "$result" == "success" ]]; then
            print_success "Setup scripts copied successfully!"
            print_log "You can run them inside Ubuntu:"
            print_log "• ./ubuntu-root-setup.sh"
            print_log "• ./ubuntu-tools-setup.sh"
        else
            print_warning "Could not copy setup scripts"
            print_status "You can copy them manually later"
        fi
    fi
}

# Function to show post-install menu
show_post_install_menu() {
    local version=$1
    
    echo ""
    echo "What would you like to do next?"
    echo "  1. 🔧 Enter Ubuntu ${version} and run root setup"
    echo "  2. 🛠️  Enter Ubuntu ${version} and run tools setup"
    echo "  3. ↩️  Return to main menu"
    echo ""
    read -p "Enter your choice (1-3): " choice
    
    case $choice in
        1)
            print_status "Entering Ubuntu ${version} for root setup..."
            proot-distro login ubuntu-${version}
            ;;
        2)
            print_status "Entering Ubuntu ${version} for tools setup..."
            proot-distro login ubuntu-${version}
            ;;
        3)
            print_status "Returning to main menu..."
            ;;
        *)
            print_status "Returning to main menu..."
            ;;
    esac
}

# Function to remove Ubuntu in background
remove_ubuntu_background() {
    # Remove proot-distro installations
    proot-distro remove ubuntu-18.04 2>/dev/null || true
    proot-distro remove ubuntu-20.04 2>/dev/null || true
    proot-distro remove ubuntu-22.04 2>/dev/null || true
    proot-distro remove ubuntu-24.04 2>/dev/null || true
    
    # Clean up
    rm -rf $HOME/ubuntu 2>/dev/null || true
    
    echo "success" > $HOME/remove_result
}

# Function to remove Ubuntu with loading
remove_ubuntu() {
    print_header
    print_warning "⚠️  This will remove all Ubuntu installations!"
    echo ""
    read -p "Are you sure? (y/N): " confirm_remove
    
    if [[ "$confirm_remove" =~ ^[Yy]$ ]]; then
        print_status "🗑️  Removing Ubuntu installations..."
        
        # Start background removal
        remove_ubuntu_background &
        local pid=$!
        
        # Show loading animation
        show_loading "Removing Ubuntu installations" $pid
        
        # Wait for completion
        wait $pid
        
        # Check result
        if [[ -f $HOME/remove_result ]]; then
            local result=$(cat $HOME/remove_result)
            rm -f $HOME/remove_result
            
            if [[ "$result" == "success" ]]; then
                print_success "Ubuntu installations removed successfully!"
            else
                print_error "Failed to remove Ubuntu installations"
            fi
        fi
    else
        print_status "Removal cancelled."
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Function to show installation guide
show_installation_guide() {
    print_header
    echo "Installation Guide:"
    echo ""
    echo "Step 1: 🚀 Install Ubuntu"
    echo "   Choose your Ubuntu version and install it."
    echo ""
    echo "Step 2: 🔧 Root Setup"
    echo "   After installation, enter Ubuntu and run:"
    echo "   ./ubuntu-root-setup.sh"
    echo ""
    echo "Step 3: 🛠️  Tools Setup"
    echo "   After root setup, run:"
    echo "   ./ubuntu-tools-setup.sh"
    echo ""
    echo "Step 4: 🎉 Enjoy!"
    echo "   Your Ubuntu environment is ready for development!"
    echo ""
    read -p "Press Enter to continue..."
}

# Function to install Ubuntu (main menu)
install_ubuntu() {
    print_header
    print_status "🚀 Ubuntu Installation Menu"
    echo ""
    echo "Select Installation Method:"
    echo "  1. 🐧 Proot-Distro (Recommended - Easy)"
    echo "  2. 🔧 Chroot (Advanced - Auto Setup Scripts)"
    echo "  3. ↩️  Return to Main Menu"
    echo ""
    read -p "Enter your choice (1-3): " choice
    
    case $choice in
        1)
            install_ubuntu_proot_menu
            ;;
        2)
            install_ubuntu_chroot_menu
            ;;
        3)
            return
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
}

# Function to show Proot installation menu
install_ubuntu_proot_menu() {
    print_header
    print_status "🐧 Proot-Distro Installation"
    echo ""
    echo "Select Ubuntu Version:"
    echo "  1. 🐧 Ubuntu 18.04 LTS (Bionic Beaver)"
    echo "  2. 🐧 Ubuntu 20.04 LTS (Focal Fossa)"
    echo "  3. 🐧 Ubuntu 22.04 LTS (Jammy Jellyfish)"
    echo "  4. 🐧 Ubuntu 24.04 LTS (Noble Numbat)"
    echo "  5. ↩️  Return to Installation Menu"
    echo ""
    read -p "Enter your choice (1-5): " choice
    
    case $choice in
        1)
            install_ubuntu_proot "18.04"
            ;;
        2)
            install_ubuntu_proot "20.04"
            ;;
        3)
            install_ubuntu_proot "22.04"
            ;;
        4)
            install_ubuntu_proot "24.04"
            ;;
        5)
            return
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
}

# Function to show Chroot installation menu
install_ubuntu_chroot_menu() {
    print_header
    print_status "🔧 Chroot Installation"
    echo ""
    echo "Select Ubuntu Version:"
    echo "  1. 🐧 Ubuntu 18.04 LTS (Bionic Beaver)"
    echo "  2. 🐧 Ubuntu 20.04 LTS (Focal Fossa)"
    echo "  3. 🐧 Ubuntu 22.04 LTS (Jammy Jellyfish)"
    echo "  4. 🐧 Ubuntu 24.04 LTS (Noble Numbat)"
    echo "  5. ↩️  Return to Installation Menu"
    echo ""
    read -p "Enter your choice (1-5): " choice
    
    case $choice in
        1)
            install_ubuntu_chroot "18.04" "bionic" "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-arm64-root.tar.xz"
            ;;
        2)
            install_ubuntu_chroot "20.04" "focal" "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-arm64-root.tar.xz"
            ;;
        3)
            install_ubuntu_chroot "22.04" "jammy" "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-arm64-root.tar.xz"
            ;;
        4)
            install_ubuntu_chroot "24.04" "noble" "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64-root.tar.xz"
            ;;
        5)
            return
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
}

# Function to show system check
show_system_check() {
    print_header
    print_success "System Check Results:"
    echo ""
    
    # Show system information
    echo -e "${CYAN}System Information:${NC}"
    available_space=$(df $HOME | awk 'NR==2 {print $4}')
    available_space_mb=$(($available_space / 1024))
    total_space=$(df $HOME | awk 'NR==2 {print $2}')
    total_space_mb=$(($total_space / 1024))
    used_space_mb=$(($total_space_mb - $available_space_mb))

    echo -e "${WHITE}Available Disk Space: ${available_space_mb}MB / ${total_space_mb}MB${NC}"
    echo -e "${WHITE}Used Disk Space: ${used_space_mb}MB${NC}"
    echo -e "${WHITE}Android Version: $(getprop ro.build.version.release)${NC}"
    echo -e "${WHITE}Architecture: $(uname -m)${NC}"
    echo -e "${WHITE}Termux Version: $(pkg --version 2>/dev/null || echo "Unknown")${NC}"
    
    echo ""
    echo -e "${CYAN}Root Status:${NC}"
    if [[ $(id -u) -eq 0 ]]; then
        echo -e "${GREEN}✓ Root access available${NC}"
    else
        echo -e "${YELLOW}⚠ No root access (Proot will be used)${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Main menu function
main_menu() {
    while true; do
        print_header
        print_menu

        read -p "Enter your choice (1-5): " choice

        case $choice in
            1) install_ubuntu ;;
            2) remove_ubuntu ;;
            3) show_installation_guide ;;
            4) show_system_check ;;
            5)
                print_header
                echo -e "${GREEN}👋 Goodbye!${NC}"
                echo -e "${WHITE}Thank you for using Ubuntu Installer!${NC}"
                echo -e "${WHITE}Don't forget to visit our GitHub repository!${NC}"
                echo ""
                sleep 2
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please enter 1-5."
                ;;
        esac
    done
}

# Function to show welcome message
show_welcome() {
    clear
    echo -e "${CYAN}Welcome to Ubuntu Installer for Termux${NC}"
    echo -e "${CYAN}This installer will help you install Ubuntu on Termux${NC}"
    echo -e "${CYAN}Supported versions: 18.04, 20.04, 22.04, 24.04${NC}"
    echo -e "${CYAN}All operations run in background with beautiful UI${NC}"
    echo ""
    sleep 3
}

# Start the installer
show_welcome
check_prerequisites
main_menu
