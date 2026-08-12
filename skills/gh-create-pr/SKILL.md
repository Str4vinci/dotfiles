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

Do not alter source files, stage changes, commit, push, or run new validation merely to write a PR unless the user also asked for those actions. Preserve unrelated and uncommitted work.

If essential facts remain uncertain, use bounded language or identify the missing evidence. Never invent motivation, user impact, test results, issue links, compatibility, or limitations.

## Draft the PR

Draft the opening before the detailed sections.

1. Explain the relevant behaviour or limitation before this change.
2. State what was wrong, inconsistent, missing, or difficult.
3. State what the PR changes and why the reader should care.

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

- the first paragraph is understandable without reading the diff;
- the problem appears before the implementation detail;
- technical terms are necessary and explained by context;
- the title describes the outcome;
- every quantitative and validation claim is sourced from inspected evidence;
- the body follows the repository template without becoming repetitive;
- the length matches the size and risk of the change; and
- the prose sounds like a knowledgeable colleague, not a generated change log.
