# AstroNvim Custom Configuration

**NOTE:** This is for AstroNvim v5+

Personal [AstroNvim](https://github.com/AstroNvim/AstroNvim) configuration with custom Gruvbox theme and transparency settings.

## Features

### Custom Theme & Transparency
- **Transparent UI elements**: WinBar, tabs, folds, and fold column
- **Orange current line number** (`#fe8019`) with transparent background
- **Custom selection highlights**:
  - NeoTree: `#504945` background with cream text
  - Telescope: `#504945` background with orange caret
- **Tab styling**: Transparent inactive tabs, highlighted active tab

### Custom Keybindings
- `J` (visual): Move selected line down (VSCode-style)
- `K` (visual): Move selected line up (VSCode-style)
- `B` (normal): Move to beginning of line
- `E` (normal): Move to end of line

### Plugins
- AstroNvim core plugins
- Aerial.nvim for code navigation
- Custom LSP and formatting configurations

## Prerequisites

- Neovim >= 0.9.5
- Git
- A [Nerd Font](https://www.nerdfonts.com/) (for icons)
- C compiler (for Treesitter)
- ripgrep (for Telescope search)
- lazygit (optional, for git integration)

## 🛠️ Installation

### Backup existing configuration

```shell
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

### Clone this repository

```shell
git clone https://github.com/<your_user>/<your_repository> ~/.config/nvim
```

### Start Neovim

```shell
nvim
```

AstroNvim will automatically install all plugins on first launch.

## 📁 Structure

```
~/.config/nvim/
├── init.lua                    # Bootstrap configuration
├── lua/
│   ├── lazy_setup.lua         # Lazy.nvim setup
│   ├── polish.lua             # Custom highlights & keybindings
│   ├── community.lua          # Community plugins
│   └── plugins/
│       ├── astrocore.lua      # Core settings
│       ├── astroui.lua        # UI configuration
│       ├── astrolsp.lua       # LSP settings
│       ├── mason.lua          # LSP installer config
│       ├── none-ls.lua        # Formatter/linter config
│       ├── treesitter.lua     # Syntax highlighting
│       └── user.lua           # User plugins (disabled by default)
└── lazy-lock.json             # Plugin version lock file
```

## 🎨 Customization

All custom highlights are defined in `lua/polish.lua`. This includes:
- Transparency settings for UI elements
- Selection colors
- Tab styling
- Line number colors

To modify colors, edit the hex values in `lua/polish.lua`:
- `#504945` - Selection/active background
- `#ebdbb2` - Cream foreground text
- `#fe8019` - Orange accent (Gruvbox orange)

## 🔄 Syncing Across Machines

### Push changes from current machine
```bash
cd ~/.config/nvim
git add .
git commit -m "Your change description"
git push
```

### Pull changes on other machines
```bash
cd ~/.config/nvim
git pull
```

Plugin updates will sync automatically via `lazy-lock.json`.

## 📚 Resources

- [AstroNvim Documentation](https://docs.astronvim.com/)
- [Lazy.nvim Plugin Manager](https://github.com/folke/lazy.nvim)
- [Gruvbox Theme](https://github.com/morhetz/gruvbox)
