---
name: handoff
description: Before /clear or a new thread, write a handoff document with what the repo cannot tell the next agent, plus a paste-ready kickoff prompt that starts the next session. Run only when the user explicitly invokes it.
argument-hint: "[what the next session should focus on]"
disable-model-invocation: true
---

# Handoff

The user runs this when the context is nearly full and they are about to `/clear` or
open a new thread. Produce two things:

1. **The handoff document.** A file with the state that exists only in this
   conversation. It looks back.
2. **The kickoff prompt.** A paste-ready brief that starts the next session. It looks
   forward. It points at the document and states the contract: what to do, what must
   not move, and how to prove it worked.

The next agent sees neither this conversation nor anything you did not write down.

If the user passed an argument, treat it as the focus of the next session. Weight both
outputs towards what that focus needs.

## Spend the remaining context carefully

The context is nearly full. Gather facts with cheap commands such as `git status`,
`git diff --stat` and `grep -n`. Do not read whole files or print full diffs. Write
from what this conversation already established, and verify only what could have moved.

## Gather the facts first

Do not write state from memory. Run:

- `git status --short` and `git diff --stat` in every repo the work touched
- `git log --oneline -10` on the current branch
- the branch name and its base

If the work spans sibling repos that deploy together, cover each one.

Verify every anchor the kickoff prompt will name. Confirm that each `file.py:line`
still points at what you claim, and that the functions, flags and config keys you name
still exist. If you cannot verify an anchor, say so and tell the next agent to locate it
by shape rather than by line.

## Part 1: the handoff document

### The inclusion test

For every line you are about to write, ask: could a competent agent rebuild this by
reading the repo?

If yes, cut it and reference the path instead. File lists, function signatures and
line-by-line change logs are all reconstructible. Do not restate the diff.

If no, keep it. Decisions not taken, rejected alternatives, discovered constraints and
in-flight state are the content.

### Where to write it

1. If the repo has a ledger document that already carries state between sessions
   (`nextwork.md`, `currentstatus.md`, a `docs/*-handover.md`, or the "what's next"
   section of a roadmap), update that. It is the file another agent will actually find,
   and Codex and Claude read the same repos.
2. Otherwise write a new file in the OS temporary directory, not the workspace. Name it
   for the work and date it, for example `/tmp/handoff-pv-options-2026-08-09.md`.

### Sections

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
act on. Date them.

**Where I stopped.** The exact next step, and any half-finished edit sitting in the
tree.

**Verification state.** Which gates were run, which passed, and the numbers.
Record baselines as counts, for example "615 passed, 7 skipped, 2 deselected", and flag
pre-existing failures or warnings as pre-existing so nobody tries to fix them.

**Open questions.** Anything that needs a human decision before the work can continue.

Drop any section that has no content. An empty heading is noise.

## Part 2: the kickoff prompt

This is a contract, not a summary. Everything in it must be checkable against the repo.
Read [references/kickoff-template.md](references/kickoff-template.md) for the section
order and the wording that has worked.

Scale it to the next step. If the next session only continues where this one stopped,
the prompt can be short: repo and branch, "read the handoff first", the next step, the
hard constraints, verification and git policy. If it starts a new, well-defined task,
use the full template.

Always include:

- **The handoff document as the first thing to read**, by full path. Do not restate
  its contents. Keep "already shipped, do not redo" to two lines.
- **Tasks in dependency order**, not importance order. Name the anchor file to read
  first.
- **An explicit scope fence.** Defaults that must not move, files not to touch, public
  signatures that are documented API, work owned by another thread. The most common
  failure is an agent tidying something adjacent.
- **Intentional oddities.** If something looks like a bug and is not, say why and
  write "preserve it, do not fix it".
- **An escalation clause.** When the plan turns out to be wrong once in the code, stop
  and report rather than force it through.
- **Verification as commands plus numbers.** Exact command lines and the baseline
  counts they should produce. Mark pre-existing failures as pre-existing.
- **The git policy.** It varies per repo. Say whether to commit, branch, push or only
  show the diff.
- **Suggested skills.** Name the skills the next agent should invoke and why. Check the
  available skills rather than guessing at names.

If the next task must not change behaviour, also read
[references/behaviour-preserving.md](references/behaviour-preserving.md) and put its
proof requirement in the prompt.

## Output

1. Write or update the handoff document. State its full path.
2. Emit the kickoff prompt as paste-ready text in one fenced block. Do not save it into
   the repo, and do not commit it.
3. End with one line telling the user they can now `/clear` or open a new thread and
   paste the prompt.

## Rules

- Redact secrets, tokens, keys and personal data. Name an environment variable, never
  its value.
- Reference specs, ADRs, plans, issues and commits by path, number or URL. Do not
  paste their contents.
- Constraints are the exception to referencing. If a constraint governs the next
  agent's work, write it inline in the kickoff prompt even when it also lives in
  `CLAUDE.md` or `AGENTS.md`. A referenced constraint is a constraint that gets skimmed
  past.
- Write in plain technical English. Short sentences, one idea each.
