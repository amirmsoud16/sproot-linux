#!/bin/bash

# CFR.SH - Custom File Reader Script (Optimized Ubuntu Setup)
# Simplified version of ubuntu-root-setup.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
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

# Loading animation function
show_loading() {
    local message="$1"
    local pid=$2
    
    echo -e "${YELLOW}Processing...${NC}"
    echo -e "${WHITE}$message${NC}"
    echo ""
    
    # Loading animation with spinner
    local i=0
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spin:$i:1}
        echo -ne "${YELLOW}Please wait... ${temp}${NC}\r"
        i=$(( (i+1) % ${#spin} ))
        sleep 0.1
    done
    
    echo -e "${GREEN}✓ Operation completed!${NC}"
    echo ""
}

# Background operation function
run_in_background() {
    local operation_function="$1"
    local message="$2"
    
    # Show loading animation
    echo -e "${YELLOW}Processing...${NC}"
    echo -e "${WHITE}$message${NC}"
    echo ""
    
    # Loading animation with spinner
    local i=0
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    # Run operation in foreground but show loading
    $operation_function &
    local pid=$!
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spin:$i:1}
        echo -ne "${YELLOW}Please wait... ${temp}${NC}\r"
        i=$(( (i+1) % ${#spin} ))
        sleep 0.1
    done
    
    echo -e "${GREEN}✓ Operation completed!${NC}"
    echo ""
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

# Fix permissions (background version)
fix_permissions() {
    # Complete system permissions fix
    
    # Fix dpkg permissions completely
    if [[ -d "/var/lib/dpkg" ]]; then
        # Directory permissions
        chmod 755 /var/lib/dpkg 2>/dev/null || true
        chmod 755 /var/lib/dpkg/info 2>/dev/null || true
        chmod 755 /var/lib/dpkg/updates 2>/dev/null || true
        chmod 755 /var/lib/dpkg/alternatives 2>/dev/null || true
        
        # File permissions
        chmod 644 /var/lib/dpkg/status 2>/dev/null || true
        chmod 644 /var/lib/dpkg/status-old 2>/dev/null || true
        chmod 644 /var/lib/dpkg/status.dpkg-old 2>/dev/null || true
        chmod 644 /var/lib/dpkg/available 2>/dev/null || true
        chmod 644 /var/lib/dpkg/available-old 2>/dev/null || true
        
        # Fix all info files permissions
        find /var/lib/dpkg/info -name "*.list" -exec chmod 644 {} \; 2>/dev/null || true
        find /var/lib/dpkg/info -name "*.md5sums" -exec chmod 644 {} \; 2>/dev/null || true
        find /var/lib/dpkg/info -name "*.postinst" -exec chmod 755 {} \; 2>/dev/null || true
        find /var/lib/dpkg/info -name "*.prerm" -exec chmod 755 {} \; 2>/dev/null || true
        find /var/lib/dpkg/info -name "*.postrm" -exec chmod 755 {} \; 2>/dev/null || true
        find /var/lib/dpkg/info -name "*.preinst" -exec chmod 755 {} \; 2>/dev/null || true
    fi
    
    # Fix apt permissions completely
    if [[ -d "/var/lib/apt" ]]; then
        chmod 755 /var/lib/apt 2>/dev/null || true
        chmod 755 /var/lib/apt/lists 2>/dev/null || true
        chmod 755 /var/lib/apt/lists/partial 2>/dev/null || true
        chmod 644 /var/lib/apt/lists/* 2>/dev/null || true
    fi
    
    if [[ -d "/var/cache/apt" ]]; then
        chmod 755 /var/cache/apt 2>/dev/null || true
        chmod 755 /var/cache/apt/archives 2>/dev/null || true
        chmod 755 /var/cache/apt/archives/partial 2>/dev/null || true
    fi
    
    # Fix etc permissions
    if [[ -d "/etc/apt" ]]; then
        chmod 755 /etc/apt 2>/dev/null || true
        chmod 644 /etc/apt/sources.list 2>/dev/null || true
        chmod 644 /etc/apt/sources.list.d/* 2>/dev/null || true
        chmod 644 /etc/apt/apt.conf.d/* 2>/dev/null || true
    fi
    
    # Remove ALL possible lock files
    rm -f /var/lib/dpkg/lock* 2>/dev/null || true
    rm -f /var/lib/dpkg/status.lock 2>/dev/null || true
    rm -f /var/cache/apt/archives/lock 2>/dev/null || true
    rm -f /var/lib/apt/lists/lock 2>/dev/null || true
    rm -f /var/lib/apt/lists/partial/* 2>/dev/null || true
    rm -f /var/cache/apt/archives/partial/* 2>/dev/null || true
    
    # Fix library permissions
    find /usr/lib -name "*.so*" -exec chmod 755 {} \; 2>/dev/null || true
    find /usr/lib64 -name "*.so*" -exec chmod 755 {} \; 2>/dev/null || true
    
    # Fix bin permissions
    find /usr/bin -type f -exec chmod 755 {} \; 2>/dev/null || true
    find /usr/sbin -type f -exec chmod 755 {} \; 2>/dev/null || true
}

# Fix permissions with loading
fix_permissions_with_loading() {
    print_info "Fixing permissions..."
    run_in_background "fix_permissions" "Fixing system permissions and lock files..."
    print_success "Permissions fixed"
}

# Fix dpkg interruption (background version)
fix_dpkg_interruption() {
    # Complete dpkg directory permissions fix
    if [[ -d "/var/lib/dpkg" ]]; then
        # Fix directory permissions
        chmod 755 /var/lib/dpkg 2>/dev/null || true
        chmod 755 /var/lib/dpkg/info 2>/dev/null || true
        chmod 755 /var/lib/dpkg/updates 2>/dev/null || true
        chmod 755 /var/lib/dpkg/alternatives 2>/dev/null || true
        
        # Fix file permissions
        chmod 644 /var/lib/dpkg/status 2>/dev/null || true
        chmod 644 /var/lib/dpkg/status-old 2>/dev/null || true
        chmod 644 /var/lib/dpkg/status.dpkg-old 2>/dev/null || true
        chmod 644 /var/lib/dpkg/available 2>/dev/null || true
        chmod 644 /var/lib/dpkg/available-old 2>/dev/null || true
        
        # Fix all info files
        find /var/lib/dpkg/info -name "*.list" -exec chmod 644 {} \; 2>/dev/null || true
        find /var/lib/dpkg/info -name "*.md5sums" -exec chmod 644 {} \; 2>/dev/null || true
        find /var/lib/dpkg/info -name "*.postinst" -exec chmod 755 {} \; 2>/dev/null || true
        find /var/lib/dpkg/info -name "*.prerm" -exec chmod 755 {} \; 2>/dev/null || true
        find /var/lib/dpkg/info -name "*.postrm" -exec chmod 755 {} \; 2>/dev/null || true
        find /var/lib/dpkg/info -name "*.preinst" -exec chmod 755 {} \; 2>/dev/null || true
    fi
    
    # Remove ALL lock files and temporary files
    rm -f /var/lib/dpkg/lock* 2>/dev/null || true
    rm -f /var/lib/dpkg/status.lock 2>/dev/null || true
    rm -f /var/lib/dpkg/status.dpkg-new 2>/dev/null || true
    rm -f /var/lib/dpkg/status.dpkg-old 2>/dev/null || true
    rm -f /var/lib/dpkg/available.dpkg-new 2>/dev/null || true
    rm -f /var/lib/dpkg/available.dpkg-old 2>/dev/null || true
    rm -f /var/cache/apt/archives/lock 2>/dev/null || true
    rm -f /var/lib/apt/lists/lock 2>/dev/null || true
    rm -f /var/lib/apt/lists/partial/* 2>/dev/null || true
    
    # Force dpkg to be in a clean state
    dpkg --audit 2>/dev/null || true
    
    # Check if dpkg is in an interrupted state and fix it
    if [[ -f "/var/lib/dpkg/status-old" ]] || [[ -f "/var/lib/dpkg/status.dpkg-old" ]]; then
        # Restore status file if needed
        if [[ -f "/var/lib/dpkg/status-old" ]]; then
            cp /var/lib/dpkg/status-old /var/lib/dpkg/status 2>/dev/null || true
        fi
        
        # Force configure all packages with multiple attempts
        for attempt in 1 2 3; do
            if dpkg --configure -a --force-confdef --force-confold; then
                break
            else
                # Additional force options
                dpkg --configure -a --force-confdef --force-confold --force-depends 2>/dev/null || true
                sleep 2
            fi
        done
    else
        # Even if no interruption, run configure to ensure clean state
        dpkg --configure -a --force-confdef --force-confold 2>/dev/null || true
    fi
    
    # Final cleanup and verification
    dpkg --audit 2>/dev/null || true
    dpkg --configure -a 2>/dev/null || true
}

# Fix dpkg interruption with loading
fix_dpkg_interruption_with_loading() {
    print_info "Checking for dpkg interruption..."
    run_in_background "fix_dpkg_interruption" "Checking and fixing dpkg interruption..."
    print_success "dpkg interruption check completed"
}

# Fix apt issues (background version)
fix_apt() {
    # Configure dpkg with comprehensive options
    cat > /etc/apt/apt.conf.d/local << 'EOF'
Dpkg::Options::="--force-confnew";
Dpkg::Options::="--force-confdef";
Dpkg::Options::="--force-confold";
Dpkg::Options::="--force-depends";
APT::Get::AllowUnauthenticated "true";
APT::Get::AllowDowngrades "true";
APT::Get::Fix-Broken "true";
EOF
    
    # Fix dpkg interruption first
    fix_dpkg_interruption
    
    # Update package lists with multiple attempts
    for attempt in 1 2 3; do
        if apt update -y; then
            break
        else
            # Force update with additional options
            apt update -y --allow-releaseinfo-change 2>/dev/null || true
            sleep 2
        fi
    done
    
    # Fix broken packages with multiple attempts
    for attempt in 1 2 3; do
        if apt --fix-broken install -y; then
            break
        else
            # Force install with additional options
            apt --fix-broken install -y --allow-downgrades --allow-remove-essential 2>/dev/null || true
            sleep 2
        fi
    done
    
    # Clean cache completely
    apt clean -y 2>/dev/null || true
    apt autoclean -y 2>/dev/null || true
    
    # Final verification
    dpkg --audit 2>/dev/null || true
    dpkg --configure -a 2>/dev/null || true
}

# Fix apt issues with loading
fix_apt_with_loading() {
    print_info "Fixing apt issues..."
    run_in_background "fix_apt" "Fixing apt and dpkg issues..."
    print_success "Apt issues fixed"
}

# Fix internet (background version)
fix_internet() {
    # Setup DNS
    cat > /etc/resolv.conf << 'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF
}

# Fix internet with loading
fix_internet_with_loading() {
    print_info "Fixing internet connectivity..."
    run_in_background "fix_internet" "Configuring DNS and internet settings..."
    print_success "Internet configured"
}

# Setup user (background version)
setup_user() {
    # Create user
    useradd -m -s /bin/bash $USERNAME
    
    # Set passwords - both root and user have the same password
    echo "root:$ROOT_PASS" | chpasswd
    echo "$USERNAME:$ROOT_PASS" | chpasswd
    
    # Add to sudo group
    usermod -aG sudo $USERNAME
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USERNAME
    chmod 440 /etc/sudoers.d/$USERNAME
}

# Setup user with loading
setup_user_with_loading() {
    print_info "Setting up user..."
    run_in_background "setup_user" "Creating user account and setting permissions..."
    print_success "User setup completed"
    print_info "Both root and $USERNAME have the same password"
}

# Create start scripts (background version)
create_scripts() {
    UBUNTU_VERSION=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2 | cut -d'.' -f1)
    
    # Create /usr/local/bin directory if it doesn't exist
    mkdir -p /usr/local/bin
    
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
}

# Create start scripts with loading
create_scripts_with_loading() {
    print_info "Creating start scripts..."
    run_in_background "create_scripts" "Creating access scripts and shortcuts..."
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
    echo -e "${YELLOW}=== Next Steps ===${NC}"
    print_info "1. Enter Ubuntu user: ubuntu${UBUNTU_VERSION}-$USERNAME"
    print_info "2. Install tools: ./CFU.sh"
    print_info "3. CFU.sh will install development tools and packages"
    echo ""
    print_success "You can now use these commands from anywhere!"
    echo ""
    print_info "💡 Tip: Run CFU.sh after entering Ubuntu to install development tools!"
}

# Main function
main() {
    print_info "Starting Ubuntu Setup..."
    
    check_environment
    get_user_input
    fix_permissions_with_loading
    fix_dpkg_interruption_with_loading
    fix_apt_with_loading
    fix_internet_with_loading
    setup_user_with_loading
    create_scripts_with_loading
    show_final_instructions
}

# Run main function
main 
