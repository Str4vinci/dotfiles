---
name: gh-create-pr
description: Draft, create, or update clear GitHub pull requests from repository evidence. Use when asked to prepare or improve a PR title or body, explain a branch for reviewers, open a PR with gh, or edit an existing PR with gh. Prioritise an accessible human explanation before implementation detail and report only verified changes, impact, limitations, and validation.
---

# Create a GitHub pull request

Write for a developer who understands the project but has not followed the implementation.
Explain the change before cataloguing it.

Read [references/pr-writing.md](references/pr-writing.md) before drafting the title or body.
Read [references/examples.md](references/examples.md) when the change is difficult to explain, the draft sounds mechanical, or a concrete before-and-after pattern would help.

## Choose the operation

Determine whether the user asked to:

- draft or revise text only;
- create a new GitHub PR; or
- update an existing GitHub PR.

Do not create or edit a PR when the user asked only for wording, review, diagnosis, or suggestions. Treat "draft a PR description" as text-only work unless the user clearly asked for a GitHub draft PR.

## Establish the evidence

Inspect the repository before writing. Use the available terminal with `git` and `gh`; do not depend on agent-specific tool names or prompt substitutions.

1. Read applicable repository instructions and the pull-request template.
2. Confirm the repository, current branch, working-tree state, remote, and intended base branch.
3. Check whether a PR already exists for the branch.
4. Review the commits and complete base-to-head diff, including changed files and generated artifacts.
5. Gather issue context, stack relationships, compatibility notes, test output, and validation provenance that are actually available.
6. Separate branch-specific evidence from checks run on a larger stack or an earlier branch state.

Use the user's stated base when provided. Otherwise discover it from repository instructions, existing PR metadata, remote defaults, or branch relationships. Do not hard-code `main`, `master`, or `develop`.

Do not alter source files, stage changes, commit, or push merely to write a PR unless the user also asked for those actions. Preserve unrelated and uncommitted work. Read-only runs that measure impact (see "Show the impact") are part of writing the PR and are expected; keep their scripts and outputs outside the repository.

If essential facts remain uncertain, use bounded language or identify the missing evidence. Never invent motivation, user impact, test results, issue links, compatibility, or limitations.

## Draft the PR

Draft the opening before the detailed sections.

1. Start with the **10-second executive lead**: one plain-English sentence (max 25 words) stating the user or engineering outcome without code symbols, config keys, or bare PR numbers.
2. Explain the relevant behaviour or limitation before this change.
3. State what was wrong, inconsistent, missing, or difficult.
4. State what the PR changes and why the reader should care.

Keep this opening proportional to the change. A small PR may need one short paragraph; a complex PR may need two to four. Unless a repository template requires it, begin with the explanation rather than a generic `Summary` heading.

Then add only useful sections, such as:

- `What changed`
- `Technical details`
- `Impact`
- `Compatibility`
- `Known limitations`
- `Follow-ups`
- `Validation`
- `Stack context`

Omit empty headings. Do not repeat the opening under `Why`. Use bullets for parallel facts and prose for reasoning. Use a table only when several exact comparisons are easier to scan that way.

Write an outcome-focused title in sentence case. Do not include the PR number. Prefer what becomes correct, consistent, supported, or possible over internal operations such as "refactor", "consolidate", or "update" when a clearer outcome is known.

## Show the impact

A reviewer should be able to see what the change does to results, not only why it was needed. When a change can alter reported numbers, outputs, performance, or user-visible behaviour, measure it and put the evidence in an `Impact` section. Skip this only for changes that cannot move anything observable (docs, comments, pure renames, CI config), and say so in one line when a reader might expect numbers.

1. **Compare before and after on the same inputs.** Run the base branch and the PR head on identical, representative inputs. Prefer the repository's own fixtures or golden scenarios (for example committed baseline outputs or a regeneration tool) over ad-hoc cases, and cover the cases the change targets plus at least one it should leave alone.
2. **Report the headline metrics users read**, not internal counters: for a simulator, the reported yields, costs, key rates or state values; for a performance change, timings with hardware and repeat count; for a behaviour change, the before and after output or error for one concrete input.
3. **Show it in a compact table**: one row per scenario, columns for the before and after values of each metric. Include the scenarios that did not change, marked unchanged, so the reader sees the boundary. When the effect is a series (per month, per year, across a sweep), a Mermaid `xychart-beta` block renders as a chart on GitHub and can replace a long table.
4. **Interpret it in two or three sentences**: the size in context (percentage points, currency, relative change), the direction and why it goes that way, and whether it matters for users or earlier published results.
5. **State the comparator and scope exactly**: which base commit, which inputs, what was not measured. Keep the measurement scripts out of the repository unless they are worth committing as a tool.

If a measurement is not practical, use the evidence-safe fallback in [references/examples.md](references/examples.md) rather than implying there is no effect.

## Report validation

List commands exactly enough to reproduce them and state the observed result. Distinguish:

- checks run on the current branch;
- checks inherited from a combined or stacked branch;
- checks not run, with the reason when useful;
- failures known to be unrelated, with evidence for that boundary.

Do not present an earlier combined run as branch-specific validation. Do not claim that behaviour is unchanged, output is bit-for-bit identical, or a failure is unrelated unless the evidence establishes it.

## Create or update with gh

Before changing GitHub state, re-check the title, base, head, and final body against the evidence.

- Prefer a body file with `gh pr create --body-file` or `gh pr edit --body-file` so Markdown and shell characters are preserved.
- Use the repository's requested PR type, labels, reviewers, issue-closing syntax, and draft state only when supported by the request or repository guidance.
- Do not push implicitly unless the user asked for the complete publish workflow and pushing is required.
- After creation or update, read the PR back with `gh pr view` and verify the title, base, head, body, URL, and draft state.

Return the PR URL and a concise account of what was created or changed. If working text-only, return the final title and copy-ready body.

## Final quality check

Before delivering, confirm that:

- the opening begins with a clear 10-second executive lead understandable without reading the diff or memorizing past PRs;
- no code symbols, config keys, formulas, or bare issue/PR numbers appear in that first sentence;
- the problem appears before the implementation detail;
- technical terms are necessary and explained by context;
- the title describes the outcome;
- every quantitative and validation claim is sourced from inspected evidence;
- a change that can move results shows a measured before-and-after comparison, or says why it could not be measured;
- the body follows the repository template without becoming repetitive;
- the length matches the size and risk of the change; and
- the prose sounds like a knowledgeable colleague, not a generated change log.
