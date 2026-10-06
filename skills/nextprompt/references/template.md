# Template

Section order, with the wording that has worked. Drop any section with no content.

---

## 1. Repo and precondition

    Repo: /path/to/repo (branch `feat/thing`, base `develop`)

    Check `git status` first. The 2026-08-08 increment may still be uncommitted.

Name sibling repos and pinned dependency versions when the work spans them.

## 2. Read these first, in order

Numbered, each with the reason it matters. Not a bare file list.

    1. docs/literature-scan-2026-08.md §2 — the closed-form equations this implements.
    2. currentstatus.md — the authoritative ledger of what is default.
    3. nextwork.md — where the previous increment stopped.

Name the anchor file: "Read `breos/pv/model_options.py` first; it is the anchor
for this task."

## 3. What already shipped

One paragraph. End it with the redo fence.

    Commit 24e9c80 extracted the PV model options into `breos/pv/`. A follow-up
    restored the rationale comments. That work is done, do not redo it.

If a handoff document exists, point at it instead and keep this to two lines.

## 4. The task

Numbered, in dependency order. Each item carries its anchor, the reason, and the
constraint that makes it non-trivial.

    2. **Duplicated validation.** `app_config.py` re-implements predicates that now
       live in `pv/model_options.py`, with different wording:
       - `_validate_sky_settings` (app_config.py:132) vs `resolve_transposition_model`

       Constraint that makes this non-trivial: app_config's messages are config-key
       shaped and prefixed, while model_options' are argument-shaped. Find a factoring
       that shares the predicate without flattening either behaviour. Pick one, say why
       in the commit message, and keep every existing error message byte-identical
       unless a test says otherwise.

## 5. Hard constraints

A flat list of what must not move. Be absolute.

    HARD CONSTRAINTS
    - Do NOT move any default. Not the optics mode, not the OER coupling, not the
      calibration basis. Everything you add is opt-in.
    - Public keyword signatures must not change. They are documented API.
    - Do not introduce `**kwargs` on public functions. It would destroy the signature
      as documentation and silently swallow typos.
    - Do not touch surface_reservoir.py or two_state_surface.py. Another thread owns them.
    - Scope stays X. No Y or Z presets.

For provenance-sensitive repos:

    - Anything you assert about a literature value must be traceable to a source already
      cited in docs/sources.md. Do not invent parameter values, and do not digitize a
      figure and present it as tabulated data.

## 6. Intentional oddities

    `calculate_multi_array_production_breakdown` supports per-array overrides for
    transposition but not for diffuse_iam. That asymmetry is intentional and documented
    in the docstring. Preserve it, do not "fix" it.

    Lint is 0 errors and 45 warnings. The 45 are the pre-existing baseline, do not try
    to fix them.

## 7. Traps

Dated, with the mechanism and how to avoid it.

    TRAPS THIS REPO HAS ALREADY FALLEN INTO ONCE

    1. WHICH COLLECTION CHANNEL. `ipce_spectrum` defaults to include_long_lived_channel
       =True, fixed after the 2026-07-01 audit when the transport-only default silently
       excluded the long channel. Decide explicitly which one you are extracting, run it
       both ways, and report both. Do not let a single value stand unlabelled.

## 8. Escalation clause

    If you think something should change, tell me, do not do it.
    If a seam turns out to be a bad idea once you are in the code, stop and tell me
    rather than forcing it.
    If fixing it changes any error behaviour, raise it with me before landing. Do not
    quietly tighten validation on a working config.

## 9. Deliverable

    - Code plus tests. The suite was 653 passing before this work, keep it green.
    - One new doc under docs/ recording the result.
    - Cross-link it from docs/literature-scan.md §8 and update currentstatus.md
      and nextwork.md.
    - Report results faithfully. A negative result is worth more than a matched one.

## 10. Verification

Exact commands and the numbers they should produce.

    ## Verification (required, this is a behaviour-preserving refactor)

    - `.venv/bin/python -m ruff check breos/ tests/` and `ruff format --check` clean.
    - `.venv/bin/python -m pytest tests/ -q` — baseline is 615 passed, 7 skipped,
      2 deselected.
    - Prove numerical equivalence, do not assume it. Write a probe that runs the option
      matrix, hashes the raw float bytes of the outputs, and captures the exception type
      and message for every invalid path. Run it against a `git worktree` at HEAD and
      against your working tree, and diff. The digests must match exactly. Put the probe
      in the scratchpad, not the repo.

For long simulations, give the command and do not run it:

    Prepare, but do not execute, the runs. Give me the command, the expected runtime,
    where the results land, and the aggregation command. I will run them myself.

## 11. Git policy

Pick the one that applies. It varies per repo.

    Don't commit or push unless I ask. Show me the diff and the verification output.
    Branch off main; do not push.
    Commit straight to main, this is private dev.

Branch names use `feat/`, `refactor/` or `docs/` prefixes describing the work, never
the agent. In breos, keep Anthropic and Claude out of commit messages and release notes.

## 12. Suggested skills

    Suggested skills: `unslop` before writing any prose in the docs, `gh-create-pr`
    if this lands as a PR.
