---
name: export
description: "Package a vault subset as a portable bundle — by tag, type, project, or explicit list. Resolves wikilinks, strips internal paths. Use when sharing vault content externally."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *), Bash(mkdir *), Bash(cp *), Bash(wc *), Bash(tar *), Agent
argument-hint: "'query or filter' [--format dir|zip] [--output path]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Vault root: /Users/graeme/Desktop/DEVELOPMENT/brain

(At start of execution, use Glob to check: total note count by listing notes/**/*.md files.)

# /export — Package Vault Subset for Sharing

You are extracting a portable subset of the vault. The output should be self-contained, with internal paths stripped, wikilinks resolved, and no references to vault infrastructure.

## Step 1: Parse Arguments

Parse `$ARGUMENTS` for:
- **Filter** — what to include. Options:
  - By tag: `tag:crypto` or `tags:crypto,gold`
  - By type: `type:position` or `types:position,reference` (filter by `classification` for sub-types: belief, question, decided, taste, goal)
  - By project: `project:rla` or `project:mortality`
  - By explicit list: `notes/positions/gold-crisis.md notes/positions/hmm-regime.md`
  - By query: `"everything about mortality"` (searches content)
  - By date range: `since:2026-03-01` or `range:2026-03-01..2026-03-15`
- **--format** — `dir` (default, directory of markdown files) or `zip` (tar.gz archive)
- **--output** — custom output path (default: `artifacts/exports/`)

If filter is ambiguous, ask ONE clarifying question.

## Step 2: Collect Notes

Based on the filter, find all matching notes. For each note:

1. Read the file
2. Parse frontmatter
3. Add to export set

### Dependency resolution:
For each note in the set, scan for `[[wikilinks]]`. For each link:
- If the linked note is ALSO in the export set → resolve to relative link
- If the linked note is NOT in the export set → decide based on strategy:
  - **Default:** Replace `[[slug]]` with **bold text** of the title (no link)
  - If the linked note is a stub (< 5 lines of body), include it as a stub in the export
  - Never include notes the user didn't ask for without flagging

Track: notes included, notes excluded (referenced but not in filter), total size.

## Step 3: Transform Notes

For each note in the export set:

### Strip vault-specific content:
- Remove absolute vault paths from any field
- Remove `ai_generated`, `ai_model` fields from frontmatter
- Remove `concepts_mentioned` field (internal tracking)
- Keep all other frontmatter intact

### Resolve wikilinks:
- `[[in-set-note]]` → `[Note Title](in-set-note.md)` (standard markdown link)
- `[[not-in-set-note]]` → **Note Title** (bold, no link)

### Clean paths:
- Strip `notes/positions/`, etc. prefixes (all epistemic notes are in `notes/positions/`)
- Flatten into a single directory or organize by type (user preference)

## Step 4: Build Export Package

### Directory format (default):
```
artifacts/exports/{today}-{slug}/
├── README.md          # Auto-generated index
├── positions/         # All epistemic notes (beliefs, questions, decisions, tastes, goals)
│   ├── note-1.md
│   └── note-2.md
└── references/        # If any references included
    └── ref-1.md
```

### README.md (auto-generated):
```markdown
# Export: {filter description}

Generated: {today}
Source: Brain vault
Notes included: {count}

## Contents

### Positions ({count})
- [Title](positions/slug.md) — {one-line from thesis} [{classification}]

### References ({count})
- [Title](references/slug.md) — {source_type}

---

*Exported from Brain vault. Some internal links have been resolved to text.*
*{count} referenced notes were not included in this export.*
```

### Zip format:
Same directory structure, compressed to `artifacts/exports/{today}-{slug}.tar.gz`.

## Step 5: Confirm

```
=== Export Complete ===

Package: {path}
Notes included: {count} ({breakdown by type})
Notes referenced but excluded: {count}
Format: {dir|zip}
Size: {file size}

Excluded references (notes linked but not in export):
- {list of excluded wikilink targets, if any}
```
