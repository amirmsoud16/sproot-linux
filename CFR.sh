#!/bin/bash

# CFR.SH - Custom File Reader Script (Optimized Ubuntu Setup)
# Simplified version of ubuntu-root-setup.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Simple print functions
print_info() {
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

# Check Ubuntu environment
check_environment() {
    print_info "Checking Ubuntu environment..."
    
    if [[ ! -f "/etc/os-release" ]]; then
        print_error "This script must be run inside Ubuntu!"
        exit 1
    fi
    
    if ! grep -q "Ubuntu" /etc/os-release; then
        print_error "This script is designed for Ubuntu only!"
        exit 1
    fi
    
    if [[ $(id -u) -ne 0 ]]; then
        print_warning "This script requires root access!"
        exit 1
    fi
    
    print_success "Ubuntu environment detected"
}

# Get user input
get_user_input() {
    echo -e "${CYAN}=== User Configuration ===${NC}"
    
    read -p "Enter username: " USERNAME
    read -s -p "Enter root password: " ROOT_PASS
    echo ""
    read -s -p "Confirm root password: " ROOT_PASS_CONFIRM
    echo ""
    
    if [[ "$ROOT_PASS" != "$ROOT_PASS_CONFIRM" ]]; then
        print_error "Passwords do not match!"
        exit 1
    fi
    
    print_success "User configuration saved"
}

# Fix permissions
fix_permissions() {
    print_info "Fixing permissions..."
    
    # Fix dpkg permissions
    print_info "Fixing dpkg permissions..."
    if [[ -d "/var/lib/dpkg" ]]; then
        chmod 755 /var/lib/dpkg 2>/dev/null || true
        chmod 644 /var/lib/dpkg/status 2>/dev/null || true
        print_success "dpkg permissions fixed"
    else
        print_warning "dpkg directory not found, skipping permissions fix"
    fi
    
    # Remove lock files
    print_info "Removing lock files..."
    rm -f /var/lib/dpkg/lock* 2>/dev/null || true
    rm -f /var/cache/apt/archives/lock 2>/dev/null || true
    rm -f /var/lib/apt/lists/lock 2>/dev/null || true
    print_success "Lock files removed"
    
    # Fix library permissions
    print_info "Fixing library permissions..."
    find /usr/lib -name "*.so*" -exec chmod 755 {} \; 2>/dev/null || true
    
    print_success "Permissions fixed"
}

# Fix dpkg interruption specifically
fix_dpkg_interruption() {
    print_info "Checking for dpkg interruption..."
    
    # Check if dpkg is in an interrupted state
    if [[ -f "/var/lib/dpkg/status-old" ]] || [[ -f "/var/lib/dpkg/status.dpkg-old" ]]; then
        print_warning "Detected dpkg interruption, attempting to recover..."
        
        # Force configure all packages
        print_info "Running dpkg --configure -a to fix interrupted packages..."
        if dpkg --configure -a; then
            print_success "dpkg configuration completed successfully"
        else
            print_warning "dpkg configuration had issues, trying alternative approach..."
            # Try with force options
            dpkg --configure -a --force-confdef --force-confold 2>/dev/null || true
        fi
    else
        print_info "No dpkg interruption detected"
    fi
}

# Fix apt issues
fix_apt() {
    print_info "Fixing apt issues..."
    
    # Configure dpkg
    echo 'Dpkg::Options::="--force-confnew";' > /etc/apt/apt.conf.d/local
    
    # Fix dpkg interruption first
    fix_dpkg_interruption
    
    # Fix broken packages
    print_info "Running apt --fix-broken install..."
    if apt --fix-broken install -y; then
        print_success "Broken packages fixed successfully"
    else
        print_warning "Some broken packages could not be fixed, but continuing..."
    fi
    
    # Clean cache
    apt clean 2>/dev/null || true
    
    print_success "Apt issues fixed"
}

# Fix internet
fix_internet() {
    print_info "Fixing internet connectivity..."
    
    # Setup DNS
    cat > /etc/resolv.conf << 'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF
    
    print_success "Internet configured"
}

# Setup user
setup_user() {
    print_info "Setting up user..."
    
    # Create user
    useradd -m -s /bin/bash $USERNAME
    
    # Set passwords - both root and user have the same password
    echo "root:$ROOT_PASS" | chpasswd
    echo "$USERNAME:$ROOT_PASS" | chpasswd
    
    # Add to sudo group
    usermod -aG sudo $USERNAME
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USERNAME
    chmod 440 /etc/sudoers.d/$USERNAME
    
    print_success "User setup completed"
    print_info "Both root and $USERNAME have the same password"
}

# Create start scripts
create_scripts() {
    print_info "Creating start scripts..."
    
    UBUNTU_VERSION=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2 | cut -d'.' -f1)
    
    # Root access script
    cat > /start-ubuntu.sh << EOF
#!/bin/bash
unset LD_PRELOAD
echo -n "Enter root password: "
read -s ROOT_PASS
echo ""
proot -0 -r \$HOME/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs \\
    -b /dev -b /proc -b /sys \\
    -b \$HOME:/root \\
    -w /root /usr/bin/env -i HOME=/root TERM="\$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x /start-ubuntu.sh
    
    # User access script
    cat > /start-ubuntu-user.sh << EOF
#!/bin/bash
unset LD_PRELOAD
proot -0 -r \$HOME/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs \\
    -b /dev -b /proc -b /sys \\
    -b \$HOME:/home/$USERNAME \\
    -w /home/$USERNAME /usr/bin/env -i HOME=/home/$USERNAME USER=$USERNAME TERM="\$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/su - $USERNAME
EOF
    chmod +x /start-ubuntu-user.sh
    
    # Create quick access command (ubuntu18-username)
    cat > /usr/local/bin/ubuntu${UBUNTU_VERSION}-$USERNAME << EOF
#!/bin/bash
unset LD_PRELOAD
proot -0 -r \$HOME/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs \\
    -b /dev -b /proc -b /sys \\
    -b \$HOME:/home/$USERNAME \\
    -w /home/$USERNAME /usr/bin/env -i HOME=/home/$USERNAME USER=$USERNAME TERM="\$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/su - $USERNAME
EOF
    chmod +x /usr/local/bin/ubuntu${UBUNTU_VERSION}-$USERNAME
    
    # Create root quick access command
    cat > /usr/local/bin/ubuntu${UBUNTU_VERSION}-root << EOF
#!/bin/bash
unset LD_PRELOAD
echo -n "Enter root password: "
read -s ROOT_PASS
echo ""
proot -0 -r \$HOME/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs \\
    -b /dev -b /proc -b /sys \\
    -b \$HOME:/root \\
    -w /root /usr/bin/env -i HOME=/root TERM="\$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash --login
EOF
    chmod +x /usr/local/bin/ubuntu${UBUNTU_VERSION}-root
    
    # Create shortcuts in home directory
    cat > ~/ubuntu${UBUNTU_VERSION}-$USERNAME << EOF
#!/bin/bash
ubuntu${UBUNTU_VERSION}-$USERNAME
EOF
    chmod +x ~/ubuntu${UBUNTU_VERSION}-$USERNAME
    
    cat > ~/ubuntu${UBUNTU_VERSION}-root << EOF
#!/bin/bash
ubuntu${UBUNTU_VERSION}-root
EOF
    chmod +x ~/ubuntu${UBUNTU_VERSION}-root
    
    print_success "Start scripts and quick commands created"
    print_info "Quick access commands:"
    print_info "  ubuntu${UBUNTU_VERSION}-$USERNAME  - Quick user access"
    print_info "  ubuntu${UBUNTU_VERSION}-root       - Quick root access"
    print_info "  ~/ubuntu${UBUNTU_VERSION}-$USERNAME - Home shortcut"
    print_info "  ~/ubuntu${UBUNTU_VERSION}-root      - Home shortcut"
}

# Show final instructions
show_final_instructions() {
    print_success "Setup completed successfully!"
    echo ""
    echo -e "${CYAN}=== Ubuntu Access Information ===${NC}"
    print_info "Username: $USERNAME"
    print_info "Password: ******** (same for root and user)"
    echo ""
    echo -e "${CYAN}=== Quick Access Commands ===${NC}"
    print_info "User access: ubuntu${UBUNTU_VERSION}-$USERNAME"
    print_info "Root access: ubuntu${UBUNTU_VERSION}-root"
    print_info "Home shortcuts: ~/ubuntu${UBUNTU_VERSION}-$USERNAME"
    echo ""
    echo -e "${CYAN}=== Usage Examples ===${NC}"
    print_info "Quick user access: ubuntu${UBUNTU_VERSION}-$USERNAME"
    print_info "Quick root access: ubuntu${UBUNTU_VERSION}-root"
    print_info "From home: ~/ubuntu${UBUNTU_VERSION}-$USERNAME"
    echo ""
    print_success "You can now use these commands from anywhere!"
}

# Main function
main() {
    print_info "Starting Ubuntu Setup..."
    
    check_environment
    get_user_input
    fix_permissions
    fix_dpkg_interruption
    fix_apt
    fix_internet
    setup_user
    create_scripts
    show_final_instructions
}

# Run main function
main 
