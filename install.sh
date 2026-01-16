#!/bin/bash
set -e

cd "$(dirname "$0")"

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "Error: GNU Stow is not installed. Install it with: brew install stow"
    exit 1
fi

# Stow all packages
for package in yabai skhd nvim kitty tmux zsh; do
    echo "Stowing $package..."
    stow -v -t ~ "$package"
done

echo "Done! All configs have been symlinked."
