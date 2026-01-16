#!/bin/bash

# AstroNvim Custom Config Installer
# This script backs up existing config and installs the custom AstroNvim configuration

set -e

GITHUB_REPO="ruskeyz/nvim-config"  # Update this with your GitHub username/repo
NVIM_CONFIG="$HOME/.config/nvim"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d_%H%M%S)"

echo "========================================"
echo "AstroNvim Custom Config Installer"
echo "========================================"
echo ""

# Check if Neovim is installed
if ! command -v nvim &> /dev/null; then
    echo "Error: Neovim is not installed. Please install Neovim first."
    echo "Visit: https://github.com/neovim/neovim/releases"
    exit 1
fi

# Check Neovim version
NVIM_VERSION=$(nvim --version | head -n1 | grep -oP 'v\K[0-9]+\.[0-9]+')
REQUIRED_VERSION="0.9"
if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$NVIM_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "Warning: Neovim version $NVIM_VERSION may not be compatible. Required: >= $REQUIRED_VERSION"
fi

echo "Detected Neovim version: $NVIM_VERSION"
echo ""

# Backup existing configuration
if [ -d "$NVIM_CONFIG" ]; then
    echo "Backing up existing Neovim configuration..."
    mv "$NVIM_CONFIG" "${NVIM_CONFIG}${BACKUP_SUFFIX}"
    echo "Backup created at: ${NVIM_CONFIG}${BACKUP_SUFFIX}"
fi

# Backup Neovim data directories
for dir in "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
    if [ -d "$dir" ]; then
        echo "Backing up $dir..."
        mv "$dir" "${dir}${BACKUP_SUFFIX}"
    fi
done

echo ""
echo "Cloning configuration from GitHub..."
git clone "https://github.com/${GITHUB_REPO}.git" "$NVIM_CONFIG"

echo ""
echo "========================================"
echo "Installation complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Update your GitHub repository URL in install.sh"
echo "2. Run 'nvim' to start Neovim"
echo "3. Plugins will install automatically on first launch"
echo ""
echo "Your old config was backed up with suffix: $BACKUP_SUFFIX"
echo ""
