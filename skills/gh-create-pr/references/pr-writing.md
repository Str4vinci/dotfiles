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

Make the opening answer these questions in order:

1. What did the software do before, or what could it not do?
2. What problem did that cause?
3. What does this PR change, and why does that matter?

Lead with the product, behaviour, or developer task. Introduce internal functions and formulas after the reader understands their purpose.

Prefer a direct opening such as:

> Battery resistance increases as the battery ages, which makes charging and discharging less efficient. BREOS accounted for this in two places, and those paths used different calculations.

Avoid an opening that makes the reader reverse-engineer the problem:

> Route initial dispatch and daily resistance updates through one efficiency mapping.

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

<Observed user, API, compatibility, performance, numerical, or migration effect.>

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
