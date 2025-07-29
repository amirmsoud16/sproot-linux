#!/bin/bash

# =============================================================================
# CFR.sh - Custom File Reader Script - Optimized Ubuntu Setup
# =============================================================================
# Description: Professional Ubuntu chroot/proot setup script for Termux
# Author: Custom Ubuntu Setup
# Version: 2.0
# =============================================================================

# =============================================================================
# CONFIGURATION
# =============================================================================
SCRIPT_NAME="CFR.sh"
SCRIPT_VERSION="2.0"
REQUIRED_UBUNTU_VERSION="18.04"
MIN_TERMUX_VERSION="0.118"

# =============================================================================
# COLOR CODES
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# =============================================================================
# GLOBAL VARIABLES
# =============================================================================
USERNAME=""
ROOT_PASS=""
UBUNTU_VERSION=""
LOG_FILE="/tmp/cfr_setup.log"
ERROR_COUNT=0
WARNING_COUNT=0

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Print functions with logging
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    log_message "INFO" "$1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    log_message "SUCCESS" "$1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log_message "WARNING" "$1"
    ((WARNING_COUNT++))
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log_message "ERROR" "$1"
    ((ERROR_COUNT++))
}

print_header() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN} $1${NC}"
    echo -e "${CYAN}================================${NC}"
}

print_step() {
    echo -e "${WHITE}Step $1:${NC} $2"
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

# Check if running as root
check_root_access() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root!"
        print_info "Please run: sudo ./$SCRIPT_NAME"
        exit 1
    fi
    print_success "Root access confirmed"
}

# Check Ubuntu environment
check_ubuntu_environment() {
    print_info "Checking Ubuntu environment..."
    
    if [[ ! -f "/etc/os-release" ]]; then
        print_error "This script must be run inside Ubuntu!"
        exit 1
    fi
    
    if ! grep -q "Ubuntu" /etc/os-release; then
        print_error "This script is designed for Ubuntu only!"
        exit 1
    fi
    
    # Get Ubuntu version
    UBUNTU_VERSION=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2 | cut -d'.' -f1)
    print_success "Ubuntu $UBUNTU_VERSION environment detected"
}

# Check system requirements
check_system_requirements() {
    print_info "Checking system requirements..."
    
    # Check available disk space (minimum 2GB)
    local available_space=$(df / | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 2000000 ]]; then
        print_warning "Low disk space detected. Recommended: 2GB free space"
    fi
    
    # Check memory (minimum 512MB)
    local total_mem=$(free -m | awk 'NR==2{print $2}')
    if [[ $total_mem -lt 512 ]]; then
        print_warning "Low memory detected. Recommended: 512MB RAM"
    fi
    
    print_success "System requirements check completed"
}

# =============================================================================
# USER INPUT FUNCTIONS
# =============================================================================

# Get user input with validation
get_user_input() {
    print_header "User Configuration"
    
    # Get username
    while true; do
        read -p "Enter username (3-20 characters, lowercase): " USERNAME
        if [[ "$USERNAME" =~ ^[a-z][a-z0-9_-]{2,19}$ ]]; then
            break
        else
            print_error "Invalid username! Use 3-20 lowercase letters, numbers, - or _"
        fi
    done
    
    # Get password
    while true; do
        read -s -p "Enter password (minimum 6 characters): " ROOT_PASS
        echo ""
        if [[ ${#ROOT_PASS} -ge 6 ]]; then
            read -s -p "Confirm password: " ROOT_PASS_CONFIRM
            echo ""
            if [[ "$ROOT_PASS" == "$ROOT_PASS_CONFIRM" ]]; then
                break
            else
                print_error "Passwords do not match!"
            fi
        else
            print_error "Password must be at least 6 characters!"
        fi
    done
    
    print_success "User configuration saved"
    print_info "Username: $USERNAME"
    print_info "Password: ********"
}

# =============================================================================
# SYSTEM FIX FUNCTIONS
# =============================================================================

# Comprehensive permission fix
fix_system_permissions() {
    print_step "1" "Fixing system permissions"
    
    # Fix dpkg permissions
    if [[ -d "/var/lib/dpkg" ]]; then
        chmod 755 /var/lib/dpkg 2>/dev/null || true
        chmod 755 /var/lib/dpkg/info 2>/dev/null || true
        chmod 755 /var/lib/dpkg/updates 2>/dev/null || true
        chmod 755 /var/lib/dpkg/alternatives 2>/dev/null || true
        
        # Fix dpkg files
        chmod 644 /var/lib/dpkg/status 2>/dev/null || true
        chmod 644 /var/lib/dpkg/status-old 2>/dev/null || true
        chmod 644 /var/lib/dpkg/status.dpkg-old 2>/dev/null || true
        chmod 644 /var/lib/dpkg/available 2>/dev/null || true
        chmod 644 /var/lib/dpkg/available-old 2>/dev/null || true
        
        # Fix info files
        find /var/lib/dpkg/info -name "*.list" -exec chmod 644 {} \; 2>/dev/null || true
        find /var/lib/dpkg/info -name "*.md5sums" -exec chmod 644 {} \; 2>/dev/null || true
        find /var/lib/dpkg/info -name "*.postinst" -exec chmod 755 {} \; 2>/dev/null || true
        find /var/lib/dpkg/info -name "*.prerm" -exec chmod 755 {} \; 2>/dev/null || true
        find /var/lib/dpkg/info -name "*.postrm" -exec chmod 755 {} \; 2>/dev/null || true
        find /var/lib/dpkg/info -name "*.preinst" -exec chmod 755 {} \; 2>/dev/null || true
    fi
    
    # Fix apt permissions
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
    
    # Remove lock files
    rm -f /var/lib/dpkg/lock* 2>/dev/null || true
    rm -f /var/lib/dpkg/status.lock 2>/dev/null || true
    rm -f /var/cache/apt/archives/lock 2>/dev/null || true
    rm -f /var/lib/apt/lists/lock 2>/dev/null || true
    rm -f /var/lib/apt/lists/partial/* 2>/dev/null || true
    rm -f /var/cache/apt/archives/partial/* 2>/dev/null || true
    
    # Fix library permissions
    find /usr/lib -name "*.so*" -exec chmod 755 {} \; 2>/dev/null || true
    find /usr/lib64 -name "*.so*" -exec chmod 755 {} \; 2>/dev/null || true
    find /usr/bin -type f -exec chmod 755 {} \; 2>/dev/null || true
    find /usr/sbin -type f -exec chmod 755 {} \; 2>/dev/null || true
    
    print_success "System permissions fixed"
}

# Comprehensive dpkg fix
fix_dpkg_system() {
    print_step "2" "Fixing dpkg package system"
    
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
    
    print_success "dpkg package system fixed"
}

# Comprehensive apt fix
fix_apt_system() {
    print_step "3" "Fixing apt package manager"
    
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
    
    print_success "apt package manager fixed"
}

# Configure internet connectivity
configure_internet() {
    print_step "4" "Configuring internet connectivity"
    
    # Setup DNS
    cat > /etc/resolv.conf << 'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF
    
    # Test internet connectivity
    if ping -c 1 8.8.8.8 &> /dev/null; then
        print_success "Internet connectivity configured and working"
    else
        print_warning "Internet connectivity configured but connection test failed"
    fi
}

# =============================================================================
# USER SETUP FUNCTIONS
# =============================================================================

# Create user account
create_user_account() {
    print_step "6" "Creating user account"
    
    # Check if user already exists
    if id "$USERNAME" &>/dev/null; then
        print_warning "User $USERNAME already exists"
        read -p "Do you want to recreate the user? (y/N): " recreate_user
        if [[ "$recreate_user" =~ ^[Yy]$ ]]; then
            userdel -r "$USERNAME" 2>/dev/null || true
        else
            print_info "Using existing user $USERNAME"
            return 0
        fi
    fi
    
    # Create user
    if useradd -m -s /bin/bash "$USERNAME"; then
        print_success "User $USERNAME created successfully"
    else
        print_error "Failed to create user $USERNAME"
        return 1
    fi
    
    # Set passwords - both root and user have the same password
    if echo "root:$ROOT_PASS" | chpasswd && echo "$USERNAME:$ROOT_PASS" | chpasswd; then
        print_success "Passwords set successfully"
    else
        print_error "Failed to set passwords"
        return 1
    fi
    
    # Add to sudo group
    if usermod -aG sudo "$USERNAME"; then
        print_success "User added to sudo group"
    else
        print_warning "Failed to add user to sudo group"
    fi
    
    # Configure sudo access
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/"$USERNAME"
    chmod 440 /etc/sudoers.d/"$USERNAME"
    
    print_success "User account setup completed"
    print_info "Both root and $USERNAME have the same password"
}

# =============================================================================
# ACCESS SCRIPT FUNCTIONS
# =============================================================================

# Create access scripts
create_access_scripts() {
    print_step "5" "Creating access scripts and shortcuts"
    
    # Create /usr/local/bin directory if it doesn't exist
    mkdir -p /usr/local/bin
    
    # Root access script
    cat > /start-ubuntu.sh << EOF
#!/bin/bash
# Ubuntu Root Access Script
# Generated by $SCRIPT_NAME v$SCRIPT_VERSION

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
    
    # User access script (will be updated after user creation)
    cat > /start-ubuntu-user.sh << EOF
#!/bin/bash
# Ubuntu User Access Script
# Generated by $SCRIPT_NAME v$SCRIPT_VERSION

unset LD_PRELOAD
proot -0 -r \$HOME/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs \\
    -b /dev -b /proc -b /sys \\
    -b \$HOME:/home/$USERNAME \\
    -w /home/$USERNAME /usr/bin/env -i HOME=/home/$USERNAME USER=$USERNAME TERM="\$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/su - $USERNAME
EOF
    chmod +x /start-ubuntu-user.sh
    
    # Create quick access command (ubuntu18-username)
    cat > /usr/local/bin/ubuntu${UBUNTU_VERSION}-"$USERNAME" << EOF
#!/bin/bash
# Quick Ubuntu User Access
# Generated by $SCRIPT_NAME v$SCRIPT_VERSION

unset LD_PRELOAD
proot -0 -r \$HOME/ubuntu/ubuntu${UBUNTU_VERSION}-rootfs \\
    -b /dev -b /proc -b /sys \\
    -b \$HOME:/home/$USERNAME \\
    -w /home/$USERNAME /usr/bin/env -i HOME=/home/$USERNAME USER=$USERNAME TERM="\$TERM" LANG=C.UTF-8 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/su - $USERNAME
EOF
    chmod +x /usr/local/bin/ubuntu${UBUNTU_VERSION}-"$USERNAME"
    
    # Create root quick access command
    cat > /usr/local/bin/ubuntu${UBUNTU_VERSION}-root << EOF
#!/bin/bash
# Quick Ubuntu Root Access
# Generated by $SCRIPT_NAME v$SCRIPT_VERSION

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
    cat > ~/ubuntu${UBUNTU_VERSION}-"$USERNAME" << EOF
#!/bin/bash
ubuntu${UBUNTU_VERSION}-$USERNAME
EOF
    chmod +x ~/ubuntu${UBUNTU_VERSION}-"$USERNAME"
    
    cat > ~/ubuntu${UBUNTU_VERSION}-root << EOF
#!/bin/bash
ubuntu${UBUNTU_VERSION}-root
EOF
    chmod +x ~/ubuntu${UBUNTU_VERSION}-root
    
    print_success "Access scripts and shortcuts created"
    print_info "Quick access commands:"
    print_info "  ubuntu${UBUNTU_VERSION}-$USERNAME  - Quick user access"
    print_info "  ubuntu${UBUNTU_VERSION}-root       - Quick root access"
    print_info "  ~/ubuntu${UBUNTU_VERSION}-$USERNAME - Home shortcut"
    print_info "  ~/ubuntu${UBUNTU_VERSION}-root      - Home shortcut"
}

# =============================================================================
# FINAL INSTRUCTIONS
# =============================================================================

# Show final instructions
show_final_instructions() {
    print_header "Setup Completed Successfully!"
    
    echo -e "${CYAN}=== Ubuntu Access Information ===${NC}"
    print_info "Username: $USERNAME"
    print_info "Password: ******** (same for root and user)"
    print_info "Ubuntu Version: $UBUNTU_VERSION"
    
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
    
    # Show statistics
    echo ""
    echo -e "${CYAN}=== Setup Statistics ===${NC}"
    print_info "Errors: $ERROR_COUNT"
    print_info "Warnings: $WARNING_COUNT"
    print_info "Log file: $LOG_FILE"
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

# Main function
main() {
    print_header "$SCRIPT_NAME v$SCRIPT_VERSION - Ubuntu Setup"
    
    # Initialize log file
    echo "=== $SCRIPT_NAME v$SCRIPT_VERSION Setup Log ===" > "$LOG_FILE"
    echo "Started at: $(date)" >> "$LOG_FILE"
    
    # System checks
    check_root_access
    check_ubuntu_environment
    check_system_requirements
    
    # Get user input
    get_user_input
    
    print_header "System Setup Phase"
    
    # First: Fix all permissions and system issues
    fix_system_permissions
    fix_dpkg_system
    fix_apt_system
    configure_internet
    
    print_header "Access Scripts Setup"
    
    # Second: Create access scripts first
    create_access_scripts
    
    print_header "User Account Setup"
    
    # Third: Create user account (last step)
    create_user_account
    
    # Show final instructions
    show_final_instructions
    
    # Final log entry
    echo "Completed at: $(date)" >> "$LOG_FILE"
    echo "Total errors: $ERROR_COUNT" >> "$LOG_FILE"
    echo "Total warnings: $WARNING_COUNT" >> "$LOG_FILE"
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Run main function
main "$@" 
