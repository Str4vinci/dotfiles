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
