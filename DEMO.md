# Demo: box-plot accent notations (#487 item 5)

Real terminal capture of `scripts/verify-box-plot.py` on mutated copies of the shipped box-plot examples.

## What the recording shows

1. Title: upstream/main `d74d8c2` vs `feat/box-plot-accent-notations`.
2. Four notations, one at a time, each held about 3 s on main then 3 s on this branch:
   - `hwb(13.96 12.55% 25.1%)` on the muted Auth series
   - `lab(46.9% 48.61 47.51)`
   - `oklch(0.5544 0.1643 36.71)`
   - `currentColor` with `color="#bf4520"`
3. On upstream/main each mutation exits 0. On this branch each is a rule-7 finding: "2 series wear the accent … at most one focal series", exit 1.
4. `python3 scripts/verify-box-plot.py --all` on this branch: 3 shipped files clean, exit 0. Final frame held about 3 s.

Named-colour mutations (`tomato`, `coral`) are in `commands.log` and the test file; they pass on both checkers (no CSS named colour sits within `HSL_TOLERANCE` 4.5 of either shipped accent).

## How it was recorded

- Xvfb `:99`, 1920×1080×24
- `xterm` (DejaVu Sans Mono 16, UTF-8) running `scripts/demo.sh`
- `ffmpeg -f x11grab -video_size 1920x1080 -framerate 30` → H.264 yuv420p
- `preview.gif` from the MP4 with `palettegen`/`paletteuse`, 1280×720, 10 fps, 64 colours

No generated media. The commands in the video are the real checker on the real fixtures in `fixtures/`.
