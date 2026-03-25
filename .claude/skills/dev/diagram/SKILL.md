---
name: diagram
description: Generate interactive system diagrams from any codebase
allowed-tools: Read, Write, Glob, Grep, Bash(date *), Bash(ls *), Bash(wc *), Bash(basename *), Agent
argument-hint: "[scope: 'this repo', 'the database', 'src/api', etc.]"
---

input = $ARGUMENTS
Template path: `~/.claude/skills/diagram/templates/diagram-template.html`
Style index: `~/.claude/styles/_index.md`

# /diagram — Interactive System Diagram Generator

Generate a self-contained HTML system diagram from real codebase discovery. Every box must trace to a real file or component.

## Phase 1 — Parse Intent

Determine from the user's input:

1. **Scope** — what to diagram:
   - "this repo" / "map the system" → whole project
   - "the database" / "data layer" → schema, migrations, models
   - "src/api" / specific path → that subtree only
   - "the pipeline" → scripts, queues, data flow
   - If unclear, default to whole project

2. **Output path** — where to write the HTML:
   - Default: `SYSTEM/{repo-slug}-diagram.html` (create `SYSTEM/` if needed)
   - Use user-specified path if given

3. **Default style** — `clean-90s` unless user specifies otherwise

4. **Repo slug** — `basename` of the project root, lowercased, hyphenated (used as localStorage key prefix)

## Phase 2 — Discovery

Read real files to understand the system. NEVER hallucinate structure.

### Read Strategy by Scope

| Scope | Read these files |
|-------|-----------------|
| Whole project | CLAUDE.md, README.md, package.json/pyproject.toml/Cargo.toml, top-level tree, key source directories |
| Data layer | Schema files, migrations, models, ORM config, database configs |
| Specific path | All files in path + imports/exports for connections |
| API surface | Route files, controllers, middleware, OpenAPI spec |
| Pipeline | Scripts, cron configs, queue definitions, pipeline manifests |

### Discovery Steps

1. **Read project metadata**: CLAUDE.md, README, manifest files
2. **Scan structure**: Use Glob to find key directories and files
3. **Read key files**: Source files that define components, not every file
4. **Identify components** → become boxes (max 60)
5. **Identify groupings** → become regions (by directory, layer, or domain)
6. **Trace connections** → become connection lines (imports, API calls, data flow)
7. **Write descriptions** → plain-English notes for regions and info for boxes

**STOP GATE**: If you find more than 60 components, ask the user to narrow scope or suggest grouping before continuing.

## Phase 3 — Build DIAGRAM_SPEC

Structure discovered components into this JSON:

```js
{
  id: "{repo-slug}-system",        // stable localStorage key
  title: "Repo Name",              // toolbar title
  defaultStyle: "clean-90s",       // initial style
  regions: [
    {
      id: "region-slug",
      label: "Region Label",
      color: "orange",             // one of: orange, cyan, purple, amber, blue, green, red, pink
      x: 40, y: 60, w: 800, h: 500,
      note: "What this region does in plain English"
    }
  ],
  boxes: [
    {
      id: "box-slug",
      label: "Component Name",
      sub: "brief tech context",
      note: "What it does in one sentence",
      color: "orange",             // accent bar color
      region: "region-slug",       // which region this belongs to
      badge: { type: "live", text: "LIVE" },  // optional: live|disabled|blocked
      info: {                      // optional: shown in info panel on click
        plain: "Non-technical explanation",
        tech: "Technical detail",
        path: "relative/file/path",
        stats: ["stat1", "stat2"]
      }
    }
  ],
  connections: [
    { from: "box-id", to: "box-id", color: "cyan", dashed: false }
  ],
  connectionLabels: [
    { from: "box-id", to: "box-id", text: "data flow label" }
  ],
  marginNotes: [
    {
      id: "mn-slug",
      title: "What this part does",
      body: "Plain-English explanation for a non-technical reader",
      targetRegion: "region-slug"   // leader line target
    }
  ],
  legend: [
    { color: "cyan", label: "Data Flow", dashed: false },
    { color: "amber", label: "Processing", dashed: false }
  ]
}
```

### Region Layout Rules

Position regions in a semantic flow (top→bottom):
- **Row 1** (top): Inputs, sources, external systems
- **Row 2** (middle): Processing, logic, engines
- **Row 3** (bottom): Outputs, persistence, surfaces

Layout: max 3 regions per row. Starting position x=40, y=60. Row gap: 100px. Column gap: 100px.

Size each region based on box count:
- 1-4 boxes: w=600, h=400
- 5-8 boxes: w=900, h=500
- 9-12 boxes: w=1200, h=600
- 13+: w=1500, h=700

Boxes within regions are auto-positioned by the template's grid-pack algorithm. Do NOT set `x`/`y`/`w` on individual boxes — the template handles it.

### Connection Color Semantics

Use colors consistently to convey meaning:
- **orange** — external API calls, third-party integrations
- **cyan** — data flow, storage reads/writes
- **purple** — framework/theory connections, knowledge links
- **amber** — internal processing, pipeline flow
- **blue** — UI/surface connections
- **green** — feedback loops (usually dashed)

### Margin Notes

Write ONE per region. Each note should explain what the region does for someone who knows nothing about the project. Use simple language, no jargon.

## Phase 4 — Style Integration

1. Read `~/.claude/styles/_index.md` to get available style names
2. Read each style's `.md` file
3. For each style, find the `### CSS Custom Properties` section
4. Extract the CSS block (`:root { ... }` and `[data-theme="dark"] { ... }`)
5. Rewrite selectors:
   - `:root { ... }` → `[data-style="{name}"] { ... }`
   - `[data-theme="dark"] { ... }` → `[data-style="{name}"][data-theme="dark"] { ... }`
   - Also add `[data-style="{name}"][data-theme="light"] { ... }` with the `:root` values
6. Also extract any font-specific CSS overrides for the style (toolbar title font, box label font, etc.)
   - For `signal-ink`: IBM Plex family overrides
   - For `teenage-engineering`: Space Grotesk/Mono overrides, border-radius changes, matte surfaces

Build the combined CSS as `{{STYLE_BLOCKS}}`.

7. Collect all Google Font `<link>` tags needed:
   - Base: Inter + Instrument Serif
   - signal-ink: IBM Plex Sans, Serif, Mono
   - teenage-engineering: Space Grotesk, Space Mono

Build as `{{FONT_LINKS}}`.

8. Build `{{STYLE_NAMES}}` as a JS array: `['clean-90s', 'signal-ink', 'teenage-engineering']`

## Phase 5 — Render

1. Read the template: `~/.claude/skills/diagram/templates/diagram-template.html`
2. Replace placeholders:
   - `{{SPEC_JSON}}` — the DIAGRAM_SPEC as a JSON string
   - `{{STYLE_BLOCKS}}` — combined style CSS
   - `{{FONT_LINKS}}` — `<link>` tags for Google Fonts
   - `{{TITLE}}` — diagram title (from spec)
   - `{{DEFAULT_STYLE}}` — initial style name
   - `{{DEFAULT_STYLE_LABEL}}` — initial style name UPPERCASED
   - `{{STYLE_NAMES}}` — JS array of style names
3. Write the rendered HTML to the output path

**IMPORTANT**: The template already has the full style overrides for signal-ink and teenage-engineering hardcoded into the reference. When extracting from style `.md` files, also include the typography/component overrides (box labels, toolbar fonts, info panel headings, margin note titles, region headers, legend, badges, border-radius changes).

Refer to the reference diagram at `predictive-history/SYSTEM/system-diagram.html` for the complete `[data-style]` CSS blocks. Copy those style blocks verbatim for the `{{STYLE_BLOCKS}}` — they are already correct and comprehensive.

## Phase 6 — Report

Tell the user:
- Output file path
- Component counts: regions, boxes, connections
- Styles embedded
- "Open in browser to interact. Drag boxes, edit notes — positions persist across page reloads and regeneration."

## Anti-Goals

1. NEVER hallucinate boxes — every one must trace to a real file/component
2. NEVER modify source files — read-only except the output HTML
3. NEVER hardcode project content in the template
4. NEVER use external JS libraries — vanilla JS only
5. NEVER exceed 60 boxes without asking user
6. NEVER duplicate style definitions — always read from `~/.claude/styles/`
