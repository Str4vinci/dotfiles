# Point every zsh at the socket-activated ssh-agent user unit
# (`systemctl --user enable --now ssh-agent.socket`). This lives in .zshenv
# rather than .zshrc because non-interactive shells — scripts, editors, and
# agent tooling — need it too, and .zshrc is only sourced for interactive ones.
#
# The value is a path to a Unix socket, not key material. The agent holds the
# decrypted key in memory; add it once per login with `ssh-add`.
if [ -z "$SSH_AUTH_SOCK" ] && [ -n "$XDG_RUNTIME_DIR" ]; then
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi
