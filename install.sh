#!/bin/bash
# Bootstrap these dotfiles on a fresh Mac.
# Safe to re-run: existing real configs are backed up to *.bak once,
# existing correct symlinks are left alone.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "ok      $dst"
    return
  fi
  if [ -e "$dst" ]; then
    echo "backup  $dst -> $dst.bak"
    rm -rf "$dst.bak"
    mv "$dst" "$dst.bak"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "link    $dst -> $src"
}

# --- Homebrew ---------------------------------------------------------------
if ! command -v brew >/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
brew bundle --file="$DOTFILES/Brewfile"

# --- oh-my-zsh (required by zshrc) -------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# --- npm globals (tree-sitter CLI for nvim, mermaid for markdown preview) ----
npm ls -g tree-sitter-cli >/dev/null 2>&1 || npm install -g tree-sitter-cli
npm ls -g @mermaid-js/mermaid-cli >/dev/null 2>&1 || npm install -g @mermaid-js/mermaid-cli

# --- symlinks -----------------------------------------------------------------
link "$DOTFILES/nvim" "$HOME/.config/nvim"
link "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"
link "$DOTFILES/zshrc" "$HOME/.zshrc"
link "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"

# --- nvim plugins + language servers ------------------------------------------
echo "Installing nvim plugins (takes a minute on first run)..."
nvim --headless "+Lazy! restore" +qa
nvim --headless -c "Lazy load mason.nvim" \
  -c "MasonInstall vtsls zls lua-language-server stylua shfmt json-lsp marksman markdownlint-cli2 markdown-toc prettier tree-sitter-cli" \
  -c "qa" || true

echo
echo "Done. Open a new terminal, run 'vi', enjoy."
