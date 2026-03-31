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
2. Detect the frontend framework in use (scan for package.json, tailwind config, vite config, Jinja templates, Remotion config, plain HTML, etc.)
3. Apply using the appropriate translation from the style file:
   - **Tailwind v4**: Use the `@theme` translation block
   - **Tailwind v3**: Map tokens to `tailwind.config.js` `extend.colors`
   - **React + CSS Modules / vanilla CSS**: Use the CSS Custom Properties block
   - **Remotion / inline styles**: Use the JS Style Objects block
   - **Jinja2 / Python templates**: Use the Python Template block
   - **Single-file HTML**: Embed CSS Custom Properties in a `<style>` block
4. Include the Google Fonts import appropriate to the medium (CSS `@import`, HTML `<link>`, or JS font loader)
5. Apply typography, controls, and surface rules from the style
6. Verify output against the Anti-Patterns section — fix any violations before presenting
7. Report what was applied and flag any manual steps needed

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
