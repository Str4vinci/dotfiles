---
name: council
description: Get one independent read-only review or opinion from three models of three providers in parallel — Claude Opus, GPT 6.2 Sol, and Gemini 4 Neon, all at high effort — then check and merge the findings. Use ONLY when the user says "council" or invokes /council.
---

# Council

Three reviewers from three providers review the same thing at the same time.
You collect their answers, check them, and report. There is **one round**,
unless the user asks for another. Tokens are limited.

This skill is the same in Claude Code, Codex, and Antigravity (agy). The
reviewers are always fresh, separate runs. You lead; you are not one of the
three.

## Before you call the council

Address outstanding PR comments, fix known issues, and run the relevant checks.
Give the council the current implementation. Do not hold back known fixes for
the reviews to find. If the user wants to discard the implementation and explore
new ideas, do not fix code that will be replaced.

## Write the prompt

Write one prompt file, for example `/tmp/council-<topic>.md`. All three
reviewers get the same text. They do not see this conversation, so the prompt
must stand alone:

- The user's request and why it matters.
- The files, the diff (`git diff <base>...HEAD`), or the PR number to look at.
- The constraints and the decisions that are already made, so that the
  reviewers do not argue them again.
- "Read-only. Do not edit files, commit, or push."
- The answer format: findings as `file:line` with severity and a one-line
  reason. For a code review, end with a last line `Score: N/10`.

## Run the council

```bash
~/code/dotfiles/skills/_workers/council.sh <workdir> /tmp/council-<topic>.md
```

The script starts the three reviewers in parallel and waits for all of them:

| Reviewer | Run by |
| --- | --- |
| Claude Opus, effort high | `claude-worker.sh` (`claude -p`, your own login, read-only tools) |
| GPT Sol, effort high | `codex-worker.sh` (`codex exec`, read-only sandbox) |
| Gemini Neon, high | `agy-worker.sh` (`agy -p`, plan mode) |

It prints one block per reviewer. The exit code is the number of reviewers that
failed. A review takes minutes, so use a long timeout (at least 30 minutes):

- **Claude Code:** Bash with `run_in_background: true` and `timeout: 1800000`.
  Do other work while it runs; you get a notification when it ends.
- **Codex:** the command needs network access, which the sandbox blocks. Ask
  for approval to run it outside the sandbox, with a timeout of at least
  1800000 ms.
- **agy:** run it as a terminal command with a timeout of at least 30 minutes.
  Approve it if agy asks.

If a reviewer fails (CLI missing, not logged in, model not available), tell the
user what failed. Read the tail of `log.txt` in its run directory under
`~/.cache/agent-workers/`. Do not retry silently and do not put a different
model in its place.

If the user names other council members, do not use `council.sh`. Run the
single-worker scripts in the same folder in parallel with the models they name.
See `~/code/dotfiles/skills/_workers/README.md`.

## Report

Check each finding against the code before you report it: open the cited
`file:line` and re-run the test. Then give the user:

1. The real findings, merged and de-duplicated, with the reviewers that raised
   each one.
2. Where the reviewers disagree, and your opinion.
3. The findings you rejected, with a one-line reason each.
4. The fixes you recommend, in scope only.

Then fix the findings that you agree with. **Do not start a second round
unless the user asks.** A fresh review of the fixed code is a new round.

## Scores in the PR

For a code review that ends in a pull request, put this section in the PR
description, before the model and harness line at the end. Add one column per
round:

```markdown
## Council review

Rounds: 1

| Reviewer | Round 1 |
| --- | --- |
| Claude Opus | 8/10 |
| GPT Sol | 7/10 |
| Gemini Neon | no score |
```

If a reviewer gives no score, write `no score`. Do not invent one. If the PR is
open, edit the description (`gh pr edit --body-file`). Do not post a comment.
If there is no PR, put the table in your final reply.

## Keep the scope small

Reviewers suggest more work than the task needs. Your job is to keep the scope
limited. Fix bugs and real risks in the change. List good ideas outside the
scope as follow-ups for the user to decide on. Do not do them.
