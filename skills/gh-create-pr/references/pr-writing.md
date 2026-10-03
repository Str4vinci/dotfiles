# Pull-request writing contract

Use Google developer-documentation style as the voice layer and selected ASD-STE100 principles as clarity checks. Do not claim formal ASD-STE100 compliance.

Use the repository's established English variant and terminology. Apply Google's guidance for clarity and tone, not as a requirement to adopt Google-specific spelling.

The source basis is:

- [Google developer documentation: voice and tone](https://developers.google.com/style/tone)
- [Google developer documentation: active voice](https://developers.google.com/style/voice)
- [Google developer documentation: global audience](https://developers.google.com/style/translation)
- [ASD-STE100 overview and principles](https://www.asd-ste100.org/about_STE.html)

Use the distilled rules below during normal PR work. Consult the sources only when the user asks for a formal style audit or a rule is uncertain.

## Opening contract

Draft the opening with a **10-second executive lead** followed by plain context.

### 1. The 10-Second Executive Lead (Sentence 1)
Start the very first sentence with a clear, outcome-focused statement of what this PR accomplishes:
- **Max 25 words.**
- **Active voice:** `This PR [verb] [outcome]...` or `This change [enables/fixes]...`.
- **Passes the "coffee test":** A colleague or non-specialist reading only this sentence immediately understands what was improved.
- **No code symbols, config keys, formulas, or bare issue/PR numbers (`#NNN`)** in this first sentence. Explain the intent, not the internal mechanism.

### 2. Context, Problem, and Mechanism (Sentences 2–4)
Follow the lead with two to three short sentences answering:
1. What did the software do before, or what could it not do?
2. What problem, error, or slowdown did that cause?
3. How does this PR resolve it?

Prefer an opening such as:

> **This PR keeps battery efficiency calculations consistent over time by using one shared formula as battery resistance increases.**
>
> As a battery ages, its internal resistance increases, reducing charge and discharge efficiency. BREOS accounted for this in two places—initial setup and daily degradation—but those paths used different calculations, producing inconsistent efficiencies for the same battery.

Avoid an opening that dumps configuration keys or internal functions right away:

> Under `fixed_target`, `overlap_policy = "hold_target"` lets a period be both a charge and discharge period...

Avoid an opening that references recent PR numbers without context:

> `#386` gave the planner a wear weight and left `tools/oracles/` untouched...

## Plain technical English

- Use familiar, concrete words when they retain the meaning.
- Give one main idea to each sentence.
- Prefer active voice and name the component that acts.
- Keep the same term for the same concept.
- Use necessary domain terms; explain them in context on first use.
- Put conditions before outcomes when that order helps comprehension.
- Break long reasoning into short paragraphs rather than dense bullets.
- Preserve precision. Simple language must not weaken technical boundaries.

Useful rewrites include:

| Mechanical wording | Clearer wording |
| --- | --- |
| consolidate the mapping | use one calculation |
| route both paths through | make both paths use |
| preserve the configured ratio | keep the relationship configured by the user |
| non-positive growth | zero or negative growth |
| prevent behaviour drift | keep the two behaviours consistent |
| impose an artificial floor | add a minimum limit |
| retain round-trip-efficiency derating | apply the intended reduction in round-trip efficiency |

Treat these as examples, not forbidden-word substitutions. Choose the wording that is most accurate in context.

## Human tone

Write as a knowledgeable colleague explaining the work to another developer.

- Be conversational, direct, and respectful.
- Avoid marketing language, self-congratulation, and exaggerated importance.
- Avoid filler such as "This PR aims to", "It should be noted", and "In order to".
- Avoid unexplained acronyms, stacked noun phrases, and unnecessary nominalisations.
- Do not make the prose choppy merely to shorten sentences.
- Do not remove the mechanism, formula, boundary, or caveat that reviewers need.

The accessible opening is not a replacement for technical detail. It is the path into it.

## Adaptive body template

Use this as a menu, not a mandatory form:

```markdown
<One to four short paragraphs: context, problem, outcome.>

## What changed

- <Concrete change>
- <Concrete change>

## Technical details

<Exact implementation, algorithm, formula, data flow, or edge-case behaviour.>

## Impact

<Measured before-and-after comparison on the same inputs: a table of headline metrics per scenario, including unchanged ones, then two or three sentences on size, direction and whether it matters. Also API, compatibility or migration effects.>

## Known limitations

<Boundary that remains after this PR.>

## Follow-ups

- <Clearly separate future work>

## Validation

- `<command>` - <observed result>

## Stack context

<Base PR, dependent PR, split history, and which validation applies where.>
```

For a small PR, the opening plus `What changed` and `Validation` can be enough. For a complex scientific or numerical change, retain the mechanism, measured impact, comparator, scope, and limitations.

## Evidence boundaries

- Say "can" only when the change makes something possible; say "does" only when observed or guaranteed.
- Separate expected impact from measured impact.
- State the comparator and scope for percentages, timings, and numerical changes.
- Do not infer broad compatibility from a narrow test.
- Do not describe a pre-existing failure as unrelated without comparing an appropriate baseline or other evidence.
- Do not say "all tests pass" when only a focused subset ran.
- Label validation from an earlier combined stack explicitly.

## Title checks

Prefer titles such as:

- Keep battery efficiency updates consistent as resistance grows
- Add the remaining pvlib temperature models
- Reject incomplete NOCT configuration during setup

Avoid titles that expose only the implementation operation:

- Consolidate resistance-fade efficiency mapping
- Refactor temperature handling
- Update PV code

Use a conventional prefix only when the repository requires it.
