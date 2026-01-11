# Set up the prompt

autoload -Uz promptinit
promptinit

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
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

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
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
PROMPT='%F{magenta}${vcs_info_msg_0_}%f%F{cyan}%n%f@%F{yellow}%~%f %F{green}%%%f%f '

if [ -f "$HOME/.config/broot/launcher/zsh/br" ]; then
    source "$HOME/.config/broot/launcher/zsh/br"
fi.config/broot/launcher/bash/br
