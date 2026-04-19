# dotfiles

> macOS developer environment — managed via symlinks to `~/.config/`

![macOS](https://img.shields.io/badge/macOS-Sequoia-black?logo=apple&logoColor=white)
![Shell](https://img.shields.io/badge/shell-fish-2a6ef4?logo=fish&logoColor=white)
![Editor](https://img.shields.io/badge/editor-neovim-57a143?logo=neovim&logoColor=white)
![Terminal](https://img.shields.io/badge/terminal-ghostty-6d3fc0)
![WM](https://img.shields.io/badge/wm-aerospace-0a84ff)
![Theme](https://img.shields.io/badge/theme-catppuccin%20mocha-cba6f7)

---

## Overview

Opinionated macOS setup with a focus on keyboard-driven workflows. All configs live here and are symlinked to `~/.config/` via `setup.sh`. Adding a new tool is as simple as creating a directory.

---

## Requirements

| Dependency | Purpose | Install |
|---|---|---|
| macOS 13+ | Host OS | — |
| [Homebrew](https://brew.sh) | Package manager | Auto-installed by `setup.sh` |
| [Xcode CLT](https://developer.apple.com/xcode/) | Build tools | Auto-installed by `setup.sh` |

> Everything else is installed automatically by `setup.sh`.

---

## Stack

### Shell
| Tool | Purpose |
|---|---|
| [fish](https://fishshell.com) | Default shell |
| [starship](https://starship.rs) | Cross-shell prompt |
| [atuin](https://atuin.sh) | Shell history with sync |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [carapace](https://carapace.sh) | Multi-shell completions |

### Editor
| Tool | Purpose |
|---|---|
| [Neovim](https://neovim.io) | Primary editor |
| [LazyVim](https://lazyvim.org) | Neovim config framework |
| [Catppuccin Mocha](https://catppuccin.com) | Theme (transparent) |
| [oil.nvim](https://github.com/stevearc/oil.nvim) | File manager |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Status line |

### Terminal & Multiplexer
| Tool | Purpose |
|---|---|
| [Ghostty](https://ghostty.org) | Terminal emulator |
| [Zellij](https://zellij.dev) | Terminal multiplexer |
| JetBrainsMono Nerd Font | Font with icons |

### Window Management
| Tool | Purpose |
|---|---|
| [AeroSpace](https://github.com/nikitabobko/AeroSpace) | Tiling window manager |

### CLI Utilities
| Tool | Purpose |
|---|---|
| [bat](https://github.com/sharkdp/bat) | `cat` with syntax highlighting |
| [fd](https://github.com/sharkdp/fd) | Modern `find` |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast `grep` |
| [yazi](https://github.com/sxyazi/yazi) | Terminal file manager |
| [lazygit](https://github.com/jesseduffield/lazygit) | Git TUI |
| [btop](https://github.com/aristocratos/btop) | System monitor |
| [jq](https://jqlang.github.io/jq/) | JSON processor |
| [gh](https://cli.github.com) | GitHub CLI |

### Languages & Runtimes
| Tool | Purpose |
|---|---|
| [Rust](https://rustup.rs) | Via `rustup` |
| [Volta](https://volta.sh) | Node.js version manager |
| [Bun](https://bun.sh) | JS runtime & package manager |

---

## Installation

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

`setup.sh` will:
1. Install Xcode Command Line Tools
2. Install Homebrew and all packages
3. Install Rust, Volta (Node), and Bun
4. Symlink every directory to `~/.config/<name>`
5. Set Fish as the default shell
6. Install Fisher plugins
7. Sync Neovim plugins via lazy.nvim
8. Apply macOS system defaults

---

## Structure

```
.dotfiles/
├── aerospace/       → ~/.config/aerospace
├── atuin/           → ~/.config/atuin
├── btop/            → ~/.config/btop
├── fish/            → ~/.config/fish
├── gh/              → ~/.config/gh
├── ghostty/         → ~/.config/ghostty
├── nvim/            → ~/.config/nvim
├── zellij/          → ~/.config/zellij
├── starship.toml    → ~/.config/starship.toml
└── setup.sh
```

Each top-level directory is automatically symlinked — no manual registration needed.

---

## Adding a new tool

```bash
mkdir mytool
# add config files inside
# re-run setup.sh or manually:
ln -sf ~/.dotfiles/mytool ~/.config/mytool
```

---

## Post-install

```bash
atuin login          # sync shell history (optional)
nvim                 # opens and auto-installs plugins on first run
```

---

## Fish plugins

Managed by [Fisher](https://github.com/jorgebucaran/fisher), declared in `fish/fish_plugins`:

- `jorgebucaran/fisher`
- `jorgebucaran/nvm.fish`
- `patrickf1/fzf.fish`
