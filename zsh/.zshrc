# Set up the prompt

autoload -Uz promptinit
promptinit

setopt histignorealldups sharehistory

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Homebrew (broot, bat, glow, ...). Before compinit so brew completions load, and
# before the system PATH export below so system binaries keep precedence.
[ -x /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'

# Ensure system Python takes precedence for system applications like Calibre
export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:$HOME/.local/bin:$PATH"
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
export EDITOR=vim
bindkey -v
bindkey -M viins jj vi-cmd-mode 
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char
setopt prompt_subst

# Load version control information
autoload -Uz vcs_info

# Set up vcs_info parameters
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '(%b)'

# This function runs before each prompt is displayed
precmd() {
  vcs_info
}

# Set up the prompt - MUST come after setting prompt_subst
PROMPT='%F{magenta}${vcs_info_msg_0_}%f%F{cyan}%n%f@%F{yellow}%m%f %F{yellow}%~%f %F{green}%%%f '

if [ -f "$HOME/.config/broot/launcher/zsh/br" ]; then
    source "$HOME/.config/broot/launcher/zsh/br"
fi

[[ -r "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
export PATH="$HOME/.local/share/omarchy/bin:$PATH"

# Development environment tmux session
alias dev="$HOME/.local/bin/dev-session"

# Scaffold a new blog post on website_stravinci (guarded so other machines don't break)
[ -x "$HOME/Work/website_stravinci/scripts/new-post.sh" ] && \
  alias make_post="$HOME/Work/website_stravinci/scripts/new-post.sh"


# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end


# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"

# mise — per-project runtime versions (node, python). Comes last so its shims
# take precedence over the system node in /usr/bin that the PATH exports above
# put in place. Guarded so a machine without mise still gets a working shell.
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"

[ -f "$HOME/.config/broot/launcher/bash/br" ] && source "$HOME/.config/broot/launcher/bash/br"

# Windows OpenSSH launches WSL in the Windows profile dir; start in Linux home instead
[[ $PWD == /mnt/c/Users/Leonardo ]] && cd ~
