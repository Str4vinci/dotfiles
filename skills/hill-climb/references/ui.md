# Climbing a UI with screenshots

## Harness

- Screenshot the real app, against real backends when the target shows their
  results. Mocked data hides layout problems such as long names, empty states,
  and wrapping numbers.
- Always shoot at least two viewports: the common one and the floor (the
  smallest size you support). In `verlantis_designer` these are **1440 × 800**
  and **1280 × 600**. Most regressions show up only at the floor.
- Shoot every **state** of the target, not only the happy path: empty, loading,
  error, populated, long content, open menus and dialogs, hover and focus when
  they matter.
- For tall pages, take a full-page shot (`fullPage: true`) in addition to the
  viewport shot. The viewport shot tells you what is above the fold. The full-page shot tells
  you the total height.
- JPEG at quality ~70 is enough to judge layout and costs fewer tokens than PNG.
  Use PNG only to judge fine text rendering or colour.
- Wait for the state, not for time, when you can: wait for a locator, then add a
  short settle delay for animations and canvases (WebGL needs one).
- Prefer the project's tour script. With no tour script, start from
  `scripts/shoot.mjs` in this skill (`<skill-dir>` is the directory that holds
  this skill's `SKILL.md`):

  ```
  node <skill-dir>/scripts/shoot.mjs <outdir> <url> [<url>...]
  VIEWPORTS=1440x800,1280x600 FULL=1 PREFIX=round-2 node .../shoot.mjs ...
  ```

  Run it from the project root so it finds the project's Playwright.

## Measurements that go with the screenshots

Screenshots catch what a measurement misses. Measurements catch what the eye
misses. Add the cheap ones to the harness:

- Page or panel height in px, and whether the primary action is above the fold
  at the floor viewport.
- Text contrast (`verlantis_designer`: `node scripts/ux-contrast.mjs`).
- Horizontal overflow: `document.documentElement.scrollWidth > innerWidth`.
- Console errors during the tour.
- Truncated text: elements with `scrollWidth > clientWidth` and
  `text-overflow: ellipsis` or `overflow: hidden`.

## Default rubric

Add these to the user's own points. Order is rough priority.

1. **Broken**: overlap, clipping, cropped labels, z-order fights, horizontal
   scroll, content off-screen at the floor viewport.
2. **Task path**: can a new user tell what to do next? Is the primary action
   obvious and reachable without scrolling? Is any control a trap, such as a
   tab that triggers an action?
3. **Hierarchy**: one clear focal point per view. Headings, weights, and sizes
   rank things in order of importance.
4. **Density**: no repeated information, no explanations that sit in the way
   (move them into hints), no chrome taking space from the main content.
5. **Alignment and rhythm**: shared edges, consistent spacing scale, controls
   of the same kind look the same.
6. **Labels**: plain words, the user's vocabulary, units shown, no internal
   names.
7. **States**: empty, loading, error, and stale states say what happened and what to
   do.
8. **Accessibility**: AA contrast, visible focus, hit targets ≥ 24 px, works
   with the keyboard.
9. **Industry practice**: when unsure how a control should behave, follow
   what the established tools in the domain do, and say which ones you checked.

## Task presets

Use a preset when the request names one of these jobs, even vaguely ("make it
modern", "improve this form", "make it work on mobile", "make it accessible").
Add the preset's rules to the rubric and its "Don't touch" list to the hard
constraints. Do the "First" step in the baseline critique. The user's words
outrank the preset. Ask only when they conflict.

### Hierarchy and density (dashboards, busy views)

- **Goal:** one focal point per view. A user finds the main number or action
  at a glance.
- **First:** list the 5 biggest hierarchy and density problems, ranked, before
  you change anything.
- **Tokens:** use the project's tokens (Tailwind config, CSS variables, theme
  file). If there are none, define a spacing scale, a type scale, and a small
  colour set: a neutral ramp, one accent, and status colours (success,
  warning, error) used only for status. Then use only those.
- **Don't touch:** data, queries, features. Ask before you remove a panel.
- **Report:** the ranked problem list, each with a before and after crop.

### Forms

- **Goal:** completion rate.
- **Rules:**
  - One column. Labels above inputs. A placeholder is not a label.
  - Validate a field on blur, not on each keystroke. After a field shows an
    error, validate it on input, so the error goes away as soon as it is fixed.
  - On submit, validate all fields and move focus to the first error.
  - An error message says what to do ("Enter a date after 1 Jan 2026"), not
    only what is wrong.
  - Each control has focus, disabled, loading, and error states. The submit
    button shows loading and blocks a second submit.
  - Correct `type`, `inputmode`, and `autocomplete` on each input. Mark
    required or optional fields the same way everywhere.
- **Don't touch:** field order, field names, API calls, payload shape.
- **Report:** a shot of each state of the form.

### Responsive

- **Viewports:** 320, 390, 768, 1440 px wide. These replace the default pair.
  320 px is the WCAG reflow width (1.4.10).
- **Rules:**
  - No page-level horizontal scroll at any viewport.
  - Touch targets ≥ 44 px on phone and tablet layouts (24 px is the AA floor).
  - Nothing is reachable only by hover.
  - Tables: choose by task. If users compare rows, keep a table: hide
    low-priority columns, or scroll inside the table with a sticky first
    column. If users read one record at a time, use stacked cards below 768 px.
- **Don't touch:** the desktop layout. Compare its 1440 shot with the baseline
  each round. Any change there is a regression.
- **Report:** a shot per viewport, and a list of what broke at each and the fix.

### Accessibility (WCAG 2.2 AA)

- **First:** run axe (`@axe-core/playwright`) if the project has it or can add
  it. Axe finds only part of the issues, so do the manual checks too.
- **Contrast:** 4.5:1 for normal text. 3:1 for large text (≥ 24 px, or
  ≥ 18.7 px bold), and for UI parts: input borders, icons, focus rings (1.4.11).
- **Keyboard:** Tab reaches every action in a logical order. Enter, Space, and
  Esc work as expected. No keyboard traps. The focus ring is visible and not
  hidden by sticky headers or overlays (2.4.7, 2.4.11).
- **Names:** use native elements first (`button`, `a`, `label`). Add
  `aria-label` only where there is no visible text, for example icon buttons.
  Images have `alt`, or `alt=""` if decorative.
- **New in 2.2:** targets ≥ 24 px or spaced apart (2.5.8). Every drag has a
  click alternative (2.5.7). Do not ask again for data the user already gave
  (3.3.7). Login allows paste and password managers (3.3.8).
- **Zoom:** content reflows at 320 px and works at 200% text size (1.4.4).
- **Motion:** respect `prefers-reduced-motion`. This is AAA (2.3.3), but cheap.
  Do it and label it as beyond AA.
- **Don't touch:** visual design beyond what a fix needs.
- **Report:** a table: criterion, issue, before, after, how checked. Do not say
  "WCAG compliant". Say what you checked and what you did not.

## Traps

- Do not judge from a screenshot taken before the page settled. A half-loaded
  page looks broken and leads you to "fix" non-problems.
- A dev server with HMR may full-reload while you edit. Don't run a tour or the
  e2e suite while you are still editing files.
- e2e specs often select by role and accessible name. If you rename a label or
  change a control type, run the affected specs before you keep the round.
- Fixed-position overlays sized for one layout break in another. Check
  every shell or layout variant that the change touches, not only the one you
  are climbing.
