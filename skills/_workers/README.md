# Agent workers

Shared scripts for the `horsepower`, `reviewer`, and `council` skills. Each
script runs one outside AI CLI once, without interaction, and blocks until it
finishes. The calling agent runs it in the background and reads the result.

This folder is not a skill. It has no `SKILL.md`, and nothing links it into
`~/.claude/skills/`. The skills call the scripts by their path in dotfiles.

| Script | CLI | Read-only (`ro`) | Write (`rw`) |
| --- | --- | --- | --- |
| `codex-worker.sh` | OpenAI Codex (`codex exec`) | `read-only` sandbox | `workspace-write` sandbox, only `<workdir>`, no network |
| `agy-worker.sh` | Google Antigravity (`agy -p`) | `--mode plan` | `--mode accept-edits --sandbox` (not tested yet) |
| `claude-worker.sh` | Claude Code (`claude -p`) | Read, Grep, Glob, read-only git | also Edit and Write; other shell commands blocked |

`council.sh <workdir> <prompt-file>` runs the three workers in parallel, read-only
(Claude Opus high, GPT 6.2 Sol high, Gemini 4 Neon high), and prints all three
results. The council skill uses it in Claude Code, Codex, and agy.

`claude-worker.sh` passes `--permission-mode default`, because the user default
is `auto`, which would approve shell writes. It removes `ANTHROPIC_API_KEY` and
`ANTHROPIC_AUTH_TOKEN`, so that the run uses your subscription login and not API
billing. Do not add `--bare`: it skips the subscription login.

```sh
<script> <label> <ro|rw> <workdir> <prompt-file> [extra CLI args...]
<script> --resume <session-id> <label> <ro|rw> <workdir> <prompt-file> [extra CLI args...]
```

Run a script with no arguments to print its usage. Each run writes
`prompt.md`, `result.md`, `log.txt`, and `meta.txt` to
`~/.cache/agent-workers/<timestamp>-<label>/`. The session id for `--resume` is
in `meta.txt`.

In plan mode, agy writes an `implementation_plan.md` artifact instead of
answering. `agy-worker.sh` puts a line at the start of every `ro` prompt that
tells agy to answer directly.

Headless agy cannot ask for a permission. It denies the tool, then reports
`SUCCESS` with an empty answer. In `ro` mode, `agy-worker.sh` allows
`read_file(*)` for the session, so agy can read files outside the workdir and
paths written with `~`. If the answer is still empty, the script exits 1 and
prints the denied tools on stderr and in `meta.txt`.

## Requirements

- [Codex CLI](https://developers.openai.com/codex/cli), signed in (`codex login`).
- Antigravity CLI (`agy`), signed in.
- Claude Code (`claude`), signed in with your own subscription.
- Bash, git, and `jq`.

## Scope and safety

These scripts are for an agent on your own machine, started by you, with your
own sign-ins.

- Do not run them in CI for a public repository. OpenAI's
  [CI/CD auth guide](https://developers.openai.com/codex/auth/ci-cd-auth) says
  not to use ChatGPT-managed auth for public or open-source repositories. Use an
  API key for automation.
- Treat `~/.codex/auth.json` and the agy credentials like passwords. Never commit
  them or copy them to another machine.
- `codex-worker.sh` never passes `--dangerously-bypass-approvals-and-sandbox` or
  `danger-full-access`. `agy-worker.sh` never passes
  `--dangerously-skip-permissions`. Keep it that way.
- Several Codex workers at once share one sign-in. If runs fail with
  `token_invalidated`, run one worker at a time or use an API key
  ([openai/codex#26303](https://github.com/openai/codex/issues/26303)).
