# Pull-request examples

## Small numerical-behaviour change

### Mechanical version

**Title:** Consolidate resistance-fade efficiency mapping

> Route initial dispatch and daily resistance updates through one efficiency mapping. Preserve the configured charge/discharge efficiency ratio as resistance grows. Remove the helper's artificial efficiency floor and cover edge cases explicitly.

This version is technically accurate, but it starts with code operations. The reader must reconstruct the battery behaviour and the inconsistency.

### Reader-first version

**Title:** Keep battery efficiency updates consistent as resistance grows

> Battery resistance increases as the battery ages, which makes charging and discharging less efficient. BREOS accounted for this in two places: when dispatch was first configured and during the daily ageing update. Those paths used different calculations, so they could produce different efficiencies for the same battery.
>
> This PR makes both paths use one calculation. If resistance has not increased, BREOS keeps the configured charge and discharge efficiencies unchanged. When resistance increases, both efficiencies decrease by the same factor. This keeps the relationship configured by the user: if charging was less efficient than discharging before ageing, it remains so afterwards.
>
> The change also removes the helper's minimum efficiency limit. Unusual inputs now have explicit behaviour covered by tests instead of being silently adjusted.

Then give the exact rule without making the reader search for it:

```markdown
## Technical details

- For resistance growth less than or equal to zero, return the configured efficiencies unchanged.
- For positive growth, divide each efficiency by `sqrt(1 + resistance_growth)`.
- Remove the helper's previous efficiency floor.
- Use this calculation during both initial dispatch setup and daily resistance updates.

## Validation

- `uv run pytest -q tests/test_battery.py` - 82 passed
- `uv run ruff check breos tests` - passed
- `uv run ruff format --check breos tests` - passed

## Stack context

Before this branch was split from the stack, the combined changes passed 792 tests, with 7 skipped and 2 deselected. This is additional stack-level evidence, not a branch-specific run.
```

## Large feature and correction

For a PR that both adds options and fixes existing behaviour, use this order:

1. Explain the current capability and its limit.
2. Introduce the added capability in plain language.
3. Explain the existing error and why it changes results.
4. State what remains unchanged.
5. Provide grouped implementation details.
6. Show measured impact with the comparator and scope.
7. State limitations and follow-ups separately.
8. End with reproducible validation and stack relationships.

Do not compress this kind of PR into three summary bullets. Do not begin with a catalogue of model names before explaining why the models or correction matter.

## Evidence-safe fallback

When the diff establishes the implementation but no measured impact is available, write:

> This PR makes both update paths use the same calculation. It does not include a new end-to-end yield comparison, so the numerical effect outside the covered tests has not been measured here.

This is better than inventing an impact or claiming that all other results are unchanged.
