---
name: boot
description: Session start ritual — insight-forward surface of what changed, what needs attention, and your epistemic landscape. Consumes briefing, session index, and micro-captures for cross-session continuity. Read-only.
allowed-tools: Read, Glob, Grep, Bash(date *), Bash(find *), Bash(ls *), Bash(test *), Bash(wc *), Bash(grep *), Bash(python3 *), AskUserQuestion
dashterm: true
argument-hint: "[optional: 'portfolio' for per-project drill-down]"
effort: low
---

input = $ARGUMENTS

TODAY=!`date +%Y-%m-%d`
BRAIN_DIR=!`echo "$BRAIN_VAULT_PATH"`
INBOX_COUNT=!`find "$BRAIN_DIR/notes/inbox" -name "*.md" -not -name ".gitkeep" 2>/dev/null | wc -l | tr -d ' '`
ACTIVE_PROJECTS=!`find "$BRAIN_DIR/notes/projects" -name "*.md" -not -name ".gitkeep" 2>/dev/null | wc -l | tr -d ' '`
MODES_COUNT=!`ls "$BRAIN_DIR/knowledge/modes/"*.md 2>/dev/null | wc -l | tr -d ' '`
FLAG_EXISTS=!`test -f "$BRAIN_DIR/knowledge/inbox-pending.flag" && echo "yes" || echo "no"`
POSITION_COUNT=!`ls "$BRAIN_DIR/notes/positions/" 2>/dev/null | wc -l | tr -d ' '`
QUESTION_COUNT=!`grep -l "classification: question" "$BRAIN_DIR/notes/positions/"*.md 2>/dev/null | wc -l | tr -d ' '`
UNVERIFIED_COUNT=!`grep -c "needs_intent_verification" "$BRAIN_DIR/knowledge/epistemic-ledger.jsonl" 2>/dev/null || echo 0`

# /boot — Session Start

## Portfolio subcommand

If `$ARGUMENTS` contains "portfolio", skip the standard boot and jump to **Portfolio Mode** below.

## Standard boot — session-aware output

Output format (strict — no prose improvisation outside these blocks):

```
SESSION START — {TODAY}

{BRIEFING SUMMARY:}
[Find the most recent briefing: check studio/briefing/latest.html first (symlink). If it doesn't exist, glob studio/briefing/2*.html and take the most recent by filename sort.]
[If a briefing exists and was generated within the last 48 hours:]
[Extract the OPENING section — 2-3 sentences of editorial summary]
[Extract PRESSURE POINTS — contested/weakening positions, stalled questions]
[Extract RECOMMENDATIONS — tactical items only, max 3]
[If no briefing found or most recent is >48h stale: "No recent briefing. Run metabolism or /briefing to generate."]

{PREVIOUS SESSIONS — cross-session continuity:}
[Read knowledge/session-index.jsonl — find sessions since last boot]
[Determine "last boot" from the second-most-recent entry in knowledge/session-index.jsonl with skill "boot", or fall back to 24h ago]
[Take the most recent 5 sessions across ALL repos]
[For each session:]
  [1. Check knowledge/session-captures/ for micro-capture matching the session date — read if exists]
  [2. Check knowledge/session-extractions/ for extraction matching session ID — read if exists]
  [3. If neither exists but session has >20 messages: flag as "uncharacterized session"]
[Synthesize across sessions: what was the user working on, what decisions were made, what's parked]
[Format:]
PREVIOUS SESSIONS (since last boot):
- {repo}: {1-sentence summary from micro-capture or extraction}
  {If parked items exist: "Parked: {item}"}
  {If continuity.next_session_context exists in extraction: use it}
- {repo}: {summary}
[If no sessions found since last boot: "No sessions recorded since last boot."]
[If sessions exist but none have captures/extractions: "N sessions since last boot (no captures — micro-capture not yet active for all repos)"]

ATTENTION NOW:
[Items needing immediate attention:]
- {From briefing PRESSURE POINTS if available}
- {Temporally urgent: deadlines from recent daily notes and graph-projects.yml, pending decisions}
- {Blocked projects from graph-projects.yml waiting on external input}
- {Unverified events: if UNVERIFIED_COUNT > 0, show "⚠ {N} events need intent verification — from automation runs. Review with /digest or /bridge."}
- {Inbox: if INBOX_COUNT > 5, show "Inbox: {N} items — consider /triage"}
- {Uncharacterized sessions: if any flagged above, show "⚠ {N} uncharacterized sessions — micro-capture not running in those repos"}
{IF FLAG_EXISTS == "yes":}
- Queued inbox work pending (check knowledge/inbox-pending.flag)

YOUR LANDSCAPE:
- Positions: {POSITION_COUNT} total
  [Read knowledge/graph-epistemic.yml — count by trajectory: {N} strengthening, {N} contested, {N} weakening]
- Questions: {QUESTION_COUNT} open (classification: question positions)
  [Count by resolution_proximity from graph-epistemic.yml: {N} approaching resolution, {N} ready to resolve]
- Inbox: {INBOX_COUNT} notes
- Active projects: {ACTIVE_PROJECTS}

{IF knowledge/absorption-log.jsonl has entries:}
ABSORPTION:
[Read knowledge/absorption-log.jsonl — group by domain_tags]
[Entries now have `intent` (applied|evaluative) and `absorption_history` fields. Show intent distribution if mixed.]
[For domains with 3+ items consumed and NO corresponding position in notes/positions/ with that tag:]
- {domain}: {N} items consumed ({N} evaluative, {N} applied), no position formed. Forming a view?
[If no consumption clusters found: skip this section]

ACTIVE THREADS (from daily notes):
[Read last 3 daily notes from notes/daily/. Extract ## Work and ## Decisions sections. Synthesize into active thread list — what's in progress, what's blocked, what was just completed.]

{IF MODES_COUNT > 0:}
MODES: {MODES_COUNT} available — "load mode {name}" to activate

SUGGESTIONS (from activation layer):
[Try: run `python -m activation --scope brain --view home --vault-root "$BRAIN_DIR" 2>/dev/null`]
[If the command succeeds (exit 0), parse the JSON output:]
[Show up to 3 candidates where suppression_reason is null and final_score >= 55, formatted as:]
- → /{skill_ref} — {why_now}
[If fewer than 3 candidates score >= 55, show top 3 unsuppressed regardless of score]
[If the command fails or activation/ directory doesn't exist: skip this section silently]

SYSTEM HEALTH:
[Read knowledge/metabolism-last-run.json:]
- Last cycle: {last_run_at} ({N} hours ago)
- Phases completed: {steps_completed}
- Duration: {duration_seconds}s
[If last_run_at is >6 hours ago: "⚠ Metabolism hasn't run recently"]
[If metabolism-last-run.json doesn't exist: "Metabolism not yet running."]

OFFER:
- /briefing for the full editorial
- /boot portfolio for per-project drill-down
[If metabolism is stale:] - Run metabolism --force to process now
[else:] - Metabolism handles all processing automatically

Ready.
```

---

## Portfolio Mode

When `$ARGUMENTS` contains "portfolio", present a per-project drill-down instead of standard boot.

Read `knowledge/graph-projects.yml`. For each project with `last_worked` in the last 14 days:

```
PORTFOLIO — {TODAY}

{For each project, ordered by last_worked (most recent first):}

## {Project Name}
Status: {1-line from graph-projects.yml status field}
Last worked: {date} ({N} days ago)
Next step: {from graph-projects.yml next_step field, or "not specified"}
Blocked: {blocked_by field if present, otherwise "no"}
Connected to: {other projects sharing positions or features — check for shared tags/areas}

Recent: {Read last 2-3 daily notes, find entries mentioning this project under ## Work. Summarize in 2-3 sentences.}

---

{Projects last worked 15+ days ago, if not parked:}
COOLING:
- {project}: last touched {N} days ago. {parked_reason if set, else "Consider parking or resuming."}
```

If `graph-projects.yml` doesn't exist or is empty: "No project state data. Run /sync to populate."

---

## First-run detection (empty vault)

Before the standard boot output, check for an empty vault:

1. `ACTIVE_PROJECTS == 0` AND `INBOX_COUNT == 0` AND no daily notes exist (`find notes/daily -name "*.md" | wc -l` == 0)
2. AND no session-index.jsonl entries exist (vault has never been used)

If ALL conditions are true, this is a **first run**. Check for pre-seed research:

**If `knowledge/pre-seed.yml` exists:**
```
FIRST RUN DETECTED — Welcome to Brain.

I found research on you (from pre-seed). Let's use it to set up your vault:

1. /onboard — Interactive setup using what I already know about you (~3 min)
2. /guided-tour — Walk through what the system can do (5 min)
3. /domain-seed — Pre-load deeper context for your primary domain

Recommended: start with /onboard — I'll greet you with what I learned.
```

**If `knowledge/pre-seed.yml` does NOT exist:**
```
FIRST RUN DETECTED — Welcome to Brain.

Your vault is empty. Let's set it up:

1. /onboard — Interactive setup through conversation (~3 min)
2. /guided-tour — Walk through what the system can do (5 min)
3. /domain-seed — Pre-load context for your primary domain

Recommended: start with /onboard. Or just start capturing — "I think X" or "save this: URL".

Tip: Run /pre-seed 'Your Name' --github yourhandle first for a richer onboarding experience.
```

**Legacy fallback:** `/profile-init` is still available as a manual alternative if preferred.

Then STOP — do not output the standard boot format. The user will invoke the skills manually.

## Edge cases

- If daily note does not exist: in briefing summary, proceed — briefing covers this
- If recommendations.md is stale (more than 24h since "Last refreshed:" date): do not show recommendations section — the OFFER section covers this
- If ACTIVE_PROJECTS > 10: append "⚠ {N} active projects — consider parking some" in YOUR LANDSCAPE
- If MODES_COUNT == 0 or knowledge/modes/ directory has no .md files: skip the MODES line entirely
- If modes directory does not exist: skip silently
- If graph-epistemic.yml doesn't exist: show raw counts only in YOUR LANDSCAPE, skip trajectory breakdown
- If absorption-log.jsonl is empty or only has comment headers: skip ABSORPTION section
- If UNVERIFIED_COUNT == 0: don't mention unverified events in ATTENTION NOW
- If repo-signals.jsonl doesn't exist or is empty: skip REPO SIGNALS section
- If session-index.jsonl doesn't exist: show "Session tracking not yet active" in PREVIOUS SESSIONS

## Read sequence

1. Read studio/briefing/latest.html OR glob studio/briefing/2*.html for most recent (for BRIEFING SUMMARY — system state from last metabolism cycle)
2. Read knowledge/session-index.jsonl (for PREVIOUS SESSIONS — cross-session continuity, and last boot date)
3. Read relevant session-captures/ and session-extractions/ files (for per-session context)
4. Read last 3 daily notes from notes/daily/ (for ACTIVE THREADS and ATTENTION NOW)
5. Read knowledge/graph-epistemic.yml (for LANDSCAPE trajectory counts)
6. Read knowledge/graph-projects.yml (for blocked projects in ATTENTION NOW, and for portfolio mode)
7. Read knowledge/absorption-log.jsonl (for ABSORPTION section)
8. Grep knowledge/epistemic-ledger.jsonl for `needs_intent_verification` (for unverified event count)
9. Check knowledge/inbox-pending.flag if FLAG_EXISTS == "yes"
10. Check knowledge/modes/ for .md files
11. Read knowledge/metabolism-last-run.json (for SYSTEM HEALTH)

## Critical constraint

/boot is strictly read-only. It reads vault files directly — no cached summaries in auto-memory. After running, git status must show no modified files.
