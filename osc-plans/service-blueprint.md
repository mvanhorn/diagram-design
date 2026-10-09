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

# feat: add a service blueprint visual type

## Problem

The skill can already draw what a person *does* and how it *feels* (`User journey`). It cannot draw the other half of the same story: what the service does in front of the customer, what stays hidden, and which support processes hold it up.

A journey's load-bearing element is the sentiment curve. A swimlane's is flow across owner lanes. A process diagram is sequential handoffs. None of those force a **line of visibility** across a shared stage grid, with customer / frontstage actions above it and backstage / support actions below it. Without that line, "the email goes out" and "the fraud check runs" look like the same kind of step, and the reader cannot see which failures the customer will notice.

Typical asks this currently misroutes:

- "Draw the checkout service — what the customer sees vs. what billing and risk actually do."
- "Map onboarding: the screens, the jobs behind them, and where a ticket gets stuck."
- "Show why the 'payment failed' moment is a backstage timeout, not a UI copy problem."

Routing those onto journey (no visibility line), swimlane (arrows, no stage census), or process (no front/back split) drops the claim the figure exists to make.

## User-facing behavior

Add **Service blueprint** as visual type #45.

When the user asks for a service blueprint, a frontstage/backstage map, or "what the customer sees vs. what the service does," the skill:

1. States the type (Service blueprint), size preset, and what the budget will cut, then draws.
2. Lays out **stages as equal columns** (max 6) and **layers as labeled rows** in this order, top to bottom:
   - Physical evidence (optional)
   - Customer actions (required)
   - Line of interaction (hairline)
   - Frontstage actions — onstage staff or the visible product (required)
   - **Line of visibility** (load-bearing; heavier rule than the other lines)
   - Backstage actions (required)
   - Line of internal interaction (hairline)
   - Support processes (optional)
3. Treats the grid as a **census**, not a flow chart. Stage order is the sequence. No connector arrows in v1 (that is swimlane territory). Wait times and systems are cell text, not edges.
4. Puts at most **one** accent cell — the failure, wait, or handoff the figure exists to show — usually on or below the visibility line.
5. Ships three variants: minimal light, minimal dark, full editorial.

**Not this type** (called out in the reference and the journey/swimlane/process "Not this type" lists):

- Sentiment across stages, no backstage → **User journey**
- Flow with handoffs across named owners → **Swimlane**
- Sequential nodes with data payloads → **Process**
- One person's phases, waits, retries → **Lifecycle phase map** on State machine

Worked example (same narrative as `example-journey.html`, other side of the story): *Trial to paid — what the customer never sees.* Five stages (Sign up, Activate, Hit the limit, Upgrade, First invoice). Focal cell: backstage `dunning-job timeout` under "Hit the limit," sitting below the visibility line while the customer row still says "Retry payment."

## Files to touch

Implementation + wiring + tests (complete contract):

| File | Why |
|---|---|
| `skills/diagram-design/references/type-service-blueprint.md` | Layout, visibility-line grammar, anti-patterns, honesty rules, element pattern |
| `skills/diagram-design/assets/example-service-blueprint.html` | Minimal light |
| `skills/diagram-design/assets/example-service-blueprint-dark.html` | Minimal dark |
| `skills/diagram-design/assets/example-service-blueprint-full.html` | Full editorial (cards + footer) |
| `skills/diagram-design/assets/index.html` | Independent gallery tab; renumber later independent eyebrows so 01..N stays contiguous |
| `skills/diagram-design/SKILL.md` | Frontmatter hook, "Forty-five visual types", §3 row, description still names every type |
| `skills/diagram-design/references/layout-budget.md` | Budget row: 6 stages, required layers customer/frontstage/backstage, optional evidence/support, 1 focal cell |
| `skills/diagram-design/references/semantic-patterns.md` | Opening "the 45 visual types" |
| `skills/diagram-design/references/type-journey.md` | "Not this type" pointer to blueprint |
| `skills/diagram-design/references/type-swimlane.md` | Same, one line |
| `skills/diagram-design/references/type-process.md` | Same, one line |
| `scripts/verify-service-blueprint.py` | Executable contract (see Tests) |
| `scripts/test-verify-service-blueprint.py` | Shipped files pass; named mutation classes fail |
| `scripts/verify-docs-sync.py` | `VISUAL_TYPE_COUNT = 45`; `DESCRIPTION_ALIASES["service blueprint"] = "blueprint"` |
| `scripts/verify-semantic-motion.py` | `VISUAL_TYPE_COUNT = 45` |
| `docs/adr/0002-semantic-patterns-do-not-expand-the-taxonomy.md` | Amendment: **the count is 45** |
| `docs/adr/0015-service-blueprint-is-a-visibility-line-grammar.md` | Why journey/swimlane/process fail the bar |
| `docs/screenshots/service-blueprint.png` | Canonical README shot from `render-canonical-screenshots.py` |
| `docs/screenshots/manifest.json` | New entry (script-owned) |
| `docs/screenshots/thumbs/service-blueprint.webp` + thumbs manifest | `build-readme-thumbs.py` |
| `docs/pr-previews/service-blueprint/` | Light, dark, full PNGs for the PR template |
| `README.md` | Screenshot grid cell + verifier prose; do **not** hardcode a type-count numeral |
| `CONTRIBUTING.md` | Gate rows for the new verifier + tests |
| `.github/workflows/ci.yml` | `verify-service-blueprint.py --all` and `test-verify-service-blueprint.py` |
| `.maintainer-policy.json` | Same two commands in `gates.local_commands` (must match ci.yml) |
| `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, `.factory-plugin/plugin.json` | **Descriptions only** — add the `blueprint` hook. **Never bump `version`.** Native descriptions are 498/500 chars; alias + a short trim (see Description budget). Codex `longDescription` keeps the full name "service blueprint" and "45 diagram types." |

Do not edit `.claude-plugin/plugin.json` `version` (or the Codex/Factory copies). Do not add `scripts/lint-skin-baseline.txt` entries. Do not add a builder script unless geometry proves too brittle by hand — journey did not need one; match that unless the verifier cannot read static SVG.

Optional if `lint-render.py --all` flags the wide stage grid on the mobile viewport: a local overflow wrapper on the examples (waterfall already has a mobile containment check; copy that pattern only if the paint oracle fails).

## Grammar (for the type reference and ADR 0015)

Audit against ADR 0002 / 0007:

| Nearest type | Why it fails |
|---|---|
| User journey | Load-bearing element is a sentiment curve. No visibility line, no backstage layer, one persona's feelings. |
| Swimlane | Load-bearing element is flow across owner lanes. Arrows are the claim. No stage census, no visibility line. |
| Process | Sequential nodes and data handoffs. No layered split of what is onstage vs offstage. |
| Kanban | State census in columns, deliberately no connectors — closest cousin structurally, but columns are *states*, not narrative stages, and there is no visibility line. |
| Story map | Narrative backbone × release slices. The cut line is scope, not visibility. |
| Layer stack | Abstraction bands with no stage columns. |

The new grammar is: **one shared stage grid, required customer / frontstage / backstage rows, and a visibility line that is the figure.** That is not a zoom level on journey and not a missing arrow on swimlane.

### Data contract (machine-readable, like waterfall)

Every layer group: `data-layer="evidence|customer|frontstage|backstage|support"`.

Every cell: `data-stage="<stage-id>"` matching a header `data-stage`, plus `data-name` for the printed action.

Visibility line: `data-role="visibility"`. The two hairlines: `data-role="interaction"` and `data-role="internal-interaction"`.

Optional focal cell: `data-focal="true"` on at most one cell.

No `transform`, geometry `style`, or `<style>` rules that move marks (same fail-closed as other chart verifiers).

### Layout numbers (write these into the reference)

- ViewBox `0 0 1280 720` (journey's frame) for the minimal examples; full editorial can keep the same SVG and add cards.
- Left margin 96px for layer labels (Geist Mono 8px, uppercase, horizontal — never `writing-mode: vertical`).
- 5 columns × 208px + 16px gutters in the worked example; the type allows 4–6 stages.
- Row heights: evidence 48px (if present), customer 64px, frontstage 64px, backstage 64px, support 48px (if present). Hairlines 8px including stroke.
- Visibility line: 2px `ink` at 0.45 opacity (must clear 3:1 on paper); other lines 1px `rule`.
- Cell text: Geist 12px, one line; a second muted mono line is allowed for a system or wait (`dunning-job · 4h`).
- Legend: visibility line, backstage layer, focal cell — in that order.

### Anti-patterns

- No visibility line, or a line that sits in the wrong gap (not between frontstage and backstage).
- Sentiment curve on a blueprint (that's a journey; split the figures).
- Arrows crossing layers (that's a swimlane).
- Accent on every failing cell.
- Empty required layers with no `—` / `Not applicable` mark.
- More than 6 stages; more than two lines of cell text.

## Tests / validation gates

New gates:

- `python3 scripts/verify-service-blueprint.py --all` — shipped examples pass.
- `python3 scripts/test-verify-service-blueprint.py` — both polarities per ADR 0005.

Verifier findings (named, fail-closed):

1. **Layer order** — evidence (optional) → customer → frontstage → backstage → support (optional). Missing required layer, duplicate layer, or wrong vertical order.
2. **Visibility** — exactly one `data-role="visibility"` line, horizontally spanning the plot, vertically between the frontstage row bottom and the backstage row top (±2px).
3. **Stage grid** — every cell's `x` matches its stage header; column widths equal; gutters equal.
4. **Census** — every stage has a customer cell and a frontstage cell and a backstage cell (empty allowed only with an explicit `—` / `Not applicable` `data-name`).
5. **Focal** — ≤1 `data-focal`.
6. **Budget** — ≤6 stages; no extra `data-layer` values.
7. **Print** — each cell's visible text contains its `data-name`.
8. **No CSS motion of marks** — `transform` / geometry properties in attributes, inline style, or `<style>`.
9. **Contrast** — visibility line stroke vs paper clears 3:1 (reuse the dumbbell/waterfall approach, do not invent a third contrast helper if one is importable).

Adversarial mutations in `test-verify-service-blueprint.py` (one class each, all must fail with the named finding): swap two layers; drop the visibility line; put the visibility line above the customer row; shift one cell off its column; drop a backstage cell; two focal cells; seven stages; CSS `translate` on a cell; printed text disagrees with `data-name`.

Existing gates that will see the new files automatically:

- `lint-skin.py --all --baseline` (a11y SVG contract, palette, no baseline append)
- `lint-render.py --all` (paint oracle; watch mobile overflow)
- `verify-docs-sync.py` + `test-verify-docs-sync.py` (count, hooks, gallery, README tree)
- `verify-semantic-motion.py --markdown-only` (count, ADR 0002 amendment)
- `verify-screenshot-freshness.py` + thumbs check
- `verify-plugin-package.py --require-no-bump origin/main`
- `test-maintainer-policy.py` (ci.yml ↔ policy)
- `test-lint-a11y.py` (unchanged unit tests; examples still must satisfy the contract)

## Description budget (500-char Cowork cap)

Native plugin `description` fields are **498/500** today. They must keep every type hook and the discovery hook `lifecycle phase`.

Do this in the same PR:

1. `DESCRIPTION_ALIASES["service blueprint"] = "blueprint"` in `verify-docs-sync.py`.
2. Put `blueprint` in every native `description` (substring is enough; "service blueprint" also contains it).
3. Free ≥10 characters without dropping a hook. Safe trim: `"dependency graph"` → `"dependency"` in the *plugin* descriptions only, plus a two-character trim elsewhere if still over (ADR 0014 used `exploded/plan` and `journey` the same way). Keep `"lifecycle phase"` intact (`lifecycle phases` still matches).
4. SKILL.md frontmatter can keep the full phrase `service blueprint` (823/1024 today).
5. Codex `longDescription` lists the full name and is not under the 500 cap; update its type list there.

Never trade a type name out of the SKILL.md description to pay the byte cap (ADR 0004). SKILL.md is ~30,098 bytes; one §3 row is well under 40,000. No body-prose trim required unless the description rewrite somehow balloons the file.

## Verification commands

From repo root, after the files exist:

```bash
python3 scripts/verify-service-blueprint.py --all \
  && python3 scripts/test-verify-service-blueprint.py \
  && python3 scripts/lint-skin.py \
       skills/diagram-design/assets/example-service-blueprint.html \
       skills/diagram-design/assets/example-service-blueprint-dark.html \
       skills/diagram-design/assets/example-service-blueprint-full.html \
  && python3 scripts/verify-docs-sync.py \
  && python3 scripts/verify-semantic-motion.py --markdown-only \
  && python3 scripts/verify-plugin-package.py --require-no-bump origin/main
```

Then the full CONTRIBUTING chain (do not skip). Playwright is required for `lint-render.py --all` and screenshot regeneration:

```bash
python3 -m pip install playwright==1.62.0 Pillow==12.1.1
python3 -m playwright install chromium
python3 scripts/render-canonical-screenshots.py
python3 scripts/build-readme-thumbs.py
```

Inspect the new PNG and all 45 catalog renders before committing digests.

Ask the maintainer for `release:minor` in the PR body (new visual type). Do not bump manifests.

## Screenshots needed

PR template visual proof (required for a new type):

| Variant | File |
|---|---|
| Light | `docs/pr-previews/service-blueprint/service-blueprint-light.png` |
| Dark | `docs/pr-previews/service-blueprint/service-blueprint-dark.png` |
| Full editorial | `docs/pr-previews/service-blueprint/service-blueprint-full.png` |

Also:

- Canonical `docs/screenshots/service-blueprint.png` (first SVG, 1440×1000 @2x)
- README thumb `docs/screenshots/thumbs/service-blueprint.webp`
- Demo GIF + MP4 (hyperframes, GIF < 8 MB) for the 30–45s storyboard below

Accessible SVG: `role="img"`, first-child `<title>`, `aria-labelledby` naming `service-blueprint-title` / `service-blueprint-desc` (and `service-blueprint-dark-*`, `service-blueprint-full-*`).

## Demo storyboard (30–45s)

1. **0–6s — the gap.** Split screen: the shipped journey *Trial to paid: the first week* (sentiment dip at "Hit the limit") next to a messy whiteboard of "also the billing job, the dunning queue, Stripe, the invoice worker." Voice: the journey shows how it feels; it cannot show what the service hides.
2. **6–14s — the grammar.** Cut to the type reference's layer stack. Highlight the visibility line between frontstage and backstage. One sentence: stages are columns, layers are rows, the line is the claim.
3. **14–28s — the redraw.** Crossfade the whiteboard into `example-service-blueprint.html`. Pause on the focal backstage cell `dunning-job timeout` under "Hit the limit," still below the line while the customer row says "Retry payment."
4. **28–36s — skins.** Click the gallery tab; show dark, then full editorial (cards naming the timeout and the recovery).
5. **36–45s — the contract.** Terminal: `python3 scripts/verify-service-blueprint.py --all` → OK. Optional one-liner: a mutant with the visibility line deleted fails by name. End on the light figure.

## Duplicate-check evidence

Checked 2026-10-09 against `cathrynlavery/diagram-design` (open issues, open PRs, issue search, PR search).

| Query / surface | Result | Notes |
|---|---|---|
| Open issues titled service blueprint / frontstage / visibility line / backstage map | none | 21 open issues; nearest UX type is already-shipped journey |
| Open PRs for blueprint / journey extension | none | #129 is histogram-on-bar; #198 is unit grid/waffle |
| `gh search issues --repo cathrynlavery/diagram-design "service blueprint"` | `[]` | |
| Issue #62 dataviz laundry list | open | waffle, hex, arc, small multiples, warming stripes, punch card — **not** blueprint |
| ADR 0007 rejected list | C4, mindmap, pie, git graph, use case | Blueprint is **not** listed; journey was admitted as its own grammar |
| #252 route strip, #250 port cross-connect, #251 physical link | open | Patterns on Timeline / DB schema / Deployment — different grammars |
| #190 host-aware install doctor | open | Must not overlap; this PR does not touch doctor/install |
| Recent merges | Waterfall #191 (Matt), heatmap, architecture-delta, exploded, axonometric plan | Precedent for a full §10 type + verifier + ADR 0002 count amendment |

**CLEAN.** Not implemented. No open or recent PR/issue covering a service-blueprint type.

## Issue to file before the PR

**Title:** `[Feature]: Service blueprint — frontstage and backstage on a shared stage grid`

**Body:**

```markdown
### What are you trying to show?

I want to show how a service actually runs across a few stages: what the customer does, what they can see, and what stays hidden. The reader should see the line of visibility — the moment a failure is backstage (a billing job, a fraud check, a queue) even though the customer row still looks like a simple retry.

A user journey is the wrong figure here. That type is for how the experience *feels*. A swimlane is also wrong: that type is flow across owners, not a census of onstage vs offstage work. A process diagram is sequential handoffs, not a layered split.

Sketch of the claim:

```
          Sign up     Activate     Hit limit     Upgrade     Invoice
Customer  Create acct  Use product  Retry pay     Pick plan   Read bill
          ────────────────────────────────────────────────────────────
Front     Welcome      In-app nags  Pay modal     Checkout    Receipt
========== visibility ================================================
Back      CRM write    Usage meter  Dunning job*  Tax calc    Ledger
Support   Email        Analytics    Card processor            GL
```

\* the one cell the figure exists to show

### Proposed solution

A new visual type, **Service blueprint**, with the usual shipping set: `references/type-service-blueprint.md`, light / dark / full examples, gallery tab, SKILL.md selection row, and a verifier that the visibility line sits between frontstage and backstage on one shared stage grid.

No arrows in the first version — stage order is the sequence. Wait times and system names are cell text. One accent cell.

Route away from journey / swimlane / process in those references so the skill does not draw the wrong figure.

### Scope

New diagram type (reference + 3 examples + gallery)

### Design-system fit

- [x] I've checked the anti-patterns and "When not to use" — this still seems worth drawing
- [x] I'm willing to contribute the implementation
```

File this with the `enhancement` label (feature-request template). The PR `Closes #<n>`.

## Implementation notes for the later PR

- Conventional Commits: `feat(type): add service blueprint visual type`
- Copy `assets/template.html` / `template-dark.html` / `template-full.html`; do not start from the journey HTML (different load-bearing element).
- Pay the 500-char description cap with an alias, not by dropping routing vocabulary.
- Request `release:minor`.
- Do not mention other products, research, or "parity" in the PR body. One or two sentences of what/why, visual proof table, gate checklist, `Closes #<issue>`.
- Independent of the PlantUML import plan; different primary files. Both touch SKILL.md — rebase the later PR.
