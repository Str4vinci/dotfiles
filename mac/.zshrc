# =============================================================================
# ~/.zshrc — macOS (leo@neo)
# =============================================================================

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt histignorealldups sharehistory

# --- Keybindings (vi mode) ---
bindkey -v
bindkey -M viins jj vi-cmd-mode
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char

# --- Completion ---
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Homebrew completions
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# --- PATH ---
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.local/bin:$PATH"

# --- Environment ---
export EDITOR=vim

# --- ls colors (macOS BSD ls) ---
export CLICOLOR=1
# Bold blue dirs, bold magenta symlinks, bold green sockets,
# bold yellow pipes, bold red executables — matches Linux feel
export LSCOLORS=ExFxCxDxBxegedabagacad

alias ls='ls -G'
alias ll='ls -alFG'
alias la='ls -AG'
alias l='ls -CFG'

# --- Prompt ---
autoload -Uz promptinit vcs_info
promptinit

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '(%b) '

setopt prompt_subst

precmd() { vcs_info }

# (branch) leo@neo ~/path %
PROMPT='%F{magenta}${vcs_info_msg_0_}%f%F{cyan}leo%f@%F{blue}neo%f %F{yellow}%~%f %F{green}%%%f '

# --- Tools ---

# broot (if installed)
[ -f "$HOME/.config/broot/launcher/zsh/br" ] && source "$HOME/.config/broot/launcher/zsh/br"

# dev tmux session
alias dev="$HOME/dotfiles/tmux/scripts/dev-session"

# Blog post scaffold (guarded — only if the script exists)
[ -x "$HOME/Work/website_stravinci/scripts/new-post.sh" ] && \
  alias make_post="$HOME/Work/website_stravinci/scripts/new-post.sh"
