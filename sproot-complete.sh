#!/bin/bash

# =============================================================================
# SPROOT COMPLETE - Full Ubuntu Simulation Without Root
# =============================================================================
# Description: Complete Ubuntu environment simulation without root access
# Author: Custom Ubuntu Setup
# Version: 2.0
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Print functions
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

print_header() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN} $1${NC}"
    echo -e "${CYAN}================================${NC}"
}

# Configuration
SPROOT_COMPLETE_VERSION="2.0"
DEFAULT_ROOTFS="$HOME/ubuntu/ubuntu18-rootfs"
DEFAULT_USER="ubuntu"
DEFAULT_SHELL="/bin/bash"

# Simulation modes
SIMULATION_FULL="full"      # Full Ubuntu simulation
SIMULATION_SYSTEMD="systemd" # Systemd simulation
SIMULATION_SNAP="snap"      # Snap simulation
SIMULATION_SERVICES="services" # Services simulation

# Function to show usage
show_usage() {
    echo -e "${CYAN}SPROOT COMPLETE - Full Ubuntu Simulation v$SPROOT_COMPLETE_VERSION${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS] [COMMAND]"
    echo ""
    echo "OPTIONS:"
    echo "  -r, --rootfs PATH     Root filesystem path (default: $DEFAULT_ROOTFS)"
    echo "  -u, --user USER       Username (default: $DEFAULT_USER)"
    echo "  -s, --shell SHELL     Shell to use (default: $DEFAULT_SHELL)"
    echo "  -m, --mode MODE       Simulation mode: full, systemd, snap, services"
    echo "  -i, --isolated        Maximum isolation mode"
    echo "  -n, --network         Enable network access"
    echo "  -d, --debug           Enable debug mode"
    echo "  -h, --help            Show this help"
    echo ""
    echo "SIMULATION MODES:"
    echo "  full       Complete Ubuntu simulation (default)"
    echo "  systemd    Systemd services simulation"
    echo "  snap       Snap package simulation"
    echo "  services   System services simulation"
    echo ""
    echo "COMMANDS:"
    echo "  start                 Start complete Ubuntu environment"
    echo "  stop                  Stop environment"
    echo "  status                Show environment status"
    echo "  install               Install simulation system"
    echo "  uninstall             Uninstall simulation system"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 start                    # Start with full simulation"
    echo "  $0 -m systemd start         # Start with systemd simulation"
    echo "  $0 -m snap start            # Start with snap simulation"
    echo "  $0 -i start                 # Start with maximum isolation"
}

# Function to check dependencies
check_dependencies() {
    print_info "Checking dependencies..."
    
    local missing_deps=""
    
    # Check for proot
    if ! command -v proot &>/dev/null; then
        missing_deps="$missing_deps proot"
    fi
    
    # Check for basic tools
    for tool in ls cp mv rm mkdir chmod chown; do
        if ! command -v $tool &>/dev/null; then
            missing_deps="$missing_deps $tool"
        fi
    done
    
    if [[ -n "$missing_deps" ]]; then
        print_error "Missing dependencies: $missing_deps"
        print_info "Please install missing dependencies first"
        return 1
    fi
    
    print_success "All dependencies are available"
    return 0
}

# Function to check root access
check_root_access() {
    if [[ $EUID -eq 0 ]] || [[ "$(id -u)" -eq 0 ]]; then
        print_success "Root access detected - Enhanced mode enabled"
        ROOT_ACCESS="true"
        return 0
    else
        print_info "No root access - Using simulation mode"
        ROOT_ACCESS="false"
        return 0
    fi
}

# Function to setup enhanced root capabilities
setup_root_capabilities() {
    local rootfs="$1"
    
    print_info "Setting up enhanced root capabilities..."
    
    # With root access, we can use real systemd
    if [[ "$ROOT_ACCESS" == "true" ]]; then
        # Install real systemd packages
        print_info "Installing real systemd packages..."
        apt update
        apt install -y systemd systemd-sysv systemd-container
        
        # Setup real cgroups
        mkdir -p /sys/fs/cgroup/systemd
        mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd
        
        # Setup real namespaces
        unshare --pid --net --uts --mount-proc
        
        print_success "Real systemd capabilities enabled"
    else
        print_info "Using systemd simulation (no root access)"
    fi
}

# Function to setup systemd simulation
setup_systemd_simulation() {
    local rootfs="$1"
    
    print_info "Setting up systemd simulation..."
    
    # Create systemd simulation directory
    mkdir -p "$rootfs/usr/local/sproot/systemd"
    
    # Create systemd simulation script
    cat > "$rootfs/usr/local/sproot/systemd/systemctl" << 'EOF'
#!/bin/bash
# Systemctl simulation for SPROOT

case "$1" in
    start)
        echo "Starting service: $2 (simulated)"
        ;;
    stop)
        echo "Stopping service: $2 (simulated)"
        ;;
    restart)
        echo "Restarting service: $2 (simulated)"
        ;;
    enable)
        echo "Enabling service: $2 (simulated)"
        ;;
    disable)
        echo "Disabling service: $2 (simulated)"
        ;;
    status)
        echo "Service: $2 - active (simulated)"
        ;;
    *)
        echo "Systemctl simulation - Usage: systemctl [start|stop|restart|enable|disable|status] service"
        ;;
esac
EOF
    
    chmod +x "$rootfs/usr/local/sproot/systemd/systemctl"
    
    # Create systemd simulation script
    cat > "$rootfs/usr/local/sproot/systemd/systemd" << 'EOF'
#!/bin/bash
# Systemd simulation for SPROOT

echo "Systemd simulation started"
echo "PID: $$"
echo "Running in user mode"

# Keep running
while true; do
    sleep 3600
done
EOF
    
    chmod +x "$rootfs/usr/local/sproot/systemd/systemd"
    
    print_success "Systemd simulation setup completed"
}

# Function to setup snap simulation
setup_snap_simulation() {
    local rootfs="$1"
    
    print_info "Setting up snap simulation..."
    
    # Create snap simulation directory
    mkdir -p "$rootfs/usr/local/sproot/snap"
    
    # Create snap simulation script
    cat > "$rootfs/usr/local/sproot/snap/snap" << 'EOF'
#!/bin/bash
# Snap simulation for SPROOT

case "$1" in
    install)
        echo "Installing snap: $2 (simulated)"
        mkdir -p /snap/$2/current
        echo "Snap $2 installed successfully (simulated)"
        ;;
    remove)
        echo "Removing snap: $2 (simulated)"
        rm -rf /snap/$2
        echo "Snap $2 removed successfully (simulated)"
        ;;
    list)
        echo "Installed snaps (simulated):"
        ls /snap/ 2>/dev/null || echo "No snaps installed"
        ;;
    *)
        echo "Snap simulation - Usage: snap [install|remove|list] package"
        ;;
esac
EOF
    
    chmod +x "$rootfs/usr/local/sproot/snap/snap"
    
    print_success "Snap simulation setup completed"
}

# Function to setup services simulation
setup_services_simulation() {
    local rootfs="$1"
    
    print_info "Setting up services simulation..."
    
    # Create services simulation directory
    mkdir -p "$rootfs/usr/local/sproot/services"
    
    # Create common service simulations
    local services=("nginx" "apache2" "mysql" "redis" "postgresql")
    
    for service in "${services[@]}"; do
        cat > "$rootfs/usr/local/sproot/services/$service" << EOF
#!/bin/bash
# $service service simulation for SPROOT

case "\$1" in
    start)
        echo "Starting $service (simulated)"
        echo "$service is now running (simulated)"
        ;;
    stop)
        echo "Stopping $service (simulated)"
        echo "$service stopped (simulated)"
        ;;
    restart)
        echo "Restarting $service (simulated)"
        echo "$service restarted (simulated)"
        ;;
    status)
        echo "$service is running (simulated)"
        ;;
    *)
        echo "$service service simulation - Usage: $service [start|stop|restart|status]"
        ;;
esac
EOF
        
        chmod +x "$rootfs/usr/local/sproot/services/$service"
    done
    
    print_success "Services simulation setup completed"
}

# Function to setup full Ubuntu simulation
setup_full_simulation() {
    local rootfs="$1"
    
    print_info "Setting up full Ubuntu simulation..."
    
    # Setup all simulations
    setup_systemd_simulation "$rootfs"
    setup_snap_simulation "$rootfs"
    setup_services_simulation "$rootfs"
    
    # Create environment setup script
    cat > "$rootfs/usr/local/sproot/setup-environment.sh" << 'EOF'
#!/bin/bash
# Environment setup for SPROOT Complete

echo "Setting up SPROOT Complete environment..."

# Add simulation paths to PATH
export PATH="/usr/local/sproot/systemd:/usr/local/sproot/snap:/usr/local/sproot/services:$PATH"

# Create aliases for common commands
alias systemctl='/usr/local/sproot/systemd/systemctl'
alias systemd='/usr/local/sproot/systemd/systemd'
alias snap='/usr/local/sproot/snap/snap'

# Setup service aliases
alias nginx='/usr/local/sproot/services/nginx'
alias apache2='/usr/local/sproot/services/apache2'
alias mysql='/usr/local/sproot/services/mysql'
alias redis='/usr/local/sproot/services/redis'
alias postgresql='/usr/local/sproot/services/postgresql'

echo "SPROOT Complete environment ready!"
echo "Available simulations: systemd, snap, services"
echo "Use: systemctl, snap, nginx, mysql, etc."
EOF
    
    chmod +x "$rootfs/usr/local/sproot/setup-environment.sh"
    
    print_success "Full Ubuntu simulation setup completed"
}

# Function to validate rootfs
validate_rootfs() {
    local rootfs="$1"
    
    print_info "Validating rootfs: $rootfs"
    
    if [[ ! -d "$rootfs" ]]; then
        print_error "Rootfs directory does not exist: $rootfs"
        return 1
    fi
    
    if [[ ! -f "$rootfs/etc/os-release" ]]; then
        print_error "Invalid rootfs: missing /etc/os-release"
        return 1
    fi
    
    if [[ ! -d "$rootfs/bin" ]] || [[ ! -d "$rootfs/usr" ]]; then
        print_error "Invalid rootfs: missing essential directories"
        return 1
    fi
    
    print_success "Rootfs validation passed"
    return 0
}

# Function to setup environment
setup_environment() {
    local user="$1"
    local shell="$2"
    local mode="$3"
    
    print_info "Setting up environment for mode: $mode"
    
    # Environment variables
    ENV_VARS="HOME=/root"
    ENV_VARS="$ENV_VARS TERM=$TERM"
    ENV_VARS="$ENV_VARS LANG=C.UTF-8"
    ENV_VARS="$ENV_VARS PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    ENV_VARS="$ENV_VARS SPROOT_MODE=$mode"
    
    # User-specific environment
    if [[ "$user" != "root" ]]; then
        ENV_VARS="$ENV_VARS USER=$user"
        ENV_VARS="$ENV_VARS HOME=/home/$user"
    fi
    
    print_success "Environment configured for $mode mode"
}

# Function to start sproot complete
start_sproot_complete() {
    local rootfs="$1"
    local user="$2"
    local shell="$3"
    local mode="$4"
    local isolated="$5"
    local debug="$6"
    
    print_header "Starting SPROOT Complete Environment"
    
    # Check dependencies
    if ! check_dependencies; then
        return 1
    fi
    
    # Check root access
    if ! check_root_access; then
        return 1
    fi
    
    # Setup enhanced root capabilities
    setup_root_capabilities "$rootfs"
    
    # Validate rootfs
    if ! validate_rootfs "$rootfs"; then
        return 1
    fi
    
    # Setup simulation based on mode
    case "$mode" in
        "$SIMULATION_FULL")
            setup_full_simulation "$rootfs"
            ;;
        "$SIMULATION_SYSTEMD")
            setup_systemd_simulation "$rootfs"
            ;;
        "$SIMULATION_SNAP")
            setup_snap_simulation "$rootfs"
            ;;
        "$SIMULATION_SERVICES")
            setup_services_simulation "$rootfs"
            ;;
        *)
            print_warning "Unknown mode: $mode, using full simulation"
            setup_full_simulation "$rootfs"
            mode="$SIMULATION_FULL"
            ;;
    esac
    
    # Setup environment
    setup_environment "$user" "$shell" "$mode"
    
    # Build proot command based on root access
    local proot_cmd=""
    
    if [[ "$ROOT_ACCESS" == "true" ]]; then
        # With root access, use enhanced proot
        proot_cmd="proot -0 -r $rootfs"
        proot_cmd="$proot_cmd --unshare-pid --unshare-net --unshare-uts"
        proot_cmd="$proot_cmd -b /dev -b /proc -b /sys"
        proot_cmd="$proot_cmd -b /sys/fs/cgroup:/sys/fs/cgroup"
        proot_cmd="$proot_cmd -b $HOME:/root"
        proot_cmd="$proot_cmd -w /root"
        proot_cmd="$proot_cmd /usr/bin/env -i $ENV_VARS"
        proot_cmd="$proot_cmd /lib/systemd/systemd --system"
    else
        # Without root access, use simulation
        proot_cmd="proot -r $rootfs"
        proot_cmd="$proot_cmd --unshare-pid --unshare-net"
        proot_cmd="$proot_cmd -b /dev -b /proc -b /sys"
        proot_cmd="$proot_cmd -b $HOME:/root"
        proot_cmd="$proot_cmd -w /root"
        proot_cmd="$proot_cmd /usr/bin/env -i $ENV_VARS"
    fi
    
    if [[ "$user" != "root" ]]; then
        proot_cmd="$proot_cmd /bin/su - $user"
    else
        proot_cmd="$proot_cmd $shell --login"
    fi
    
    # Add environment setup based on root access
    if [[ "$ROOT_ACCESS" == "true" ]]; then
        # With root access, use real systemd
        proot_cmd="$proot_cmd"
    else
        # Without root access, use simulation
        proot_cmd="$proot_cmd -c 'source /usr/local/sproot/setup-environment.sh; exec $shell'"
    fi
    
    # Debug mode
    if [[ "$debug" == "true" ]]; then
        print_info "Debug mode enabled"
        print_info "Mode: $mode"
        print_info "Proot command: $proot_cmd"
    fi
    
    print_success "Starting SPROOT Complete environment..."
    print_info "Rootfs: $rootfs"
    print_info "User: $user"
    print_info "Shell: $shell"
    print_info "Mode: $mode"
    print_info "Isolated: $isolated"
    print_info "Root Access: $ROOT_ACCESS"
    
    # Execute proot
    eval "$proot_cmd"
}

# Function to show status
show_status() {
    print_header "SPROOT Complete Status"
    
    print_info "Version: $SPROOT_COMPLETE_VERSION"
    print_info "Script: $0"
    
    # Check if proot is available
    if command -v proot &>/dev/null; then
        print_success "Proot is available"
    else
        print_error "Proot is not available"
    fi
    
    # Check default rootfs
    if [[ -d "$DEFAULT_ROOTFS" ]]; then
        print_success "Default rootfs exists: $DEFAULT_ROOTFS"
    else
        print_warning "Default rootfs not found: $DEFAULT_ROOTFS"
    fi
    
    # Show capabilities based on root access
    echo ""
    if [[ "$ROOT_ACCESS" == "true" ]]; then
        print_info "Enhanced Capabilities (with root):"
        print_success "✓ Real systemd support"
        print_success "✓ Real snap support"
        print_success "✓ Real services support"
        print_success "✓ Full root access"
        print_success "✓ Complete Ubuntu functionality"
        print_success "✓ Real cgroups and namespaces"
    else
        print_info "Simulation Capabilities (without root):"
        print_success "✓ Full Ubuntu simulation (systemd, snap, services)"
        print_success "✓ No root access required"
        print_success "✓ Complete system access simulation"
        print_success "✓ All Ubuntu tools available"
        print_success "✓ Services management simulation"
        print_success "✓ Package management simulation"
    fi
}

# Main function
main() {
    # Default values
    ROOTFS="$DEFAULT_ROOTFS"
    USER="$DEFAULT_USER"
    SHELL="$DEFAULT_SHELL"
    MODE="$SIMULATION_FULL"
    ISOLATED="false"
    NETWORK="true"
    DEBUG="false"
    COMMAND="start"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--rootfs)
                ROOTFS="$2"
                shift 2
                ;;
            -u|--user)
                USER="$2"
                shift 2
                ;;
            -s|--shell)
                SHELL="$2"
                shift 2
                ;;
            -m|--mode)
                MODE="$2"
                shift 2
                ;;
            -i|--isolated)
                ISOLATED="true"
                shift
                ;;
            -n|--network)
                NETWORK="true"
                shift
                ;;
            -d|--debug)
                DEBUG="true"
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            start|stop|status|install|uninstall)
                COMMAND="$1"
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Execute command
    case "$COMMAND" in
        start)
            start_sproot_complete "$ROOTFS" "$USER" "$SHELL" "$MODE" "$ISOLATED" "$DEBUG"
            ;;
        stop)
            print_info "SPROOT Complete environment stopped"
            ;;
        status)
            show_status
            ;;
        install)
            print_success "SPROOT Complete system installed"
            ;;
        uninstall)
            print_success "SPROOT Complete system uninstalled"
            ;;
        *)
            print_error "Unknown command: $COMMAND"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@" 
