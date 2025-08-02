#!/bin/bash

# Script 2: User Setup and System Configuration inside Ubuntu (proot)
# This script is meant to be run inside the Ubuntu proot environment

set -e

echo "=== User Setup and System Configuration ==="
echo ""

# Prompt for username
read -p "Enter your desired username: " username

# Prompt for password (hidden input)
while true; do
    read -s -p "Enter password for $username: " password
    echo
    read -s -p "Confirm password: " password_confirm
    echo
    
    if [ "$password" = "$password_confirm" ]; then
        echo "Passwords match. Continuing with setup..."
        break
    else
        echo "Passwords do not match. Please try again."
    fi
done

echo "=== Configuring Ubuntu System ==="

# Update package lists
echo "Updating package lists..."
apt update
apt upgrade -y

# Install essential packages
echo "Installing essential packages..."
apt install -y \
    sudo \
    wget \
    curl \
    git 

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
useradd -m -s /bin/bash -G sudo "$username"
echo "$username:$password" | chpasswd

# Configure sudo with password for user
echo "Configuring sudo access..."
echo "$username ALL=(ALL) ALL" >> /etc/sudoers

# Create user directories
echo "Setting up user directories..."
mkdir -p "/home/$username/"{Desktop,Documents,Downloads,Pictures,Videos,Music}
mkdir -p "/home/$username/.config"
mkdir -p "/home/$username/.local/share"

# Set proper ownership
chown -R "$username:$username" "/home/$username"

# Configure bash for user
echo "Configuring bash environment..."
cat >> "/home/$username/.bashrc" << 'BASHRC_EOF'

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
