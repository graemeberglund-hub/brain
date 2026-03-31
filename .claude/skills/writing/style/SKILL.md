---
name: style
description: Apply a named style/design system to the current frontend, validate coverage, or compose new styles from taste atoms. Use when user says "apply style X", "use style X", "style list", or describes a style mashup.
allowed-tools: Read, Glob, Grep, Edit, Write, Bash
argument-hint: "<style-name> | list | validate [name] | compose <base> + <pref1> [+ <pref2> ...] [as <new-name>]"
---

# Style System

You manage a collection of named design styles at `~/.claude/styles/`.
Each style composes from atomic taste positions cataloged in `studio/design-system/preference-index.yml`.

## Commands

**`/style list`** — Read `~/.claude/styles/_index.md` and show available styles with descriptions.

**`/style <name>`** — Apply a named style to the current project:

1. Read `~/.claude/styles/<name>.md` to load the full design system
2. **Slop scan** — before applying, scan the target HTML/CSS/JSX for AI slop patterns (see Slop Detection below). If 2+ patterns detected, warn and ask whether to clean up first or apply anyway.
3. Detect the frontend framework in use (scan for package.json, tailwind config, vite config, Jinja templates, Remotion config, plain HTML, etc.)
4. Apply using the appropriate translation from the style file:
   - **Tailwind v4**: Use the `@theme` translation block
   - **Tailwind v3**: Map tokens to `tailwind.config.js` `extend.colors`
   - **React + CSS Modules / vanilla CSS**: Use the CSS Custom Properties block
   - **Remotion / inline styles**: Use the JS Style Objects block
   - **Jinja2 / Python templates**: Use the Python Template block
   - **Single-file HTML**: Embed CSS Custom Properties in a `<style>` block
5. Include the Google Fonts import appropriate to the medium (CSS `@import`, HTML `<link>`, or JS font loader)
6. Apply typography, controls, and surface rules from the style
7. Verify output against the Anti-Patterns section — fix any violations before presenting
8. Report what was applied and flag any manual steps needed

**`/style validate [name]`** — Check a style's preference coverage:

1. Read `~/.claude/styles/<name>.md` and extract its `**Preferences:**` line
2. Read `studio/design-system/preference-index.yml`
3. Cross-reference: for each preference the style claims, verify the style actually implements its key_tokens and respects its rules
4. Check for unlisted preferences — does the style use tokens/patterns from a preference it doesn't declare?
5. Check for rejection violations — does the style violate any rejection preferences it should inherit?
6. Report:
   - **Declared**: preferences listed
   - **Implemented**: declared preferences that are actually reflected in the style's tokens/rules
   - **Missing implementation**: declared but not visible in the style
   - **Undeclared usage**: patterns present but not in the Preferences line
   - **Suggested additions**: preferences from the index that align with this style's aesthetic
7. If `[name]` is omitted, validate ALL styles and produce a coverage matrix

**`/style compose <base> + <pref1> [+ <pref2> ...] [as <new-name>]`** — Create a new style by layering preferences onto a base:

1. Read the base style from `~/.claude/styles/<base>.md`
2. Read each additional taste position from `notes/positions/` (filter by `classification: taste` and matching slug)
3. Read the preference-index.yml for key_tokens of each addition
4. Check for conflicts:
   - Does the new preference contradict the base? (e.g., adding `frosted-glass-panels` to a style that uses `opaque-solid-panels`)
   - Does the new preference contradict a rejection the base inherits? (e.g., adding `no-neon-glow` violating preferences)
   - Report conflicts and ask user to resolve before proceeding
5. Merge:
   - Start from the base style's full content
   - For each new preference: integrate its key_tokens into the palette/typography/controls/motion sections as appropriate
   - Update the `**Preferences:**` line to include the additions
   - Adjust the intro paragraph to reflect the composite identity
6. If `as <new-name>` is provided:
   - Write to `~/.claude/styles/<new-name>.md`
   - Update `~/.claude/styles/_index.md` with the new entry
   - Update `preference-index.yml` to list the new style under each preference it uses
7. If no name given, output the composed style for review without saving

**`/style look [name]`** — Generate or regenerate look HTML for a style:

1. If `[name]` is provided, run `python3 lab/archived/surfaces/gallery/generate.py <name>` to generate that one look
2. If `--all` or no name, run with `--all` to regenerate all looks
3. After generation, open the look in the browser: `open lab/archived/surfaces/gallery/<name>.html`
4. If `gallery` is the argument, open the gallery page: `open lab/archived/surfaces/gallery/gallery.html`

## Rules

- The palette tables are the source of truth. Translation blocks are convenience — if they diverge, the tables win.
- Never hardcode hex values outside of a central token definition (theme file, CSS vars block, or constants file)
- When a project has multiple frontends (e.g. `front-end/app-a/` and `investigations/.../tool/`), ask which one to apply to — or apply to a specific path the user indicates
- The style defines taste, not layout. Don't impose grid/layout structure — only color, type, surfaces, controls, and motion.
- Reference the "Key Phrases" section for taste calibration on subjective decisions
- Reference the "Decision Heuristic" for tie-breaking
- Every style MUST have a `**Preferences:**` line after its intro paragraph listing the preference slugs it composes from
- The preference-index.yml is bidirectional: preferences list their styles, styles list their preferences. Keep both in sync.

## Slop Detection

Before applying any style, scan the target files for these 6 AI slop anti-patterns. These are signatures of AI-generated UI that signal "nobody designed this."

| # | Anti-Pattern | Detection Signal | Why It's Slop |
|---|-------------|-----------------|---------------|
| 1 | Purple gradients | `linear-gradient` with purple/violet/indigo values | Default AI aesthetic — the tell that screams generated |
| 2 | 3-column icon grids | Exactly 3 cards with centered icons in a row | Every AI landing page looks identical |
| 3 | Icons in colored circles | `border-radius: 50%` + background color on icon wrappers | Generic feature section filler |
| 4 | Centered everything | `text-align: center` on >60% of sections | Avoids making layout decisions |
| 5 | Uniform bubbly radius | `border-radius` >12px on most containers | "Friendly" default that reads as undesigned |
| 6 | Generic hero copy | "Revolutionize", "Unleash", "Transform your workflow", "Seamlessly" | Zero-information headlines |

**Behavior:**
- Count how many of the 6 patterns are present in the target files
- If 0-1: proceed silently
- If 2+: warn before applying: "This file has {N} AI slop patterns: {list}. Clean these up before styling, or apply anyway?"
- Log each detection to `knowledge/style-slop-detections.jsonl`:
  ```jsonl
  {"timestamp": "ISO8601", "file": "path", "patterns_found": ["purple-gradients", "centered-everything"], "count": 2, "action": "warned|cleaned|bypassed"}
  ```
