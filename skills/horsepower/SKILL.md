---
name: horsepower
description: Delegate code changes to an outside worker in its own Git worktree, then verify and commit the result. Defaults to Claude Opus when invoked from Codex and GPT 6.2 Sol when invoked from Claude Code. Use only when the user invokes horsepower ($horsepower or /horsepower) or explicitly asks a supported outside model to implement something. For reviews, use reviewer or council.
---

# Horsepower: outside workers for implementation

Horsepower is for **writing code**. A worker makes the change in its own git
worktree. You review the diff, run the checks, and commit. For a read-only
review, use `/reviewer` (one model) or `/council` (three models).

## Pick the worker

| Worker | How to start it |
| --- | --- |
| Claude Opus from Codex (default) | `~/code/dotfiles/skills/_workers/claude-worker.sh <label> rw <worktree> <prompt-file> --model opus --effort medium` |
| GPT Sol (default from Claude Code) | `~/code/dotfiles/skills/_workers/codex-worker.sh <label> rw <worktree> <prompt-file> -m gpt-6.2-sol -c model_reasoning_effort="high"` |
| Gemini Neon | `~/code/dotfiles/skills/_workers/agy-worker.sh <label> rw <worktree> <prompt-file> --model gemini-4-neon-high` |
| Claude Opus from Claude Code | Agent tool, `model: opus`, `effort: medium`, `isolation: worktree`, `run_in_background: true`. |

- Use the invoking app's default unless the user names another worker.
- When using a GPT worker for design and model decisions, use
  `-m gpt-6.2-astra -c model_reasoning_effort="high"`.
- Always pass the model arguments, even when they match `~/.codex/config.toml`.
- The Neon `rw` mode is not tested yet. Watch the first run, and tell the user
  if it hangs or asks for approval.

## Start a worker

1. Make a git worktree for the worker under `/home/leo/code/`, never in `/tmp`
   (tmpfs) and never in the user's main checkout. Two workers must not share a
   worktree. The native Claude Code Agent tool creates its own worktree.
2. Write the prompt to a file, for example `/tmp/hp-<label>.md`, and pass the
   file path to the worker script.
3. In Codex, start the script with `exec_command` and a short `yield_time_ms`,
   then poll with `write_stdin` until it finishes. Use sandbox escalation for
   the worker's network access when required. In Claude Code, run scripts
   through Bash with `run_in_background: true` and a `timeout` of at least
   1800000 ms. Start independent workers together when using more than one.
4. Read the result block that the script prints when it finishes.
   The run directory `~/.cache/agent-workers/<ts>-<label>/` holds `result.md`,
   `log.txt` (the full transcript), and `meta.txt` (session id and exit code).

To send a follow-up to the same worker, run the same script with
`--resume <session-id>` before the other arguments. The session id is in
`meta.txt`. For a native Claude Code subagent, use SendMessage.

## Write the prompt

The worker does not see this conversation. Each prompt must stand alone:

- The goal, and why it matters.
- The exact files, symbols, issue numbers, and constraints you already know.
- What "done" means: the tests to run and the checks to pass.
- The shape of the final message, for example "summarize the diff and the test
  output".
- "Do not commit, push, or open PRs. Leave changes uncommitted."

Point a Claude worker to applicable `AGENTS.md` instructions in the worktree.
Codex reads them automatically.

## Rules

- Never pass `--dangerously-bypass-approvals-and-sandbox`,
  `danger-full-access`, or `--dangerously-skip-permissions`.
- If a worker needs network (for example `uv sync`), do that step yourself
  before you start it. Only add `-c sandbox_workspace_write.network_access=true`
  if the user agrees.
- You commit, not the worker. Before you commit, read the diff
  and check `git -C <worktree> status --short` for new files. Run the tests and
  linters yourself. The Claude CLI worker can edit files and inspect Git, so
  run any required shell checks from the parent session. Commit
  messages follow the user's rules: no tool attribution of any kind.
- Treat results as reports, not facts. Check the diff and re-run the tests. If
  the exit code is not 0 or `result.md` is empty, read the tail of `log.txt` and
  tell the user what failed. Do not retry silently.
