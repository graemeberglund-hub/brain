# Note Schemas — Full YAML Reference

All notes in `notes/` use YAML frontmatter + markdown body. `[[wikilinks]]` connect notes.

## Base Fields (all note types)

```yaml
---
title: "Note Title"
type: project | area | concept | reference | journal | daily | inbox | conversation | position | trace
tags: [tag1, tag2]
created: 2026-02-27
updated: 2026-02-27
---
```

## Project-Specific Fields (type: project only)

```yaml
---
title: "Mortality Pipeline"
type: project
tags: [mortality, epidemiology, smr, rla]
created: 2026-02-27
updated: 2026-02-27
# --- project fields ---
name: "Mortality Pipeline"           # Must match cluster project list
areas: [rla]                         # Which area(s) this belongs to (area note slugs)
cluster: Mortality                   # Which cluster family (legacy, optional)
arc: infrastructure                  # spike|organic|need-driven|infrastructure|exploratory|deliverable|meta
repo: rla-story-dev-clean            # Which repo this project lives in
origin: "Statistical analysis..."    # One-liner trigger/reason
spawned_by: Alumni Analysis          # Parent project (or external trigger)
enables:                             # Downstream projects this unblocks
  - Mortality Report / Deploy
  - Mortality Explorer
value_note: "SMR 1.684 [1.391, 2.015]"  # Impact/outcome
parked_reason: null                  # Why resting/archived (if applicable)
repo_paths:                          # Links to repo directories
  - path: investigations/rla_master/analyses/mortality/
    label: Pipeline + scripts
---

## About
[Description]

## Key Artifacts
- [Bullet list]
```

### Arc Types
- **spike** — burst of intense work, then done
- **organic** — grew naturally over time
- **need-driven** — triggered by downstream requirement
- **infrastructure** — foundational layer
- **exploratory** — outcome uncertain
- **deliverable** — external artifact (reports, tools)
- **meta** — system/process management

## Area-Specific Fields (type: area only)

```yaml
---
title: "Filmmaking"
type: area
tags: [filmmaking, craft]
created: 2026-03-02
updated: 2026-03-02
---

## About
[What this area covers, why it matters]

## Active Projects
- [[project-slug]]

## Learning
- [Topics being explored, courses, resources]

## Key Concepts
- [[concept-slug]]
```

Areas are long-lived, open-ended containers — they never "finish." They live in `notes/areas/` and serve as curated index pages. Projects link to areas via the `areas:` frontmatter field.

## Position Fields (type: position — unified epistemic type)

All epistemic notes (beliefs, tastes, goals, questions, decisions) use `type: position` with a `classification` field. One schema, one directory (`notes/positions/`), one retrieval pattern.

```yaml
---
title: "Gold outperforms crypto in systemic crisis"
type: position
classification: belief       # belief | taste | goal | question | decided
testable: true               # true | false
stage: exploring             # forming | exploring | held | acted-on | falsified | achieved | abandoned
confidence: medium           # low | medium | high
weight: high                 # classification: goal only — high | medium | low
tags: [gold, crypto, investing]
created: 2026-03-06
updated: 2026-03-06
area: "[[investing]]"        # optional, single area link
parent: "[[us-late-stage-empire]]"  # optional, broader thesis
thesis_layer: competitive    # optional: architectural | competitive | wedge
repos: [oren-sher]           # optional: linked repo names from repos/*.yml — triggers auto-promotion when repo has commits
derived_predictions:         # optional: predictions in PH that test this position
  - repo: predictive-history
    id: PRED-008
    claim: "Short description of what the prediction tests"
---

## Thesis
What the user believes / wants / is asking / chose / prefers.

## Evidence For
- [[reference-slug]] — specific claim with context (date)

## Evidence Against
- (none yet)

## Weight Evidence                     # classification: goal only
Why this goal is at its current weight, with dated entries and evidence links.

## Progress Signals                    # classification: goal only
Observable indicators of movement toward the target state.

## Evolution
- **2026-03-06** — Position formed from {source}. Starting at exploring/medium.
```

### Classification definitions

| Classification | Meaning | Testable | Action | Lifecycle |
|---|---|---|---|---|
| `belief` | "I think X is true" | usually yes | challenge, test, gather evidence | can be falsified, strengthened, or evolved |
| `taste` | "I like/want X done this way" | no | apply, don't challenge unless asked | strengthens with application, rarely changes |
| `goal` | "I want outcome X" | progress is measurable | track progress, reweight priority | achieved, abandoned, or reweighted by evidence |
| `question` | "I don't know X" | answer is findable | investigate, gather evidence | resolves into belief or decided |
| `decided` | "I chose X at time T" | was testable, now acted on | reference, don't update — frozen snapshot | superseded by new decision if revisited |

### Stage definitions

| Stage | Meaning |
|---|---|
| `forming` | Initial capture, minimal evidence |
| `exploring` | Actively gathering evidence |
| `held` | Sufficient evidence, currently believed/applied |
| `acted-on` | Used to make a choice or take action |
| `falsified` | Evidence killed this |
| `achieved` | Goal reached (goals only) |
| `abandoned` | Deliberately dropped |

### Lifecycle transition rules

```
taste + 3 applications with no challenge    → stage: forming → held
taste + first challenge                     → evaluate: remains taste, or reclassify as belief?
question + evidence accumulates             → reclassify: question → belief (stage: exploring)
question + answered and acted on            → reclassify: question → decided (stage: acted-on)
belief + falsifying evidence                → stage: → falsified, archive, spawn question or new belief
belief + acted on                           → stage: → acted-on (or spawn decided classification)
goal + evidence changes priority            → update weight + Weight Evidence section
goal + target state reached                 → stage: → achieved, archive
goal + deliberately dropped                 → stage: → abandoned, record why in Evolution
decided + new information reopens           → spawn new question, don't edit the decision
```

Stage and confidence are orthogonal — a position can be `held` at `low` confidence. The Evolution section is a chronological diary of shifts. `parent:` enables thesis hierarchies. Taste positions feed the design system at `studio/design-system/preference-index.yml`. Named styles in `~/.claude/styles/` compose from taste positions.

## Reference-Specific Fields (type: reference only)

```yaml
---
title: "ICIJ Cross-Border Methodology"
type: reference
tags: [methodology, icij]
created: 2026-02-28
updated: 2026-02-28
source: "https://www.icij.org/..."
source_type: article                # article | video | tool | paper | case-study
---
```

## Conversation-Specific Fields (type: conversation only)

```yaml
---
title: "Coffee with Dave — AI tooling discussion"
type: conversation
tags: [ai, tooling]
created: 2026-03-06
participants: [Dave Smith, Jarett Holmes]
duration: "45min"
audio_source: "sources/conversations/2026-03-06-dave-jarett.m4a"
transcript_source: "sources/conversations/2026-03-06-dave-jarett.json"
---

## Context
Brief description of when/where/why this conversation happened.

## Threads
- **Thread name** — summary. See [[existing-note]] / -> [[inbox-note]]
```

Threads are the knowledge payload. Raw transcript lives in `sources/conversations/`.

## Trace-Specific Fields (type: trace only)

```yaml
---
title: "Brain Productization — Idea Trace"
type: trace
tags: [brain, productization]
created: 2026-03-14
source_conversation: "[[2026-03-14-conv-jarett-viktor]]"
trace_method: chronological    # chronological | thematic | convergence
---
```

## Daily Note Fields (type: daily)

```yaml
---
title: "2026-02-28"
type: daily
tags: []
created: 2026-02-28
---
```

Daily notes have NO `updated:` field. Sections: Work, Decisions, Captured, Notes.

## Week Schema

```yaml
# activity/weeks/2026-02-26.yml
date_start: "2026-02-26"
date_end: "2026-03-04"
activities:
  - project: "Mortality Pipeline"
    repo: story-dev-clean
    items:
      - "Ran SMR analysis with updated roster"
```

## Repo Manifest Schema

```yaml
# repos/rla-story-dev-clean.yml
name: RLA Story Dev (Clean)
path: /Users/ritual/Projects/Development/rla-story-dev-clean
description: Master evidence and narrative development for the RLA documentary
claude_md: true
key_directories:
  evidence: collections/
  analysis: investigations/rla_master/analyses/
```

### Deliverable Tracking Fields (optional)

```yaml
# Parent repo
deliverables:
  - repo: nuclear-autoresearch
    status: frozen                   # frozen | active | archived
    date: 2026-03-17

# Child repo
source_repo: jason-holt
source_prp: bannane-reimplementation-autoresearch.md
extracted: 2026-03-17
status: frozen
```
