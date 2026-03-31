---
name: onboarding-kit
description: "Prepare an onboarding kit for a new external Brain user. Creates project seeds from their repos, packages skills/hooks, and produces an AirDrop-ready folder."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, Agent, WebSearch, WebFetch
argument-hint: "'name' [repo1 repo2 ...] [--skip-preseed]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Vault root: !`cd "$(dirname "$0")/../../../.." && pwd`
Kit path: !`cd "$(dirname "$0")/../../../.." && echo "$(pwd)/product/onboarding-kit"`
Pre-seed exists: !`VAULT=$(cd "$(dirname "$0")/../../../.." && pwd) && test -f "$VAULT/knowledge/pre-seed.yml" && echo "yes" || echo "no"`
Existing seeds: !`VAULT=$(cd "$(dirname "$0")/../../../.." && pwd) && ls "$VAULT/product/onboarding-kit/project-seeds/" 2>/dev/null`
Conversation notes: !`VAULT=$(cd "$(dirname "$0")/../../../.." && pwd) && ls "$VAULT/notes/conversations/" 2>/dev/null | grep -i "$(echo '$ARGUMENTS' | awk '{print $1}' | tr '[:upper:]' '[:lower:]')" | head -5`

# /onboarding-kit — Prepare Kit for New External User

You are preparing an onboarding package for a new Brain user. This produces an AirDrop-ready folder that sets them up from zero.

## Parse Arguments

Extract from `$ARGUMENTS`:
- `name` (required) — the person's name
- repo names (optional) — their project repos to seed
- `--skip-preseed` — skip the pre-seed research phase

If no name is provided:
```
Usage: /onboarding-kit 'Peter Ricq' [repo1 repo2 ...] [--skip-preseed]
```

## Phase 1: Research (unless --skip-preseed)

Check if a pre-seed already exists for this person (`knowledge/pre-seed.yml`). If not, and `--skip-preseed` was NOT passed:

1. Ask: "Want me to run /pre-seed on {name} first? I can research them to build better project seeds. (y/n)"
2. If yes, invoke `/pre-seed` with the name
3. If no, continue — we'll build seeds from conversation notes and user input

Also check `notes/conversations/` for any existing conversation transcripts with this person — these are gold for understanding their projects.

## Phase 2: Identify Their Repos

If repos were passed as arguments, use those. Otherwise:

1. Check conversation notes for mentions of their projects/repos
2. Check pre-seed data for project references
3. Ask the user: "What repos does {name} work in? I need names to create CLAUDE.md seeds."

For each repo, gather:
- What the project is (purpose, domain)
- Key directories and file types
- Any known conventions or workflows
- How it connects to their other work

## Phase 3: Create Project Seeds

For each repo, create `product/onboarding-kit/project-seeds/{repo-name}/CLAUDE.md` containing:

1. **Project identity** — what it is, who it's for, key context
2. **Key directories** — where important files live (infer from project type if unknown)
3. **Agent routing** — common intents mapped to actions (keep minimal, 3-5 routes)
4. **Brain integration** — `brain-vault: {path}` pointer so skills can write back to the vault

Use this structure:
```markdown
# {Project Name}

{One paragraph description}

## Key Directories
- `src/` — ...
- `docs/` — ...

## Conventions
- {Convention 1}
- {Convention 2}

## Common Tasks

**IF** user wants to {task} →
→ {action}
```

Keep seeds lean — 30-60 lines. The user will refine them after they start working.

## Phase 4: Generate global-claude.md

Read the template at `product/onboarding-kit/global-claude.md`. The `{{BRAIN_PATH}}` variable is substituted automatically by `setup.sh` at install time — no action needed unless the user has special preferences to add.

If you learned preferences from conversations or pre-seed that should go in their global config, add them under `## Preferences`.

## Phase 5: Package

Run `prepare.sh` to snapshot current skills, hooks, and reference files into the kit:

```bash
cd product/onboarding-kit && bash prepare.sh
```

This copies the live skill library, hooks, reference files, and skill-index into the kit's `brain/` template.

## Phase 6: Verify and Report

After packaging, verify:
- [ ] Project seeds exist for each repo
- [ ] `brain/CLAUDE.md` is present in the template
- [ ] Skills were copied (check `brain/.claude/skills/` is non-empty)
- [ ] Reference files exist (`brain/.claude/reference/conventions.md`)
- [ ] Knowledge state files exist (`brain/knowledge/session-index.jsonl`, etc.)
- [ ] `notes/` subdirectories exist (daily, positions, inbox, areas, etc.)
- [ ] `studio/` subdirectories exist (design-system, briefing, readable)
- [ ] `setup.sh` is executable

Then report to the user:

```
Onboarding kit ready for {name}.

Package: product/onboarding-kit/
Project seeds: {list of repos}
Skills: {count} skills packaged
Hooks: {count} hooks packaged

Delivery:
  1. AirDrop the onboarding-kit/ folder
  2. Tell {name}: open Terminal, drag setup.sh in, press Enter
  3. After setup: open editor → brain folder → terminal → `claude` → `/onboard`
```

## Important Notes

- **Never overwrite existing seeds** without asking — the user may have hand-tuned them
- **Seeds are starting points** — keep them lean, the user refines after first session
- **prepare.sh must run last** — it snapshots the current skill state
- **Conversation notes are the best source** — they capture what the person actually cares about, not what's public
