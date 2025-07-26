# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Ubuntu Chroot Installer
- Real chroot environment support (not proot)
- XFCE4 desktop environment installation
- KDE Plasma desktop environment installation
- Command-line only installation option
- SSH service setup and configuration
- Hardware acceleration with virglrenderer
- One-click startup with Termux Widget
- Interactive menu system
- Professional colored output
- Automatic system configuration
- User account creation and management
- Locale setup (English and Persian)
- Timezone configuration
- DNS resolution setup
- Package management and updates
- Complete uninstall functionality
- Status checking and reporting
- Comprehensive error handling
- Hardware requirement checking
- Snapd disabling for better compatibility
- Firefox ESR installation
- Additional software packages (gedit, gimp, vlc)
- Development tools (vim, git, sudo)

### Features
- **Real Chroot**: Full root access and maximum performance
- **Multiple Desktops**: XFCE4 (lightweight) and KDE (full-featured)
- **Hardware Support**: virglrenderer for OpenGL acceleration
- **Remote Access**: SSH service for remote management
- **Easy Startup**: Termux Widget integration
- **Complete Management**: Install, uninstall, and status checking
- **Professional UI**: Colored output and interactive menus
- **Automatic Setup**: DNS, users, locales, and system configuration

### Technical Details
- Based on Ubuntu 24.04.2 (Noble Numbat)
- ARM64 architecture support
- Compatible with Android 8.0+
- Requires 6GB+ RAM (4GB minimum)
- Requires 10GB+ storage
- Root access mandatory

### Security
- Default credentials: root/ubuntu123, user/ubuntu123
- SSH service with configurable access
- Proper file permissions and ownership
- Snapd disabled for better compatibility

### Documentation
- Comprehensive README with installation guide
- Troubleshooting section
- Performance optimization tips
- Security recommendations 