#!/bin/bash

# Script 2: User Setup and System Configuration using proot-distro

set -e

echo "=== User Setup and System Configuration ==="
echo ""

# Check if Ubuntu is installed
if ! proot-distro list | grep -q "ubuntu.*installed"; then
    echo "Error: Ubuntu not installed. Please run 01_setup_termux.sh first"
    exit 1
fi

echo "Configuring Ubuntu system..."

# Configure Ubuntu system using proot-distro
echo "Running system configuration in Ubuntu..."

proot-distro login ubuntu -- bash -c '
set -e

echo "=== Configuring Ubuntu System ==="

# Update package lists
echo "Updating package lists..."
apt update

# Install essential packages
echo "Installing essential packages..."
apt install -y \
    sudo \
    wget \
    curl \
    git \
    nano \
    vim \
    htop \
    neofetch \
    locales \
    tzdata \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https

# Configure locales
echo "Configuring locales..."
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# Set timezone
echo "Setting timezone..."
ln -sf /usr/share/zoneinfo/Asia/Tehran /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

# Create user account
echo "Creating user account..."
useradd -m -s /bin/bash -G sudo user
echo "user:user123" | chpasswd

# Configure sudo with password for user
echo "Configuring sudo access..."
echo "user ALL=(ALL) ALL" >> /etc/sudoers

# Create user directories
echo "Setting up user directories..."
mkdir -p /home/user/{Desktop,Documents,Downloads,Pictures,Videos,Music}
mkdir -p /home/user/.config
mkdir -p /home/user/.local/share

# Set proper ownership
chown -R user:user /home/user

# Configure bash for user
echo "Configuring bash environment..."
cat >> /home/user/.bashrc << 'BASHRC_EOF'

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Custom prompt
PS1='\[\033[01;32m\]\u@ubuntu\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Welcome message
echo "Welcome to Ubuntu on Termux!"
neofetch
BASHRC_EOF

# Configure root bash
cat >> /root/.bashrc << 'ROOT_BASHRC_EOF'

# Root aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Root prompt
PS1='\[\033[01;31m\]\u@ubuntu\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\# '
ROOT_BASHRC_EOF

# Install Python and development tools
echo "Installing Python and development tools..."
apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    git

# Install Node.js
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt install -y nodejs

# Clean package cache
echo "Cleaning package cache..."
apt autoremove -y
apt autoclean

echo ""
echo "=== System Configuration Complete! ==="
echo ""
echo "User 'user' created with password 'user123'"
echo "User has sudo access (password required)"
'



echo ""
echo "=== User Setup Complete! ==="
echo ""
echo "Available commands:"
echo "  proot-distro login ubuntu           - Login as root"
echo "  proot-distro login ubuntu --user user - Login as user"
echo ""
echo "User credentials:"
echo "  Username: user"
echo "  Password: user123"

# Create/Update shortcuts after user setup
echo "Creating Ubuntu shortcuts..."

# Create ubuntu shortcut (root login)
cat > $PREFIX/bin/ubuntu << 'EOF'
#!/bin/bash
proot-distro login ubuntu
EOF

chmod +x $PREFIX/bin/ubuntu

# Create ubuntu-user shortcut (user login)
cat > $PREFIX/bin/ubuntu-user << 'EOF'
#!/bin/bash
proot-distro login ubuntu --user user
EOF

chmod +x $PREFIX/bin/ubuntu-user

echo "Shortcuts created successfully!"
echo ""
echo "You can now enter Ubuntu with these commands:"
echo "  ubuntu       # Login as root"
echo "  ubuntu-user  # Login as user (recommended)"
echo ""
echo "Next step: Run 03_install_desktop.sh to install desktop environment"
