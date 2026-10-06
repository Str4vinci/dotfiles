---
name: scientific-manuscript-editing
description: Proofread, scientifically edit, developmentally edit, or audit scientific manuscripts, abstracts, methods, results, discussions, conclusions, captions, tables, equations, and plot labels. Use for UK-English language and reporting work and for manuscript-level density, cuts, cohesion, repetition, redundancy, section ownership, prose-table compression, and prioritised revision planning while preserving scientific meaning, evidence, uncertainty, and authorial voice.
---

# Scientific Manuscript Editing

## Purpose

Proofread, copy-edit, developmentally edit, and audit scientific prose and article components while preserving the technical meaning, numerical evidence, uncertainty, provenance, and authorial voice of the source material. Do not invent results, methods, citations, or claims.

Use the target journal's instructions when they are available. Apply this skill as the project house style when no higher-priority journal rule is supplied. Consult [references/style-sources.md](references/style-sources.md) when a source-backed convention or reporting standard needs to be checked.

Read [references/developmental-editing.md](references/developmental-editing.md) completely when the request concerns whole-manuscript structure, narrative or information density, cuts, cohesion, repetition, redundancy, section effectiveness, prose that reads like a table, or a prioritised editorial assessment.

## Editing modes

Choose the least invasive mode that satisfies the request:

- **Proofread**: correct grammar, spelling, punctuation, UK English, typography, units, numbers, and house-style violations. Preserve sentence structure and wording unless a correction is required.
- **Scientific edit**: improve clarity, flow, tense, voice, structure, terminology, claim strength, and separation between methods, results, interpretation, and limitations. Preserve the underlying evidence.
- **Developmental edit**: evaluate claim hierarchy, section ownership, density, cohesion, repetition, redundancy, compression opportunities, and the progression from research questions to conclusions. Diagnose and prioritise before line-editing; do not rewrite the manuscript wholesale or impose a different voice.
- **Audit**: inspect the manuscript and its figures, tables, data, code, citations, and reporting statements for inconsistencies, unsupported claims, missing provenance, precision problems, and reproducibility gaps. Report issues and evidence before proposing changes.
- **Draft**: write new text only when explicitly requested, and only from supplied evidence, cited literature, or clearly marked assumptions. Treat drafting as a constrained extension of editing, not permission to invent content.

## Working order

1. Identify the deliverable, study type, target audience, target journal, required section, and whether the user authorised file edits. Treat assessment and review requests as read-only unless edits were explicitly requested.
2. Inspect the latest source text, data, figures, tables, equations, comments, and relevant project conventions before rewriting. Confirm version and evidence scope when several artefacts exist.
3. Reconcile factual, comparator, terminology, and Methods–Results mismatches before compression. Do not let a smoother rewrite conceal a contradiction.
4. Separate facts directly supported by the supplied material from interpretation, inference, fitted hypotheses, and proposed wording.
5. Assign each claim a canonical section and identify duplication before making local cuts.
6. Apply journal instructions first, then project-specific terminology, then this house style.
7. Proofread, edit, audit, or draft according to the selected mode while preserving quantitative meaning, claim strength, necessary qualifications, and deliberate voice.
8. Run the final audit below. Flag unresolved contradictions with `[CHECK]` rather than silently choosing a value.

## Developmental editing and concision

- Treat shorter text as a means, not an objective. Recommend cuts only when material is redundant, low-yield, misplaced, overly explanatory, unsupported, or weaker than the surrounding text.
- Distinguish **over-dense** passages, which compress too many ideas or comparison bases, from **low-yield** passages, which use many words without advancing the argument.
- Give each claim a primary home. The Abstract should carry the question, essential method, headline evidence, and directional conclusion; Results should own detailed evidence; the Discussion should own interpretation and implications; the Conclusion should answer the research questions rather than repeat the Results sequence.
- Prevent prose tables. Let tables, figures, or Supporting Information carry stable cell-level detail. In prose, retain the governing pattern, decision boundary, extrema, reversals, exceptions, mechanism, and scope qualification.
- Consolidate recurring caveats at a canonical location while retaining a short local warning where readers could otherwise overgeneralise the result.
- Quantify repeated words or structures when useful, but do not vary accurate technical terms merely for novelty. A repetition watchlist is diagnostic, not a prohibited-word list.
- Perform structural and section-level compression before sentence-level synonym changes or punctuation polishing.
- For every substantial cut, state what function would be lost and whether that function is already performed elsewhere.

## Language and tone

- Use UK English consistently, including forms such as `colour`, `analyse`, `modelling`, and `behaviour`, unless a field-specific or journal-specific term requires another form.
- Use concise, precise, impersonal scientific language. Avoid colloquialisms, idioms, marketing language, vague intensifiers, and unsupported superlatives.
- Prefer formal passive constructions when the actor is not scientifically important, for example, `The samples were analysed`.
- Use active constructions when they improve clarity, but do not use first-person plural formulations such as `we found` or `we calculated`. Use constructions such as `The analysis showed` or `A value of ... was obtained`.
- Do not introduce em dashes. Use commas, full stops, semicolons, or parentheses instead. Use an en dash only for a genuine range or established paired term, not as sentence punctuation.
- Do not begin a revised sentence with `Because`; recast the causal relationship or place the reason after the main clause.
- Define abbreviations at first use and use the same abbreviation, symbol, capitalisation, and spelling thereafter.
- Distinguish clearly between measured, simulated, calculated, estimated, fitted, inferred, assumed, and hypothesised quantities.

## Tense and voice

- Use past tense by default for the study's methods, implemented procedures, simulations, observations, calculations, and study-specific results.
- Use present tense only for established general knowledge, definitions, persistent facts, or a direct statement about what a figure or table currently shows. If the user requests a fully past-tense revision, keep present tense only where removing it would make the statement grammatically or scientifically misleading.
- Use cautious language for interpretation. Match the verb to the evidence: `was associated with`, `suggested`, or `was consistent with` is preferable to a causal claim unless causality was established.
- Keep methods, results, interpretation, and limitations distinct. Do not hide an interpretation inside a method statement or present an assumption as a result.

## Numbers, units, and symbols

Use the non-breaking space character U+00A0 in manuscript text where the rules below require `NBSP`. Do not replace it with an ordinary space.

- Use a full stop as the decimal marker, never a decimal comma.
- For reported decimal values, use two decimal places by default, for example `4.25`, unless the source precision, uncertainty, quantity type, or journal style requires another precision.
- Do not manufacture precision. Do not force decimal places onto counts, years, identifiers, sample sizes, integer constraints, exact values, p-values, exponents, or other quantities for which fixed decimal formatting would misrepresent the evidence.
- For numbers with more than four integral digits, group digits in threes with NBSP and never with commas: `12 345.67`. Do not group four-digit values unless the journal requires it.
- Write negative numbers with the ordinary hyphen-minus, for example `-500`. Do not confuse this numeric sign with an em dash, and do not replace it with an em dash.
- Separate a number from a unit symbol with NBSP: `22 mL`, `5 kWh`, `30.2 °C`, and `12 %`.
- For euro-denominated amounts, place the euro symbol after the numerical value with NBSP: `3450 €` or `12 345.00 €`. Do not write the euro symbol before the value. Do not add decimal places to whole amounts unless the source or journal requires currency precision.
- Keep SI prefixes joined to the unit symbol: `kWh`, `mV`, `MW`, and `mm`. Do not insert a space between a prefix and its unit.
- Apply the no-space exception only to plane-angle symbols: `30°`, `22′`, and `8″`. A degree-Celsius value is not a plane-angle value and therefore uses NBSP: `30.2 °C`. Use NBSP with `rad` unless the target journal specifies otherwise.
- Use upright unit symbols and consistent capitalisation. Treat variables and mathematical quantities according to the document's equation and typesetting convention.
- Keep the numerical value, uncertainty, and unit unambiguous. When reporting a value with an uncertainty, round both to a compatible decimal place, for example `12.35 ± 0.08 kWh`.
- State the denominator and population for percentages, rates, ratios, and normalised quantities. Do not report a percentage without making its basis clear when the context could be ambiguous.
- Preserve source values and provenance. If two supplied artifacts disagree, report the conflict and identify the source path, row, version, or other available provenance before selecting a manuscript value.

## Plots, figures, tables, and captions

- Label quantitative axes, colourbars, and similar plot scales as `Quantity / unit`, for example `Grid Independence / %`, `Energy / kWh`, or `Temperature / °C`.
- Do not use parenthetical unit labels such as `Grid Independence (%)` when this house style is in force. Keep the quantity name and unit consistent with the manuscript and source code.
- Use a concise plot title only when it adds information beyond the caption and axis labels. Do not use a decorative or redundant title.
- Make every caption self-contained. Explain panel labels, scenario names, symbols, line styles, uncertainty bars, sample sizes, statistical tests, and abbreviations needed to interpret the figure without searching the main text.
- Keep units in axis labels, table headings, legends, and captions. Do not repeat the unit in every data cell when a shared heading is unambiguous.
- Do not duplicate an entire table in prose or an entire plot in a table. Summarise only the comparisons that advance the argument.
- Use accessible colours, sufficient contrast, distinguishable line styles or markers, and readable labels. Preserve exact code-derived detail when a figure is generated from stored results.
- Verify requested visual artifacts by rendering or opening them when the task concerns figure layout, labels, or readability. Report the verified output path.

## Article structure and reporting

For original research, use the journal's required structure. When no structure is specified, use an IMRaD-like progression:

- Introduction: establish the problem, relevant literature, gap, objective, and hypothesis or research question.
- Methods: describe the design, data, materials, model, parameters, calibration, assumptions, analysis, uncertainty treatment, and software sufficiently for reproduction.
- Results: present findings in a logical order, give the principal quantitative results first, and separate observations from interpretation. Lead numerical comparisons with the governing pattern; do not serially narrate every table or figure cell.
- Discussion: answer the research question, compare with relevant literature, explain implications, state limitations, and distinguish robust conclusions from sensitivity-dependent conclusions.
- Conclusion: answer the stated research questions, synthesise decision implications and limitations, and state only conclusions supported by the presented evidence. Do not introduce new results or traverse every Results subsection again.

For the abstract, include the objective, essential method, principal quantitative findings, and conclusion. Keep terminology and numerical values consistent with the main text.

Check whether a study-type reporting guideline applies. Where relevant, report data and code availability, software versions, parameter provenance, random seeds, sample sizes, baselines, system boundaries, exclusions, deviations from the planned method, and limitations.

## Scientific integrity and claim control

- Base mechanistic claims on cited literature or demonstrated results. Label fitted hypotheses, calibration choices, empirical correlations, and extrapolations explicitly.
- Do not call a trend an inflection point, a maximum, a validation, or a causal effect unless the stored data and method support that term. Use a defined method for knees, thresholds, fronts, envelopes, and other derived features.
- Distinguish raw calculations from reporting transformations. For example, state separately when adjacent designs supplied a raw ratio and when a lower convex envelope supplied a convexified summary.
- Report uncertainty, sensitivity, and limitations where they affect interpretation. Do not use `significant` in its statistical sense without an appropriate statistical basis.
- Preserve distinctions between a common baseline, a tariff-conditional value, an absolute value, an improvement relative to a comparator, and a claim of overall superiority.
- Do not upgrade a result from a particular scenario, calibration domain, or weather year into a general claim without evidence for that scope.

## Final audit

Before delivering the text or artifact, check:

- UK spelling and terminology were used consistently.
- No em dash appears anywhere in the revised text, captions, labels, or tables.
- First-person plural and unsupported authorial claims were removed.
- Past tense and mostly passive voice were used for study-specific work.
- Decimal points were used, not decimal commas.
- No thousands commas remain.
- Five-or-more-digit numbers use NBSP grouping, and four-digit values were not grouped without a reason.
- Number and unit pairs use NBSP, including percentages and degree Celsius.
- Negative values use a hyphen-minus, for example `-500`, rather than an em dash.
- Euro amounts place `€` after the value with NBSP, never before it.
- Only plane-angle symbols use the no-space exception.
- Plots use `Quantity / unit` labels and consistent notation.
- Precision reflects the source evidence and uncertainty.
- Abbreviations, symbols, units, baselines, and scenario names are defined and consistent.
- Claims are traceable to supplied data, cited literature, or explicitly marked inference.
- Figures, tables, captions, methods, data/code statements, and limitations meet the applicable journal or reporting-guideline requirements.
- Each major section has a distinct function and advances the manuscript.
- Methods, Results, Abstract, and Conclusion use consistent scopes, comparators, labels, and quantitative values.
- No major result is narrated in full in the Abstract, Results, and Conclusion.
- Numerical prose retains decision-defining evidence but leaves exhaustive matrices to figures, tables, or Supporting Information.
- Repeated caveats have a canonical home, with only necessary local warnings retained.
- Cuts do not remove unique mechanisms, qualifications, transitions, atmosphere, or other material that earns its space.
