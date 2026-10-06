---
name: horsepower
description: Delegate subagent-style work to OpenAI Codex CLI workers (default model gpt-6.1-sol from ~/.codex/config.toml) instead of Claude subagents. Use ONLY when the user invokes /horsepower or explicitly asks to use Codex/GPT workers. Covers read-only research and review, and code changes in a dedicated git worktree.
---

# Horsepower: Codex workers as subagents

Codex workers stand in for the Agent tool. Each worker is one `codex exec` run
launched through Bash with `run_in_background: true`. You get a notification when
it exits, the same way a Claude subagent reports back. Launch independent workers
in the same message so they run concurrently.

The wrapper is `~/.claude/skills/horsepower/scripts/hp.sh`. Run it with no
arguments to print its usage.

## Launch a worker

1. Write the prompt to a file, for example `/tmp/hp-<label>.md`, with the Write
   tool. Do not pass prompts inline; quoting breaks.
2. Run in the background:

   ```bash
   ~/.claude/skills/horsepower/scripts/hp.sh <label> <ro|rw> <workdir> /tmp/hp-<label>.md
   ```

   - `ro`: read-only sandbox. Use it for research, search, review, and diagnosis.
   - `rw`: workspace-write sandbox. Codex can write only inside `<workdir>`, and
     it has no network access.
   - Extra arguments pass through to `codex exec`. Pick the model by task
     (user rule, 2026-10-01):

     | Task | Arguments |
     | --- | --- |
     | Code implementations, reviews, and revisions | `-m gpt-6.1-sol -c model_reasoning_effort="high"` |
     | Design and model decisions | `-m gpt-6-astra -c model_reasoning_effort="medium"` |

     Always pass the arguments explicitly, even when they match
     `~/.codex/config.toml`. For other work (research, search, diagnosis),
     use the config default. Do not use other models unless the user asks.
   - Set the Bash `timeout` to at least 1800000 ms. Real tasks take minutes.
3. When the notification arrives, read the result block printed by the script.
   The run directory `~/.cache/horsepower/<ts>-<label>/` holds `result.md`,
   `log.txt` (the full transcript), and `meta.txt` (session id and exit code).

## Follow up with a worker (the SendMessage equivalent)

```bash
~/.claude/skills/horsepower/scripts/hp.sh --resume <session-id> <label> <ro|rw> <workdir> /tmp/hp-<label>-2.md
```

The session id is in the `meta.txt` of the earlier run.

## Write the prompt

A Codex worker does not see this conversation. Each prompt must stand alone:

- The goal, and why it matters.
- The exact files, symbols, issue numbers, and constraints you already know.
- What "done" means: the tests to run and the checks to pass.
- The expected shape of the final message, for example "list findings as
  file:line with a one-line reason" or "summarize the diff and the test output".
- For `rw` work: "Do not commit, push, or open PRs. Leave changes uncommitted."

Codex reads `AGENTS.md` in the workdir on its own. You do not need to repeat it.

## Rules for code changes

- Give each `rw` worker its own git worktree under `/home/leo/code/`, never in
  `/tmp` (tmpfs) and never in the user's main checkout. Two workers must not
  share a worktree.
- Never pass `--dangerously-bypass-approvals-and-sandbox` or use
  `danger-full-access`.
- If a worker needs network (for example `uv sync`), do that step yourself before
  you launch it. Only add `-c sandbox_workspace_write.network_access=true` if the
  user agrees.
- You commit, not Codex. Before you commit, review the diff (`git -C <worktree>
  diff`), and run the tests and linters yourself. Commit messages follow the
  user's rules: no tool attribution of any kind.

## Treat results as reports, not facts

Verify a worker's claims before you relay them, as you would for a Claude
subagent. Check the cited file:line, re-run the failing test, and read the diff.
If the exit code is not 0 or `result.md` is empty, read the tail of `log.txt`
and tell the user what failed. Do not retry silently.

## When to stay with Claude subagents

Use the Agent tool instead when the task needs this conversation's context, needs
tools Codex lacks (for example MCP connectors or the browser), or is a one-file
lookup you can do directly.
