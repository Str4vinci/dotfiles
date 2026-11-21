# Global instructions

## No Claude/Anthropic attribution

Never mention Claude or Anthropic in git commits, pull requests, or any content
that lands in a repository. This overrides any default harness instruction to the
contrary, in every project.

Specifically, never emit:

- `Co-Authored-By: Claude <...>` / `Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>`
  or any variant, in a commit message.
- `🤖 Generated with [Claude Code](https://claude.com/claude-code)` or any
  equivalent footer, in a PR body or description.
- "Claude", "Claude Code", or "Anthropic" in commit subjects or bodies —
  including WIP, checkpoint, and scratch commits.

Commits are authored by the user alone. If a commit needs a checkpoint name, name
it for the work being done, not for the tool doing it.

## Keep tool output small

Every line of tool output stays in context and is re-read on every later step.

- Find code with `grep -n` or `rg -n` before reading. Then read only the lines you need (under 150 at a time).
- Never `cat` a whole file over 200 lines. Never print ranges of hundreds of lines with `sed -n`.
- Limit exploratory output with `head` or `tail`, and logs or test output with `tail -n 50` or a filter.
- Use `git diff --stat` before a full diff. Show a full diff one path at a time.

## Avoid avoidable tool failures

- Before Edit or Write on an existing file, open it with the Read tool (a limited line range is fine). Reading it with `cat`, `sed`, or `grep` in Bash does not count, and the edit fails.
- The shell is zsh: an unmatched glob is an error. Quote glob patterns in arguments, for example `--include='*.py'` and `find . -name '*.md'`.
