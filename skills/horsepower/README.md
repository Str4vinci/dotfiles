# horsepower

A Claude Code skill that hands subagent-style work to OpenAI Codex CLI workers.
Each worker is one `codex exec` run in the background. Read-only workers do
research, review and diagnosis. Write workers make code changes in their own git
worktree. The calling agent reviews the diff, runs the tests and commits; Codex
never commits.

Invoke it with `/horsepower`, or ask the agent to use Codex workers. It does not
trigger on its own.

## Requirements

- [Codex CLI](https://developers.openai.com/codex/cli), signed in (`codex login`).
- Bash and git.

## Install

From the dotfiles root:

```sh
stow -t ~ agent-skills
```

This links `~/.claude/skills/horsepower` to this directory. The skill is linked
for Claude Code only; under Codex it would delegate to itself.

## Use

The wrapper is `scripts/hp.sh`. Run it with no arguments for usage.

```sh
scripts/hp.sh <label> <ro|rw> <workdir> <prompt-file> [extra codex args...]
scripts/hp.sh --resume <session-id> <label> <ro|rw> <workdir> <prompt-file>
```

- `ro` runs Codex in a read-only sandbox.
- `rw` runs it in a workspace-write sandbox, limited to `<workdir>`, with no
  network access.

Each run writes `prompt.md`, `result.md`, `log.txt` and `meta.txt` to
`~/.cache/horsepower/<timestamp>-<label>/`. The session id for `--resume` is in
`meta.txt`.

Model choice by task:

| Task | Arguments |
| --- | --- |
| Code implementations, reviews, and revisions | `-m gpt-6.1-sol -c model_reasoning_effort="high"` |
| Design and model decisions | `-m gpt-6-astra -c model_reasoning_effort="medium"` |

Other work uses the default in `~/.codex/config.toml`.

## Scope and safety

This skill is for an agent on your own machine, started by you, with your own
Codex sign-in.

- Do not run it in CI for a public repository. OpenAI's
  [CI/CD auth guide](https://developers.openai.com/codex/auth/ci-cd-auth) says
  not to use ChatGPT-managed auth for public or open-source repositories. Use an
  API key for automation.
- Treat `~/.codex/auth.json` like a password. Never commit it or copy it to
  another machine.
- The wrapper never passes `--dangerously-bypass-approvals-and-sandbox` or
  `danger-full-access`. Keep it that way.
- Several workers at once share one sign-in. If runs fail with
  `token_invalidated`, run one worker at a time or use an API key
  ([openai/codex#26303](https://github.com/openai/codex/issues/26303)).
