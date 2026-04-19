#!/usr/bin/env bash
# =============================================================================
# macOS Dotfiles Setup Script
# =============================================================================
# Instala y configura todo el entorno desde cero en macOS.
# Requiere macOS con conexión a internet.
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# =============================================================================
# 1. Xcode Command Line Tools
# =============================================================================
install_xcode_tools() {
  info "Verificando Xcode Command Line Tools..."
  if ! xcode-select -p &>/dev/null; then
    info "Instalando Xcode Command Line Tools..."
    xcode-select --install
    # Wait for installation to complete
    until xcode-select -p &>/dev/null; do sleep 5; done
    success "Xcode Command Line Tools instalados."
  else
    success "Xcode Command Line Tools ya están instalados."
  fi
}

# =============================================================================
# 2. Homebrew
# =============================================================================
install_homebrew() {
  info "Verificando Homebrew..."
  if ! command -v brew &>/dev/null; then
    info "Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for the rest of the script
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    success "Homebrew instalado."
  else
    success "Homebrew ya está instalado."
    brew update
  fi
}

# =============================================================================
# 3. Homebrew packages
# =============================================================================
install_brew_packages() {
  info "Instalando paquetes de Homebrew..."

  local formulae=(
    # Shell y terminal
    fish          # Shell moderna
    starship      # Prompt cross-shell
    atuin         # Historial de comandos con sync
    zoxide        # cd inteligente (z)
    fzf           # Fuzzy finder
    carapace      # Completions multi-shell

    # Editor
    neovim        # Editor principal

    # Multiplexor
    zellij        # Multiplexor de terminal

    # Herramientas de archivo y búsqueda
    bat           # cat con syntax highlighting
    fd            # find moderno
    ripgrep       # grep ultra rápido
    yazi          # File manager en terminal
    jq            # Procesador JSON

    # Git
    git
    gh            # GitHub CLI
    lazygit       # TUI para git

    # Sistema
    btop          # Monitor de sistema
    curl
    wget
  )

  local casks=(
    # Window manager (macOS)
    aerospace     # Tiling window manager

    # Terminal
    ghostty       # Emulador de terminal moderno

    # Fuentes (necesarias para iconos en Ghostty/Neovim)
    font-jetbrains-mono-nerd-font
    font-symbols-only-nerd-font
  )

  for pkg in "${formulae[@]}"; do
    if brew list --formula "$pkg" &>/dev/null; then
      success "$pkg ya instalado."
    else
      info "Instalando $pkg..."
      brew install "$pkg"
    fi
  done

  # Tap para aerospace si no está
  brew tap nikitabobko/tap 2>/dev/null || true

  for cask in "${casks[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
      success "$cask ya instalado."
    else
      info "Instalando cask $cask..."
      brew install --cask "$cask" 2>/dev/null || warn "No se pudo instalar $cask (puede que requiera instalación manual)"
    fi
  done

  success "Paquetes de Homebrew instalados."
}

# =============================================================================
# 4. Rust (via rustup)
# =============================================================================
install_rust() {
  info "Verificando Rust..."
  if ! command -v rustup &>/dev/null; then
    info "Instalando Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    source "$HOME/.cargo/env"
    success "Rust instalado."
  else
    success "Rust ya está instalado."
    rustup update stable
  fi
}

# =============================================================================
# 5. Volta (Node.js version manager)
# =============================================================================
install_volta() {
  info "Verificando Volta..."
  if ! command -v volta &>/dev/null && [[ ! -d "$HOME/.volta" ]]; then
    info "Instalando Volta..."
    curl https://get.volta.sh | bash -s -- --skip-setup
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"
    volta install node
    volta install npm
    success "Volta instalado con Node.js LTS."
  else
    success "Volta ya está instalado."
  fi
}

# =============================================================================
# 6. Bun
# =============================================================================
install_bun() {
  info "Verificando Bun..."
  if ! command -v bun &>/dev/null && [[ ! -d "$HOME/.bun" ]]; then
    info "Instalando Bun..."
    curl -fsSL https://bun.sh/install | bash
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    success "Bun instalado."
  else
    success "Bun ya está instalado."
  fi
}

# =============================================================================
# 7. Symlinks de dotfiles
# =============================================================================
link_dotfiles() {
  info "Creando symlinks de dotfiles..."

  local config_dir="$HOME/.config"
  mkdir -p "$config_dir"

  link() {
    local src="$1"
    local dst="$2"
    if [[ -L "$dst" ]]; then
      warn "Symlink ya existe: $dst"
    elif [[ -e "$dst" ]]; then
      warn "Haciendo backup de $dst -> ${dst}.bak"
      mv "$dst" "${dst}.bak"
      ln -sf "$src" "$dst"
      success "Linked: $dst -> $src"
    else
      mkdir -p "$(dirname "$dst")"
      ln -sf "$src" "$dst"
      success "Linked: $dst -> $src"
    fi
  }

  # Link all top-level directories to ~/.config/<name>
  for dir in "$DOTFILES_DIR"/*/; do
    local name
    name="$(basename "$dir")"
    link "$dir" "$config_dir/$name"
  done

  # starship.toml lives at root, not in a subdirectory
  link "$DOTFILES_DIR/starship.toml" "$config_dir/starship.toml"

  success "Symlinks creados."
}

# =============================================================================
# 8. Fish como shell por defecto
# =============================================================================
set_fish_default() {
  info "Configurando Fish como shell por defecto..."

  local fish_path
  if [[ -f /opt/homebrew/bin/fish ]]; then
    fish_path="/opt/homebrew/bin/fish"
  else
    fish_path="/usr/local/bin/fish"
  fi

  if ! grep -q "$fish_path" /etc/shells 2>/dev/null; then
    info "Añadiendo $fish_path a /etc/shells..."
    echo "$fish_path" | sudo tee -a /etc/shells
  fi

  if [[ "$SHELL" != "$fish_path" ]]; then
    info "Cambiando shell por defecto a Fish..."
    chsh -s "$fish_path"
    success "Shell cambiada a Fish. Tendrá efecto en la próxima sesión."
  else
    success "Fish ya es la shell por defecto."
  fi
}

# =============================================================================
# 9. Fisher + plugins de Fish
# =============================================================================
install_fish_plugins() {
  info "Instalando Fisher y plugins de Fish..."

  local fish_path
  if [[ -f /opt/homebrew/bin/fish ]]; then
    fish_path="/opt/homebrew/bin/fish"
  else
    fish_path="/usr/local/bin/fish"
  fi

  # Instalar Fisher
  $fish_path -c "
    if not functions -q fisher
      curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
      fisher install jorgebucaran/fisher
    end
  " 2>/dev/null || warn "Fisher ya podría estar instalado."

  # Instalar plugins desde fish_plugins
  if [[ -f "$DOTFILES_DIR/fish/fish_plugins" ]]; then
    $fish_path -c "fisher update" 2>/dev/null || true
    success "Plugins de Fish instalados."
  fi
}

# =============================================================================
# 10. Neovim: instalar plugins vía lazy.nvim
# =============================================================================
setup_neovim() {
  info "Configurando Neovim (instalando plugins con lazy.nvim)..."
  if command -v nvim &>/dev/null; then
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || \
    nvim --headless -c "Lazy sync" -c "qa" 2>/dev/null || \
    warn "No se pudieron instalar plugins automáticamente. Abre nvim y ejecuta :Lazy sync"
    success "Plugins de Neovim instalados."
  else
    warn "Neovim no encontrado. Instala los plugins manualmente con :Lazy sync."
  fi
}

# =============================================================================
# 11. macOS defaults útiles
# =============================================================================
macos_defaults() {
  info "Aplicando configuración de macOS..."

  # Mostrar archivos ocultos en Finder
  defaults write com.apple.finder AppleShowAllFiles -bool true

  # Mostrar extensiones de archivos siempre
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Deshabilitar la animación de Mission Control para que vaya más rápido
  defaults write com.apple.dock expose-animation-duration -float 0.1

  # Dock: auto-hide
  defaults write com.apple.dock autohide -bool true

  # Deshabilitar el sonido de inicio
  sudo nvram SystemAudioVolume=" " 2>/dev/null || true

  # Trackpad: tap to click
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  killall Finder 2>/dev/null || true
  killall Dock 2>/dev/null || true

  success "Configuración de macOS aplicada."
}

# =============================================================================
# Main
# =============================================================================
main() {
  echo ""
  echo "============================================="
  echo "   macOS Dotfiles Setup"
  echo "============================================="
  echo ""

  if [[ "$(uname)" != "Darwin" ]]; then
    error "Este script es solo para macOS."
  fi

  install_xcode_tools
  install_homebrew
  install_brew_packages
  install_rust
  install_volta
  install_bun
  link_dotfiles
  set_fish_default
  install_fish_plugins
  setup_neovim
  macos_defaults

  echo ""
  echo "============================================="
  success "Setup completado!"
  echo "============================================="
  echo ""
  echo "Próximos pasos:"
  echo "  1. Reinicia la terminal o abre una nueva sesión"
  echo "  2. Abre Ghostty como emulador de terminal"
  echo "  3. AeroSpace arranca automáticamente (start-at-login = true)"
  echo "  4. En nvim ejecuta :Mason para instalar LSPs adicionales"
  echo "  5. Ejecuta 'atuin login' si quieres sincronizar el historial"
  echo ""
}

main "$@"
