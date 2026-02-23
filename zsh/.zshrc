#!/usr/bin/env zsh

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Multi-project worktree manager with Claude support
# 
# ASSUMPTIONS & SETUP:
# - Your git projects live in: ~/personal/
# - Worktrees will be created in: ~/personal/worktrees/<project>/<branch>
# - New branches will be named: <your-username>/<feature-name>
#
# DIRECTORY STRUCTURE EXAMPLE:
# ~/personal/
# ├── my-app/              (main git repo)
# ├── another-project/     (main git repo)
# └── worktrees/
#     ├── my-app/
#     │   ├── feature-x/   (worktree)
#     │   └── bugfix-y/    (worktree)
#     └── another-project/
#         └── new-feature/ (worktree)
#
# CUSTOMIZATION:
# To use different directories, modify these lines in the w() function:
#   local projects_dir="$HOME/personal"
#   local worktrees_dir="$HOME/personal/worktrees"
#
# INSTALLATION:
# 1. Add to your .zshrc (in this order):
#    fpath=(~/.zsh/completions $fpath)
#    autoload -U compinit && compinit
#
# 2. Copy this entire script to your .zshrc (after the lines above)
#
# 3. Restart your terminal or run: source ~/.zshrc
#
# 4. Test it works: w <TAB> should show your projects
#
# If tab completion doesn't work:
# - Make sure the fpath line comes BEFORE the w function in your .zshrc
# - Restart your terminal completely
#
# USAGE:
#   w <project> <worktree>              # cd to worktree (creates if needed)
#   w <project> <worktree> <command>    # run command in worktree
#   w --list                            # list all worktrees
#   w --rm <project> <worktree>         # remove worktree
#
# EXAMPLES:
#   w myapp feature-x                   # cd to feature-x worktree
#   w myapp feature-x claude            # run claude in worktree
#   w myapp feature-x gst               # git status in worktree
#   w myapp feature-x gcmsg "fix: bug"  # git commit in worktree

# Multi-project worktree manager
w() {
    local projects_dir="$HOME/personal"
    local worktrees_dir="$HOME/personal/worktrees"

    # Helper: Detect project type from main repo
    _w_detect_project_type() {
        local main_repo="$1"
        local -a types=()
        [[ -f "$main_repo/package.json" ]] && types+=("nodejs")
        [[ -f "$main_repo/pyproject.toml" || -f "$main_repo/requirements.txt" ]] && types+=("python")
        echo "${types[@]}"
    }

    # Helper: Setup Node.js environment
    _w_setup_nodejs() {
        local main_repo="$1"
        local wt_path="$2"

        echo "Setting up Node.js..."

        # Check if node_modules exists in main repo
        if [[ ! -d "$main_repo/node_modules" ]]; then
            echo "  Installing dependencies in main repo..."
            (cd "$main_repo" && npm install) || {
                echo "  Failed to install dependencies in main repo"
                return 1
            }
        fi

        # Create symlink in worktree
        echo "  Linking node_modules from main repo..."
        ln -s "$main_repo/node_modules" "$wt_path/node_modules"
    }

    # Helper: Setup Python environment
    _w_setup_python() {
        local main_repo="$1"
        local wt_path="$2"

        # Check if uv is installed
        if ! command -v uv &> /dev/null; then
            echo "Error: uv is not installed."
            echo "Install it with: curl -LsSf https://astral.sh/uv/install.sh | sh"
            return 1
        fi

        echo "Setting up Python..."

        # Deactivate any existing venv
        [[ -n "$VIRTUAL_ENV" ]] && deactivate

        # Create fresh venv with uv
        echo "  Creating virtual environment with uv..."
        uv venv "$wt_path/.venv" || {
            echo "  Failed to create virtual environment"
            return 1
        }

        # Install dependencies
        echo "  Installing Python dependencies..."
        (
            cd "$wt_path"
            source "$wt_path/.venv/bin/activate"
            if [[ -f "$wt_path/pyproject.toml" ]]; then
                uv sync
            elif [[ -f "$wt_path/requirements.txt" ]]; then
                uv pip install -r requirements.txt
            fi
        ) || {
            echo "  Failed to install Python dependencies"
            return 1
        }

        # Activate venv
        source "$wt_path/.venv/bin/activate"
        echo "  Activated venv: $wt_path/.venv"
    }

    # Helper: Copy .env file
    _w_setup_env() {
        local main_repo="$1"
        local wt_path="$2"

        if [[ -f "$main_repo/.env" ]]; then
            echo "Copying .env from main repo..."
            cp "$main_repo/.env" "$wt_path/.env"
        fi
    }

    # Helper: Full worktree setup
    _w_setup_worktree() {
        local main_repo="$1"
        local wt_path="$2"

        echo "Detecting project type..."
        local types=($(_w_detect_project_type "$main_repo"))

        if [[ ${#types[@]} -eq 0 ]]; then
            echo "  No package.json or pyproject.toml/requirements.txt found"
        else
            for type in "${types[@]}"; do
                case "$type" in
                    nodejs)
                        echo "  Found: package.json (Node.js)"
                        ;;
                    python)
                        if [[ -f "$main_repo/pyproject.toml" ]]; then
                            echo "  Found: pyproject.toml (Python)"
                        else
                            echo "  Found: requirements.txt (Python)"
                        fi
                        ;;
                esac
            done
        fi

        # Run setups
        for type in "${types[@]}"; do
            case "$type" in
                nodejs)
                    _w_setup_nodejs "$main_repo" "$wt_path"
                    ;;
                python)
                    _w_setup_python "$main_repo" "$wt_path"
                    ;;
            esac
        done

        # Copy .env
        _w_setup_env "$main_repo" "$wt_path"
    }

    # Helper: Activate venv if exists (for cd mode)
    _w_activate_venv_if_exists() {
        local wt_path="$1"

        if [[ -d "$wt_path/.venv" ]]; then
            # Deactivate any existing venv first
            [[ -n "$VIRTUAL_ENV" ]] && deactivate
            source "$wt_path/.venv/bin/activate"
        fi
    }

    # Handle special flags
    if [[ "$1" == "--list" ]]; then
        echo "=== All Worktrees ==="
        # Check new location
        if [[ -d "$worktrees_dir" ]]; then
            for project in $worktrees_dir/*(/N); do
                project_name=$(basename "$project")
                echo "\n[$project_name]"
                for wt in $project/*(/N); do
                    echo "  • $(basename "$wt")"
                done
            done
        fi
        # Also check old core-wts location
        if [[ -d "$projects_dir/core-wts" ]]; then
            echo "\n[core] (legacy location)"
            for wt in $projects_dir/core-wts/*(/N); do
                echo "  • $(basename "$wt")"
            done
        fi
        return 0
    elif [[ "$1" == "--rm" ]]; then
        shift
        local project="$1"
        local worktree="$2"
        if [[ -z "$project" || -z "$worktree" ]]; then
            echo "Usage: w --rm <project> <worktree>"
            return 1
        fi

        # Determine worktree path
        local wt_path=""
        if [[ "$project" == "core" && -d "$projects_dir/core-wts/$worktree" ]]; then
            wt_path="$projects_dir/core-wts/$worktree"
        else
            wt_path="$worktrees_dir/$project/$worktree"
        fi

        if [[ ! -d "$wt_path" ]]; then
            echo "Worktree not found: $wt_path"
            return 1
        fi

        # Safety: Remove symlinked node_modules first to avoid affecting main repo
        if [[ -L "$wt_path/node_modules" ]]; then
            echo "Removing node_modules symlink..."
            rm "$wt_path/node_modules"
        fi

        # Remove the worktree
        (cd "$projects_dir/$project" && git worktree remove "$wt_path")
        return $?
    elif [[ "$1" == "--clean" ]]; then
        shift
        local project="$1"
        local force=false
        [[ "$2" == "--force" ]] && force=true
        if [[ -z "$project" ]]; then
            echo "Usage: w --clean <project> [--force]"
            echo "Removes ALL worktrees for a project."
            echo "  --force  Remove even with uncommitted changes"
            return 1
        fi

        local main_repo="$projects_dir/$project"
        if [[ ! -d "$main_repo/.git" ]]; then
            echo "Not a git repo: $main_repo"
            return 1
        fi

        # Collect all worktree paths (skip the main working tree)
        local -a wt_paths
        wt_paths=("${(@f)$(cd "$main_repo" && git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //')}")

        local count=0
        for wt in "${wt_paths[@]}"; do
            [[ "$wt" == "$main_repo" ]] && continue
            count=$((count + 1))
        done

        if (( count == 0 )); then
            echo "No worktrees to clean for $project."
            return 0
        fi

        echo "Found $count worktree(s) for $project:"
        for wt in "${wt_paths[@]}"; do
            [[ "$wt" == "$main_repo" ]] && continue
            echo "  • $wt"
        done

        echo ""
        read -q "REPLY?Remove all $count worktree(s)? [y/N] "
        echo ""
        if [[ "$REPLY" != "y" ]]; then
            echo "Aborted."
            return 0
        fi

        # If currently inside a worktree, cd out first
        local cwd="$PWD"
        for wt in "${wt_paths[@]}"; do
            [[ "$wt" == "$main_repo" ]] && continue
            if [[ "$cwd" == "$wt"* ]]; then
                echo "You're inside a worktree — moving to main repo."
                cd "$main_repo"
                break
            fi
        done

        local removed=0 skipped=0
        for wt in "${wt_paths[@]}"; do
            [[ "$wt" == "$main_repo" ]] && continue
            # Remove symlinked node_modules first
            if [[ -L "$wt/node_modules" ]]; then
                rm "$wt/node_modules"
            fi
            if $force; then
                echo "Removing: $wt"
                (cd "$main_repo" && git worktree remove --force "$wt") && removed=$((removed + 1))
            else
                if (cd "$wt" && git diff --quiet && git diff --cached --quiet) 2>/dev/null; then
                    echo "Removing: $wt"
                    (cd "$main_repo" && git worktree remove "$wt") && removed=$((removed + 1))
                else
                    echo "Skipping (uncommitted changes): $wt"
                    skipped=$((skipped + 1))
                fi
            fi
        done

        # Prune any stale worktree references
        (cd "$main_repo" && git worktree prune)

        # Clean up empty directories in worktrees_dir
        local project_wt_dir="$worktrees_dir/$project"
        if [[ -d "$project_wt_dir" ]]; then
            find "$project_wt_dir" -mindepth 1 -type d -empty -delete 2>/dev/null
            rmdir "$project_wt_dir" 2>/dev/null
        fi

        echo "Done. Removed $removed/$count worktree(s)."
        (( skipped > 0 )) && echo "Skipped $skipped with uncommitted changes. Use --force to remove them."
        return 0
    elif [[ "$1" == "--sync" ]]; then
        shift
        local project="$1"
        local worktree="$2"
        if [[ -z "$project" || -z "$worktree" ]]; then
            echo "Usage: w --sync <project> <worktree>"
            return 1
        fi

        local main_repo="$projects_dir/$project"
        local wt_path="$worktrees_dir/$project/$worktree"

        # Check for core legacy location
        if [[ "$project" == "core" && -d "$projects_dir/core-wts/$worktree" ]]; then
            wt_path="$projects_dir/core-wts/$worktree"
        fi

        if [[ ! -d "$wt_path" ]]; then
            echo "Worktree not found: $wt_path"
            return 1
        fi

        # Check if both have package.json
        if [[ -f "$main_repo/package.json" && -f "$wt_path/package.json" ]]; then
            # Compare package.json files
            if ! diff -q "$main_repo/package.json" "$wt_path/package.json" > /dev/null 2>&1; then
                echo "Dependencies differ - running npm install..."
                # Remove symlink if it exists
                if [[ -L "$wt_path/node_modules" ]]; then
                    rm "$wt_path/node_modules"
                fi
                (cd "$wt_path" && npm install)
            else
                echo "Dependencies are in sync."
            fi
        else
            echo "No package.json found in both main repo and worktree."
        fi
        return 0
    fi

    # Normal usage: w <project> <worktree> [command...]
    local project="$1"
    local worktree="$2"
    shift 2
    local command=("$@")

    if [[ -z "$project" || -z "$worktree" ]]; then
        echo "Usage: w <project> <worktree> [command...]"
        echo "       w --list"
        echo "       w --rm <project> <worktree>"
        echo "       w --clean <project> [--force]"
        echo "       w --sync <project> <worktree>"
        return 1
    fi

    # Check if project exists
    if [[ ! -d "$projects_dir/$project" ]]; then
        echo "Project not found: $projects_dir/$project"
        return 1
    fi

    local main_repo="$projects_dir/$project"

    # Handle "main" as special worktree name to go to main repo
    if [[ "$worktree" == "main" ]]; then
        cd "$main_repo"
        return 0
    fi

    # Determine worktree path - check multiple locations
    local wt_path=""
    local is_new_worktree=false
    if [[ "$project" == "core" ]]; then
        # For core, check old location first
        if [[ -d "$projects_dir/core-wts/$worktree" ]]; then
            wt_path="$projects_dir/core-wts/$worktree"
        elif [[ -d "$worktrees_dir/$project/$worktree" ]]; then
            wt_path="$worktrees_dir/$project/$worktree"
        fi
    else
        # For other projects, check new location
        if [[ -d "$worktrees_dir/$project/$worktree" ]]; then
            wt_path="$worktrees_dir/$project/$worktree"
        fi
    fi

    # If worktree doesn't exist, create it
    if [[ -z "$wt_path" || ! -d "$wt_path" ]]; then
        echo "Creating new worktree: $worktree"
        is_new_worktree=true

        # Ensure worktrees directory exists
        mkdir -p "$worktrees_dir/$project"

        # Determine branch name (use current username prefix)
        local branch_name="$USER/$worktree"

        # Create the worktree in new location
        wt_path="$worktrees_dir/$project/$worktree"
        (cd "$projects_dir/$project" && git worktree add "$wt_path" -b "$branch_name") || {
            echo "Failed to create worktree"
            return 1
        }

        # Run setup for new worktree
        _w_setup_worktree "$main_repo" "$wt_path"

        echo "Done! You are now in: $wt_path"
    fi

    # Execute based on number of arguments
    if [[ ${#command[@]} -eq 0 ]]; then
        # No command specified - just cd to the worktree
        cd "$wt_path"
        # Auto-activate venv if exists (only for cd mode, not pass-through commands)
        _w_activate_venv_if_exists "$wt_path"
    else
        # Command specified - run it in the worktree without cd'ing
        local old_pwd="$PWD"
        cd "$wt_path"
        eval "${command[@]}"
        local exit_code=$?
        cd "$old_pwd"
        return $exit_code
    fi
}

# Setup completion if not already done
if [[ ! -f ~/.zsh/completions/_w ]]; then
    mkdir -p ~/.zsh/completions
    cat > ~/.zsh/completions/_w << 'EOF'
#compdef w
_w() {
    local curcontext="$curcontext" state line
    typeset -A opt_args
    
    local projects_dir="$HOME/personal"
    local worktrees_dir="$HOME/personal/worktrees"
    
    # Define the main arguments
    _arguments -C \
        '(--rm --sync --clean)--list[List all worktrees]' \
        '(--list --sync --clean)--rm[Remove a worktree]' \
        '(--list --rm --sync)--clean[Remove ALL worktrees for a project]' \
        '(--list --rm --clean)--sync[Sync dependencies if package.json differs]' \
        '1: :->project' \
        '2: :->worktree' \
        '3: :->command' \
        '*:: :->command_args' \
        && return 0
    
    case $state in
        project)
            if [[ "${words[1]}" == "--list" ]]; then
                # No completion needed for --list
                return 0
            fi
            
            # Get list of projects (directories in ~/personal that are git repos)
            local -a projects
            for dir in $projects_dir/*(N/); do
                if [[ -d "$dir/.git" ]]; then
                    projects+=(${dir:t})
                fi
            done
            
            _describe -t projects 'project' projects && return 0
            ;;
            
        worktree)
            local project="${words[2]}"
            
            if [[ -z "$project" ]]; then
                return 0
            fi
            
            local -a worktrees
            
            # For core project, check both old and new locations
            if [[ "$project" == "core" ]]; then
                # Check old location
                if [[ -d "$projects_dir/core-wts" ]]; then
                    for wt in $projects_dir/core-wts/*(N/); do
                        worktrees+=(${wt:t})
                    done
                fi
                # Check new location
                if [[ -d "$worktrees_dir/core" ]]; then
                    for wt in $worktrees_dir/core/*(N/); do
                        # Avoid duplicates
                        if [[ ! " ${worktrees[@]} " =~ " ${wt:t} " ]]; then
                            worktrees+=(${wt:t})
                        fi
                    done
                fi
            else
                # For other projects, check new location only
                if [[ -d "$worktrees_dir/$project" ]]; then
                    for wt in $worktrees_dir/$project/*(N/); do
                        worktrees+=(${wt:t})
                    done
                fi
            fi
            
            if (( ${#worktrees} > 0 )); then
                _describe -t worktrees 'existing worktree' worktrees
            else
                _message 'new worktree name'
            fi
            ;;
            
        command)
            # Suggest common commands when user has typed project and worktree
            local -a common_commands
            common_commands=(
                'claude:Start Claude Code session'
                'gst:Git status'
                'gaa:Git add all'
                'gcmsg:Git commit with message'
                'gp:Git push'
                'gco:Git checkout'
                'gd:Git diff'
                'gl:Git log'
                'npm:Run npm commands'
                'yarn:Run yarn commands'
                'make:Run make commands'
            )
            
            _describe -t commands 'command' common_commands
            
            # Also complete regular commands
            _command_names -e
            ;;
            
        command_args)
            # Let zsh handle completion for the specific command
            words=(${words[4,-1]})
            CURRENT=$((CURRENT - 3))
            _normal
            ;;
    esac
}
_w "$@"
EOF
    # Add completions to fpath if not already there
    fpath=(~/.zsh/completions $fpath)
fi

# Initialize completions
autoload -U compinit && compinit

# If you come from bash you might have to change your $PATH
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$PATH:$HOME/Library/Python/3.11/bin
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(
  git
  bundler
  dotenv
  macos
  npm
  zsh-autosuggestions
)
source $ZSH/oh-my-zsh.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

eval "$(thefuck --alias)"

source $HOME/.config/broot/launcher/bash/br

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
eval "$(direnv hook zsh)"

# Created by `pipx` on 2024-04-15 22:22:52
export PATH="$PATH:$HOME/.local/bin"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"; if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "${___MY_VMOPTIONS_SHELL_FILE}"; fi
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$PATH:$HOME/personal/worldbanc/private/bin"

# Starship prompt
eval "$(starship init zsh)"
