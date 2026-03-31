#!/bin/bash
# PreCompact hook: re-inject vault conventions into context
# Outputs a compact summary so Claude retains key rules after compaction

cat << 'CONVENTIONS'
=== Brain Vault Conventions (preserved across compaction) ===

FRONTMATTER RULES:
- All notes require: title, type, tags, created
- Types: project | area | concept | reference | journal | daily | inbox | conversation | position | trace
- Every edit MUST update `updated:` to today (except type: daily — no updated field)
- Daily notes live in notes/daily/YYYY-MM-DD.md
- Daily notes use calendar date (midnight rollover)

NOTE LOCATIONS:
- notes/projects/rla/ and notes/projects/brain/ — project notes
- notes/areas/ — long-lived area index pages
- notes/positions/ — all epistemic notes (beliefs, tastes, goals, questions, decisions) with classification field
- notes/concepts/ — patterns and frameworks
- notes/references/ — external sources
- notes/daily/ — daily notes (type: daily)
- notes/journal/ — reflective journal entries (type: journal)
- notes/inbox/ — uncategorized captures
- notes/conversations/ — transcribed conversations
- activity/weeks/ — weekly activity YAML
- notes/claims/ — source-attributed arguments (type: claim, provenance, endorsed status)
- knowledge/ — epistemic-ledger.jsonl, graph-index.yml, graph-dev.yml, graph-projects.yml, graph-epistemic.yml

CONVENTIONS:
- Wikilinks: [[note-filename]] without extension
- Tags: lowercase, hyphenated, in frontmatter tags array
- Filenames: lowercase, hyphenated slugs
- One note = one idea, interconnected via wikilinks

SKILLS: Use /capture, /reference, /decision, /position, /question, /digest, /youtube, /llm, /ingest, /transcribe, /trace, /connect, /drift, /sync, /triage, /weekly-review, /seed
GIT: Local only, backup remote at /Volumes/RLA_MASTER_WORK/00_SYSTEMS/brain — never push to GitHub
===
CONVENTIONS

exit 0
