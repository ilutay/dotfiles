# Dotfiles

My dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── yabai/      → ~/.yabairc (window manager)
├── skhd/       → ~/.skhdrc (hotkey daemon)
├── nvim/       → ~/.config/nvim (editor)
├── kitty/      → ~/.config/kitty (terminal)
├── tmux/       → ~/.tmux.conf (terminal multiplexer)
└── zsh/        → ~/.zshrc, ~/.zprofile (shell)
```

## Installation

### Prerequisites

Install GNU Stow:

```bash
brew install stow
```

```bash
cd ~/personal/dotfiles
./install.sh
```

Or stow individual packages:

```bash
stow nvim    # Only nvim config
stow zsh     # Only zsh config
```

### Uninstalling

To remove symlinks for a package:

```bash
stow -D nvim
```

## Adding New Configs

1. Create a new directory: `mkdir newapp`
2. Mirror the home directory structure inside it
3. Move your config: `mv ~/.newapprc newapp/.newapprc`
4. Stow it: `stow newapp`
