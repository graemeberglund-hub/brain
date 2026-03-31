---
name: resolve-feedback
description: Flow prediction resolution outcomes back to Brain positions via staged interpretation. Use when PH predictions resolve (pass/fail) and linked brain positions need updating.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(date *), Bash(ls *), Agent
argument-hint: "[optional: specific PRED-ID to process, or 'all' to scan]"
dashterm: true
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
PH repo path: /Users/ritual/Projects/Development/predictive-history

# /resolve-feedback — Resolution → Belief Update Pipeline

Flow prediction resolution outcomes from Predictive History back to Brain positions through a staged interpretation model. This is the feedback loop that makes the epistemic system learn from reality.

## Central Design Principle

> Prediction outcomes discipline beliefs through interpretation, not direct inheritance; the system must distinguish claim failure from mechanism failure, parameter error, timing error, and regime-specific exception before emitting a belief-update event.

## Phase 1: Detect resolved predictions

Scan PH predictions for recent resolutions:

```bash
# Find predictions with resolved status
ls /Users/ritual/Projects/Development/predictive-history/tracking/predictions/
```

If `input` specifies a PRED-ID, process only that prediction. Otherwise scan all predictions for `status: passed` or `status: failed` or `status: expired`.

**Active prediction handling:** If a PRED-ID is specified but the prediction has `status: active`, do NOT silently skip. Instead, run a **trajectory check**:
1. Read the prediction file — get claim, deadline, confidence, verification source
2. Fetch current market/real-world data using the verification method specified in the file
3. Update `resolution_notes:` in the prediction file with the current market snapshot and trajectory assessment (do NOT change `status:`)
4. Report to the user:
   - Current value vs. threshold
   - Days until deadline
   - Likely interpretation class (e.g., `claim_failure`, `direct_support`, `timing_failure`) based on trajectory
   - "Re-run `/resolve-feedback {PRED-ID}` after {deadline} for formal resolution."
5. Do NOT emit any ledger events during a trajectory check — the ledger only receives events after formal resolution

This replaces the ad-hoc `inference_mode: "prediction-preliminary"` pattern. Trajectory checks are read/write to the prediction file only.

For each resolved prediction:
1. Read the prediction file
2. Check if it has `brain_positions:` in frontmatter — skip if absent (no cross-link, nothing to update)
3. Check if this resolution has already been processed — Grep `knowledge/epistemic-ledger.jsonl` for events with `"source"` containing this PRED-ID and `"inference_mode": "resolution"`. If found, skip (idempotent).
4. Package the resolution context:
   - Prediction ID, claim, status (passed/failed/expired)
   - Confidence at resolution time
   - Resolution date and notes
   - Timeline (created → deadline → resolved)
   - Linked brain positions

## Phase 2: Fetch linked positions

For each linked brain position slug in `brain_positions:`:
1. Find the position file: `Glob pattern="*{slug}*" path="notes/positions/"`
2. Read the position file — understand the thesis, current status, confidence, existing evidence
3. Read the position's `derived_predictions:` to understand the full prediction portfolio (how many predictions test this position, how many have resolved)

## Phase 3: Interpretive classification (LLM-mediated)

This is the core step. For each (resolved prediction, linked position) pair:

**Classify the resolution into one of these interpretation classes:**

| Class | Meaning | When to use |
|-------|---------|-------------|
| `direct_support` | Parent mechanism confirmed | Prediction passed, outcome validates position's core claim |
| `broader_support` | Outcome exceeded prediction scope | Prediction passed, revealed mechanism is stronger/wider than claimed |
| `claim_failure` | Operationalization too narrow/strong | "Right mechanism, wrong parameter" — timing, magnitude, or specificity was off |
| `mechanism_failure` | Parent mechanism invalidated | Reality showed the structural claim is wrong, not just the parameterization |
| `timing_failure` | Right mechanism, wrong timeline | The mispricing/dynamic exists but resolved on different timescale |
| `asset_mapping_failure` | Right mechanism, wrong instrument | The structural claim is real but doesn't express through this asset/market |
| `regime_exception` | Mechanism right in general, specific regime broke path | Exogenous intervention disrupted transmission (policy, black swan) |
| `inconclusive` | Resolution confounded | Multiple factors, can't cleanly attribute outcome |

**Classification must include:**
- The interpretation class
- A 1-2 sentence reasoning explaining WHY this class was chosen
- Whether the failure (if any) was about the position's core mechanism or just the prediction's parameterization

## Phase 4: Verb selection from interpretation

Map interpretation class to Brain epistemic verb:

| Interpretation Class | Brain Verb | Confidence Modifier |
|---------------------|-----------|-------------------|
| `direct_support` | SUPPORTS | Full prediction confidence |
| `broader_support` | EXTENDS | Full prediction confidence |
| `claim_failure` | REFINES | Reduced (× 0.7) — mapping is indirect |
| `mechanism_failure` | CONTRADICTS | Full prediction confidence |
| `timing_failure` | REFINES | Reduced (× 0.7) |
| `asset_mapping_failure` | REFINES | Reduced (× 0.7) |
| `regime_exception` | No event | N/A — update forecast library, not worldview |
| `inconclusive` | No event | N/A |

**"No event" is an explicit outcome.** Not every resolved prediction should update the parent position.

**Confidence calculation:**
1. Start with the PH prediction's confidence at resolution time
2. Apply modifier from table above (full or × 0.7)
3. Cap at T1 ceiling (0.95) — resolution outcomes are empirical data

## Phase 5: Emit ledger events

For each (prediction, position) pair:

### 5a. Raw resolution event (always emit)

Emit a PREDICTION_PASSED or PREDICTION_FAILED event — the hardest epistemic signal in the system:

```json
{
  "timestamp": "ISO 8601 (now)",
  "verb": "PREDICTION_PASSED",
  "source": "notes/positions/{position-slug}.md",
  "target": "notes/positions/{position-slug}.md",
  "target_type": "position",
  "reasoning": "PRED-{ID}: '{claim}'. Outcome: {actual result}.",
  "confidence": 1.0,
  "inference_mode": "resolution",
  "prediction_id": "PRED-{ID}",
  "predicted": "{claim}",
  "actual": "{actual outcome}",
  "run_id": "resolve-{today's date}",
  "source_tier": "T1-primary"
}
```

This is T1, confidence 1.0 — unambiguous reality feedback. No source-tier ceiling. No interpretation needed.

### 5b. Interpreted event (when interpretation produces a verb)

For each pair where the interpretation produces an event:

```json
{
  "timestamp": "ISO 8601 (now)",
  "verb": "{selected verb from Phase 4}",
  "source": "notes/positions/{position-slug}.md",
  "target": "notes/positions/{position-slug}.md",
  "target_type": "position",
  "reasoning": "PRED-{ID} {passed|failed}: {interpretation reasoning}. Interpretation: {class} — {why this class was chosen}.",
  "confidence": 0.65,
  "inference_mode": "resolution",
  "interpretation_class": "{class}",
  "run_id": "resolve-{today's date}",
  "source_tier": "T1"
}
```

**Important design note on source field:** For resolution events, `source` and `target` are BOTH the position file. The prediction is referenced in `reasoning` and tracked via `interpretation_class`. This is because:
- The validation hook requires source to be an existing local file
- The prediction lives in a different repo
- The resolution event is about the POSITION updating, not about the prediction

2. Append to `knowledge/epistemic-ledger.jsonl` — the validation hook will enforce schema
3. If the hook blocks (e.g., duplicate within 7 days), log and skip

### 5c. Cascade analysis

After emitting events, trace impact:
1. **Direct position** — already updated above
2. **Child positions** — grep `notes/positions/` for `parent: "[[{position-slug}]]"`. For each child, assess if the resolution outcome affects the child's thesis.
3. **Sibling predictions** — check `derived_predictions:` on the same position for other unresolved predictions. Note if the resolution changes their expected outcome.
4. **Cross-position assumptions** — check if other positions share assumptions with this one (e.g., both assume "Hormuz supply disruption" → both affected by same resolution)
5. Report cascade findings. If a child position is materially affected, emit CASCADE_PRESSURE to `knowledge/operational-ledger.jsonl`.

### 5d. Update prediction calibration

Read and update `knowledge/prediction-calibration.yml`:
1. Increment `total_predictions_resolved`
2. Update `overall_calibration` (recalculate stated_confidence_avg, actual_accuracy, calibration_gap)
3. Update `by_domain` section (add or update domain entry)
4. If conversation context is available (from `conversation_context` field on prediction), update `by_creation_speed`
5. If patterns emerge (3+ resolutions in a domain), add to `signature_biases`

## Phase 6: Update position notes

For each emitted event:
1. Append to position's `## Evolution` section:
   ```
   - **YYYY-MM-DD** — {VERB} by PRED-{ID} resolution ({passed|failed}): {one-line interpretation} (via /resolve-feedback, class: {interpretation_class})
   ```

2. Update Evidence sections:
   - SUPPORTS or EXTENDS → add to `## Evidence For`
   - CONTRADICTS → add to `## Evidence Against`
   - REFINES → add to `## Evidence For` with note about refinement needed

## Phase 7: Report

```
Resolution feedback for {date}:
- Predictions scanned: {N}
- Resolved with brain links: {N}
- Already processed: {N} (skipped)

Results:
  - PRED-{ID} ({passed|failed}) → {position-slug}
    Interpretation: {class}
    Verb: {verb} (confidence: {conf})
    {reasoning summary}

  - PRED-{ID} ({passed|failed}) → (no event — {class})

Next /digest will crystallize these into graph-epistemic.yml.
```

## Edge Cases

- **Multiple positions linked to one prediction:** Process each pair independently. The same prediction may SUPPORTS one position and REFINES another.
- **No brain_positions field:** Skip silently — not all predictions are cross-linked yet.
- **Prediction expired (not passed/failed):** Treat expiry as a soft failure — default to `inconclusive` unless the expiry itself is informative.
- **Position already has many resolution events:** That's fine — the existing digest crystallization handles aggregation. Multiple resolutions accumulate in the ledger; /digest Phase 5 computes trajectory from totals.
