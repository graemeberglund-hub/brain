---
name: skill-scaffold
description: "Generate a new skill from a description — creates SKILL.md with correct frontmatter, routing entry, and skill-index entry. Use when building a new skill."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(ls *), Bash(date *), Bash(ln -s *)
argument-hint: "family/skill-name 'what the skill does'"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`

(At start of execution, use Glob to check: existing skill families by listing .claude/skills/*/ directories, and skill count by listing .claude/skills/*/SKILL.md and .claude/skills/*/*/SKILL.md files.)

# /skill-scaffold — Generate a New Skill

You are creating a new skill with correct structure, frontmatter, and catalog entries.

## Step 1: Parse Arguments

Parse `$ARGUMENTS` for:
- **family/name** — e.g., `dev/my-tool` or `the-brain/my-skill`. If no family prefix, ask which family.
- **description** — everything after the name. This becomes the skill's purpose.

If arguments are missing or unclear, ask ONE question to clarify: family, name, and what the skill does.

## Step 2: Determine Surface and Conventions

Based on the family:
- `the-brain`, `the-brain-analysis`, `inputs` → **vault** surface (brain-specific paths, epistemic context)
- `dev`, `writing`, `research`, `seo`, `integrations`, `media` → **portable** surface (works in any repo)
- `google`, `google-recipes` → **portable** (GWS integration)
- `personas` → **portable** (role templates)

For **portable** skills, the skill will also need a symlink to `~/.claude/skills/`.

## Step 3: Generate SKILL.md

Create `.claude/skills/{family}/{name}/SKILL.md` with this structure:

```markdown
---
name: {name}
description: "{one-line description}. Use when {trigger condition}."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash({relevant patterns})
argument-hint: "{example arguments}"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
{any other dynamic context lines relevant to the skill}

# /{name} — {Title}

You are {one-sentence role description}.

## Steps

### 1. {First step}

{Instructions}

### 2. {Second step}

{Instructions}

### N. Confirm

Report:
- What was done
- Files created/modified
- Any follow-up suggestions
```

### Frontmatter rules:
- `name:` — the invoke name (lowercase, hyphenated)
- `description:` — must end with a "Use when..." clause for discoverability
- `allowed-tools:` — minimum necessary. Include `Bash(pattern)` only for specific commands needed. Common patterns:
  - File work: `Read, Write, Edit, Glob, Grep`
  - Git ops: `Bash(git *)`
  - Date: `Bash(date *)`
  - System: `Bash(ls *), Bash(mkdir *), Bash(test *)`
- `argument-hint:` — shows users what to pass

### Dynamic context lines:
- Use `!`backtick` ` for shell commands that provide runtime context
- Common: `Today's date: !`date +%Y-%m-%d``
- Vault skills often check file existence, count notes, etc.

### Body rules:
- Instructions are written TO Claude (second person: "You are...", "Read the...", "Create a...")
- Steps should be numbered and self-contained
- Always end with a confirmation step that reports what was done
- Keep instructions concrete — avoid vague guidance
- Reference specific paths and file formats

## Step 4: Suggest Router Entry

Generate a CLAUDE.md router block for the user to add:

```
**IF** user {trigger description} →
_{example phrases}_
→ Invoke skill: `{name}`
```

## Step 5: Update Skill Index

Add an entry to `.claude/skill-index.yml` under the appropriate section (`vault_skills:` or `portable_skills:`):

```yaml
  - name: {name}
    trigger: "{one-line trigger description}"
    path: {.claude/skills/{family}/{name}/SKILL.md or ~/.claude/skills/{name}}
```

Update the `meta.total_vault_skills` or `meta.total_portable_skills` count.

## Step 6: Create Symlink (portable skills only)

For portable-surface skills, create the symlink:
```
ln -s $(pwd)/.claude/skills/{family}/{name} ~/.claude/skills/{name}
```

## Step 7: Confirm

Report:
- Skill file created at `.claude/skills/{family}/{name}/SKILL.md`
- Skill index updated
- Router entry suggestion (for manual addition to CLAUDE.md)
- Symlink status (if portable)
- Reminder: review the generated SKILL.md body — the scaffold provides structure, but domain-specific logic needs the operator's input
