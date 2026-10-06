# PR Plan: Configurable date-based subdirectories for screenshots and screen recordings

## Motivation

`omarchy-capture-screenshot` writes every screenshot directly into
`$OMARCHY_SCREENSHOT_DIR` (or `$XDG_PICTURES_DIR`). Heavy users accumulate
hundreds of files in one flat directory, which makes them hard to browse,
back up selectively, or archive.

A common workaround is to set `OMARCHY_SCREENSHOT_DIR` with command
substitution, e.g.:

```bash
export OMARCHY_SCREENSHOT_DIR="$HOME/Pictures/Screenshots/$(date +%Y-%m)"
```

This works in `~/.config/uwsm/default` but has two real downsides:

1. The substitution evaluates **once at session start**. A long-running
   session that crosses a month boundary keeps writing into the old folder
   until the user logs out and back in.
2. It's invisible to anyone reading the env file; there's no signal that
   the directory will rotate.

This PR proposes a small, opt-in addition that solves both issues for
screenshots, with the same pattern mirrored for screen recordings.

## Proposal

Add `OMARCHY_SCREENSHOT_SUBDIR_FORMAT`. When set, it is passed to
`date +<format>` at the moment of capture and appended to the output
directory. When unset, behavior is identical to today.

Example user config (`~/.config/uwsm/default`):

```bash
# Sort screenshots into YYYY-MM subfolders.
export OMARCHY_SCREENSHOT_SUBDIR_FORMAT="%Y-%m"

# Or by day:
# export OMARCHY_SCREENSHOT_SUBDIR_FORMAT="%Y/%m/%d"
```

Result: each screenshot lands in
`$OMARCHY_SCREENSHOT_DIR/<formatted>/screenshot-<timestamp>.png`, with the
subdirectory created on demand.

Also add `OMARCHY_SCREENRECORD_SUBDIR_FORMAT` for screen recordings:

```bash
# Sort screen recordings into YYYY-MM subfolders.
export OMARCHY_SCREENRECORD_SUBDIR_FORMAT="%Y-%m"
```

Result: each recording lands in
`$OMARCHY_SCREENRECORD_DIR/<formatted>/screenrecording-<timestamp>.mp4`,
with the subdirectory created on demand.

## Implementation

Change `bin/omarchy-capture-screenshot`. Current logic:

```bash
OUTPUT_DIR="${OMARCHY_SCREENSHOT_DIR:-${XDG_PICTURES_DIR:-$HOME/Pictures}}"

if [[ ! -d $OUTPUT_DIR ]]; then
  mkdir -p "$OUTPUT_DIR"
  notify-send "Created screenshot directory: $OUTPUT_DIR" -u normal -t 2000
fi
```

Proposed:

```bash
OUTPUT_DIR="${OMARCHY_SCREENSHOT_DIR:-${XDG_PICTURES_DIR:-$HOME/Pictures}}"

if [[ -n $OMARCHY_SCREENSHOT_SUBDIR_FORMAT ]]; then
  OUTPUT_DIR="$OUTPUT_DIR/$(date +"$OMARCHY_SCREENSHOT_SUBDIR_FORMAT")"
fi

mkdir -p "$OUTPUT_DIR"
```

Notes:
- Keep the current one-time `notify-send` when the normal screenshot
  directory is first created, but suppress it when creating dated subdirs.
  Without that guard, users would get a directory-created notification every
  month/day rollover.
- `date +"$FORMAT"` is safe against arbitrary format strings; it does not
  shell-evaluate the value.
- Mirror the same date-subdir logic in `bin/omarchy-capture-screenrecording`
  with `OMARCHY_SCREENRECORD_SUBDIR_FORMAT`.
- Keep screen recording's current "base directory must exist" behavior:
  validate `$OMARCHY_SCREENRECORD_DIR`/`$XDG_VIDEOS_DIR` before appending
  the formatted subdirectory, then `mkdir -p` only the dated child
  directory. This avoids silently creating a misspelled base recordings
  directory.

## Documentation

Update `config/uwsm/default` to include the new var alongside the existing
ones, commented out by default:

```bash
# Use a custom directory for screenshots (remember to make the directory!)
# export OMARCHY_SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

# Sort screenshots into a date-based subfolder. Format is passed to `date`.
# Example: "%Y-%m" creates Screenshots/2026-05/screenshot-...png
# export OMARCHY_SCREENSHOT_SUBDIR_FORMAT="%Y-%m"
```

Same pattern for the screenrecording entries.

## Alternatives considered

1. **Allow `$(date ...)` in `OMARCHY_SCREENSHOT_DIR` and document it.**
   Rejected: the substitution-at-session-start gotcha is exactly the
   problem this PR is trying to solve, and documenting a footgun is worse
   than adding one extra var.

2. **Hardcode YYYY-MM as default.** Rejected: changes default behavior
   for every existing user, breaks the "screenshots all in one place"
   expectation. Opt-in is the right default.

3. **Fold this into a hook (e.g., `~/.config/omarchy/hooks/capture`).**
   Rejected: adds an entirely new hook surface for a four-line change.

## Backwards compatibility

100% compatible. With `OMARCHY_SCREENSHOT_SUBDIR_FORMAT` unset (the
default), output paths are byte-identical to current behavior.

## Test plan

- Unset var -> screenshot lands directly in `$OMARCHY_SCREENSHOT_DIR`.
- `OMARCHY_SCREENSHOT_SUBDIR_FORMAT="%Y-%m"` -> lands in
  `$OMARCHY_SCREENSHOT_DIR/2026-05/...`. Subdirectory auto-created.
- Format with nested separators (`%Y/%m`) -> nested directories created
  via `mkdir -p`.
- Empty string vs unset -> both behave as "no subdirectory".
- Editor save path (`satty --output-filename`) still resolves correctly
  inside the new subdirectory.
- Repeat for screenrecording.

## Open questions for maintainers

- Naming: `OMARCHY_SCREENSHOT_SUBDIR_FORMAT` vs
  `OMARCHY_SCREENSHOT_DATE_SUBDIR` vs reusing
  `OMARCHY_SCREENSHOT_DIR` with a `${date:%Y-%m}` mini-DSL. Prefer the
  first: explicit, no new syntax, mirrors existing `*_DIR` naming.
- Should the screenrecording var name be paired exactly
  (`OMARCHY_SCREENRECORD_SUBDIR_FORMAT`)? Assumed yes.
- Is there an appetite for a migration that pre-creates the rotated
  directory at session start? Not strictly needed (`mkdir -p` handles
  it), but would let users `cd` there without taking a screenshot first.

## Filing checklist

- [x] Fork basecamp/omarchy.
- [x] Create local branch `screenshot-subdir-format`.
- [x] Edit `bin/omarchy-capture-screenshot` and
      `bin/omarchy-capture-screenrecording`.
- [x] Edit `config/uwsm/default` with documented examples.
- [x] Run `bash -n` on the changed scripts.
- [ ] Run full repo test suite. Current `test/omarchy-cli-test.sh` fails
      before this patch's changed behavior, on existing `omarchy-pkg-add`
      route metadata.
- [ ] Manual test matrix above on a clean omarchy install.
- [ ] Verify `omarchy refresh config uwsm/default` regenerates the new
      template content correctly (no orphan migration needed since the
      var is opt-in).
- [x] Push branch to fork and open PR. Reference this doc in the description and link to the
      discussion in the omarchy issue tracker if one exists for
      "screenshot organization".
