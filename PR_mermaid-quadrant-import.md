Title: feat(import): redraw Mermaid quadrantChart blocks as quadrant diagrams

## What does this PR do?

Mermaid import now reads `quadrantChart` blocks (standalone `.mmd` / `.mermaid` files and fenced Markdown) and emits a `"kind": "quadrant"` IR: title, original x/y axis strings, Mermaid-numbered quadrant labels (1 top-right, 2 top-left, 3 bottom-left, 4 bottom-right), and points with coordinates in `[0, 1]`. Point styling, `classDef`, and `:::class` are counted and discarded. The four existing grammars are unchanged.

Named failures (exit 2): coordinates outside `[0, 1]`, non-numeric coordinates, duplicate point labels, and a chart with no points. More than 12 points are kept, with a digest note that the Quadrant type recommends splitting (hard cap 2000). Mapping notes in `import-mermaid.md` cover one-word axis tips (originals stay in the IR), a 0.04 nudge off an exact 0.5 axis, and no coral focal at extract time.

## Visual proof

Redraw of an eight-point Impact × Effort chart from the extracted IR. No new shipped example.

| Variant | Rendered preview |
|---|---|
| Light | ![Light redraw](https://raw.githubusercontent.com/mvanhorn/pr-demo-assets/main/osc-bulk-1115b/mermaid-quadrant-import/light.png) |
| Dark | ![Dark redraw](https://raw.githubusercontent.com/mvanhorn/pr-demo-assets/main/osc-bulk-1115b/mermaid-quadrant-import/dark.png) |
| Full editorial | Not applicable: import path only, no new shipped example |

## Validation gates

Local CONTRIBUTING.md table: 101 passed, 0 failed, including `claude plugin validate . --strict`, `lint-render.py --all`, and `verify-plugin-package.py --require-no-bump origin/main`. `scripts/lint-skin-baseline.txt` is unchanged. Plugin versions were not bumped.

- [x] `python3 scripts/test-lint-a11y.py`
- [x] `python3 scripts/lint-skin.py --all --baseline`
- [x] `python3 scripts/verify-sequence-oauth.py`
- [x] `python3 scripts/verify-drawio-import.py`
- [x] `python3 scripts/verify-mermaid-import.py`
- [x] `git diff --exit-code` green after `python3 scripts/build-icons.py` (if icons changed)
- [x] Docs updated in the same PR where behavior changed

Also run and passed: `verify-docs-sync.py`, `test-verify-docs-sync.py`, `test-install-scan.py`, `verify-plugin-package.py --require-no-bump origin/main`, and the rest of the CONTRIBUTING.md Validation gates table. Outputs are on `demo/mermaid-quadrant-import` under `logs/`.

## Checklist

- [ ] I have no more than five open PRs here, including drafts, and have addressed feedback on my existing PRs
- [x] No new entries added to `scripts/lint-skin-baseline.txt`
- [x] Generated and source files are consistent (extractor ↔ verifier ↔ reference ↔ command)
- [ ] Accessible SVG contract satisfied for new/changed examples
- [ ] Rendered screenshots are attached for every new/changed diagram variant, or visual proof is marked not applicable
- [ ] Code of Conduct respected

## Related issues

None

## Demo

![demo](https://raw.githubusercontent.com/mvanhorn/pr-demo-assets/main/osc-bulk-1115b/mermaid-quadrant-import/preview.gif)

Full recording (MP4): https://raw.githubusercontent.com/mvanhorn/pr-demo-assets/main/osc-bulk-1115b/mermaid-quadrant-import/out.mp4
