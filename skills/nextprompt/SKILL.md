---
name: nextprompt
description: Write a paste-ready task brief that starts a new, well-defined piece of work in a fresh session. Use when the current task is finished and the next one needs specifying in a clean thread. To preserve unfinished in-flight state instead, use handoff.
argument-hint: "[the task the next session should do]"
disable-model-invocation: true
---

# Next prompt

Produce a brief that a fresh agent can act on without this conversation.

This is a contract, not a summary. It states what to do, what must not move, and how
the next agent proves it worked. Everything in it should be checkable against the repo.

Read [references/template.md](references/template.md) for the section order and the
wording that has worked.

## Before writing

Verify, do not recall. Every anchor in the brief gets checked against the current tree:

- Confirm each `file.py:line` reference actually points at what you claim. Line numbers
  move.
- Confirm the functions, flags and config keys you name still exist.
- Run `git status`, `git log --oneline -5` and the branch name.
- Read the repo's ledger docs and `AGENTS.md` or `CLAUDE.md` so the brief matches
  house rules.
- Establish the current verification baseline by running the gate, or by quoting the
  last recorded run. A baseline you guessed is worse than none.

If an anchor cannot be verified, say so in the brief and tell the next agent to locate
it by shape rather than by line.

## What makes the brief work

**Order the tasks by dependency**, not by importance. Say which one is the anchor to
read first.

**Fence the scope explicitly.** Name what must not change: defaults that must not move,
files not to touch, public signatures that are documented API, work in progress in
another thread. The most common failure is an agent tidying something adjacent.

**Protect intentional oddities.** If the repo contains something that looks like a bug
and is not, say so and say why. For example a documented asymmetry, a file left
deliberately unformatted, or a known-failing test. Write "preserve it, do not fix it".

**Carry the traps forward.** If this repo has already made a mistake in this area,
describe it and how to avoid repeating it. Date it.

**Give an escalation clause.** State what the agent should do when the plan turns out
to be wrong once it is in the code: stop and report, rather than force it through.

**State the verification as commands plus numbers.** Exact command lines, and the
baseline counts they should produce. Mark pre-existing failures and warnings as
pre-existing.

**State the git policy.** It differs per repo. Say whether to commit, branch, push or
only show the diff.

## Behaviour-preserving refactors

When the task must not change behaviour, specifying the tests is not enough. Require
proof:

- Build a probe that exercises the affected surface across its option matrix, including
  the error paths, and captures the exception type and message for every invalid input.
- Hash the raw float bytes of the numerical outputs rather than comparing printed values.
- Run the probe against a `git worktree` at the current HEAD and against the working
  tree, then diff the digests. They must match exactly.
- Keep the probe in the scratchpad, not in the repo.

Say "prove equivalence, do not assume it" and name the surface to cover.

## Output

Emit the brief as paste-ready text in a fenced block. Do not save it into the repo,
and do not commit it.

Close with a suggested skills line naming the skills the next agent should invoke and
why. Check the available skills rather than guessing at names.

If a handoff document exists for the in-flight state, reference it by path rather than
restating it, and keep the "already shipped, do not redo" section to a paragraph.

Write in plain technical English. Short sentences, one idea each.
