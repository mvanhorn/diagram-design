# Demo: Claude Desktop skill ZIP (#525)

Real terminal capture of a naive zip of `skills/diagram-design` (over the 200-file upload limit) and of `scripts/build-claude-skill-zip.py` building `dist/diagram-design-claude-skill.zip` under that limit.

## What the recording shows

1. Title: `feat/claude-skill-zip` from upstream/main `d74d8c2`.
2. Naive zip of `skills/diagram-design`: `find` reports 325 files; the archive has 325 files (1,565,007 bytes). Host upload limit is 200 files. Held about 3 s.
3. `python3 scripts/build-claude-skill-zip.py` writes `dist/diagram-design-claude-skill.zip` (164 files, 791,653 bytes). Held about 3 s.
4. `python3 scripts/build-claude-skill-zip.py --check` prints `OK Claude Desktop skill ZIP: 164 files, 2,669,104 bytes uncompressed (host limit 200 files with margin 20; 31,457,280 bytes)`. Held about 4 s.
5. Top of the archive: top-level `diagram-design/`, `SKILL.md` at its root, then `assets/`. Final frame held about 4 s.

Claude Desktop is not installed on this Linux box; the macOS import was not tried.

## How it was recorded

- Xvfb `:99`, 1920×1080×24
- `xfwm4` (no compositor) so `xterm -fullscreen` fills the display
- `xterm` (DejaVu Sans Mono 18, UTF-8) running `scripts/demo-run.sh`
- `ffmpeg -f x11grab -video_size 1920x1080 -framerate 30 -draw_mouse 0` → H.264 yuv420p
- `preview.gif` from the MP4 with `palettegen`/`paletteuse`, 1280×720, 10 fps, 64 colours

No generated media. The commands in the video are the real builder and `--check` on this branch, plus a naive `python3 -m zipfile -c` of the skill folder.
