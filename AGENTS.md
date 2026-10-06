# Dotfiles workspace instructions

- Treat this repository as the source of truth for user configuration.
- Never edit files under `~/.local/share/omarchy/`; those are upstream defaults.
- Never edit or track `~/.config/omarchy/current/`; Omarchy generates it from the active theme.
- Edit Waybar in `waybar/.config/waybar/`, not directly in `~/.config/waybar/`.
- Keep custom Hyprland bindings in `hypr/.config/hypr/bindings-overrides.conf`; the stock `bindings.conf` should only source that file.
- Put persistent Omarchy user files under `omarchy/.config/omarchy/` so GNU Stow installs them at the correct path.
- Preserve unrelated local and uncommitted changes.
- After Waybar changes, run `omarchy restart waybar`.
- After Hyprland changes, run `hyprctl reload` and ensure `hyprctl configerrors` is empty.
