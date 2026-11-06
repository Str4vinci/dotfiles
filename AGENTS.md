# Dotfiles workspace instructions

- Treat this repository as the source of truth for user configuration.
- Never edit files under `/usr/share/omarchy/` (also reachable as `~/.local/share/omarchy/`); those are upstream defaults owned by the omarchy package.
- Never edit or track `~/.config/omarchy/current/`; Omarchy generates it from the active theme.
- Hyprland is configured in Lua (Omarchy 4+). Keep custom keybindings in `hypr/.config/hypr/bindings.lua` (use `o.bind` / `o.rebind`) and startup apps in `hypr/.config/hypr/autostart.lua` (use `o.launch_on_start`).
- The bar and widgets are the Omarchy shell (Quickshell), configured in `~/.config/omarchy/shell.json`. Waybar is no longer used.
- Put persistent Omarchy user files under `omarchy/.config/omarchy/` so GNU Stow installs them at the correct path.
- Preserve unrelated local and uncommitted changes.
- After Hyprland changes, run `hyprctl reload` and ensure `hyprctl configerrors` is empty.
