Title: feat(package): build a Claude Desktop skill ZIP under the upload file limit

## What does this PR do?

Claude Desktop rejects a custom-skill ZIP with more than 200 files (issue #525). Zipping `skills/diagram-design` as-is is over that: 321 tracked files in the git index, 325 files on disk in this checkout. Public Agent Skills documentation states the frontmatter `name`/`description` limits and a 30 MiB uncompressed upload size, but does not publish a file-count cap. This change uses the 200-file error the issue reported.

`scripts/build-claude-skill-zip.py` builds `dist/diagram-design-claude-skill.zip` (gitignored) from the git index, the same way the existing directory ZIP builder (`scripts/build-openai-plugin-zip.py`) does: deterministic entry order and timestamps, Unix modes, a top-level `diagram-design/` folder with `SKILL.md` at its root.

Include rule (product decision for this host; adjust the function in the builder, not a hand list of names):

- `SKILL.md`
- every file under `references/`
- every file under `scripts/`
- `assets/template*.html` and `assets/icons.html`
- every `assets/example-*.html` that is not a gallery or CI-only variant

Left out: `assets/index.html`, and `example-*-dark.html` / `example-*-full.html` / `example-*-animated.html`. A markdown link in `SKILL.md` or `references/*.md` that resolves to a tracked skill file must still be in the ZIP; `--check` fails if the rule would drop one.

`--check` fails when the file count is above 180 (host 200 with a margin of 20), uncompressed size is above 30 MiB, `name`/`description` miss the host limits, or a referenced path is missing. On this tree it reports 164 files and 2,669,104 bytes uncompressed.

README, the cookbook host matrix, and CONTRIBUTING describe how to build or later download the ZIP. No release workflow is added. Plugin manifest versions are unchanged.

Gates run on this branch (Python 3.13.5, Linux), every `gates.local_commands` entry in `.maintainer-policy.json` (105 commands). All 105 passed in 579.6 s. `python3 scripts/test-build-claude-skill-zip.py` is 45 cases (count limit, a synthetic SKILL.md that markdown-links an omitted file, determinism, layout, dirty-tree uses the index). `python3 scripts/build-claude-skill-zip.py --check` printed OK at 164 files. `python3 scripts/verify-plugin-package.py --require-no-bump origin/main` passed. `python3 scripts/lint-skin.py --all --baseline` passed with no new baseline entries. `python3 scripts/lint-render.py --self-test` and `--all` passed (slowest gate, 257.5 s). `npm ci --prefix .github/ci/node && .github/ci/node/node_modules/.bin/claude plugin validate . --strict` passed. The two new commands are registered in `.maintainer-policy.json`, `.github/workflows/ci.yml`, and the CONTRIBUTING validation list in the same place as the existing directory ZIP builder.

Not verified: GitHub Actions on a pull request (this change is not opened as a PR from this checkout). Claude Desktop's macOS import UI is not available on this Linux box, so the ZIP was not imported there.

## Visual proof

Not applicable — this change builds a skill ZIP; it does not add or change a diagram, example, or template.

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

#525

## Demo

![demo](https://raw.githubusercontent.com/mvanhorn/pr-demo-assets/main/osc-bulk-1119/claude-skill-zip/preview.gif)

Full recording (MP4): https://raw.githubusercontent.com/mvanhorn/pr-demo-assets/main/osc-bulk-1119/claude-skill-zip/out.mp4
