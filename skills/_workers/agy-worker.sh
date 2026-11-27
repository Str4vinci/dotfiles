#!/usr/bin/env bash
# Run one Antigravity (agy) worker non-interactively and block until it finishes.
# Same interface as codex-worker.sh, so the skill can swap backends.
#
#   agy-worker.sh <label> <ro|rw> <workdir> <prompt-file> [extra agy args...]
#   agy-worker.sh --resume <conversation-id> <label> <ro|rw> <workdir> <prompt-file> [extra agy args...]
#
# ro = --mode plan (agy writes nothing; it stops at a plan). rw = --mode accept-edits --sandbox.
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
  sed -n '2,13p' "$0" >&2
  exit 2
fi

label="$1" mode="$2" workdir="$3" prompt_file="$4"
shift 4

case "$mode" in
  # Headless agy cannot prompt, so it denies every read outside the workspace (and any
  # path written with ~) and then returns an empty answer. Plan mode writes nothing,
  # so allowing reads everywhere is safe. --settings replaces the user's permissions, so this
  # repeats ~/.gemini/antigravity-cli/settings.json (command(*) and its denies) and adds read_file(*).
  ro) mode_args=(--mode plan --settings '{"permissions":{"allow":["read_file(*)","command(*)"],"deny":["command(sudo *)","command(sudo)","command(rm -rf *)","command(rm -r *)"]}}') ;;
  rw) mode_args=(--mode accept-edits --sandbox) ;;
  *) echo "mode must be ro or rw, got: $mode" >&2; exit 2 ;;
esac

[[ -d "$workdir" ]] || { echo "workdir not found: $workdir" >&2; exit 2; }
[[ -f "$prompt_file" ]] || { echo "prompt file not found: $prompt_file" >&2; exit 2; }

run_dir="$HOME/.cache/agent-workers/$(date +%Y%m%d-%H%M%S)-${label//[^A-Za-z0-9_-]/_}"
mkdir -p "$run_dir"
cp "$prompt_file" "$run_dir/prompt.md"
echo "run_dir: $run_dir"

resume_args=()
[[ -n "$resume_id" ]] && resume_args=(--conversation "$resume_id")

prompt="$(cat "$prompt_file")"
# In plan mode agy otherwise answers with an implementation_plan.md artifact, not the answer.
[[ "$mode" == ro ]] && prompt="You are in read-only mode. Do not write an implementation plan or any artifact. Put your full answer in your final message.

$prompt"

cd "$workdir" || exit 2
# agy needs flags before -p, and the prompt as the value of -p.
agy "${mode_args[@]}" "${resume_args[@]}" --output-format json "$@" \
  -p "$prompt" >"$run_dir/log.txt" 2>&1
status=$?

json="$(grep -m1 '^{' "$run_dir/log.txt")"
session_id="$(jq -r '.conversation_id // empty' <<<"$json" 2>/dev/null)"
agy_status="$(jq -r '.status // empty' <<<"$json" 2>/dev/null)"
jq -r '.response // empty' <<<"$json" >"$run_dir/result.md" 2>/dev/null
[[ "$status" -eq 0 && -n "$agy_status" && "$agy_status" != "SUCCESS" ]] && status=1
denied="$(jq -r '[.denied_actions[]?.action] | unique | join(", ")' <<<"$json" 2>/dev/null)"
# agy reports SUCCESS with an empty answer when a tool was denied; treat that as a failure.
if [[ ! "$(tr -d '[:space:]' <"$run_dir/result.md")" ]]; then
  [[ "$status" -eq 0 ]] && status=1
  [[ -n "$denied" ]] && echo "agy denied: $denied (empty answer). Allow it with --settings or --add-dir." >&2
fi

{
  echo "label: $label"
  echo "mode: ${mode_args[*]}"
  echo "workdir: $workdir"
  echo "session_id: ${session_id:-$resume_id}"
  echo "agy_status: ${agy_status:-unknown}"
  [[ -n "$denied" ]] && echo "denied: $denied"
  echo "exit: $status"
} >"$run_dir/meta.txt"

cat "$run_dir/meta.txt"
echo "--- result ---"
if [[ "$(tr -d '[:space:]' <"$run_dir/result.md")" ]]; then
  cat "$run_dir/result.md"
else
  echo "(no result; see log tail)"
  tail -30 "$run_dir/log.txt"
fi
exit "$status"
