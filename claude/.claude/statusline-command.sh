#!/usr/bin/env bash
# Claude Code statusLine command — mirrors the zsh PROMPT:
#   %F{magenta}(branch)%f%F{cyan}user%f@%F{yellow}~/path%f  model  [progress bar] 42%  143.1K/1M

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
username=$(whoami)

# Git branch (magenta), matching vcs_info format
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  [ -n "$branch" ] && git_branch="($branch)"
fi

# Shorten cwd like zsh %~: replace $HOME prefix with ~
short_cwd="${cwd/#$HOME/~}"

# Model display name
model=$(echo "$input" | jq -r '.model.display_name // empty')

# Context usage percentage
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Raw token counts
used_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
max_tokens=$(echo "$input"  | jq -r '.context_window.context_window_size // empty')

# Rate-limit usage (Claude.ai Pro/Max only; populated after the first API response).
# five_hour = rolling 5h window, seven_day = weekly window. Values are 0-100.
five_h_pct=$(echo "$input"  | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_d_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Format a token count as a compact K/M string (e.g. 143100 -> "143.1K", 1000000 -> "1M")
fmt_tokens() {
  awk -v n="$1" 'BEGIN {
    if (n >= 1000000) {
      v = n / 1000000
      # Drop ".0" suffix when it would appear
      printf (v == int(v)) ? "%gM" : "%.1fM", v
    } else if (n >= 1000) {
      v = n / 1000
      printf (v == int(v)) ? "%gK" : "%.1fK", v
    } else {
      printf "%d", n
    }
  }'
}

# Render a 0-100 percentage, colored by severity: gray <75, yellow >=75, red >=90
color_pct() {
  awk -v p="$1" 'BEGIN {
    if (p >= 90)      printf "\033[31m%.0f%%\033[0m", p
    else if (p >= 75) printf "\033[33m%.0f%%\033[0m", p
    else              printf "\033[90m%.0f%%\033[0m", p
  }'
}

# Build progress bar (10 chars wide)
bar_str=""
if [ -n "$used_pct" ]; then
  filled=$(echo "$used_pct" | awk '{printf "%d", int($1 / 10 + 0.5)}')
  [ "$filled" -gt 10 ] && filled=10
  empty=$((10 - filled))
  bar_str=""
  for i in $(seq 1 "$filled"); do bar_str="${bar_str}#"; done
  for i in $(seq 1 "$empty");  do bar_str="${bar_str}-"; done
fi

# Build token-count string (only when both values are available)
token_str=""
if [ -n "$used_tokens" ] && [ -n "$max_tokens" ]; then
  token_str="$(fmt_tokens "$used_tokens")/$(fmt_tokens "$max_tokens")"
fi

# Print: (branch)user@~/path  model  [####------] 42%  143.1K/1M
printf '\033[35m%s\033[0m\033[36m%s\033[0m@\033[33m%s\033[0m' \
  "$git_branch" "$username" "$short_cwd"

if [ -n "$model" ]; then
  printf '  \033[90m%s\033[0m' "$model"
fi

if [ -n "$used_pct" ] && [ -n "$bar_str" ]; then
  printf '  \033[90m[%s]\033[0m \033[90m%s%%\033[0m' "$bar_str" "$(printf '%.0f' "$used_pct")"
  if [ -n "$token_str" ]; then
    printf '  \033[90m%s\033[0m' "$token_str"
  fi
fi

# Rate-limit usage: (5h 35%  7d 42%)
if [ -n "$five_h_pct" ] || [ -n "$seven_d_pct" ]; then
  printf '  \033[90m(\033[0m'
  sep=""
  if [ -n "$five_h_pct" ]; then
    printf '\033[90m5h\033[0m %s' "$(color_pct "$five_h_pct")"
    sep="  "
  fi
  if [ -n "$seven_d_pct" ]; then
    printf '%s\033[90m7d\033[0m %s' "$sep" "$(color_pct "$seven_d_pct")"
  fi
  printf '\033[90m)\033[0m'
fi
