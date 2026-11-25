---
name: reviewer
description: Get a read-only second opinion from one outside model — GPT 6.2 Sol through Codex by default, Gemini 4 Neon through agy, or a Claude Opus subagent — on code, a diff, a PR, a plan, or a design. Use ONLY when the user invokes /reviewer or explicitly asks one of these models to review something. For three models at once, use the council skill.
---

# Reviewer: one outside model, read-only

One delegate reviews the work. It does not change files. You check its findings
and report them. For three reviewers from three providers, use `/council`.

## Before the review

Address outstanding PR comments, fix known issues, and run the relevant checks.
Do not hold back known fixes for the reviewer to find.

## Pick the reviewer

| Reviewer | How to start it |
| --- | --- |
| GPT Sol (default) | `~/code/dotfiles/skills/_workers/codex-worker.sh review-gpt ro <workdir> <prompt-file> -m gpt-6.2-sol -c model_reasoning_effort="high"` |
| Gemini Neon | `~/code/dotfiles/skills/_workers/agy-worker.sh review-neon ro <workdir> <prompt-file> --model gemini-4-neon-high` |
| Claude Opus | Agent tool, `subagent_type: general-purpose`, `model: opus`, `effort: high`, `run_in_background: true`. |

- Use GPT Sol unless the user names another reviewer.
- Run the scripts through Bash with `run_in_background: true` and a `timeout` of
  at least 1800000 ms.
- If the reviewer cannot start (CLI missing, not logged in, model not listed),
  tell the user. Do not put a different model in its place.
- The run directory is `~/.cache/agent-workers/<ts>-<label>/`. See
  `~/code/dotfiles/skills/_workers/README.md`.

## The prompt

Write the prompt to a file, for example `/tmp/review-<topic>.md`. The reviewer
does not see this conversation, so the prompt must stand alone:

- What to review and why it matters.
- The files, the diff (`git diff <base>...HEAD`), or the PR number.
- The constraints and decisions that are already made, so that the reviewer does
  not argue them again.
- "Read-only. Do not edit files, commit, or push."
- The answer format: findings as `file:line` with severity and a one-line
  reason. For a code review, end with a last line `Score: N/10`.

## Report

Check each finding against the code before you report it: open the cited
`file:line` and re-run the test. Then give the user the real findings, the ones
you rejected with a one-line reason each, and the fixes you recommend. Fix the
ones you agree with. Keep the scope small: list good ideas outside the task as
follow-ups. Do not do them.
