---
title: "2026-03-26 Formalize AI provenance documentation for dezibel"
type: inbox
tags: [dezibel, provenance, AI, authorship, legal, integrity]
created: 2026-03-26
ai_generated: "2026-03-26"
ai_model: "claude-opus-4-6"
concepts_mentioned: [authorial-integrity, AI-provenance, creative-vs-organizational-AI]
---

Decision: Formalize AI provenance documentation for dezibel. Two requirements:

**(A) Architectural enforcement that Claude never writes creative content** — already in CLAUDE.md as permanent protocol, needs to be documented as a verifiable policy. The position note [[claude-organizes-not-writes]] exists. The rule is enforced in every session across all repos.

**(B) Build a provenance trail proving AI was used only for organization/project management, not content generation** — using git history, DB notes archaeology, session transcripts, and the vault's own position/skill logs as evidence.

This is about protecting the manuscript's authorial integrity for investors, press, and literary credibility.

## Existing Evidence

- `CLAUDE.md` permanent protocol: "Claude NEVER writes creative content"
- Position note: `notes/positions/2026-03-24-pos-claude-organizes-not-writes.md`
- 212 DB notes showing iterative human drafting process (false starts, contradictions, 5+ versions of wedding scene)
- Git history in dezibel repo: timestamped commits showing incremental writing
- Brain vault skill logs: every session captures what Claude did (organization, analysis, challenge, digest — never manuscript writing)
- Extraction map: maps DB note sources to story beats, showing human authorship chain
- Notes-ligatures and notes-index: curated by Claude from existing human-written material, never generated

## What Needs Building

- Formal AI usage policy document (for investors, press, legal)
- Provenance audit trail (automated or semi-automated)
- Clear separation between "Claude touched this" (organization files) and "Claude never touched this" (manuscript, DB notes, creative files)
