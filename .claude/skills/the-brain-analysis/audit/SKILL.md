---
name: audit
description: Comprehensive weekly 1M reasoning pass across the full vault. Surfaces lifecycle candidates, coherence tensions, prediction monitoring, cognitive signature evolution, and self-audit metrics. Interactive — user validates each finding.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(wc *), Bash(git -C *), Bash(git log*), Bash(ls *)
argument-hint: "[optional: 'deep' for advanced analyses]"
dashterm: true
timeout: 300
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Position count: !`ls notes/positions/ 2>/dev/null | wc -l`
Question count: !`grep -l "classification: question" notes/positions/*.md 2>/dev/null | wc -l`
Feature repos: !`ls activity/features/ 2>/dev/null || echo "none"`
Ledger size: !`wc -l < knowledge/epistemic-ledger.jsonl 2>/dev/null || echo 0`
Op ledger size: !`wc -l < knowledge/operational-ledger.jsonl 2>/dev/null || echo 0`
Corrections: !`wc -l < knowledge/corrections-ledger.jsonl 2>/dev/null || echo 0`

# /audit — Comprehensive Weekly Reasoning Pass

You are performing a full-vault epistemic audit. This is NOT rule-based threshold checking — it's a 1M-powered semantic reasoning pass. Load everything. Reason comprehensively. Surface 8-12 actionable items.

## Phase 0: Full vault load

Load the entire vault state into context:

1. **All position notes** — `notes/positions/*.md` (read each fully — includes all classifications: belief, question, decided, taste, goal)
2. **Question positions** — filter `notes/positions/*.md` for `classification: question` (read each fully)
3. **Both ledgers** — `knowledge/epistemic-ledger.jsonl` and `knowledge/operational-ledger.jsonl`
4. **Corrections ledger** — `knowledge/corrections-ledger.jsonl`
5. **All graph files** — `knowledge/graph-epistemic.yml`, `knowledge/graph-dev.yml`, `knowledge/graph-emergent.yml`, `knowledge/graph-projects.yml`
6. **Feature indices** — `activity/features/*/_index.yml`
7. **Cognitive signatures** — `knowledge/cognitive-signatures.yml`
8. **Prediction calibration** — `knowledge/prediction-calibration.yml`
9. **Recent daily notes** — last 7 days from `notes/daily/`
10. **Recent debriefs** — last 3 from `knowledge/debriefs/`

Total: ~80-120K tokens = <12% of 1M window. There is room to reason.

## Phase 1: Core analyses (every run)

Surface 8-12 items total across these categories. Not every category produces a finding — only surface what's genuinely actionable.

### 1. Feature lifecycle collaboration

Read all feature records across repos. For features with `status: wip` and no commits in 5+ days:
- Load the feature's full commit history and last diffs
- Reason about state: does the last diff look like a complete feature? Are there TODOs?
- Present to user with specific evidence: "Feature X has 8 commits, last diff shows complete editor with preview and save. Near-complete?"
- User options: confirm shipped, mark needs-revisit, park with reason, keep as wip

### 2. Hardening candidates

Find positions where:
- `stage: held` or `exploring` with `confidence: high`
- **effective_evidence** >= 3 (from graph-epistemic belief-state, NOT raw event count)
- No CONTRADICTS or CHALLENGES events in last 14 days
- Evidence diversity >= 0.3 (not echo chamber)

Present: "You've been operating on '{thesis}' without questioning. {N} independent evidence sources. Harden to taste?"
- If user confirms: update position `stage` to `operationalized`, add `classification: taste`, `hardened_date`, emit OPERATIONALIZED to operational ledger

### 3. Softening candidates

Find positions with `stage: operationalized` (classification: taste) where:
- Recent OVERRIDDEN events in operational ledger
- Recent features where the work contradicted the preference
- User correction events that challenged it

Present: "Preference '{thesis}' was overridden {N} times in recent work. Reopen for examination?"
- If user confirms: update `stage` to `held`, restore `classification: belief`, emit REOPENED to operational ledger

### 4. Stale positions

Positions with no epistemic events (any verb) in 14+ days AND stage is not `abandoned` or `parked`. Check `last_event` in graph-epistemic.yml belief-states.

### 5. Orphaned preferences

Operationalized positions with no APPLIED events in operational ledger for 21+ days. Either the preference isn't being used (orphaned) or APPLIED detection is missing them.

### 6. Unpositioned patterns

Graph-dev patterns with `recurrence_count >= 3` and empty `feeds_positions`. These are recurring observations not yet connected to beliefs.

### 7. Feature attribution gaps

Check recent commits (last 7 days) across registered repos. Any commits not appearing in any feature record?

### 8. Level flow gaps

- **L0→L1**: Features with commits but empty `learnings:` array (no debrief extracted insights)
- **L1→L2**: Learnings not linked to any graph-dev pattern
- **L2→L3**: Patterns with recurrence >= 3 not feeding any position

### 9. Question resolution candidates

Questions in graph-epistemic with `resolution_proximity: ready` (4+ ADVANCES events). Present synthesis of accumulated evidence. User decides: resolve → position, not yet, reframe, dissolve.

### 10. Cross-position coherence

Load all positions simultaneously. Look for:
- Logical tensions not expressed in parent-child links
- Hidden dependencies (position A assumes something position B contradicts)
- Redundancies that could merge
- Positions with `parent:` where the parent has been contradicted (cascade pressure)

### 11. Prediction monitoring

Read all `derived_predictions:` from position frontmatter. Flag predictions approaching resolution dates or already resolvable. Present to user for resolution via `/resolve-feedback`.

### 12. Emergent layer action items

Read `knowledge/graph-emergent.yml`. For each drift theme, weather signal, or blindspot:
- Has recent work addressed it?
- Has the underlying condition changed?
- Should the entity be archived, escalated, or left alone?

## Phase 2: Advanced analyses (when input contains 'deep' OR every 2-4 weeks)

Run these additional analyses. Check the last audit date in recent daily notes — if 2+ weeks since last 'deep' audit, run them automatically.

### 13. Attention allocation

Compare commits per domain (from feature records) vs positions per domain (from position tags/areas) over last 30 days.
- **Over-theorized**: many positions, few features → "You believe a lot about X but haven't built/tested anything"
- **Under-theorized**: many features, few positions → "You're building a lot in X without articulated beliefs"

### 14. Temporal pattern analysis (metabolic health)

Analyze the epistemic ledger over the last 30 days:
- Verb distribution trends (are SUPPORTS growing while CHALLENGES stay flat?)
- Domain cycling (are you stuck in one domain?)
- Event velocity (accelerating, steady, slowing?)
- Confidence trajectories per position

### 15. Intake diversity trends

Across recent digest cycles (group by run_id):
- Source tier distribution (too much T4-llm?)
- Domain distribution (concentrated or spread?)
- Stance diversity (all confirming or genuinely diverse?)

### 16. Meta-epistemic reasoning

The system reasons about its own reasoning:
- SUPPORTS:CONTRADICTS ratio trajectory over time
- LLM-sourced vs primary evidence proportion
- Defense discovery rate trend (is the adversarial system improving?)
- Domain coverage evenness

### 17. Cognitive signature evolution

Compare current `knowledge/cognitive-signatures.yml` against last audit:
- Which signatures changed observation count?
- Any new signatures crossing maturity thresholds (emerging → provisional → established)?
- Signature tensions: are both sides still observed, or has one resolved?

### 18. Concept-position-question triangulation

For each active domain:
- Has concepts + positions + questions = well-covered domain
- Untested concepts (concepts without linked positions or questions)
- Ungrounded positions (positions without concept backing)
- Concept-question gaps (questions about topics with no concept notes)

### 19. Predictive inference

For each held/high-confidence position:
- "What specific evidence would most effectively challenge this?"
- "Where would you find it?"
- Generates an inquiry agenda — turns the system from reactive to proactive

## Phase 3: Self-audit (every run)

Answer these questions with specific data:

1. Is defense discovery rate non-zero? (check recent digest cycles in ledger)
2. Is prosecution accuracy stable or improving? (trend from event-candidates if available)
3. Is user correction rate decreasing? (corrections-ledger size and trend)
4. Are any positions exhibiting high churn? (reversals in graph-epistemic belief-states)
5. Are cognitive signatures domain-general or domain-specific? (check evidence_conversations domain spread)
6. Is corrections-ledger showing systematic patterns? (verb/domain clustering)
7. Are prediction calibration gaps narrowing? (from prediction-calibration.yml)
8. Is the system cost-effective? (findings accepted vs surfaced)

If the system can't provide evidence for its own value, that's the most important finding.

## Phase 4: Confidence decay sweep

Apply confidence decay to uncorroborated events:
- Events with no independent corroboration for 30+ days: reduce effective_confidence by 0.05 per 30-day period
- Floor: 0.3 (never decay below — the event still happened)
- Any independent corroboration resets the decay clock
- Update effective_evidence in graph-epistemic belief-states

## Phase 5: Present findings

Output a structured report. Each finding gets:

```markdown
### Finding {N}: {Category} — {Title}

{Description with specific evidence}

**Evidence:** {what data supports this finding}

**Suggested action:** {what to do}

**Your call:** confirm | dismiss | defer | provide context
```

After presenting all findings, wait for user responses. Execute confirmed actions immediately (update position status, emit ledger events, create notes, etc.).

## Phase 6: Daily note summary

Append audit summary to today's daily note:
```
- HH:MM — /audit: {N} findings surfaced, {M} confirmed by user. {highlights}
```

## Phase 7: Report

```
Audit for {date}:
- Vault loaded: {N} positions, {M} questions, {K} features
- Ledger events: {N} epistemic, {M} operational, {K} corrections
- Findings surfaced: {N}
  - Feature lifecycle: {n}
  - Hardening/softening: {n}
  - Coherence/gaps: {n}
  - Self-audit: {pass/warn/fail}
- Advanced analyses: {run/skipped}
- Confidence decay: {N} events decayed
```
