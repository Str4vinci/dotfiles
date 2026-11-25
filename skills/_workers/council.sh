#!/usr/bin/env bash
# Run the three council reviewers in parallel (read-only) and wait for all of them.
#
#   council.sh <workdir> <prompt-file>
#
# Claude Opus (high), GPT 6.2 Sol (high), and Gemini 4 Neon (high) all get the same prompt.
# Prints each reviewer's meta and result block. The exit code is the number of reviewers
# that failed (0 = all succeeded). Each run directory is in ~/.cache/agent-workers/.
set -uo pipefail

if [[ $# -ne 2 ]]; then
  sed -n '2,8p' "$0" >&2
  exit 2
fi

workdir="$1" prompt_file="$2"
here="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
out="$(mktemp -d "${TMPDIR:-/tmp}/council.XXXXXX")"

"$here/claude-worker.sh" council-claude ro "$workdir" "$prompt_file" \
  --model opus --effort high >"$out/claude.txt" 2>&1 &
p1=$!
"$here/codex-worker.sh" council-gpt ro "$workdir" "$prompt_file" \
  -m gpt-6.2-sol -c 'model_reasoning_effort="high"' >"$out/gpt.txt" 2>&1 &
p2=$!
"$here/agy-worker.sh" council-neon ro "$workdir" "$prompt_file" \
  --model gemini-4-neon-high >"$out/neon.txt" 2>&1 &
p3=$!

failed=0
for pair in "Claude Opus:$p1:claude" "GPT Sol:$p2:gpt" "Gemini Neon:$p3:neon"; do
  IFS=: read -r name pid file <<<"$pair"
  wait "$pid" || failed=$((failed + 1))
  echo "=================== $name ==================="
  cat "$out/$file.txt"
  echo
done
rm -rf "$out"
exit "$failed"
