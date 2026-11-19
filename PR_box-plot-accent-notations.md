Title: fix(box-plot): recognise the accent in hwb, lab, oklch and currentColor

## What does this PR do?

Rule 7 of the box-plot checker treated the accent as hex, `rgb()`/`rgba()`, `hsl()`/`hsla()`, and `var()` chains. A second series painted with `hwb()`, `lab()`, `lch()`, `oklab()`, `oklch()`, or `currentColor` whose `color` is the accent still passed. This is item 5 of #487.

The checker now converts those CSS Color 4 functions to sRGB (D50/D65 as specified, clip to gamut, round to whole numbers) and compares them to the shipped accents under the same 4.5 channel tolerance used for `hsl()`. Space-separated arguments, `/ alpha`, percentages, `deg`/`grad`/`rad`/`turn` hues, and `none` are accepted. A function this parser cannot read is not treated as the accent, same as `hsl()`.

`currentColor` is the accent when the element's own or inherited `color` is: the `color` attribute, an inline `style`, and the stylesheet rules the checker already reads. `inherit` / `unset` / `currentColor` keep walking; a matching accent `color` rule counts even if another rule would override it (no cascade, fail closed).

Named colours: no CSS named colour sits within 4.5 of either shipped accent (closest on light is `brown` at 27, on dark is `coral` at 15), so they stay a no-op. Fixtures with `tomato`, `chocolate`, and `coral` still pass. Near-but-outside-tolerance `hwb()` (max channel delta 5) and a muted `currentColor` still pass.

Items 3, 6, 7, 8 and 9 of #487 are out of scope.

Gates run on this branch (Python 3.13.5, Linux), every `gates.local_commands` entry in `.maintainer-policy.json` (103 commands). All 103 passed. The first pass of `python3 scripts/lint-render.py --self-test` and `--all` exited 2 with "Playwright is not installed"; after `pip install playwright` and `python3 -m playwright install chromium`, `--self-test` was 46 cases with no false flags and `--all` rendered 240 files with 0 findings. `python3 scripts/test-verify-box-plot.py` is 227 cases, both polarities — 18 of those fail on upstream/main's checker and pass here. `python3 scripts/verify-box-plot.py --all` is clean on the three shipped examples. `python3 scripts/verify-plugin-package.py --require-no-bump origin/main` passed; plugin manifests were not edited. `python3 scripts/lint-skin.py --all --baseline` passed with no new baseline entries. `python3 scripts/verify-docs-sync.py` and `python3 scripts/test-verify-docs-sync.py` passed after the type-scatter note of the new notations.

Not verified: GitHub Actions on a pull request (this change is not opened as a PR from this checkout).

## Visual proof

Not applicable

| Variant | Rendered preview |
|---|---|
| Light | Not applicable |
| Dark | Not applicable |
| Full editorial | Not applicable |

## Validation gates

<!-- Mark what you ran and that it passed. CI runs all of these on the PR too. -->

- [ ] `python3 scripts/test-lint-a11y.py`
- [ ] `python3 scripts/lint-skin.py --all --baseline`
- [ ] `python3 scripts/verify-sequence-oauth.py`
- [ ] `python3 scripts/verify-drawio-import.py`
- [ ] `python3 scripts/verify-mermaid-import.py`
- [ ] `git diff --exit-code` green after `python3 scripts/build-icons.py` (if icons changed)
- [ ] Docs updated in the same PR where behavior changed

## Checklist

- [ ] I have no more than five open PRs here, including drafts, and have addressed feedback on my existing PRs
- [ ] No new entries added to `scripts/lint-skin-baseline.txt`
- [ ] Generated and source files are consistent (extractor ↔ verifier ↔ reference ↔ command)
- [ ] Accessible SVG contract satisfied for new/changed examples
- [ ] Rendered screenshots are attached for every new/changed diagram variant, or visual proof is marked not applicable
- [ ] Code of Conduct respected

## Related issues

https://github.com/cathrynlavery/diagram-design/issues/487 (item 5). Items 3, 6, 7, 8 and 9 stay open.

## Demo

![demo](https://raw.githubusercontent.com/mvanhorn/pr-demo-assets/main/osc-bulk-1119/box-plot-accent-notations/preview.gif)

Full recording (MP4): https://raw.githubusercontent.com/mvanhorn/pr-demo-assets/main/osc-bulk-1119/box-plot-accent-notations/out.mp4
