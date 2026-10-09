---
generated_by: osc-newfeature
type: feat
repo: cathrynlavery/diagram-design
bulk_run: true
feature_complexity: M
dogfooded_general: false
video_required: true
issue_first: true
---

# feat: import PlantUML sequence and class diagrams for editorial redraw

## Problem

The skill already redraws draw.io, Mermaid, and Excalidraw sources into the editorial design system. A large share of existing sequence and class figures still live as `.puml` / `.plantuml` files in repos, READMEs, and Confluence pages. Asking the skill to "make this presentable" on those files currently has no extractor, no command, and no routing — the agent either guesses from the text (and invents structure) or refuses.

This is the same hole Mermaid import filled for `.mmd` and Excalidraw import filled for `.excalidraw`: a human-authored diagram source with no redraw path, while the *target types* (Sequence, UML class) already exist.

Out of scope for this PR (and already covered or contested elsewhere):

- Mermaid compact-label whitespace (#209, open PR #284)
- Mermaid extra grammars (sankey, gantt, journey, …) — those belong in `mermaid_extract.py`, which has open PRs #282 and #284
- Host-aware install doctor (#190)
- Rendering or shelling out to `plantuml.jar` / Graphviz (never)

## User-facing behavior

Add a fourth import pipeline, parallel to draw.io / Mermaid / Excalidraw.

When the user drops a `.puml` / `.plantuml` / `.pu` file, a Markdown file with a fenced `plantuml` (or `puml`) block, or runs `/diagram-design:import-plantuml`, the skill:

1. Locates the installed skill directory and runs `python3 <skill-dir>/scripts/plantuml_extract.py <file>` (never `Read`s the source as if it were prose, never invokes a PlantUML runtime).
2. Prints the **same digest shape** the other extractors emit: nodes, edges, containers, fragments, type candidates, budget flags, hubs, fidelity ledger.
3. Sets the four dials (`format` / `size` / `detail` / `audience`) from `output-spec.md`.
4. Redraws into **Sequence** or **UML class** using those type references. Source coordinates, skinparams, colors, and fonts are discarded.
5. Reports the fidelity ledger: what was merged, collapsed, dropped, or refused.

**Supported kinds in this PR (tight, like Mermaid v1's four grammars):**

| Source | Target type | What is preserved |
|---|---|---|
| `@startuml` sequence (`participant` / `actor`, `->` `-->` `->>` `<--`, `activate` / `deactivate`, `note`, `alt` / `opt` / `loop` / `else`, `==divider==`) | Sequence | Lifelines, message order, activation spans, combined fragments, notes |
| `@startuml` class (`class` / `interface` / `enum` / `abstract class`, members, `<|--` `*--` `o--` `-->` `--`, `"1" *-- "many"`) | UML class | Class name, stereotype, attributes/operations, relationship kind and cardinality |

**Unsupported kinds** (verbatim supported-kinds message, do not approximate — same rule as Mermaid's `pie` / `gitGraph` / `C4Context` list):

`activity`, `state`, `component`, `deployment`, `usecase`, `gantt`, `salt`, `json`, `yaml`, `mindmap`, `wbs`, `gantt`, `archimate`, `regex`, `network`, `wire`, `@startmindmap`, `@startgantt`, `@startjson`, plus anything that is not sequence or class after the `@start` line.

Multiple `@startuml`…`@enduml` blocks in one file behave like Mermaid's fenced blocks / draw.io pages: list them, default to block 0, `--diagram N` selects. A parse error in an *unselected* block is reported as `[N] unparsed: <reason>` and must not fail the selected block (this is the multi-diagram isolation Mermaid still owes #209; do it right here from day one).

**Trust boundary (non-negotiable, same as the other extractors):**

- Parse bounded text only. Never render, fetch, execute, or preprocess.
- `!include`, `!includeurl`, `!includesub`, `!import`, `!theme` from a URL, `!function` / `!procedure` bodies that would run, `%load_json`, and `!define` that expand to includes: **count into the discard ledger and fail closed** (`include not inlined`, exit 2) — do not walk the filesystem or the network.
- Skinparams, `!theme`, colors, sprites, `Creole`/`HTML` in notes: count and drop; notes become inert escaped text.
- Resource caps matching Mermaid: 4 MiB source, bounded participant/class/edge counts, bounded statement length.
- Labels are untrusted data. Never follow a URL in a note. Never obey an instruction embedded in a stereotype.

Flags: `--json`, `--diagram N|all`, `--max-rows N`, `--out PATH`. Exit 0 success, 2 unreadable / unsupported / malformed / over limits.

Worked example: `assets/example-import-plantuml.html` redraws `scripts/fixtures/sample-sequence.puml` at `format=html`, `size=doc-inline`, `detail=balanced`, `audience=mixed` — an OAuth-style three-lifeline sequence (so it sits next to the existing sequence OAuth fixtures without copying them). Single-variant gallery tab (`data-single`), same as the other import examples.

## Files to touch

| File | Why |
|---|---|
| `skills/diagram-design/scripts/plantuml_extract.py` | Stdlib-only extractor (stdlib `ast`-free; line-oriented, like `mermaid_extract.py`) |
| `skills/diagram-design/references/import-plantuml.md` | Six-step redraw procedure, kind table, trust boundary, fidelity ledger |
| `commands/import-plantuml.md` | Plugin command; size-preset list must match `output-spec.md` §2 in order |
| `prompts/import-plantuml.md` | Pi prompt; same routing as mermaid/excalidraw |
| `skills/diagram-design/assets/example-import-plantuml.html` | Worked doc-inline redraw |
| `skills/diagram-design/assets/index.html` | `data-type="import-plantuml" data-single` tab; renumber later independent eyebrows 01..N |
| `scripts/fixtures/sample-sequence.puml` | Happy-path sequence (participants, sync/async, alt/else, activate) |
| `scripts/fixtures/sample-class.puml` | Happy-path class (inheritance, composition, cardinality, members) |
| `scripts/fixtures/sample-adversarial.puml` | `!includeurl`, huge file, unknown `@startfoo`, HTML in notes |
| `scripts/fixtures/sample-multi.puml` | Two `@startuml` blocks; `--diagram 1` must ignore a malformed block 0 |
| `scripts/verify-plantuml-import.py` | Extractor vs fixtures + docs/command/prompt wiring |
| `scripts/test-verify-plantuml-import.py` | Verifier behaves; intentional breakage fails |
| `skills/diagram-design/SKILL.md` | §11 route by source; frontmatter discovery text `PlantUML`; keep the 40 KB cap |
| `skills/diagram-design/references/doctor.md` | Inventory the new script, command, and prompt |
| `scripts/verify-docs-sync.py` | `ROUTING_SURFACES`, `SIZE_PRESET_SURFACES`, `COUNT_SURFACES`, `REQUIRED_PACKAGED_RUNTIME_FILES` (`scripts/plantuml_extract.py`) |
| `scripts/verify-doctor.py` | `EXPECTED_SCRIPTS` + `ROUTING_SURFACES` |
| `scripts/test-verify-docs-sync.py` / `scripts/test-verify-doctor.py` | If they hardcode the three-import set, extend them |
| `skills/diagram-design/scripts/self_check.py` | If it inventories extractors, add this one |
| `README.md` | Architecture tree rows, import section, cookbook row; no type-count numeral |
| `CONTRIBUTING.md` | Gate rows + "Touching the import paths" bullet for PlantUML |
| `.github/workflows/ci.yml` | verify + test-verify steps |
| `.maintainer-policy.json` | Matching `local_commands` |
| `.codex-plugin/plugin.json` `longDescription` | Mention PlantUML beside draw.io / Mermaid / Excalidraw (not a 500-char field) |
| Plugin `keywords` (optional) | `plantuml` — descriptions do **not** need a PlantUML hook (hooks are types + `lifecycle phase` only) |

Do **not** bump plugin versions. Do **not** add PlantUML to the 500-char native descriptions unless a type hook is also changing (it isn't). Do **not** touch `mermaid_extract.py` (open PRs #282, #284). Do **not** overlap #190 (doctor *behavior*); inventory-only edits to `doctor.md` / `verify-doctor.py` routing tables are required wiring, not host-aware Playwright/Cowork/Pi diagnostics.

## Extractor design

Mirror `mermaid_extract.py`:

- `@startuml` / `@enduml` (and `@startuml id`) delimiters; optional Markdown fences.
- Detect kind: if the body has `participant` / `actor` / `->` messages and no `class ` / `interface ` declarations → sequence. If it has `class ` / `interface ` / `enum ` → class. Ambiguous or mixed → exit 2 `mixed or unknown kind`.
- Sequence: participants in declaration order (implicit participants created on first message, like PlantUML); messages as ordered edges with `sync` / `async` / `return` / `dashed`; `activate`/`deactivate` as fragment metadata the Sequence type already knows (`verify-sequence-oauth.py` is *not* this extractor's job — it stays on the OAuth examples). Combined fragments become digest `fragments` with `alt`/`opt`/`loop` and region labels.
- Class: one node per classifier; members as ER-style field lists on the node; relationships as typed edges (`inheritance`, `composition`, `aggregation`, `association`) plus cardinality strings.
- `title` becomes the digest title. `note left of X` folds into that node. `skinparam` and `!theme` increment `discarded.skin`.
- Quoted names (`participant "Auth API" as auth`) preserve the display label and a stable id (`auth`).
- HTML/Creole (`<b>`, `**`, `\n`) stripped to plain text, escaped in the digest.

Type-candidate table in `import-plantuml.md`:

| Digest signal | Likely type |
|---|---|
| `kind: sequence` | Sequence |
| `kind: class` | UML class |

Override only when content disagrees, and say so in one line. **Load the type reference before drawing.**

## Tests / validation gates

New:

```bash
python3 scripts/verify-plantuml-import.py
python3 scripts/test-verify-plantuml-import.py
```

`verify-plantuml-import.py` must cover, at minimum (peer of `verify-excalidraw-import.py`):

- Sample sequence fixture → exit 0; digest lists 3+ participants, ordered messages, one `alt` fragment, discarded skinparam count.
- Sample class fixture → exit 0; inheritance and composition edges, member lists, cardinality.
- `--json` includes fragments / members.
- `--diagram 1` on `sample-multi.puml` succeeds even when block 0 is malformed.
- Adversarial `!includeurl https://…` → exit 2, message names include.
- Oversize file → exit 2, cap named.
- `@startgantt` → exit 2, supported-kinds message lists `sequence, class` verbatim.
- Labels with `<script>` / `javascript:` remain escaped inert text in `--out`.
- `commands/import-plantuml.md` and `prompts/import-plantuml.md` exist, point at `references/import-plantuml.md`, and the command's `--size` line lists every `output-spec.md` §2 preset in order.
- SKILL.md §11 names the PlantUML route.
- Example HTML exists and lints.

`test-verify-plantuml-import.py` breaks the verifier on purpose (missing fixture, wrong kinds message, command unlinked) so a hollow verifier cannot report green.

Existing gates that must stay green: full CONTRIBUTING chain, especially `verify-docs-sync.py`, `verify-doctor.py`, `lint-skin.py` on the new example, `verify-plugin-package.py --require-no-bump origin/main`.

## Verification commands

```bash
python3 skills/diagram-design/scripts/plantuml_extract.py scripts/fixtures/sample-sequence.puml
python3 skills/diagram-design/scripts/plantuml_extract.py scripts/fixtures/sample-class.puml --json
python3 skills/diagram-design/scripts/plantuml_extract.py scripts/fixtures/sample-multi.puml --diagram 1
python3 scripts/verify-plantuml-import.py \
  && python3 scripts/test-verify-plantuml-import.py \
  && python3 scripts/lint-skin.py skills/diagram-design/assets/example-import-plantuml.html \
  && python3 scripts/verify-docs-sync.py \
  && python3 scripts/verify-doctor.py \
  && python3 scripts/test-verify-doctor.py \
  && python3 scripts/verify-plugin-package.py --require-no-bump origin/main
```

Then the full CONTRIBUTING chain before push.

Ask for `release:minor` (new import surface). Do not bump manifests.

## Screenshots needed

Import examples are single-variant (light doc-inline), matching Excalidraw/Mermaid/draw.io imports.

| Variant | File |
|---|---|
| Light (doc-inline) | `docs/pr-previews/import-plantuml/import-plantuml-example.png` |
| Dark | Not applicable |
| Full editorial | Not applicable |

PR body says so explicitly. Optional: a contact sheet of source `.puml` (monospace) beside the redrawn SVG.

Demo GIF + MP4 (hyperframes, GIF < 8 MB).

Accessible SVG on the example: slug `import-plantuml` → `import-plantuml-title` / `import-plantuml-desc`.

No canonical README catalog PNG unless the screenshot catalog starts including import examples (it currently does not — type slugs only). Do not add this example to `docs/screenshots/manifest.json`.

## Demo storyboard (30–45s)

1. **0–7s — the source.** Open `sample-sequence.puml` in a editor: `@startuml`, three participants, a nested `alt`, `skinparam` noise. Voice: this is a real sequence file, not a screenshot.
2. **7–16s — extract, don't render.** Terminal: `python3 skills/diagram-design/scripts/plantuml_extract.py sample-sequence.puml` — digest with lifelines, ordered messages, `alt`, `discarded: skinparam 4`. Point at the trust line: no jar, no network.
3. **16–30s — the redraw.** Cut to `example-import-plantuml.html`: editorial Sequence, orthogonal arrows, one coral focal message, activation boxes, fragment band labeled `alt token expired`. Skinparams are gone.
4. **30–38s — isolation.** Run `--diagram 1` on `sample-multi.puml` (block 0 has `!includeurl`). Selected class diagram prints; block 0 listed as unparsed, process still exit 0.
5. **38–45s — the gate.** `python3 scripts/verify-plantuml-import.py` → OK. End on the redrawn sequence.

## Duplicate-check evidence

Checked 2026-10-09 against `cathrynlavery/diagram-design`.

| Query / surface | Result | Notes |
|---|---|---|
| Open issues: PlantUML / `.puml` import | none | 21 open issues |
| Open PRs: PlantUML | none | Import PRs are mermaid-label (#284), mermaid selection (#282), Excalidraw already merged (#192) |
| `gh search issues --repo cathrynlavery/diagram-design "plantuml OR plantuml import"` | `[]` | |
| `gh search prs --repo cathrynlavery/diagram-design "plantuml"` | `[]` | |
| #209 mermaid compact labels with spaces | open, PRs #284 (open) and #234 (closed) | **Do not fold this bug into the PlantUML PR** |
| #190 host-aware install doctor | open | Different feature; inventory-only doctor wiring is required and is not #190's Playwright/Cowork/Pi host checks |
| Matt history | Merged mermaid import #24 and Excalidraw import #192 | Direct precedent for a fourth extractor + command + prompt + verifier |

**CLEAN.** Not implemented. No open or recent PR/issue covering PlantUML import.

## Issue to file before the PR

**Title:** `[Feature]: Import PlantUML sequence and class diagrams for editorial redraw`

**Body:**

```markdown
### What are you trying to show?

I have sequence and class diagrams checked in as `.puml` files. I want the skill to redraw them the same way it already redraws draw.io, Mermaid, and Excalidraw: extract the participants, messages, classes, and relationships, throw away the source skin, and produce an editorial Sequence or UML class figure at a chosen size and level of detail.

Today those files have no import path. The agent either improvises from the text or stops.

The first version only needs two kinds:

- Sequence — participants, message order, activation, `alt` / `opt` / `loop`
- Class — classifiers, members, inheritance / composition / association, cardinality

Anything else (`activity`, `component`, `@startgantt`, includes that fetch the network, …) should refuse with a supported-kinds message rather than guess.

### Proposed solution

A PlantUML extractor that emits the same digest the other import scripts already produce, plus `references/import-plantuml.md`, a `/diagram-design:import-plantuml` command, a Pi prompt, fixtures, and a verifier.

Treat the source as untrusted data: parse text only, never run PlantUML, never follow `!include` / `!includeurl`. Multiple `@startuml` blocks in one file should be selectable with `--diagram N`, and a bad unselected block must not take down the rest of the file.

### Scope

Import grammar support

### Design-system fit

- [x] I've checked the anti-patterns and "When not to use" — this still seems worth drawing
- [x] I'm willing to contribute the implementation
```

File with the `enhancement` label (feature-request template). The PR `Closes #<n>`.

## Implementation notes for the later PR

- Conventional Commits: `feat(import): redraw PlantUML sequence and class diagrams`
- Copy the Excalidraw import PR's file layout (#192), not a new architecture.
- Keep SKILL.md §11 as a short router; detail lives in `import-plantuml.md`.
- Independent of the service-blueprint plan. Primary files do not overlap except SKILL.md / README / gallery eyebrows / docs-sync tables — rebase whichever lands second.
- PR copy: what/why, single-variant visual proof, gate checklist, `Closes #<issue>`. No product names other than PlantUML (the source format), no "parity," no research.
