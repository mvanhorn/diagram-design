# Demo: Git graph visual type

Recorded evidence for `feat/git-graph-type`. Nothing here is shipped with the skill.

## commands.log

Exact commands, exit codes, and stdout/stderr, in order:

1. `python3 scripts/verify-git-graph.py --all` on the three shipped examples. Exit 0. Three files in scope, 232 skipped. The OK line names connectors that turn at the parent or merge column.
2. `python3 scripts/test-verify-git-graph.py`. Exit 0. 43 cases, both polarities, including a merge with one parent, a connector going backwards, a branch that runs along the parent lane, and a merge that runs along the destination lane.
3. `python3 scripts/verify-git-graph.py /tmp/git-graph-one-parent.html`. Exit 1. Named finding: merge commit `m1` has 1 incoming connector — a merge has exactly two incoming connectors.
4. `python3 scripts/verify-git-graph.py /tmp/git-graph-backwards.html`. Exit 1. Named findings: connector `c2→c1` runs right-to-left (column 2 → 1) and the path itself goes right-to-left.
5. `python3 scripts/lint-skin.py --all --baseline`. Exit 0. 240 files checked, 20 skipped, 0 findings.
6. `python3 scripts/verify-docs-sync.py`. Exit 0.
7. `python3 scripts/lint-render.py` on the three git-graph examples. Exit 0. 0 findings; the full editorial file is unmeasurable because the SVG sits in `overflow: auto` (same note as the other full editorial examples).

The packaged Playwright exporter wrote `screenshots/light.png`, `screenshots/dark.png`, and `screenshots/full.png` at gallery size. `screenshots/gallery.png` is the gallery page with tab 51 Git graph selected.

## Media

- `out.mp4` — 24 s, 1920×1080, 30 fps, 720 frames, H.264, yuv420p. Light (~3 s), dark (~2.5 s), full editorial (~2.5 s), gallery tab (~2 s), then large cards labelled “Animated replay of real captured command output”: the verify-git-graph OK line (~3 s), the one-parent merge refusal (~3 s), the right-to-left connector refusal (~3 s), and lint-skin / docs-sync pass counts (~2.5 s). The last ~2.5 s return to the light render.
- `preview.gif` — 960×540, 12 fps, 24 s, last frame held ~2 s, palettegen/paletteuse, under 5 MB.

## Screenshots

Light, dark, and full editorial of the same 1.2.0 release train: main on top, `feat/billing` merged, `release/1.2` cut, a timeout hotfix on that branch, `v1.2.0` tagged, and that tagged commit merged back to main. Coral is on the hotfix and the tagged release only. Branch connectors leave the parent column vertically first; merge connectors turn at the merge column so they do not run along a lane they are not drawing.

## logs/

Full local validation-gate output from CONTRIBUTING.md (104 passed, 0 failed), plus `ffprobe.txt`.
