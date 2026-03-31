---
name: challenge
description: "Adversarial epistemic prompts — argue against held positions, surface untested beliefs, and stress-test confidence levels. Use when wanting to challenge your own thinking."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(wc *), Agent, AskUserQuestion
argument-hint: "[position-slug] [--all] [--write]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Vault root: !`echo "$BRAIN_VAULT_PATH"`
Position count: !`ls $BRAIN_VAULT_PATH/notes/positions/ 2>/dev/null | wc -l | tr -d ' '`
Held positions: !`grep -rl "status: held" $BRAIN_VAULT_PATH/notes/positions/ 2>/dev/null | wc -l | tr -d ' '`
High confidence: !`grep -rl "confidence: high\|confidence: convicted" $BRAIN_VAULT_PATH/notes/positions/ 2>/dev/null | wc -l | tr -d ' '`

# /challenge — Epistemic Immune System

You are the adversary. Your job is to argue against the user's held beliefs, surface positions that haven't been tested, and stress-test confidence levels. This is NOT destructive — it's the immune system that keeps the belief graph honest.

## Step 1: Select Targets

### If a specific position slug is given:
Read that position from `notes/positions/{slug}.md`. This is your single target.

### If `--all` is given:
Scan all positions. Prioritize for challenge (pick 2-3):
1. **High confidence + thin evidence** — positions marked `high` or `convicted` but with ≤2 items in "Evidence For" and 0 in "Evidence Against"
2. **Stale held positions** — `status: held` but `updated:` > 30 days ago (belief on autopilot)
3. **No counter-evidence** — any position with empty "Evidence Against" section
4. **Derived predictions that failed** — positions with `derived_predictions:` where PH shows a failed prediction

### If no args:
Pick the single most challengeable position using the priority order above.

### Intent checkpoint (no args only)

When no explicit position slug was provided, present the selected target to the user before proceeding:

Use AskUserQuestion:
```
I'd challenge '{title}' — {reason from priority selection above}.
Want me to proceed, pick a different position, or skip today's challenge?
```

Response handling:
- **"Proceed" / "yes" / confirmation** → Continue to Step 2 with this target
- **User names a different position** → Switch target to the named position, continue to Step 2
- **"Skip" / "no"** → End the skill with: "Challenge skipped. Run `/challenge {slug}` to target a specific position."

**When args ARE provided:** Skip this checkpoint entirely — the user already chose.

**Automation mode (inside /daily-cycle):** Skip the checkpoint. Use auto-selection. Add a note in the Phase F report: "Auto-selected {slug} for challenge. Override with `/challenge {preferred-slug}` if you'd prefer a different target."

## Step 2: Build the Challenge

For each target position, construct an adversarial analysis:

### 2a: Read the Position
Read the full position note. Understand the thesis, evidence, area, and confidence level.

### 2b: Search for Counter-Evidence
Use the Explore agent to search the vault for content that contradicts or complicates this position:
- References with opposing claims
- Decisions that went against this position
- Questions that undermine the thesis
- Other positions that create tension
- **Claim notes** (`notes/claims/*.md`) — read `provenance` and `endorsed` fields:
  - `endorsed: yes` claims that contradict → **strong** counter-evidence (source-verified argument against)
  - `endorsed: null` or `partial` claims that contradict → **weak** counter-evidence (unreviewed source argument)
  - `provenance: agent-synthesized` claims → flag as interpretive, note the agent's reasoning vs. the source
  - `endorsed: rejected` claims → skip (already dismissed)

Also consider common counter-arguments from general knowledge (but clearly label these as "general counter-arguments" vs. "vault-sourced counter-evidence").

### 2c: Construct the Challenge

For each position, produce:

```markdown
### Challenge: {position title}

**Current stance:** {status} at {confidence} confidence
**Evidence ratio:** {N} for / {M} against
**Last updated:** {date} ({age} days ago)

**The case against:**
{2-4 paragraphs arguing against this position. Be specific. Use vault evidence where available. Don't strawman — make the strongest possible counter-argument.}

**Counter-evidence by provenance:**
- Endorsed claims against: {N} (strong — source-verified arguments)
- Unendorsed claims against: {N} (weak — awaiting review)
- Agent-synthesized claims against: {N} (interpretive — check reasoning)
- Other vault sources: {N}
- General knowledge: {N}

**Untested assumptions:**
- {List assumptions baked into this position that haven't been validated}

**What would change your mind?**
- {Suggest 1-2 concrete observations or experiments that would falsify this position}

**Suggested confidence adjustment:** {higher/lower/hold} — {one sentence why}
```

## Step 3: Output

### To stdout (always):
Print each challenge with clear formatting. Lead with the most important challenge.

### If `--write` is passed:
Also append a challenge section to today's daily note under `## Notes`:

```markdown
### Epistemic Challenge ({today})

{condensed version — position name, key counter-argument, suggested action}
```

And update each challenged position's "Evidence Against" section with any vault-sourced counter-evidence found, adding a dated entry:

```markdown
- **{today}** (challenge) — {counter-evidence summary}
```

## Step 3b: Write to Challenge Ledger

Append one JSONL line to `knowledge/challenge-ledger.jsonl` for each challenged position.

If the file doesn't exist, create it with a comment header:
```
// challenge-ledger.jsonl — structured adversarial epistemic pressure record
// Schema: {timestamp, date, run_id, position_slug, position_title, status, confidence, evidence_for, evidence_against, counter_arguments_vault, counter_arguments_general, counter_claims_endorsed, counter_claims_unendorsed, counter_claims_agent_synthesized, untested_assumptions, challenge_outcome, suggested_adjustment, summary}
// Written by: /challenge
```

Classify the `challenge_outcome`:
- `robust` — if no strong counter-arguments were found, or the position's evidence ratio is >=3:1 for and no critical untested assumptions
- `urgent` — if 2+ strong vault-sourced counter-arguments AND >=2 critical untested assumptions
- `weakened` — everything else (legitimate concerns raised but not critical)

Determine `suggested_adjustment`: `higher` (position is stronger than confidence suggests), `lower` (counter-evidence warrants reduced confidence), or `hold` (confidence is well-calibrated).

Each JSONL line:
```json
{"timestamp": "{ISO 8601}", "date": "{YYYY-MM-DD}", "run_id": "{daily-cycle run_id or 'manual'}", "position_slug": "{position filename without .md}", "position_title": "{from frontmatter}", "status": "{position status at time of challenge}", "confidence": "{position confidence at time of challenge}", "evidence_for": {count}, "evidence_against": {count}, "counter_arguments_vault": {count}, "counter_arguments_general": {count}, "counter_claims_endorsed": {count}, "counter_claims_unendorsed": {count}, "counter_claims_agent_synthesized": {count}, "untested_assumptions": {count}, "challenge_outcome": "{robust|weakened|urgent}", "suggested_adjustment": "{higher|lower|hold}", "summary": "{one-sentence summary of the strongest counter-argument}"}
```

If invoked from `/daily-cycle`, use the daily-cycle `run_id`. If invoked manually, use `"manual"`.

## Step 3c: Convergence Guard

If this challenge targets a position that was challenged in a previous run (check `knowledge/challenge-convergence.jsonl`), apply the convergence protocol from `.claude/reference/convergence-protocol.md`:

1. Normalize each counter-argument to its structural core (strip phrasing, keep the claim)
2. Compare against counter-arguments from the most recent prior challenge of this same position slug
3. Log to `knowledge/challenge-convergence.jsonl`:
   ```jsonl
   {"run_id": "manual", "position_slug": "slug", "iteration": 2, "timestamp": "ISO8601", "findings_count": 4, "finding_hashes": ["..."], "matched_previous": 3, "match_ratio": 0.75, "converged": true}
   ```
4. If >50% match → STOP and report:
   ```
   Convergence: {matched}/{total} counter-arguments match previous challenge of this position.
   This position's weak points are well-mapped. No new pressure to apply.
   New counter-arguments (if any): {list}
   ```

First challenge of a position never triggers convergence.

## Step 4: Summary

```
=== Challenge Complete ===

Positions challenged: {count}
Counter-evidence found: {count} vault-sourced, {count} general
Confidence adjustments suggested: {list}
Untested assumptions surfaced: {count}

{If --write: "Written to daily note and position files."}
{If not --write: "Pass --write to persist these challenges to the vault."}
```

## Tone Guidance

- Be adversarial but respectful. The goal is truth-seeking, not nihilism.
- Don't challenge "exploring" positions — they're already uncertain. Focus on "held" positions at "medium" or higher confidence.
- If a position is genuinely strong (thick evidence, recent validation, tested predictions), say so. "This position held up well under challenge" is a valid outcome.
- Never fabricate counter-evidence. If you can't find real arguments against a position, say "This position appears robust — no strong counter-arguments found in vault or general knowledge."
