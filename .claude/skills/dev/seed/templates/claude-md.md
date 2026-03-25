# Template: CLAUDE.md Structure

Use this as the structural pattern. Replace all placeholders with domain-specific content.

---

```markdown
# {Repo Name} — Project CLAUDE.md

Extends `~/.claude/CLAUDE.md` (global rules: falsification gates, cross-repo awareness, preferences). Naming conventions follow brain Convention v2 (`brain/.claude/reference/conventions.md`). Skills are globally available via `~/.claude/skills/` — do not list them here.

# AGENT ROUTER (EXECUTE FIRST)

The user talks naturally. Your job is to recognize intent and invoke the right action. Match the first applicable rule.

## {Intent Category 1}

**IF** user {describes action} →
_"example phrase 1", "example phrase 2", "example phrase 3"_
→ Work in: `{directory}/`

## {Intent Category 2}

**IF** user {describes action} →
_"example phrase 1", "example phrase 2"_
→ {Action description}

## Status & overview

**IF** user asks about status, what's here, or wants an overview →
_"what do I have", "show me everything", "status"_
→ Summarize repo contents using directory counts and recent files

## Direct work

**IF** user asks to do something not covered above →
→ Use best judgment, work in the most appropriate directory

---

# CLAUDE.md — {Repo Display Name}

{One paragraph description of what this repo is for.}

## Git Policy

- Local-only repository. Do not push to GitHub.
- Backup remote (when configured): `backup` → `{TBD: backup path}`
- Commit frequently with descriptive messages.

## Directory Structure

| Directory | Purpose |
|-----------|---------|
| `{dir1}/` | {Description} |
| `{dir2}/` | {Description} |

## Conventions

- **Filenames**: lowercase, hyphenated slugs (e.g., `my-thing.md`)
- **Frontmatter**: YAML frontmatter on all markdown files with at least `title`, `created` fields
- {Additional domain-specific conventions}
```
