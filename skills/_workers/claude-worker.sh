#!/usr/bin/env bash
# Run one Claude Code worker (claude -p) non-interactively and block until it finishes.
# Same interface as codex-worker.sh and agy-worker.sh.
#
#   claude-worker.sh <label> <ro|rw> <workdir> <prompt-file> [extra claude args...]
#   claude-worker.sh --resume <session-id> <label> <ro|rw> <workdir> <prompt-file> [extra claude args...]
#
# Typical extra args: --model opus --effort high
# ro = Read, Grep, Glob, and read-only git commands. No edits, no other shell commands.
# rw = also Edit and Write (accepted automatically). Other shell commands stay blocked.
# Uses your own Claude login. ANTHROPIC_API_KEY is removed so that the run uses the
# subscription, not API billing. Never add --bare (it skips the subscription login).
# Writes to ~/.cache/agent-workers/<timestamp>-<label>/:
#   prompt.md  the prompt sent
#   result.md  the worker's final message
#   log.txt    raw JSON output and stderr
#   meta.txt   label, mode, workdir, session id, exit code
set -uo pipefail

resume_id=""
if [[ "${1:-}" == "--resume" ]]; then
  resume_id="$2"
  shift 2
fi

if [[ $# -lt 4 ]]; then
  sed -n '2,17p' "$0" >&2
  exit 2
fi

label="$1" mode="$2" workdir="$3" prompt_file="$4"
shift 4

git_ro=("Bash(git diff:*)" "Bash(git log:*)" "Bash(git show:*)" "Bash(git status:*)" "Bash(git blame:*)")
case "$mode" in
  ro) mode_args=(--permission-mode default --tools "Read,Grep,Glob,Bash" --allowedTools "${git_ro[@]}") ;;
  rw) mode_args=(--permission-mode acceptEdits --tools "Read,Grep,Glob,Edit,Write,Bash" --allowedTools "${git_ro[@]}") ;;
  *) echo "mode must be ro or rw, got: $mode" >&2; exit 2 ;;
esac

[[ -d "$workdir" ]] || { echo "workdir not found: $workdir" >&2; exit 2; }
[[ -f "$prompt_file" ]] || { echo "prompt file not found: $prompt_file" >&2; exit 2; }

run_dir="$HOME/.cache/agent-workers/$(date +%Y%m%d-%H%M%S)-${label//[^A-Za-z0-9_-]/_}"
mkdir -p "$run_dir"
cp "$prompt_file" "$run_dir/prompt.md"
echo "run_dir: $run_dir"

resume_args=()
[[ -n "$resume_id" ]] && resume_args=(--resume "$resume_id")

cd "$workdir" || exit 2
# -- ends the variadic --allowedTools list; the prompt comes from stdin.
env -u ANTHROPIC_API_KEY -u ANTHROPIC_AUTH_TOKEN \
  claude -p --output-format json "${mode_args[@]}" "${resume_args[@]}" "$@" -- \
  <"$prompt_file" >"$run_dir/log.txt" 2>&1
status=$?

json="$(grep -m1 '^{' "$run_dir/log.txt")"
session_id="$(jq -r '.session_id // empty' <<<"$json" 2>/dev/null)"
is_error="$(jq -r '.is_error // empty' <<<"$json" 2>/dev/null)"
jq -r '.result // empty' <<<"$json" >"$run_dir/result.md" 2>/dev/null
[[ "$status" -eq 0 && "$is_error" == "true" ]] && status=1

{
  echo "label: $label"
  echo "mode: $mode"
  echo "workdir: $workdir"
  echo "session_id: ${session_id:-$resume_id}"
  echo "exit: $status"
} >"$run_dir/meta.txt"

cat "$run_dir/meta.txt"
echo "--- result ---"
if [[ -s "$run_dir/result.md" ]]; then
  cat "$run_dir/result.md"
else
  echo "(no result; see log tail)"
  tail -30 "$run_dir/log.txt"
fi
exit "$status"
