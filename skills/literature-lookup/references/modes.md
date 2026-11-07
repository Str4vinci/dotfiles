# Modes

## advances: what is new in X

**Search.**
- Find 2–5 anchor papers: well-cited reviews or landmark papers
  (`lit search ... --reviews --sort cited`).
- Run `lit cites ANCHOR --sort date --from <year>` for each anchor.
- Run `lit search ... --sort date --from <year>` including arXiv.
- Default window: the last 3 years, unless the user says otherwise.
- Include preprints, but label them.

**Read.** Read the anchors only as far as needed to know the baseline. Read the
new papers in full.

**Synthesis template.**
```markdown
# Advances in X (YEAR–YEAR)
## Baseline
Where the field stood, with anchor citations.
## What changed
One subsection per development: what was done, the evidence and its strength,
the result with numbers, and whether it is peer reviewed or a preprint.
## Open problems and disagreements
## Groups and venues to watch
## Coverage
Search log summary; N full-text, N abstract-only, N queued.
```

## learn: teach me X

**Search.**
- Prefer review and tutorial papers, lecture notes, and the foundational,
  highly cited papers (`--reviews --sort cited`, no year filter).
- Add one or two recent reviews so the picture is current.
- Keep the set small: 5–10 papers.

**Read.** Read in full, with extra attention to definitions, the core
equations, their assumptions, and their typical parameter values.

**Synthesis template.**
```markdown
# Learning X
## The big picture
What the field is about, in plain words, with the central question.
## Prerequisites
Concepts the reader needs first, with a source for each.
## Core concepts and equations
Each concept: what it means, the equation (LaTeX, with symbols and units), its
assumptions, and the paper it comes from.
## Reading order
1. KEY: why first, which sections to read, what to skip.
2. ...
## Common confusions
## Where the field is now
```

## review: literature review on X

**Search.**
- Agree the scope first (question, inclusion and exclusion rules, years, types).
- Search systematically: run every query on every relevant source and log it.
- Snowball backward and forward from every included paper until a round adds
  nothing new.
- Count records at each stage (found, screened, included, read in full), as a
  light version of PRISMA.

**Read.** Read every included paper in full. Papers that stay abstract-only
must be visible as such in the matrix.

**Synthesis template.**
```markdown
# Review: X
## Scope and method
Question, criteria, sources, dates, counts per stage.
## Synthesis matrix
| Key | Read | System / method | Main result (with numbers) | Limitations | Location |
## Themes
One subsection per theme: what the papers agree on, where they disagree and
why (method, conditions, definitions), and how strong the evidence is.
## Gaps
What nobody has done, stated precisely enough to be checked.
## Coverage and threats to validity
```

## claim-check: is this supported?

**Input.** One or more claims, optionally with the citation the user attached.

**Process.**
1. If a citation is attached, read that paper in full first. Find the exact
   passage that supports the claim, or confirm there is none.
2. Check that the claim matches the paper's scope: conditions, system,
   baseline, and units. The common failures are overstated generality ("most
   effective" when the paper compared two options), a number taken from a
   different quantity, and a result that holds only under conditions the claim
   leaves out.
3. If no citation is attached, or the cited paper does not support the claim,
   search for supporting and contradicting work.

**Output, per claim.**
```markdown
### Claim: "..."
- **Verdict:** supported | partly supported | not supported | contradicted | cannot tell (abstract only)
- **Evidence:** KEY [§, p., Fig.] "verbatim quote"
- **Problem:** what the claim overstates or misreads, if anything
- **Suggested wording:** a version the evidence supports
```
Write these to `topics/<slug>/claims.md`.
