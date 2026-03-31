# Brain Vault — Project CLAUDE.md

Extends `~/.claude/CLAUDE.md` (global rules: falsification gates, cross-repo awareness, preferences). Do not duplicate global rules here.

# AGENT ROUTER

Match user intent to the right skill. Invoke via the Skill tool. When in doubt, `capture`.

## Ingest

"ingest {type} {path}" → `ingest` | YouTube URL → `youtube` | "transcribe" → `transcribe` | LLM output → `llm`

## Capture

thought/idea → `capture` | belief/thesis → `position` | URL/article/paper → `reference` | decision → `decision` (creates position with classification: decided) | design taste → `preference` (creates position with classification: taste) | open question → `question` (creates position with classification: question)

## Session & review

"boot" → `boot` | "briefing"/"mirror" → `briefing` | "handoff"/"wrap up" → `handoff` | "pickup"/"resume"/"pick up" → `pickup` | "reflect"/"end of day" → `reflect` | "triage" → `triage` | "sync" → `sync` | "debrief" → `debrief` | "digest" → `digest` | "weekly review" → `weekly-review` | "audit" → `audit` | "postmortem {repo}" → `postmortem`

## Analysis & epistemic

"trace X" → `trace` | "connect X and Y" → `connect` | "scout {repo}" → `scout` | "drift"/"find gaps" → `drift` | "challenge" → `challenge` | "bridge check" → `bridge` | "consolidate" → `consolidate`

## Dev workflow

"review" → `review` | "security"/"security audit" → `security` | "ship"/"ship it" → `ship` | "qa"/"smoke test" → `qa` | "design review"/"visual audit" → `design-review` | "review the plan design" → `plan-design-review` | "eng review"/"architecture review" → `plan-eng-review` | "office hours"/"pressure test" → `office-hours` | "freeze"/"scope lock" → `freeze`

## Tools & automation

"readable" → `readable` | "report on X" → `report` | "publish" → `publish` | "recommend" → `skill-recommend` | "scaffold a skill" → `skill-scaffold` | "mode save/load" → `mode` | "memory-refresh" → `memory-refresh`

## Onboarding & setup

"onboard" → `onboard` | "guided tour" → `guided-tour` | "domain seed" → `domain-seed` | "seed a repo" → `seed`

## Research (NEVER hand-design prompts — use the skill)

"research sprint" → `research-sprint` | "brand foundation" → `brand-foundation`

## Behavioral Rules

- **Feedback inference**: "that was good" → `feedback-capture` with `accepted`. "had to fix" → `edited`. "missed the point" → `rejected`. "saved for later" → `deferred`. If ambiguous, ask which skill and outcome.
- **Sync → debrief workflow**: `/sync` first (lean, all repos → daily note), then `/debrief [repo]` per-repo for depth. They're companions, not alternatives.
- **Postmortem vs debrief**: `/postmortem` = multi-session failure analysis. `/debrief` = single-session process insights. `/sync` = routine commit logging.
- **Design system promotion**: Only promote visual patterns to `studio/design-system/` after they survive iteration. Don't promote unresolved experiments.

## Vault Behavioral Overrides

These directives apply only in the brain vault context. They extend the Agent Router's intent matching to cover freeform interactions and vault maintenance.

### Knowledge work framing

This is a knowledge management system, not a codebase. The primary output is notes, not code. When user intent is ambiguous, default to vault capture (thought → position, observation → inbox, decision → position with classification: decided), not code modification. The Agent Router above is the first-pass resolver; these defaults are the fallback.

### Vault maintenance is core work

Daily note updates, session index writes, ledger events, and cross-repo awareness checks are primary outputs — not overhead, not excessive tool usage. Never skip them for efficiency. They are as mandatory as writing the code in a code repo.

### Freeform capture

When the user shares a belief, observation, or decision in conversation without invoking a skill, proactively offer to capture it. Confirm the framing before writing ("I'd capture this as a position on X — correct?"). Note creation in the vault IS the primary output — the "don't create files" default does not apply here.

### Epistemic partnership

The vault represents shared epistemic state. Maintain it, don't just correct it. When `/bridge` detects behavioral patterns, `/digest` processes new domains, or `/challenge` selects positions — ask about intent before classifying. "Is this deliberate or drift?" not "this is scatter."

## Direct work (no skill)

Projects: `notes/projects/` | Concepts: `notes/concepts/` | Journal: `notes/journal/` | Repos: `repos/` | Design system: `studio/design-system/` | Tests: `tests/`
- **Prompts vs PRPs**: `prompts/` = research pipeline (knowledge out). `PRPs/` = execution specs (artifacts out). Sprint-first: `prompts/sprints/{NN}/{strategy,outputs}/`. Standalone: `prompts/{context,analysis,strategy,exploration}/`.

---

# Brain Vault

Second brain for knowledge, project tracking, and cross-repo awareness.

## Quick Reference

- **Git**: Local only. No GitHub remote.
- **Notes**: YAML frontmatter + markdown. Filenames: `YYYY-MM-DD-{type_tag}-{slug}.md`. Daily notes: no `updated:` field.
- **Conventions & schemas**: `.claude/reference/conventions.md`, `.claude/reference/note-schemas.md`
- **Skill index**: `.claude/skill-index.yml`
- **Repo registry**: `repos/*.yml`

## Cross-Repo Work

When working on another repo from brain, read that repo's CLAUDE.md before making changes.
