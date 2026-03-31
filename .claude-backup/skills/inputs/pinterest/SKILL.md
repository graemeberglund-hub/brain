---
name: pinterest
description: Analyze Pinterest board screenshots to extract aesthetic preferences and push them all the way into the design system — token CSS, named style, specimen HTML.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *), Bash(python3 *)
argument-hint: "{image-path} [image-path ...] [--style-name 'Name'] [--board-name 'Name']"
---

input = $ARGUMENTS
Today's date: !`date +%Y-%m-%d`
Vault root: /Users/graeme/Desktop/DEVELOPMENT/brain
Preference index: studio/design-system/preference-index.yml
Design system dir: studio/design-system/
Styles dir: ~/.claude/styles/

(At start of execution, use Glob and Grep to check: existing taste positions in notes/positions/ with classification: taste, and existing styles in ~/.claude/styles/.)

# /pinterest — Board Analysis → Design System

You are a visual analyst and design system author. Your job is to look at Pinterest boards, extract what they mean as a design system, and push those findings all the way through the pipeline — from preference notes to working CSS tokens to a visual specimen.

**This is not just note-taking. By the end, the user will have a draft named style they can apply to a project.**

---

## Parse Input

From `$ARGUMENTS`, extract:
- One or more image file paths (required)
- `--style-name 'Name'` — what to call the resulting style (optional; if omitted, derive from board themes)
- `--board-name 'Name'` — label for each board in order (optional; use filenames as fallback)

If no image paths are provided:
```
Usage: /ingest pinterest {image-path} [image-path ...] [--style-name 'Name']

Example:
  /ingest pinterest ~/Downloads/home.png ~/Downloads/fashion.png --style-name "warm-editorial"
```

---

## Phase 1: Vision Analysis

Use the Read tool on each image. Look at the **grid as a whole** — the aggregate, not individual pins.

For each board, extract these concrete signals:

### Color
- **Background temperature:** What color family dominates backgrounds? (warm cream / cool gray / dark charcoal / etc.)
- **Primary colors:** What 2-4 colors appear most across surfaces and dominant elements? Extract approximate hex values.
- **Accent colors:** What 1-2 colors appear as highlights, links, or emphasis? Approximate hex.
- **Saturation:** Vivid / mid / muted / desaturated
- **Value range:** Dark-dominant / light-dominant / high contrast / compressed

### Surface & Texture
- **Material reference:** What does the surface feel like? (concrete, linen, paper, glass, leather, metal, none)
- **Finish:** Matte / glossy / grainy / smooth
- **Texture present:** Visible grain, halftone, scanlines, noise, none

### Composition
- **Density:** Dense / breathing / very open
- **Grid type:** Strict grid / editorial / organic / centered
- **Geometry:** Right angles / soft curves / hard curves / flowing organic

### Typography
- **Classification:** Serif / sans-serif / monospace / mixed
- **Weight tendency:** Light / regular / medium / bold
- **Case:** Mixed / all-caps labels / sentence case
- **Size contrast:** Subtle / strong (big display vs small body)

### Mood
- **One-word:** The dominant feeling (austere / lush / industrial / tender / editorial / raw / etc.)
- **Era / cultural reference:** What cultural moment does this evoke?
- **What it rejects:** What would look obviously wrong here?

### Motifs
- Recurring objects, materials, or subjects (plants, architecture, food, tech, etc.)

Do this for each board independently, then synthesize across boards.

---

## Phase 2: Cross-Board Synthesis

Identify:
1. **3–8 discrete preference atoms** — cross-board patterns, weighted higher than single-board signals
2. **A cohesive aesthetic identity** — one sentence that names the whole. Example: *"Printed warmth — editorial surfaces that feel picked up off a desk, not projected on a screen."*
3. **A style slug** — if `--style-name` not provided, derive a hyphenated slug from the identity phrase
4. **CSS token values** — extract actual approximate hex values and descriptions from what was seen, not placeholders

For token extraction, be concrete:
- "warm cream background" → `#f5f0e8` (or similar visible approximation)
- "olive card surface" → `#4a4a3a`
- "dusty rose accent" → `#c4867a`

If you cannot determine a value precisely, give a range and note it as approximate.

---

## Phase 3: Check for Existing Preferences

Search `notes/positions/` for existing taste positions (`classification: taste`) with overlapping themes. For matches:
- Note them for reinforcement (update existing note, don't create duplicate)
- List them as existing atoms the style will build on

---

## Phase 4: Write Taste Position Notes

For each new discrete preference, write to `notes/positions/{date}-pos-{slug}.md`:

```yaml
---
title: "{Preference Name}"
type: position
classification: taste
category: {surface|color|typography|texture|motion|controls|composition|rejection}
tags: [design, {category}, pinterest]
created: {date}
updated: {date}
stage: exploring
confidence: exploring
source: moodboard
---

{One sentence stating the preference clearly.}

## What it looks like

- {Concrete visual description with approximate token values}
- {CSS snippet if applicable}

## What it rejects

- {Anti-examples}

## Where it came from

Extracted from Pinterest boards ({board names}) on {date}. {Which boards and what patterns prompted this.}

## Related preferences

- [[{related-slug}]]
```

Update `preference-index.yml` for each new preference.

---

## Phase 5: Write Token CSS

Write to `studio/design-system/{style-slug}-tokens.css`:

```css
/* {Style Name} Tokens
 * Extracted from Pinterest boards: {board names}
 * Generated: {date}
 * Status: draft — values are approximations from visual analysis
 */

:root,
.{style-slug} {

  /* Background & Atmosphere */
  --{prefix}-bg: {hex};
  --{prefix}-bg-soft: {hex};

  /* Surfaces */
  --{prefix}-surface-1: {hex or rgba};
  --{prefix}-surface-2: {hex or rgba};

  /* Borders */
  --{prefix}-border: {rgba};

  /* Text */
  --{prefix}-text: {rgba or hex};
  --{prefix}-text-dim: {rgba or hex};

  /* Accents */
  --{prefix}-accent: {hex};
  --{prefix}-accent-warm: {hex};   /* if applicable */

  /* Typography */
  --{prefix}-font-display: {stack};
  --{prefix}-font-body: {stack};

  /* Scale (inherit from editorial if unsure) */
  --{prefix}-size-body: 14px;
  --{prefix}-size-title: 20px;
  --{prefix}-size-meta: 12px;

  /* Motion (calm by default for moodboard-derived styles) */
  --{prefix}-motion-base: 260ms;
  --{prefix}-ease: cubic-bezier(0.22, 1, 0.36, 1);

}
```

Use a 2-4 letter prefix derived from the style name (e.g., `warm-editorial` → `--we-`).

If the boards are clearly dark-mode: use dark token values.
If clearly light-mode: use light token values.
If mixed: generate both `[data-theme="dark"]` and `[data-theme="light"]` blocks.

---

## Phase 6: Write Moodboard Interpretation

Write to `studio/design-system/{style-slug}-interpretation.md`:

```markdown
# Moodboard Interpretation — {Style Name}

> **Provenance document.** Taste positions extracted here live as individual notes in `notes/positions/` (classification: taste) and are cataloged in `preference-index.yml`. This file is the original extraction record.

Source boards: {board filenames/names}
Date: {date}

## What the boards are drawn to

{One substantive paragraph naming the central aesthetic tension or identity. What is the organizing principle? What does the collection keep returning to?}

## Extracted preference atoms

### {Preference 1 Name}
{Brief description of what was seen and what it means.}

```css
{token snippet}
```

### {Preference 2 Name}
...

## What's NOT in the boards

- {Explicit rejections — what would be wrong here}

## Relationship to existing styles

| Existing style | Overlap | What these boards add |
|---|---|---|
| {closest existing style} | {shared atoms} | {new contribution} |

## Key phrases

- "{evocative phrase from the boards}"
- "{another phrase}"
```

---

## Phase 7: Write Draft Named Style

Write to `~/.claude/styles/{style-slug}.md`:

```markdown
---
name: {Style Name}
slug: {style-slug}
status: draft
source: pinterest
boards: [{board names}]
created: {date}
---

# {Style Name}

> {Evocative one-liner. What does this aesthetic feel like? Who made it? Where does it live?}

**Design identity:** {One sentence describing the aesthetic system.}

**Token file:** `studio/design-system/{style-slug}-tokens.css`
**Prefix:** `--{prefix}-`

## Preferences

{List of atomic preference slugs this style composes — both new ones created and existing ones it inherits}

- [[{slug}]] — {one-line why this preference applies here}
- [[{slug}]]
...

## Palette

### Dark
| Token | Value | Role |
|---|---|---|
| `--{prefix}-bg` | `{hex}` | Page background |
| `--{prefix}-surface-1` | `{hex}` | Card/panel |
| `--{prefix}-text` | `{hex}` | Body text |
| `--{prefix}-accent` | `{hex}` | Primary accent |

### Light *(if applicable)*
| Token | Value | Role |
|---|---|---|
| ... | ... | ... |

## Typography

| Role | Font | Size | Weight | Notes |
|---|---|---|---|---|
| Display | {font} | {size} | {weight} | {notes} |
| Body | {font} | 14px | 400 | |
| Meta/label | {font} | 12px | 500 | {uppercase?} |

## Surface treatment

{1-2 sentences: what do surfaces feel like? Material reference, texture, depth.}

## Controls

{1-2 sentences: how do buttons, links, inputs behave in this aesthetic?}

## Motion

{1-2 sentences: pacing, easing character, what moves and what doesn't.}

## Anti-patterns

Things that must NOT appear in this style:
- {Explicit rejection from board analysis}
- {Another rejection}

## Draft notes

*This style is a first-pass extraction from Pinterest boards. Values are approximate. Refine through iteration before promoting to production use.*

- [ ] Validate token values against real renders
- [ ] Test typography stack availability
- [ ] Promote `confidence: exploring` taste positions to `medium` after first iteration
- [ ] Run `/style {style-slug}` on a real project to validate
```

---

## Phase 8: Run Look Generator

Run:
```
python3 $BRAIN_VAULT_PATH/lab/archived/surfaces/gallery/generate.py {style-slug}
```

If the generator fails (draft style may not parse fully), note the error and tell the user which fields to fill in to make it parseable. Do not block — report and move on.

---

## Phase 9: Report

```
Pinterest board analysis complete.
Boards: {count} ({names})

─── Aesthetic Identity ───────────────────────────────
{Style Name}: {evocative one-liner}

─── Preferences ──────────────────────────────────────
New:      {count} created in notes/positions/ (classification: taste)
Existing: {count} reinforced

{For each new preference:}
  + {slug} ({category}) — {one-sentence summary}

─── Design System Artifacts ──────────────────────────
  studio/design-system/{style-slug}-tokens.css
  studio/design-system/{style-slug}-interpretation.md
  ~/.claude/styles/{style-slug}.md (draft)
  lab/archived/surfaces/gallery/{style-slug}.html {✓ generated | ✗ needs field: X}

─── Next Steps ───────────────────────────────────────
  /style {style-slug}          → apply this draft to a project
  /preference {slug}           → deepen any preference
  /style promote {style-slug}  → when ready to move from draft to production
```
