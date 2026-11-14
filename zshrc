export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
  git
  colored-man-pages
  common-aliases
  history-substring-search
)

# Defensive: a stale global alias `P` (old common-aliases) would get baked into
# omz_urlencode when oh-my-zsh re-reads functions.zsh on a re-source. Clear it first.
# NB: P must be escaped/quoted, else the global alias expands inside this very line.
unalias \P 2>/dev/null
unfunction omz_urlencode 2>/dev/null

# ---------------------------------------------------------------------------
# Completions — fpath MUST be populated BEFORE oh-my-zsh runs compinit.
# oh-my-zsh runs a single compinit inside oh-my-zsh.sh; adding fpath dirs after
# it (the old layout) meant our completions were missed AND forced a second,
# redundant compinit later — the main cause of slow shell startup.
# ---------------------------------------------------------------------------
FPATH="$(brew --prefix)/share/zsh-completions:$(brew --prefix)/share/zsh/site-functions:$FPATH"
fpath=(~/.grok/completions/zsh $fpath)

# Disable oh-my-zsh's async git prompt. Its fork+signal round-trip stalls the
# prompt redraw by ~1s after every command (the lag felt on unknown commands);
# synchronous git_prompt_info is only ~50ms here. MUST be set before sourcing omz.
zstyle ':omz:alpha:lib:git' async-prompt no

source $ZSH/oh-my-zsh.sh

alias p='bun'

# Neovim everywhere
alias vi='nvim'
alias vim='nvim'
export EDITOR='nvim'
export VISUAL='nvim'

# ---------------------------------------------------------------------------
# PATH  (typeset -U keeps it de-duplicated automatically)
# ---------------------------------------------------------------------------
typeset -U path PATH
export BUN_INSTALL="$HOME/.bun"
path=(
  "$HOME/.grok/bin"
  "$HOME/.local/bin"
  "$BUN_INSTALL/bin"
  # `cursor .` — ~/.local/bin/cursor is the agent shim; it hands off to this one
  "/Applications/Cursor.app/Contents/Resources/app/bin"
  $path
)
# `zed .` — Zed.app ships its CLI inside the bundle, not on PATH
alias zed="/Applications/Zed.app/Contents/MacOS/cli"

# ---------------------------------------------------------------------------
# Completion styling (zstyles are read at completion time, so they may stay
# here, after compinit). compinit itself is run exactly once by oh-my-zsh above.
# ---------------------------------------------------------------------------
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'
zstyle ':completion:*:warnings' format '%F{red}no matches%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' rehash true

[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# ---------------------------------------------------------------------------
# ZLE line-editor plugins  — order matters:
#   autosuggestions  ->  fzf  ->  syntax-highlighting (must be the LAST one)
# Never `source ~/.zshrc` to reload these; open a new terminal instead, or
# re-sourcing wraps the ZLE widgets around themselves and causes input lag.
# ---------------------------------------------------------------------------
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
bindkey '^ ' autosuggest-accept

# fzf fuzzy finder — Ctrl-R: history, Ctrl-T: insert file path, Alt-C: cd into dir
source <(fzf --zsh)
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'
export FZF_CTRL_R_OPTS='--reverse'
export FZF_CTRL_T_OPTS='--preview "cat {} 2>/dev/null | head -200"'

# zsh-syntax-highlighting MUST be sourced last among the ZLE plugins.
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ---------------------------------------------------------------------------
# zoxide — must be initialised at the very end (it warns otherwise)
# _ZO_DOCTOR=0 skips zoxide's per-startup self-check (it false-positives under
# oh-my-zsh even though init is already last here).
# ---------------------------------------------------------------------------
export _ZO_DOCTOR=0
eval "$(zoxide init --cmd cd zsh)"

# ---------------------------------------------------------------------------
# Right-prompt command timer + exit status (like powerlevel10k / starship):
#   • how long the last command took, human-readable (ms / s / m / h / d)
#   • a red ✗ with the exit code when a command fails
# Clears itself on an empty Enter so the prompt stays clean.
# ---------------------------------------------------------------------------
zmodload zsh/datetime
autoload -Uz add-zsh-hook

_fmt_duration() {
  local ms=$1
  if (( ms < 1000 )); then print -rn -- "${ms}ms"; return; fi
  local t=$(( ms / 1000 ))
  if (( t < 60 )); then printf '%.1fs' $(( ms / 1000.0 )); return; fi
  local d=$(( t/86400 )) h=$(( (t%86400)/3600 )) m=$(( (t%3600)/60 )) s=$(( t%60 )) out=
  (( d )) && out+="${d}d"
  (( h )) && out+="${out:+ }${h}h"
  (( m )) && out+="${out:+ }${m}m"
  (( s )) && out+="${out:+ }${s}s"
  print -rn -- "$out"
}

_timer_preexec() { _timer_start=$EPOCHREALTIME }
_timer_precmd() {
  local code=$?
  local seg=""
  if [[ -n $_timer_start ]]; then
    local ms=$(( (EPOCHREALTIME - _timer_start) * 1000 )); ms=${ms%.*}
    seg="%F{242}$(_fmt_duration $ms)%f"
    unset _timer_start
  fi
  (( code )) && seg="%F{red}${code}%f${seg:+  ${seg}}"
  RPROMPT=$seg
}
add-zsh-hook preexec _timer_preexec
add-zsh-hook precmd  _timer_precmd

# ---------------------------------------------------------------------------
# Kill the slow Homebrew "command-not-found" handler. Something pulls in
# /opt/homebrew/.../command-not-found/handler.sh, which runs a ~600ms brew DB
# lookup on every mistyped command. Override it (last line wins) with a no-op so
# unknown commands fail instantly, like a normal shell.
# ---------------------------------------------------------------------------
command_not_found_handler() { print -u2 "zsh: command not found: $1"; return 127 }


# opencode
export PATH=/Users/shekhar/.opencode/bin:$PATH

# kilo
export PATH=/Users/shekhar/.kilo/bin:$PATH

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<

# bun completions
[ -s "/Users/shekhar/.bun/_bun" ] && source "/Users/shekhar/.bun/_bun"

# MiniMax Code CLI
export PATH="/Users/shekhar/.minimax-code/bin:$PATH"

# Added by MiniMax Code
export PATH="/Users/shekhar/.minimax/bin:$PATH"


# Secrets and machine-only settings live outside the repo.
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
