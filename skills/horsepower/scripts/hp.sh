#!/usr/bin/env bash
# Run one Codex worker non-interactively and block until it finishes.
#
#   hp.sh <label> <ro|rw> <workdir> <prompt-file> [extra codex args...]
#   hp.sh --resume <session-id> <label> <ro|rw> <workdir> <prompt-file> [extra codex args...]
#
# Writes to ~/.cache/horsepower/<timestamp>-<label>/:
#   prompt.md  the prompt sent
#   result.md  the worker's final message
#   log.txt    full transcript (commands, output, session id)
#   meta.txt   label, mode, workdir, session id, exit code
set -uo pipefail

resume_id=""
if [[ "${1:-}" == "--resume" ]]; then
  resume_id="$2"
  shift 2
fi

if [[ $# -lt 4 ]]; then
  sed -n '2,12p' "$0" >&2
  exit 2
fi

label="$1" mode="$2" workdir="$3" prompt_file="$4"
shift 4

case "$mode" in
  ro) sandbox="read-only" ;;
  rw) sandbox="workspace-write" ;;
  *) echo "mode must be ro or rw, got: $mode" >&2; exit 2 ;;
esac

[[ -d "$workdir" ]] || { echo "workdir not found: $workdir" >&2; exit 2; }
[[ -f "$prompt_file" ]] || { echo "prompt file not found: $prompt_file" >&2; exit 2; }

run_dir="$HOME/.cache/horsepower/$(date +%Y%m%d-%H%M%S)-${label//[^A-Za-z0-9_-]/_}"
mkdir -p "$run_dir"
cp "$prompt_file" "$run_dir/prompt.md"
echo "run_dir: $run_dir"

# `resume` accepts neither --color, -s, nor -C, so pass the sandbox as config and cd instead.
common=(-c "sandbox_mode=\"$sandbox\"" -o "$run_dir/result.md")
cd "$workdir" || exit 2
if [[ -n "$resume_id" ]]; then
  codex exec resume "${common[@]}" "$@" "$resume_id" - <"$prompt_file" >"$run_dir/log.txt" 2>&1
else
  codex exec "${common[@]}" --color never -C "$workdir" "$@" - <"$prompt_file" >"$run_dir/log.txt" 2>&1
fi
status=$?

session_id="$(grep -m1 '^session id:' "$run_dir/log.txt" | awk '{print $3}')"
{
  echo "label: $label"
  echo "mode: $sandbox"
  echo "workdir: $workdir"
  echo "session_id: ${session_id:-$resume_id}"
  echo "exit: $status"
} >"$run_dir/meta.txt"

cat "$run_dir/meta.txt"
echo "--- result ---"
cat "$run_dir/result.md" 2>/dev/null || { echo "(no result; see log tail)"; tail -30 "$run_dir/log.txt"; }
exit "$status"
