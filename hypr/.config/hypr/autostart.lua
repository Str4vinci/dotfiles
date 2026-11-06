-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Open a terminal attached to the shared "Work" tmux session at login.
-- From SSH, run: tmux new -A -s Work
o.launch_on_start("omarchy-launch-terminal-tmux")
