Title: feat(type): add git graph for branch, merge and release flows

## What does this PR do?

Adds Git graph as visual type 51. One horizontal lane per branch, commits as dots on a shared left-to-right column grid, merge commits as dots with exactly two earlier parents on different lanes, tags as outlined labels above a commit, and coral on at most two commits. Timeline, Swimlane, and Gantt still cover calendars, ownership, and duration; they do not draw a two-parent merge.

The three gallery examples (light, dark, full editorial) tell one 1.2.0 release train: main on top, a billing feature merged, `release/1.2` cut, a timeout hotfix on that branch, `v1.2.0` tagged, and that tagged commit merged back to main. Branch connectors leave the parent column vertically first; merge connectors run on the source lane and turn at the merge column. `verify-git-graph.py` fails closed unless there are at least four commits, two lanes, and one merge, and it names a merge with one parent, a connector that runs right-to-left, and a connector that turns on the wrong column or runs along a lane it is not drawing.

Type ceiling is 5 lanes / 16 commits / 2 coral. The shipped examples stay at 3 lanes, 8 commits, and 9 orthogonal connectors so they also sit under the universal 9/12 budget. Plugin versions are unchanged.

## Visual proof

| Variant | Rendered preview |
|---|---|
| Light | ![Light](https://raw.githubusercontent.com/mvanhorn/pr-demo-assets/main/osc-bulk-1115b/git-graph-type/screenshots/light.png) |
| Dark | ![Dark](https://raw.githubusercontent.com/mvanhorn/pr-demo-assets/main/osc-bulk-1115b/git-graph-type/screenshots/dark.png) |
| Full editorial | ![Full editorial](https://raw.githubusercontent.com/mvanhorn/pr-demo-assets/main/osc-bulk-1115b/git-graph-type/screenshots/full.png) |

## Validation gates

Local CONTRIBUTING.md table: 104 passed, 0 failed, including `claude plugin validate . --strict`, `lint-render.py --all` (240 files, 0 findings, 3 unmeasurable notes), `verify-plugin-package.py --require-no-bump origin/main` (2.6.164 unchanged), `verify-git-graph.py --all` (3 files), and `test-verify-git-graph.py` (43 cases, both polarities). `scripts/lint-skin-baseline.txt` is unchanged.

- [x] `python3 scripts/test-lint-a11y.py`
- [x] `python3 scripts/lint-skin.py --all --baseline`
- [x] `python3 scripts/verify-sequence-oauth.py`
- [x] `python3 scripts/verify-drawio-import.py`
- [x] `python3 scripts/verify-mermaid-import.py`
- [x] `git diff --exit-code` green after `python3 scripts/build-icons.py` (if icons changed)
- [x] Docs updated in the same PR where behavior changed

Also run and passed: `verify-docs-sync.py`, `test-verify-docs-sync.py`, `test-css-string-scan.py` (16 verifiers), `lint-render.py --self-test` (46 cases), and the rest of the CONTRIBUTING.md Validation gates table. Outputs are on `demo/git-graph-type` under `logs/`.

Named refusals captured on `/tmp` copies of the light example: a merge with one incoming connector, and a connector that runs right-to-left.

Not verified here: clipping on the full editorial example (`lint-render` notes the SVG sits in `overflow: auto`, same as the other full editorial files); Windows and macOS CI runners; a source-data file compared against the chart (the type checker is internal consistency only, as for the other chart types).

## Checklist

- [ ] I have no more than five open PRs here, including drafts, and have addressed feedback on my existing PRs
- [x] No new entries added to `scripts/lint-skin-baseline.txt`
- [x] Generated and source files are consistent (extractor ↔ verifier ↔ reference ↔ command)
- [x] Accessible SVG contract satisfied for new/changed examples
- [ ] Rendered screenshots are attached for every new/changed diagram variant, or visual proof is marked not applicable
- [ ] Code of Conduct respected

## Related issues

None

## Demo

![demo](https://raw.githubusercontent.com/mvanhorn/pr-demo-assets/main/osc-bulk-1115b/git-graph-type/preview.gif)

Full recording (MP4): https://raw.githubusercontent.com/mvanhorn/pr-demo-assets/main/osc-bulk-1115b/git-graph-type/out.mp4
