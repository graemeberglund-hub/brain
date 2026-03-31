---
name: skill-package
description: "Export a skill or family as a portable bundle with dependencies, install script, and metadata. Use when packaging skills for distribution."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *), Bash(mkdir *), Bash(cp *), Bash(tar *), Bash(wc *), Bash(chmod *), Skill
argument-hint: "skill-name|family-name [--output path]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Output dir exists: !`test -d artifacts/skill-packages && echo "yes" || echo "no"`

# /skill-package — Package Skills for Distribution

You are creating a portable, installable skill bundle. The output should work in any Brain vault or Claude Code repo.

## Step 1: Parse Arguments

- **skill-name** — package a single skill
- **family-name** — package an entire family (e.g., `the-brain`, `dev`)
- **--output path** — custom output directory (default: `artifacts/skill-packages/`)

## Step 2: Pre-flight

Run `/skill-audit` on the target skill(s) first. If any ERRORs exist, halt and report:
> "Skill {name} has audit errors. Fix them before packaging: {errors}"

If only WARNs, proceed but note them in the package manifest.

## Step 3: Analyze Dependencies

For each skill being packaged, determine:

### Vault dependencies (what does this skill need from the vault?):
- **Paths referenced** — grep SKILL.md body for absolute paths, note types, directory references
- **Other skills invoked** — grep for `Invoke skill:` or `Skill` tool references
- **Dynamic context** — what do the `!` backtick lines query?
- **Knowledge files** — does it read/write to `knowledge/`?

Classify each skill as:
- **portable** — no vault dependencies, works anywhere
- **vault-required** — needs brain vault structure to function
- **vault-optional** — works without vault but enhanced with it

### Tool dependencies:
- Parse `allowed-tools:` for required tools
- Note any non-standard tools (MCP servers, custom agents)

## Step 4: Build Package

Create the package directory:

```
artifacts/skill-packages/{name}/
├── SKILL.md              # The skill file
├── manifest.yml          # Package metadata
├── install.sh            # Installation script
├── README.md             # Human-readable description
└── dependencies/         # If the skill invokes other skills
    └── {dep-name}/
        └── SKILL.md
```

### manifest.yml:

```yaml
name: {skill-name}
version: "1.0.0"
created: {today}
source: "brain-vault"

description: "{from SKILL.md frontmatter}"
family: "{family name}"
surface: "{portable|vault}"

dependencies:
  vault_paths: [{list of required vault paths, or empty}]
  skills: [{list of other skills this invokes, or empty}]
  tools: [{from allowed-tools}]
  vault_required: {true|false}

audit:
  last_audit: {today}
  warnings: [{any from pre-flight}]

install:
  target: "~/.claude/skills/{name}"
  type: "symlink|copy"
```

### install.sh:

```bash
#!/bin/bash
# Install {skill-name} into Claude Code personal scope
set -e

SKILL_DIR="$HOME/.claude/skills/{name}"

if [ -d "$SKILL_DIR" ]; then
  echo "Skill '{name}' already exists at $SKILL_DIR"
  echo "Overwrite? (y/n)"
  read -r response
  [ "$response" != "y" ] && exit 0
  rm -rf "$SKILL_DIR"
fi

mkdir -p "$SKILL_DIR"
cp SKILL.md "$SKILL_DIR/"

# Install dependencies if any
{dependency install commands}

echo "Installed '{name}' to $SKILL_DIR"
echo "Skill is now available as /{name}"
```

### README.md:

```markdown
# {Skill Name}

{Description from SKILL.md}

## Installation

```bash
cd {package-dir}
./install.sh
```

## Usage

```
/{name} {argument-hint}
```

## Dependencies

{List vault requirements, tool requirements, skill dependencies}

## Source

Packaged from Brain vault on {today}.
```

## Step 5: Optionally Archive

If the user wants a distributable archive:
```bash
tar -czf artifacts/skill-packages/{name}.tar.gz -C artifacts/skill-packages {name}/
```

## Step 6: Confirm

```
=== Package Complete ===

Package: artifacts/skill-packages/{name}/
Skills included: {count}
Surface: {portable|vault}
Dependencies: {summary}
Archive: {path if created, or "not created — pass --archive"}

Install: cd artifacts/skill-packages/{name} && ./install.sh
```
