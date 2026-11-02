---
name: hill-climb
description: Improve something by repeated small steps, each one judged by looking at what it actually produces (screenshots, rendered pages, plots, outputs, timings), not by reading the code. Use when the user says "hill-climb", "climb", "iterate on this UI with screenshots", or asks to polish a UI, report, chart, prompt, or doc by do → look → critique → repeat.
argument-hint: "[target] [--rounds N] [--critic]"
---

# Hill-climb

Climbing is a loop: **change one thing → produce the artifact → look at it →
critique it against a rubric → keep or revert → log → repeat.** The value is in
the looking. Never judge a change from its diff. Judge it from what it renders,
prints, or measures.

Pick the reference for the target before Round 0:

- UI / UX, anything in a browser → `references/ui.md`
- Anything else (PDFs, charts, prose, prompts and skills, CLI output, performance)
  → `references/targets.md`

## Round 0: set up the climb

Do these before the first change. Show the setup to the user in a few lines.

1. **Target.** One screen, flow, document, or output. Not "the app". If the
   user named a broad area, pick the part that hurts most and say why.
2. **Harness.** One command that regenerates every artifact for the target in a
   fixed state (same data, viewport, seed, fixture). Reuse the project's
   harness when it has one (in `verlantis_designer` that is
   `scripts/ux-tour.mjs`). Extend it, don't fork it. If there is none, write
   one (for a browser page, `scripts/shoot.mjs` in this skill is a start).
   The harness must run unattended. A flaky harness gives you noise to climb.
3. **Rubric.** What "better" means here, as a short checklist. Start from the
   user's own notes (feedback docs, earlier verdicts, standing instructions),
   then add the default rubric from the reference file. The user's words outrank
   the defaults.
4. **Hard constraints.** Things that must not get worse: tests pass, contrast
   holds AA, nothing overlaps at the smallest supported size, no feature removed
   without asking. Name the commands that check them.
5. **Baseline.** Run the harness. Save the output as `before-*`. Critique the
   baseline against the rubric. The baseline critique is the first work list.
6. **Budget.** Default 5 rounds, or `--rounds N`. Climbs pay off early; later
   rounds polish.

Where shots and the log go: follow the project's convention if one exists
(`verlantis_designer` uses `docs/ux-shots/<date>/<topic>/` and a "Climb N"
section in the feedback doc). Otherwise use `docs/climbs/<date>-<topic>/` with a
`log.md`. If the repo has no docs folder, ask before you add one.

## Each round

1. **Pick one issue.** Take the highest-ranked issue from the last critique.
   State it with evidence: which shot, where on it, what is wrong.
2. **Predict.** One line: "If I do X, then in shot Y, Z will change." A change
   that has no visible prediction is not a hill-climb step.
3. **Change.** One idea per round. A small cluster of edits is fine if they
   serve that one idea. Two ideas in one round means you can't tell which one
   helped.
4. **Regenerate.** Run the harness. Name new output `round-N-*`.
5. **Look.** Read the new artifacts and the previous ones next to each other.
   Crop to the region that changed when detail matters
   (`magick in.jpg -crop WxH+X+Y out.jpg`). Check the hard constraints.
6. **Critique.** Against the rubric, not against your intent:
   - Did the prediction come true?
   - What got worse? Look at the whole artifact, not only the place you changed.
     Regressions are usually somewhere else.
   - What is now the worst remaining issue?
   Be specific and skeptical. "Looks cleaner" is not a finding. "The Run button
   moved above the fold at 1280×600" is.
7. **Keep or revert.** Keep the change only if it is a clear net gain and no
   hard constraint broke. Otherwise undo **your own edits from this round**.
   Never `git restore`, `git checkout`, or stash files that you did not change
   in this round, because the tree can hold the user's uncommitted work. A
   reverted round is still progress: log what you learned.
8. **Log.** One entry per round: the issue, the change, kept or reverted, and
   why, with the shot names. Keep it short. The log is how the user reviews the
   climb without re-running it.

Do not commit between rounds unless the user asked you to. If they did, commit
each kept round on its own so any step can be reverted.

## Bias: you are grading your own work

The model that made a change tends to see it as an improvement. Counter this:

- Write the critique of the new artifact **before** you re-read your own
  prediction.
- Look for regressions first, then improvements.
- **`--critic`** (or when the user asks for fresh eyes): each round, start one
  agent that gets only the rubric and two artifacts labeled X and Y in random
  order. It does not know which is new. It returns which is better and why,
  plus the worst issue in the better one. Use its verdict for keep/revert. This
  costs an agent per round, so only use it when the user asks for it.
- The user's verdict beats every model verdict. If the user says a kept change
  is worse, revert it and add their reason to the rubric.

## Local maxima

If two rounds in a row are reverted, or every remaining issue needs a
structural change (a different layout, navigation, or information
architecture), small steps will not reach it. Stop climbing and **jump**:
propose 3–5 different directions as mockups in a separate file (the `mockup`
skill), let the user pick one, then climb from there. In `verlantis_designer`,
put real screenshot crops in the mockups for the "today" direction. Hand-built
copies of today's UI distort the comparison.

## Stop and ask

Stop the climb and ask the user when:

- The budget is spent.
- Two rounds in a row are reverted and no jump is obvious.
- The next issue is a matter of taste or product direction, not a defect (for
  example, which of two valid layouts, or removing a feature).
- A hard constraint can't hold without changing scope.

## Finish

Report to the user:

- Before and after, as artifact paths (and the key numbers when there are any:
  page height, fold position, contrast failures, runtime).
- Kept rounds, one line each. Reverted rounds, one line each, with what they
  taught.
- Open issues, ranked, with the ones that need the user's decision called out.
- Anything left running (dev servers, background processes) and how to stop it.

If the project keeps a feedback doc or handoff, add a "Climb N" section to it in
the project's own style.
