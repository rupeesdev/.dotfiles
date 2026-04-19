# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A macOS dotfiles repository. All configs are symlinked from `~/.config/` to this directory via `setup.sh`. The repo is organized by tool, each tool's directory maps directly to `~/.config/<tool>`.

## Setup

Run the full bootstrap (macOS only):
```bash
./setup.sh
```

The script installs Homebrew, packages, Rust, Volta (Node), Bun, creates symlinks, sets Fish as default shell, installs Fisher plugins, syncs Neovim plugins, and applies macOS defaults.

To apply only symlinks (useful when updating configs without a full reinstall):
```bash
# Handled inside setup.sh's link_dotfiles() — run manually or re-run setup.sh
```

To sync Neovim plugins headlessly:
```bash
nvim --headless "+Lazy! sync" +qa
```

To update Fish plugins:
```bash
fish -c "fisher update"
```

## Architecture

### Symlink model
`setup.sh` symlinks each top-level directory to `~/.config/<tool>`. Adding a new tool means: create a directory here, add a `link` call in `link_dotfiles()`, and commit.

### Tool stack
| Tool | Purpose |
|------|---------|
| **fish** | Default shell. Fisher manages plugins. `config.fish` handles PATH, tool init (starship, zoxide, atuin, fzf, carapace), vi-mode, aliases. |
| **nvim** | LazyVim-based config. Plugins in `nvim/lua/plugins/`, overrides in `nvim/lua/config/`. Theme: Catppuccin Mocha (transparent). |
| **aerospace** | Tiling window manager. Keybindings use `alt-*` for workspace switching, `alt-shift-*` for moving windows. |
| **zellij** | Terminal multiplexer. Custom keybindings in `zellij/config.kdl` (defaults cleared). |
| **ghostty** | Terminal emulator. JetBrainsMono Nerd Font, Catppuccin Mocha theme. |
| **starship** | Shell prompt via `starship.toml`. |
| **atuin** | Shell history with sync support (`atuin login` to enable). |
| **btop** | System monitor. |

### Fish plugins (managed by Fisher, declared in `fish/fish_plugins`)
- `jorgebucaran/fisher` — plugin manager
- `jorgebucaran/nvm.fish` — Node version manager
- `patrickf1/fzf.fish` — fzf integrations (git log, git status, history, directory, processes, variables)

### Neovim structure
- `nvim/lua/config/` — LazyVim overrides: keymaps, autocmds, options, colorscheme
- `nvim/lua/plugins/` — plugin specs (oil.lua, lualine.lua, colorscheme.lua, etc.)
- `nvim/lazy-lock.json` — locked plugin versions; commit changes here when upgrading plugins

## Editing configs

- Fish shell changes → `fish/config.fish` or `fish/conf.d/*.fish`
- New fish functions → `fish/functions/<name>.fish`
- Neovim plugins → `nvim/lua/plugins/<name>.lua` following LazyVim plugin spec format
- Aerospace keybindings → `aerospace/aerospace.toml`
- Zellij keybindings → `zellij/config.kdl`
