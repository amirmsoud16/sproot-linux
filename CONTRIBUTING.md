# Contributing to Ubuntu Manager for Termux

Thank you for your interest in contributing to Ubuntu Manager for Termux! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Bugs
- Use the GitHub issue tracker
- Include detailed steps to reproduce the bug
- Provide your device information (Android version, Termux version)
- Include error messages and logs

### Suggesting Features
- Open a new issue with the "enhancement" label
- Describe the feature and its benefits
- Consider implementation complexity

### Code Contributions
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 🛠️ Development Setup

### Prerequisites
- Android device with Termux
- Git knowledge
- Bash scripting experience

### Local Development
```bash
# Clone your fork
git clone https://github.com/yourusername/ubuntu-manager-termux.git
cd ubuntu-manager-termux

# Test the script
./ubuntu_manager.sh
```

## 📝 Code Style Guidelines

### Bash Scripting
- Use `#!/bin/bash` shebang
- Follow shellcheck recommendations
- Add comments for complex logic
- Use meaningful variable names
- Handle errors gracefully

### Documentation
- Update README.md for new features
- Add inline comments for complex functions
- Keep help text clear and concise

## 🧪 Testing

### Test Cases
- Installation on fresh Termux
- Uninstallation process
- Status checking
- Menu navigation
- Error handling

### Test Environment
- Test on different Android versions
- Test with different Termux versions
- Verify VNC functionality
- Check file permissions

## 📋 Pull Request Guidelines

### Before Submitting
- [ ] Code follows style guidelines
- [ ] Tests pass on your device
- [ ] Documentation is updated
- [ ] No sensitive information included

### PR Description
- Describe the changes made
- Link related issues
- Include test results
- Mention any breaking changes

## 🏷️ Issue Labels

- `bug` - Something isn't working
- `enhancement` - New feature request
- `documentation` - Documentation improvements
- `help wanted` - Extra attention needed
- `good first issue` - Good for newcomers

## 📞 Getting Help

- Check existing issues and discussions
- Join our community discussions
- Ask questions in issues

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Ubuntu Manager for Termux! 🚀 