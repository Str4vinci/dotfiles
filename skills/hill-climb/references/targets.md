# Climbing targets other than a UI

The loop is the same. What changes is the harness (how you produce the artifact)
and the rubric (what "better" means). Where an objective number exists, climb on
it and use the eye only to catch what the number misses.

## Generated documents (PDF reports, proposals, exports)

- Harness: generate the document from a fixed fixture, then render the pages to
  images: `pdftoppm -r 80 -jpeg report.pdf out/round-N` (one image per page).
  Also extract the text (`pdftotext -layout`) to check content without the eye.
- Rubric: page breaks that split a table or orphan a heading, overflowing cells,
  inconsistent number formats and units, missing context for a reader who wasn't
  in the app, how the first page reads to a customer, and whether it prints in
  greyscale.

## Charts and plots

- Harness: the plotting script on a fixed dataset, saved as PNG. Include a
  case with awkward data (one series, a zero, a long label, negative values).
- Rubric: does the chart answer its one question at a glance? Readable axes with
  units, no overlapping labels, direct labels instead of a legend where they fit,
  colours that survive colour-blindness and dark mode. Use the `dataviz` skill as
  the rubric source.

## Prose (docs, READMEs, handoffs, error messages)

- Harness: the text itself, plus a cold reader: an agent that gets only
  the text and a task ("using only this README, list the commands to run the
  app"). Its mistakes show you the defects.
- Rubric: the cold reader finishes the task, nothing is said twice, no hedging,
  no AI tells. Use `unslop` or `technical-writing` as the rubric source when the
  user wants that style.

## Prompts, skills, and agent instructions

- Harness: a small fixed set of inputs (5–10 that cover typical and edge cases),
  run through the prompt, with outputs saved per round. Keep the set fixed for
  the whole climb, or the scores can't be compared between rounds.
- Rubric: a checklist per input of what a correct output must contain or avoid.
  Grade every output against it, and count the passes. Read the failures
  themselves, not only the count.
- Watch for overfitting: hold back two inputs that you check only at the end.

## CLI and TUI output

- Harness: run the command on fixtures (normal, empty, error, very long input)
  and capture stdout and stderr. For a TUI, capture with `tmux capture-pane` or
  render to an image.
- Rubric: the first line says what happened, errors say what to do next, output
  fits 80 columns, it pipes cleanly (no colour when not a TTY), quiet on
  success.

## Performance (runtime, bundle size, memory)

- Harness: a benchmark with a warm-up and several repeats. Report the median
  and the spread. If a change moves the median by less than the spread, it is
  noise, not a step.
- Rubric: the number, plus the hard constraint that outputs are unchanged
  (diff against a golden output). Profile before each round, then change the top
  item in the profile.

## Data and model outputs (simulations, estimates, layouts)

- Harness: a fixed set of cases with known-good or reference values, plus a plot
  of error per case.
- Rubric: error against the reference, and no case that gets much worse while
  the average improves. Look at the worst cases each round, not the mean.
