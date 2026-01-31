# Dotfiles

![Neovim, Kitty, Yabai vs VS Code](readme_logo.png)

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

Zsh theme = starship + gruvbox preset

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

## Updating Changes

Since Stow creates symlinks, edits to files in this repo are automatically reflected in your home directory.

**For shell configs (zsh):**

```bash
source ~/.zshrc
```

**For apps that need restart:**

- **kitty**: Close and reopen terminal
- **yabai**: `yabai --restart-service`
- **skhd**: `skhd --restart-service`
- **nvim**: Reopen Neovim

**If you added new files to an existing package:**

```bash
stow -R zsh  # Re-stow to pick up new files
```

## Worktree Manager

The `w()` function in `.zshrc` provides a multi-project git worktree manager with automatic dev environment setup.

### Directory Structure

```
~/personal/
├── my-app/              (main git repo)
├── another-project/     (main git repo)
└── worktrees/
    ├── my-app/
    │   ├── feature-x/   (worktree)
    │   └── bugfix-y/    (worktree)
    └── another-project/
        └── new-feature/ (worktree)
```

### Commands

| Command | Description |
|---------|-------------|
| `w <project> <worktree>` | Create or cd to worktree |
| `w <project> <worktree> <cmd>` | Run command in worktree |
| `w --list` | List all worktrees |
| `w --rm <project> <worktree>` | Remove worktree |
| `w --sync <project> <worktree>` | Sync npm deps if package.json differs |

### Examples

```bash
w myapp feature-x              # cd to worktree (creates if needed)
w myapp feature-x claude       # run claude in worktree
w myapp feature-x npm test     # run tests in worktree
w --list                       # show all worktrees
w --rm myapp feature-x         # delete worktree
```

### Automatic Setup (on new worktree)

When creating a new worktree, `w` automatically:

**Node.js** (if `package.json` exists):
- Runs `npm install` in main repo if `node_modules` missing
- Symlinks `node_modules` from main repo to worktree

**Python** (if `pyproject.toml` or `requirements.txt` exists):
- Creates `.venv` with `uv venv`
- Installs deps with `uv sync` or `uv pip install`
- Activates the venv

**Environment**:
- Copies `.env` from main repo if it exists

### Dependencies

- `uv` - Python package manager ([install](https://docs.astral.sh/uv/getting-started/installation/))
- `npm` - Node.js package manager
- `git` - For worktree operations
