---
name: horsepower
description: Hand an implementation task (code changes) to an outside worker — OpenAI Codex (gpt-6.2-sol) by default, Gemini 4 Neon through agy, or a Claude Opus subagent — in its own git worktree, then review and commit the result yourself. Use ONLY when the user invokes /horsepower or explicitly asks a Codex, GPT, Gemini, Neon, or Opus worker to implement something. For reviews, use the reviewer or council skill instead.
---

# Horsepower: outside workers for implementation

Horsepower is for **writing code**. A worker makes the change in its own git
worktree. You review the diff, run the checks, and commit. For a read-only
review, use `/reviewer` (one model) or `/council` (three models).

## Pick the worker

| Worker | How to start it |
| --- | --- |
| GPT Sol (default) | `~/code/dotfiles/skills/_workers/codex-worker.sh <label> rw <worktree> <prompt-file> -m gpt-6.2-sol -c model_reasoning_effort="high"` |
| Gemini Neon | `~/code/dotfiles/skills/_workers/agy-worker.sh <label> rw <worktree> <prompt-file> --model gemini-4-neon-high` |
| Claude Opus | Agent tool, `model: opus`, `effort: medium`, `isolation: worktree`, `run_in_background: true`. |

- Use GPT Sol unless the user asks for another worker.
- For design and model decisions, use `-m gpt-6.2-astra -c model_reasoning_effort="high"`
  instead. Do not use other models unless the user asks.
- Always pass the model arguments, even when they match `~/.codex/config.toml`.
- The Neon `rw` mode is not tested yet. Watch the first run, and tell the user
  if it hangs or asks for approval.

## Start a worker

1. Make a git worktree for the worker under `/home/leo/code/`, never in `/tmp`
   (tmpfs) and never in the user's main checkout. Two workers must not share a
   worktree. (The Opus worker makes its own worktree.)
2. Write the prompt to a file, for example `/tmp/hp-<label>.md`, with the Write
   tool. Do not pass prompts inline; quoting breaks.
3. Run the script through Bash with `run_in_background: true` and a `timeout` of
   at least 1800000 ms. Real tasks take minutes. Start independent workers in
   the same message so they run at the same time.
4. When the notification arrives, read the result block that the script prints.
   The run directory `~/.cache/agent-workers/<ts>-<label>/` holds `result.md`,
   `log.txt` (the full transcript), and `meta.txt` (session id and exit code).

To send a follow-up to the same worker, run the same script with
`--resume <session-id>` before the other arguments. The session id is in
`meta.txt`. For the Opus worker, use SendMessage.

## Write the prompt

The worker does not see this conversation. Each prompt must stand alone:

- The goal, and why it matters.
- The exact files, symbols, issue numbers, and constraints you already know.
- What "done" means: the tests to run and the checks to pass.
- The shape of the final message, for example "summarize the diff and the test
  output".
- "Do not commit, push, or open PRs. Leave changes uncommitted."

Codex reads `AGENTS.md` in the workdir on its own. You do not need to repeat it.

## Rules

- Never pass `--dangerously-bypass-approvals-and-sandbox`,
  `danger-full-access`, or `--dangerously-skip-permissions`.
- If a worker needs network (for example `uv sync`), do that step yourself
  before you start it. Only add `-c sandbox_workspace_write.network_access=true`
  if the user agrees.
- You commit, not the worker. Before you commit, read the diff
  (`git -C <worktree> diff`) and run the tests and linters yourself. Commit
  messages follow the user's rules: no tool attribution of any kind.
- Treat results as reports, not facts. Check the diff and re-run the tests. If
  the exit code is not 0 or `result.md` is empty, read the tail of `log.txt` and
  tell the user what failed. Do not retry silently.
