---
name: handoff
description: Compact the current conversation into a handoff document so another agent or session can resume unfinished work. Use when context is running low, when stopping mid-task, or when handing in-flight work to another agent. To specify a new task that has not been started yet, use nextprompt instead.
argument-hint: "[what the next session should focus on]"
disable-model-invocation: true
---

# Handoff

Write down what the repository cannot tell the next agent.

A diff records what changed. It does not record what was tried and abandoned, which
approach was rejected and why, or which trap cost an hour to find. That knowledge only
exists in this conversation, and it is the whole point of the document.

## The inclusion test

For every line you are about to write, ask: could a competent agent rebuild this by
reading the repo?

If yes, cut it and reference the path instead. File lists, function signatures and
line-by-line change logs are all reconstructible. Do not restate the diff.

If no, keep it. Decisions not taken, rejected alternatives, discovered constraints and
in-flight state are the content.

## Where to write it

1. If the repo has a ledger document that already carries state between sessions
   (`nextwork.md`, `currentstatus.md`, a `docs/*-handover.md`, or the "what's next"
   section of a roadmap), update that. It is the file another agent will actually find,
   and Codex reads the same repos.
2. Otherwise write to the OS temporary directory, not the workspace.

Say which file you wrote and give the full path.

## Gather the facts first

Do not write the state section from memory. Run:

- `git status --short` and `git diff --stat` in every repo the work touched
- `git log --oneline -10` on the current branch
- the branch name and its base

If work spans sibling repos that deploy together, cover each one.

## Sections

**Where things stand.** Each repo, its branch and base, and what is uncommitted.
Name the dependency versions if the work depends on them.

**What was just finished.** Short. One paragraph per unit of work, saying what it
does, not which lines moved.

**Decisions taken, and decisions deliberately not taken.** Both, with the reason.
"A validator was deliberately not added here, because it would be a second copy of a
rule that lives upstream" is the kind of line that stops the next agent undoing the
work. This section is usually the most valuable one.

**Dead ends.** What was attempted and rejected, and what made it fail. Without this
the next agent retries it.

**Traps.** Anything that behaved unexpectedly, with the mechanism. Import-time
evaluation, fixture ordering, a cache that survives a restart. Be specific enough to
act on.

**Where I stopped.** The exact next step, and any half-finished edit sitting in the
tree.

**Verification state.** Which gates were run, which passed, and the numbers.
Record baselines as counts, for example "615 passed, 7 skipped, 2 deselected", and flag
pre-existing failures or warnings as pre-existing so nobody tries to fix them.

**Suggested skills.** Name the skills the next agent should invoke with the Skill tool,
and why each one applies. Check the available skills rather than guessing at names.

**Open questions.** Anything that needs a human decision before the work can continue.

Drop any section that has no content. An empty heading is noise.

## Rules

- Redact secrets, tokens, keys and personal data. Name an environment variable, never
  its value.
- Reference specs, ADRs, plans, issues and commits by path, number or URL. Do not
  paste their contents.
- Constraints are the exception to referencing. If a constraint governs the next
  agent's work, write it inline even when it also lives in `CLAUDE.md` or `AGENTS.md`.
  A referenced constraint is a constraint that gets skimmed past.
- Keep the repo's git policy in the document, because it varies per repo.
- Write in plain technical English. Short sentences, one idea each.

If the user passed an argument, treat it as the focus of the next session and weight
the document towards what that focus needs.
