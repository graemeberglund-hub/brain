---
name: update-docs
description: Update README.md and STATUS.md after completing work in any folder
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
argument-hint: "[folder_path]"
---

# Update Documentation for: $ARGUMENTS

**Purpose**: Update README.md and STATUS.md (or PRPs/status.md) in the target folder after completing work. Works for any tool, analysis, or workspace folder.

**Usage**: `/update-docs <folder_path>`

**Examples**:
- `/update-docs .` (current repo root)
- `/update-docs notes/projects/`
- `/update-docs activity/`

---

## PHASE 1: Locate and Read Existing Docs

### 1.1 Identify Target Folder

The target folder is: `$ARGUMENTS`

If no argument provided, infer the target folder from the current conversation context — look at which files were read, edited, or discussed to determine the working domain. If the domain is ambiguous or no prior context exists, ask the user which folder to update.

### 1.2 Read Existing Documentation

Read the following files in the target folder (if they exist):
1. `README.md` — primary documentation
2. `STATUS.md` — progress tracking (alternative locations: `PRPs/status.md`)
3. `CLAUDE.md` — agent instructions (if present)

Also scan the folder for:
- `PRPs/` directory (in_progress/ and completed/ subfolders)
- `package.json` (for tech stack info)
- Key source files (to understand current state)

### 1.3 Understand What Changed

Review context to understand changes:
1. **Current conversation** — what work was just completed?
2. **Git diff** — `git diff -- <folder_path>` for uncommitted changes
3. **Recent commits** — `git log --oneline -10 -- <folder_path>` for recent history
4. **Folder contents** — scan for new/removed files

**Capture**:
- Features added/removed/modified
- Tech stack changes
- New scripts, commands, or workflows
- Data file changes
- Architecture changes
- PRP completions or new PRPs

---

## PHASE 2: Update README.md

**File**: `<target_folder>/README.md`

**Philosophy**: README is the **authoritative guide** for agents working in this folder. It should be:
- Comprehensive (all features documented)
- Specific (file paths, exact commands)
- Practical (common tasks, gotchas)
- Current (reflects actual state)

### 2.1 Sections to Review and Update

Update each relevant section based on what changed:

| Section | Update when... |
|---------|---------------|
| **Overview/Purpose** | Scope of the tool changed |
| **Tech Stack** | Dependencies added/removed |
| **Architecture** | File structure or data flow changed |
| **Features** | New capabilities added |
| **Quick Start / Dev Commands** | New scripts or changed commands |
| **Data Sources / Data Flow** | Input/output files changed |
| **Known Issues / Gotchas** | New pitfalls discovered |
| **Configuration** | Settings or env vars changed |

### 2.2 README Principles

- **Single source of truth** — if it exists in code, it must be in README
- **Agent-friendly** — write for the next agent, not a human tutorial
- **No stale info** — remove documentation for deleted features
- **Actionable** — include exact file paths, commands, and examples
- **Token-friendly** — be thorough but not verbose

### 2.3 If No README.md Exists

Create one with this minimal structure:

```markdown
# [Folder Name]

## Overview
[One paragraph describing purpose]

## Quick Start
[Dev commands, setup steps]

## Architecture
[Key files and their roles]

## Data
[Input/output files, data flow]
```

---

## PHASE 3: Update STATUS.md / PRPs/status.md

**File**: `<target_folder>/STATUS.md` or `<target_folder>/PRPs/status.md`

**Philosophy**: STATUS tracks **what's done, what's in progress, and what's next**. It's the "where we left off" document.

### 3.1 Status Update Rules

1. **Mark completed work** — add date, brief description of what was done
2. **Update active PRPs** — move from in_progress/ to completed/ if finished
3. **Note new tasks** — any follow-up work discovered during implementation
4. **Record decisions** — architectural choices, trade-offs made
5. **Track blockers** — anything preventing progress

### 3.2 Status Entry Format

```markdown
## [Date] - [Brief Title]

**Completed**:
- [Item 1]: [what was done]
- [Item 2]: [what was done]

**Decisions**:
- [Decision]: [rationale]

**Next Steps**:
- [ ] [Follow-up task 1]
- [ ] [Follow-up task 2]
```

### 3.3 If No STATUS.md Exists

Create one with:

```markdown
# Status: [Folder Name]

## Current State
[Brief summary of overall progress]

## Change Log

### [Today's Date] - [What was done]
- [Details]

## Next Steps
- [ ] [Task 1]
- [ ] [Task 2]
```

---

## PHASE 4: Check CLAUDE.md Router (If Applicable)

**Only if** the target folder has a corresponding CLAUDE.md router entry:

1. Check if the router entry in root `CLAUDE.md` needs updating
2. Router entries should only change for:
   - New trigger keywords (major feature categories)
   - Changed dev commands
   - Changed file paths
   - New critical warnings
3. **Do NOT update router for**: minor UI tweaks, implementation details, internal refactors

If router needs updating, make minimal changes. CLAUDE.md is read every conversation — every word costs tokens.

---

## PHASE 5: Validate and Summarize

### 5.1 Validation Checklist

- [ ] README.md accurately reflects current state
- [ ] No documentation for deleted/removed features
- [ ] File paths in README are correct
- [ ] Commands in README actually work
- [ ] STATUS.md updated with today's work
- [ ] No broken internal links
- [ ] CLAUDE.md router unchanged (or minimally updated with justification)

### 5.2 Summary Report

Provide user with:

```
Documentation Updated: <folder_path>

Files Modified:
- <folder>/README.md: [what changed]
- <folder>/STATUS.md: [what changed]
- CLAUDE.md: [what changed, if anything]

Key Updates:
- [Update 1]
- [Update 2]

Next agent will see:
- [What the updated docs now communicate]
```

---

## Key Principles

### Token Sensitivity
- **CLAUDE.md**: Read in EVERY conversation — minimize words
- **README**: Read on-demand — can be detailed
- **STATUS**: Read on-demand — capture decisions and progress

### Documentation Hierarchy
```
CLAUDE.md (router — 50-100 words per entry)
    -> routes to
README.md (comprehensive — 500-2000 words)
    -> references
STATUS.md (progress — append-only log)
    -> references
Code (with inline comments)
```

### Single Source of Truth
- README = current state (not history)
- STATUS = running log (append new entries)
- If feature exists in code, it MUST be in README
- If feature was removed from code, remove from README
