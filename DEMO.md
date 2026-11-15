# Demo: Mermaid quadrantChart import

Recorded evidence for `feat/mermaid-quadrant-import`. Nothing here is shipped with the skill.

## commands.log

Exact commands, exit codes, and stdout/stderr, including the upstream refusal, the Markdown digest, `--json`, named failures, lint-skin, and PNG export. The video holds the key beats from that log at large type; it does not scroll the JSON IR.

## Video frames (`out.mp4`, 24 s, 1920×1080, 30 fps, 720 frames)

Held slides, in order:

1. **~4 s** — Markdown digest at large type: kind `quadrant`, 8 points, original axes (`Low Effort → High Effort`, `Low Impact → High Impact`), quadrants `1=Do first; 2=Major projects; 3=Quick wins; 4=Avoid`, `1 discarded styling`, exit 0. Banner: “Animated replay of real captured command output”.
2. **~3 s** — both named failures at large type: `point coordinate outside [0, 1] at line 4` and `duplicate point label at line 4`, each exit 2.
3. **~4 s** — light redraw, full-frame. Eight points, one-word EFFORT/IMPACT tips, coral on Billing API only.
4. **remainder, ending on this frame** — dark redraw, full-frame, last ~2 s held.

## preview.gif

1280×720, 12 fps, 24 s, last frame held ~2 s, under 5 MB.

## Screenshots

`screenshots/light.png` and `screenshots/dark.png` are the Playwright exports used in the video. Axis originals stay in the extractor JSON; coral was chosen while drawing.

## logs/

Full local validation-gate output from CONTRIBUTING.md, plus `ffprobe.txt`.
