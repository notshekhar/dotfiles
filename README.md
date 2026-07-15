# dotfiles

My Mac setup: Neovim (LazyVim), Ghostty, zsh.

## What's inside

| Path | Symlinked to | What |
|---|---|---|
| `nvim/` | `~/.config/nvim` | LazyVim: LSP (TypeScript, Zig, Lua, JSON, Markdown), Cursor Dark theme, git signs + lazygit, spell check + dictionary word completion, instant which-key, format-on-save off |
| `ghostty/config` | `~/.config/ghostty/config` | Ghostty terminal config |
| `zshrc` | `~/.zshrc` | oh-my-zsh, autosuggestions, syntax highlighting, fzf, zoxide, `vi`/`vim` → nvim, prompt timer |
| `.tmux.conf` | `~/.tmux.conf` | tmux config |
| `Brewfile` | — | every brew/cask dependency |
| `install.sh` | — | one-command bootstrap |

## Setup on a new Mac

```sh
git clone https://github.com/notshekhar/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

The script installs Homebrew (if missing), all Brewfile deps, oh-my-zsh,
npm globals, symlinks the configs (backing up anything already there to
`*.bak`), and pre-installs all nvim plugins + language servers pinned by
`nvim/lazy-lock.json`. Re-running it is safe.

## Keeping laptops in sync

Configs are symlinks into this repo, so edits are immediately "in" the repo:

```sh
cd ~/dotfiles
git add -A && git commit -m "update" && git push   # laptop A
git pull && nvim --headless "+Lazy! restore" +qa   # laptop B
```
