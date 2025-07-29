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