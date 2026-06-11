# Complete Workspace Migration Package
## Windsurf/Devin → Cursor Migration Guide

**Date:** June 11, 2026
**Source:** Windsurf/Devin Workspace
**Target:** Cursor (VSCode-based editor)

---

## Executive Summary

This migration package contains all configuration, dependencies, and setup information needed to recreate your complete development workspace in Cursor. The workspace consists of two primary repositories:

1. **Brain Vault** (`/Users/graeme/Desktop/DEVELOPMENT/brain`) - Second-brain knowledge management system
2. **Dezibel Editor** (`/Users/graeme/Development/dezibel-editor`) - Serialized novel editor and platform

---

## Repository Overview

### Repository 1: Brain Vault

**Path:** `/Users/graeme/Desktop/DEVELOPMENT/brain`
**Git Remote:** None (local only)
**Branch:** main
**Status:** Clean working tree
**Untracked Files:**
- `.devin/` (Windsurf-specific directory)
- `artifacts/readable/ai-sequels-swot-analysis.html`
- `notes/references/2026-06-10-ref-ai-sequels-brainstorm-evaluation.md`
- `notes/references/2026-06-10-ref-ai-sequels-swot-analysis.md`

**Purpose:** Second-brain knowledge management system with skills for capture, sync, analysis, and metabolism pipeline.

### Repository 2: Dezibel Editor

**Path:** `/Users/graeme/Development/dezibel-editor`
**Git Remote:** `https://github.com/graemeberglund-hub/dezibel-editor.git`
**Branch:** main
**Status:** Clean working tree
**Untracked Files:**
- `test-results/` (Playwright test snapshots)

**Purpose:** Serialized novel delivered over iMessage (42 days, 6 weeks). Governing phrase: "ascent as collapse"

---

## Package Managers & Dependencies

### Brain Vault

**Package Manager:** None (no package.json)
**Dependencies:** None (shell scripts only)
**Runtime Requirements:**
- Bash shell
- Standard Unix utilities (git, ls, wc, find, mv, test, mkdir, date)
- Python (via uv) for some scripts

### Dezibel Editor

**Package Manager:** npm
**Package File:** `package.json`
**Lock File:** `package-lock.json`

**Dependencies:**
```json
{
  "devDependencies": {
    "@axe-core/playwright": "^4.11.3",
    "@playwright/test": "^1.60.0",
    "electron": "^35.0.0",
    "electron-builder": "^26.0.0"
  }
}
```

**Installation Commands:**
```bash
cd /Users/graeme/Development/dezibel-editor
npm install
```

**Runtime Requirements:**
- Node.js (v18+ recommended)
- npm
- Electron (installed via npm)

---

## Environment Variables & API Keys

### Brain Vault

**No .env files found**
**No API keys required**
**Environment Variables:** None

### Dezibel Editor

**No .env files found** (16 .env-related files in node_modules are dependencies, not project config)
**API Keys Required:** None (based on current configuration)
**Environment Variables:** None

**Note:** If you have environment variables set in your system or Windsurf/Devin configuration, you'll need to manually recreate them in Cursor.

---

## Custom Tools, MCPs, Agents

### Brain Vault Custom Tools

**Hooks System:** 16 shell scripts in `.claude/hooks/`

1. `careful.sh` - Pre-tool validation for Bash commands
2. `freeze.sh` - Scope lock enforcement
3. `notify-desktop.sh` - Desktop notifications
4. `post-compact-context.sh` - Post-context cleanup
5. `post-tool-activity-log.sh` - Activity logging
6. `pre-compact-context.sh` - Pre-context preparation
7. `session-end-cleanup.sh` - Session cleanup
8. `session-end-index.sh` - Session indexing
9. `session-end-resume.sh` - Session resume state
10. `session-start-context.sh` - Session start context
11. `status-update.sh` - Status line updates
12. `update-frontmatter-date.sh` - Auto-update YAML dates
13. `validate-ledger-event.sh` - Ledger event validation
14. `validate-note-schema-post.sh` - Post-edit schema validation
15. `validate-note-schema.sh` - Pre-write schema validation
16. `validate-operational-event.sh` - Operational event validation
17. `validate-prp-naming.sh` - PRP naming validation

**Agents:** 6 agents in `.claude/agents/`

1. `conversation-metabolizer.md` - Processes conversation into structured outputs
2. `devil-advocate.md` - Adversarial analysis and challenge
3. `inference-engine.md` - Logical inference and reasoning
4. `phase-auditor.md` - Phase-based audit and review
5. `retrieval-engine.md` - Knowledge retrieval and search
6. `vault-reader.md` - Vault content analysis

**Skills:** 10 skill directories in `.claude/skills/`

- `dev/` - Development-related skills
- `google/` - Google Workspace integration
- `google-recipes/` - Google Workspace recipe automation
- `inputs/` - Input processing skills
- `integrations/` - Third-party integrations
- `media/` - Media processing skills
- `personas/` - Persona-based interactions
- `research/` - Research methodology skills
- `seo/` - SEO optimization skills
- `the-brain/` - Brain vault specific skills
- `the-brain-analysis/` - Brain analysis skills
- `writing/` - Writing assistance skills

**Status Line:** Custom status line script (`.claude/statusline.sh`)

### Dezibel Editor Custom Tools

**Commands:** 2 commands in `.claude/commands/`

1. `commit.md` - Quick commit workflow
2. `revise-claude-md.md` - CLAUDE.md revision workflow

**Skills:** 13 skills in `.claude/skills/`

1. `briefing-interactive/` - Interactive document generation
2. `character/` - Character development tools
3. `claude-md-improver/` - CLAUDE.md quality improvement
4. `day-builder/` - Day content scaffolding
5. `diagram/` - System diagram generation
6. `episode/` - Episode management
7. `format-audit/` - Format constraint checking
8. `litigate/` - Structural litigation and critique
9. `narrative-prd/` - Narrative architecture PRD
10. `readable/` - Mobile-friendly HTML conversion
11. `status/` - Status reporting
12. `story-map/` - 42-day story visualization
13. `task-list/` - Task list generation from PRDs

---

## Build, Test, Deploy Commands

### Brain Vault

**Build Commands:** None (no build process)
**Test Commands:** None (no test suite)
**Deploy Commands:** None (local only, no deployment)

**Maintenance Commands:**
```bash
# Update skill index
# (Manual process - update .claude/skill-index.yml)

# Run hooks manually
.claude/hooks/[hook-name].sh
```

### Dezibel Editor

**Build Commands:**
```bash
cd /Users/graeme/Development/dezibel-editor
npm run build          # Build Electron app for macOS
```

**Test Commands:**
```bash
cd /Users/graeme/Development/dezibel-editor
npm test               # Run Playwright tests
npx playwright test    # Alternative test command
```

**Start Commands:**
```bash
cd /Users/graeme/Development/dezibel-editor
npm start              # Start Electron app
```

**Deploy Commands:** None (manual deployment)

---

## VSCode Settings & Extensions

### Brain Vault VSCode Settings

**File:** `.vscode/settings.json`
**Theme:** Custom purple theme
**Settings:**
```json
{
  "workbench.colorCustomizations": {
    "titleBar.activeBackground": "#1e1e3a",
    "titleBar.activeForeground": "#9999dd",
    "activityBar.background": "#181830",
    "statusBar.background": "#2a2a4e",
    "statusBar.foreground": "#aaaaee",
    "sideBar.background": "#141428",
    "sideBar.border": "#2a2a4e"
  }
}
```

### Dezibel Editor VSCode Settings

**File:** `.vscode/settings.json`
**Theme:** Custom green theme
**Settings:**
```json
{
  "workbench.colorCustomizations": {
    "titleBar.activeBackground": "#1e3a1e",
    "titleBar.activeForeground": "#99dd99",
    "activityBar.background": "#183018",
    "statusBar.background": "#2a4e2a",
    "statusBar.foreground": "#aaeeaa",
    "sideBar.background": "#142814",
    "sideBar.border": "#2a4e2a"
  }
}
```

**Recommended Extensions for Cursor:**
- ESLint (if JavaScript linting needed)
- Prettier (if code formatting needed)
- GitLens (for Git history visualization)
- Markdown All in One (for Markdown editing)
- YAML (for YAML file editing)

---

## Claude/Devin Configuration

### Brain Vault Claude Configuration

**Settings File:** `.claude/settings.json`
**Settings Local:** `.claude/settings.local.json` (22KB - contains local preferences)

**Key Settings:**
- Status line: Custom command (`.claude/statusline.sh`)
- Permissions: Extensive allowlist for git, bash, web search
- Hooks: 17 hook points configured
  - PostToolUse: 3 hooks
  - PreToolUse: 5 hooks
  - SessionStart: 1 hook
  - PreCompact: 1 hook
  - PostCompact: 1 hook
  - Stop: 4 hooks
  - Notification: 1 hook

### Dezibel Editor Claude Configuration

**Settings File:** `.claude/settings.json`
**Settings Local:** `.claude/settings.local.json` (67KB - contains local preferences)

**Key Settings:**
- Permissions: Allowlist for git operations and file edits
- Denylist: `.env` files, git reset commands
- No hooks configured (minimal setup)

---

## Git Configuration

### Brain Vault

**Remote:** None (local only)
**Branch:** main
**Recent Commits:** Clean working tree
**Unpushed Changes:** None (no remote to push to)

### Dezibel Editor

**Remote:** `https://github.com/graemeberglund-hub/dezibel-editor.git`
**Branch:** main
**Recent Commits:** 
- `031532e` - Add comprehensive Dezibel core market deep dive analysis
- `e0f17f3` - Add sequel concepts and marketing strategy
- `1735d25` - Previous commits

**Unpushed Changes:** None (all commits pushed)

---

## Project Structure

### Brain Vault Structure

```
brain/
├── .claude/
│   ├── agents/          # 6 agent definitions
│   ├── hooks/           # 16 shell scripts for automation
│   ├── reference/       # Conventions and schemas
│   ├── rules/           # Behavioral rules
│   ├── skills/          # 10+ skill directories
│   ├── build-update-package.sh
│   ├── settings.json
│   ├── settings.local.json
│   └── statusline.sh
├── .claude-backup/      # Backup of old configuration
├── .devin/              # Windsurf-specific (untracked)
├── .git/
├── .vscode/
│   └── settings.json    # Custom purple theme
├── activity/            # Activity tracking
├── artifacts/           # Generated artifacts
├── knowledge/           # Knowledge base
├── notes/               # Notes (daily, areas, concepts, etc.)
├── prompts/             # Research prompts
├── repos/               # Repository registry
├── studio/              # Design system
├── CHEATSHEET.md
├── CLAUDE.md            # Agent router
├── GETTING-STARTED.md
└── MIGRATION-PACKAGE.md # This file
```

### Dezibel Editor Structure

```
dezibel-editor/
├── .claude/
│   ├── commands/        # 2 custom commands
│   ├── skills/          # 13 skills
│   ├── settings.json
│   └── settings.local.json
├── .git/
├── .gitignore
├── .vscode/
│   └── settings.json    # Custom green theme
├── DB notes/            # iCloud notes (off-limits)
├── PRPs/                # Product requirement prompts
├── SYSTEM/              # System memory files
├── analysis/            # Structural analysis
├── artifacts/           # Generated artifacts
├── characters/          # Character sheets
├── dist/                # Build output
├── electron/            # Electron app files
├── inital_files/        # Original PDFs
├── legal/               # Legal documentation
├── node_modules/        # npm dependencies
├── prompts/             # Research prompts
├── secrets/             # Secret files (empty)
├── story/               # Story content
├── strategy/            # Strategy documents
├── test-results/        # Playwright test results (untracked)
├── tests/               # Playwright tests
├── themes/              # Theme tracking
├── tools/               # Utility scripts
├── work.md              # Working state
├── package.json
├── package-lock.json
├── playwright.config.js
├── CHEATSHEET.md
└── CLAUDE.md            # Agent router
```

---

## Known Dependencies & System Requirements

### System Requirements

**Operating System:** macOS (based on paths)
**Shell:** Bash (required for Brain Vault hooks)
**Node.js:** v18+ (for Dezibel Editor)
**Python:** Required for some Brain Vault scripts (via uv)

### External Services

**Brain Vault:**
- None (local only)

**Dezibel Editor:**
- GitHub (for version control)
- None currently (no API keys configured)

**Note:** If you have external services connected (Twilio, Firebase, Vercel for the Dezibel platform demo), you'll need to manually reconnect those in Cursor.

---

## Unsaved Files & Local Changes

### Brain Vault

**Untracked Files (not committed):**
- `.devin/` - Windsurf-specific directory (can be deleted)
- `artifacts/readable/ai-sequels-swot-analysis.html` - Generated artifact
- `notes/references/2026-06-10-ref-ai-sequels-brainstorm-evaluation.md` - Reference note
- `notes/references/2026-06-10-ref-ai-sequels-swot-analysis.md` - Reference note

**Recommendation:** Commit or delete these files before migration.

### Dezibel Editor

**Untracked Files (not committed):**
- `test-results/` - Playwright test snapshots (gitignored)

**Recommendation:** Keep as-is (properly gitignored).

---

## Step-by-Step Migration Guide

### Phase 1: Preparation (Do in Windsurf/Devin)

1. **Commit any pending changes**
   ```bash
   cd /Users/graeme/Desktop/DEVELOPMENT/brain
   git status
   # Add and commit any untracked files you want to keep
   git add .
   git commit -m "Pre-migration cleanup"
   
   cd /Users/graeme/Development/dezibel-editor
   git status
   # Should be clean (test-results/ is gitignored)
   ```

2. **Push all commits**
   ```bash
   cd /Users/graeme/Development/dezibel-editor
   git push origin main
   # Brain has no remote, so skip
   ```

3. **Export environment variables** (if any)
   - Check Windsurf/Devin settings for any environment variables
   - Document them manually (not found in current analysis)

4. **Backup critical files**
   ```bash
   # Backup .claude directories
   cp -r /Users/graeme/Desktop/DEVELOPMENT/brain/.claude ~/brain-claude-backup
   cp -r /Users/graeme/Development/dezibel-editor/.claude ~/dezibel-claude-backup
   ```

### Phase 2: Cursor Setup

1. **Install Cursor**
   - Download from https://cursor.sh
   - Install following standard macOS installation

2. **Clone repositories in Cursor**
   - Open Cursor
   - Clone Dezibel Editor: `https://github.com/graemeberglund-hub/dezibel-editor.git`
   - Open local Brain Vault: `/Users/graeme/Desktop/DEVELOPMENT/brain`

3. **Install Node.js dependencies**
   ```bash
   cd /Users/graeme/Development/dezibel-editor
   npm install
   ```

4. **Configure VSCode settings**
   - Copy `.vscode/settings.json` from each repo to Cursor's settings
   - Or manually configure the color themes in Cursor settings

### Phase 3: Claude Configuration Migration

**Note:** Cursor uses a different Claude configuration system than Windsurf/Devin. You'll need to manually recreate the configuration.

1. **Brain Vault Claude Configuration**
   - The extensive hooks system (16 scripts) will need to be recreated in Cursor's equivalent
   - The agents (6 agent definitions) will need to be recreated
   - The skills (10+ skill directories) will need to be recreated
   - The status line script will need to be adapted

2. **Dezibel Editor Claude Configuration**
   - The 2 commands will need to be recreated
   - The 13 skills will need to be recreated
   - The permissions configuration will need to be recreated

**Critical:** The `.claude/` directory structure and files are NOT automatically portable between Windsurf/Devin and Cursor. You'll need to manually recreate the functionality.

### Phase 4: Testing

1. **Test Dezibel Editor**
   ```bash
   cd /Users/graeme/Development/dezibel-editor
   npm start
   # Verify Electron app launches
   ```

2. **Run tests**
   ```bash
   cd /Users/graeme/Development/dezibel-editor
   npm test
   # Verify Playwright tests pass
   ```

3. **Test Brain Vault functionality**
   - Verify file editing works
   - Verify git operations work
   - Test any critical scripts

### Phase 5: Cleanup

1. **Remove Windsurf/Devin** (optional, after verification)
   - Uninstall Windsurf/Devin
   - Remove any Windsurf/Devin configuration files

2. **Delete .devin directory**
   ```bash
   rm -rf /Users/graeme/Desktop/DEVELOPMENT/brain/.devin
   ```

---

## What Cannot Be Exported Automatically

### 1. Claude Configuration
- **Issue:** Windsurf/Devin and Cursor use different Claude configuration systems
- **Impact:** All `.claude/` hooks, agents, skills, and commands must be manually recreated
- **Workaround:** Document the functionality and recreate in Cursor's system

### 2. MCP Connections
- **Issue:** MCP (Model Context Protocol) connections are Windsurf/Devin-specific
- **Impact:** Any MCP servers or connections must be manually reconfigured
- **Workaround:** Check Windsurf/Devin settings for MCP connections and recreate in Cursor

### 3. Session State
- **Issue:** Current session state, context, and memory are not portable
- **Impact:** You'll start with a fresh session in Cursor
- **Workaround:** None (expected behavior)

### 4. Extension Configuration
- **Issue:** Windsurf/Devin extensions are not compatible with Cursor
- **Impact:** Any Windsurf/Devin-specific extensions must be replaced with Cursor/VSCode equivalents
- **Workaround:** Install equivalent VSCode extensions in Cursor

### 5. Keyboard Shortcuts
- **Issue:** Custom keyboard shortcuts may not transfer
- **Impact:** You'll need to reconfigure shortcuts in Cursor
- **Workaround:** Manually configure shortcuts in Cursor settings

### 6. Workspace Layout
- **Issue:** Window layout and panel configuration are not portable
- **Impact:** You'll need to set up your preferred layout in Cursor
- **Workaround:** Manually configure layout in Cursor

---

## Post-Migration Checklist

- [ ] Both repositories open in Cursor
- [ ] Node.js dependencies installed for Dezibel Editor
- [ ] VSCode settings configured (color themes)
- [ ] Git operations working (status, commit, push)
- [ ] Dezibel Editor starts with `npm start`
- [ ] Playwright tests pass with `npm test`
- [ ] Brain Vault file editing works
- [ ] Critical scripts tested (if any)
- [ ] Claude configuration manually recreated (hooks, agents, skills)
- [ ] MCP connections reconfigured (if any)
- [ ] Environment variables set (if any)
- [ ] External services reconnected (if any)
- [ ] Keyboard shortcuts configured
- [ ] Workspace layout configured
- [ ] Backup files deleted (after verification)

---

## Critical Notes

### Brain Vault Cross-Repo Sync

**CRITICAL:** Brain and dezibel-editor share one project. When brain learns dezibel-relevant information, it must write to dezibel-editor's memory at:

**Path:** `/Users/graeme/.claude/projects/-Users-graeme-Development-dezibel-editor/memory/`

**Key files to update:**
- `dezibel_strategy_deep_read.md`
- `dezibel_story_deep_read.md`
- `dezibel_analysis_deep_read.md`
- `operator_state.md`
- `identity.md`
- `MEMORY.md`

**When to sync:** At every `/sync`, `/handoff`, and `/commit` that touches dezibel content.

**Migration Impact:** This cross-repo sync mechanism is Windsurf/Devin-specific. You'll need to recreate this workflow in Cursor.

### Dezibel Editor "No Writing" Protocol

**CRITICAL:** Dezibel has a permanent protocol: Claude never writes a single word of the book. Claude organizes, structures, and builds tools. Graeme writes.

**Migration Impact:** Ensure this protocol is maintained in Cursor's Claude configuration.

### Brain Vault Hooks System

**CRITICAL:** Brain Vault has 16 automated hooks that enforce schema validation, update frontmatter dates, log activity, and more.

**Migration Impact:** These hooks must be manually recreated in Cursor's equivalent system, or the workflow will break.

---

## Support Resources

### Cursor Documentation
- https://cursor.sh/docs
- https://cursor.sh/docs/claude

### Dezibel Documentation
- `strategy/plan-to-launch.md` - Governing document
- `CLAUDE.md` - Agent router
- `CHEATSHEET.md` - Command reference

### Brain Vault Documentation
- `CLAUDE.md` - Agent router
- `CHEATSHEET.md` - Command reference
- `GETTING-STARTED.md` - Getting started guide

---

## Contact & Support

If you encounter issues during migration:

1. Check Cursor documentation for configuration differences
2. Verify all dependencies are installed
3. Test git operations independently
4. Review this migration package for missed steps

---

## Appendix: File Inventory

### Brain Vault Critical Files

**Configuration:**
- `.claude/settings.json` - Claude configuration
- `.claude/settings.local.json` - Local preferences
- `.vscode/settings.json` - VSCode theme
- `CLAUDE.md` - Agent router

**Hooks (16 files):**
- `.claude/hooks/careful.sh`
- `.claude/hooks/freeze.sh`
- `.claude/hooks/notify-desktop.sh`
- `.claude/hooks/post-compact-context.sh`
- `.claude/hooks/post-tool-activity-log.sh`
- `.claude/hooks/pre-compact-context.sh`
- `.claude/hooks/session-end-cleanup.sh`
- `.claude/hooks/session-end-index.sh`
- `.claude/hooks/session-end-resume.sh`
- `.claude/hooks/session-start-context.sh`
- `.claude/hooks/status-update.sh`
- `.claude/hooks/update-frontmatter-date.sh`
- `.claude/hooks/validate-ledger-event.sh`
- `.claude/hooks/validate-note-schema-post.sh`
- `.claude/hooks/validate-note-schema.sh`
- `.claude/hooks/validate-operational-event.sh`
- `.claude/hooks/validate-prp-naming.sh`

**Agents (6 files):**
- `.claude/agents/conversation-metabolizer.md`
- `.claude/agents/devil-advocate.md`
- `.claude/agents/inference-engine.md`
- `.claude/agents/phase-auditor.md`
- `.claude/agents/retrieval-engine.md`
- `.claude/agents/vault-reader.md`

### Dezibel Editor Critical Files

**Configuration:**
- `.claude/settings.json` - Claude configuration
- `.claude/settings.local.json` - Local preferences
- `.vscode/settings.json` - VSCode theme
- `CLAUDE.md` - Agent router
- `package.json` - npm dependencies
- `package-lock.json` - npm lock file
- `playwright.config.js` - Playwright configuration

**Commands (2 files):**
- `.claude/commands/commit.md`
- `.claude/commands/revise-claude-md.md`

**Skills (13 directories):**
- `.claude/skills/briefing-interactive/`
- `.claude/skills/character/`
- `.claude/skills/claude-md-improver/`
- `.claude/skills/day-builder/`
- `.claude/skills/diagram/`
- `.claude/skills/episode/`
- `.claude/skills/format-audit/`
- `.claude/skills/litigate/`
- `.claude/skills/narrative-prd/`
- `.claude/skills/readable/`
- `.claude/skills/status/`
- `.claude/skills/story-map/`
- `.claude/skills/task-list/`

---

**End of Migration Package**
