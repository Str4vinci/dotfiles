## Summary

- Add opt-in `OMARCHY_SCREENSHOT_SUBDIR_FORMAT` support to place screenshots in date-based subdirectories.
- Add matching `OMARCHY_SCREENRECORD_SUBDIR_FORMAT` support for screen recordings.
- Document both variables in `config/uwsm/default`, commented out by default.

## Why

Users who take many screenshots or recordings can end up with hundreds of
files in one flat directory. A shell workaround like:

```bash
export OMARCHY_SCREENSHOT_DIR="$HOME/Pictures/Screenshots/$(date +%Y-%m)"
```

only evaluates when the UWSM environment starts, so a session that crosses a
month boundary keeps writing to the old folder. This keeps the existing default
behavior while making date rotation explicit and evaluated when captures start.

## Behavior

When unset, output paths are unchanged.

When set:

```bash
export OMARCHY_SCREENSHOT_SUBDIR_FORMAT="%Y-%m"
export OMARCHY_SCREENRECORD_SUBDIR_FORMAT="%Y-%m"
```

captures are written to:

```text
Screenshots/2026-05/screenshot-...
Screencasts/2026-05/screenrecording-...
```

Nested formats like `%Y/%m/%d` are supported via `mkdir -p`.

## Test Plan

- `bash -n bin/omarchy-capture-screenshot bin/omarchy-capture-screenrecording`
- `bash test/omarchy-cli-test.sh` currently fails on an existing unrelated
  `omarchy-pkg-add` route metadata assertion; this patch only changes the two
  capture scripts and `config/uwsm/default`.
