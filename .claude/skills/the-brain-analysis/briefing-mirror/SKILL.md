---
name: briefing
description: Generate an editorial daily briefing — The Mirror. A narrative HTML page that tells you about yourself through your vault data. Not a dashboard — a warm, honest, occasionally wry editorial voice.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(date *), Bash(wc *), Bash(ls *), Bash(mkdir *), Bash(tail *), Bash(head *), Agent
argument-hint: "[optional: 'light' for light mode default, 'rerun' to regenerate]"
dashterm: true
timeout: 0
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Day of week: !`date +%A`
Current time: !`date +%H:%M`
Last briefing: !`ls -1 studio/briefing/*.html 2>/dev/null | tail -1 || echo "(none)"`
Inbox count: !`ls notes/inbox/ 2>/dev/null | wc -l | tr -d ' '`
Position count: !`ls notes/positions/ 2>/dev/null | wc -l | tr -d ' '`
Question count: !`grep -l "classification: question" notes/positions/*.md 2>/dev/null | wc -l | tr -d ' '`
Ledger size: !`wc -l < knowledge/epistemic-ledger.jsonl 2>/dev/null || echo 0`
Recent daily notes: !`ls -1 notes/daily/ 2>/dev/null | grep -E '^[0-9]{4}-' | tail -3`

# /briefing — The Mirror

Generate a self-contained HTML editorial briefing about the user's intellectual state, grounded in vault data. This is not a dashboard — it's a narrative document with a warm, honest, occasionally wry voice that tells the user about themselves through their data.

## Phase 1: Data Gathering

Read these files. Do NOT skip any — the narrative quality depends on having the full picture.

### Required reads (parallel where possible)

**Knowledge subgraphs:**
1. `knowledge/graph-index.yml` — routing and counts
2. `knowledge/graph-epistemic.yml` — belief states, question states, thesis layer states
3. `knowledge/graph-cross-cutting.yml` — promoted cross-domain principles
4. `knowledge/graph-emergent.yml` — drift themes (may be empty)
5. `knowledge/graph-projects.yml` — project state snapshots
6. `knowledge/graph-dev.yml` — dev solutions, patterns, dead-ends
6b. `knowledge/absorption-log.jsonl` — consumption tracking (may be empty on first run)

**Temporal data:**
7. `knowledge/epistemic-ledger.jsonl` — filter to events since last briefing (or last 7 days if first run)
8. Most recent weekly activity YAML from `activity/weeks/` — the `epistemic:` section is especially rich
9. Last 2-3 daily notes from `notes/daily/` (use the filenames from dynamic context above)

**Selective deep reads (3-5 notes):**
10. Read the full text of any position with `trajectory: contested` or `trajectory: weakening` in graph-epistemic.yml
11. Read any question with `resolution_proximity: approaching` or `resolution_proximity: ready`
12. Read any position mentioned in cross-cutting principles that is under pressure

**Learning signal:**
13b. `knowledge/feedback-ledger.jsonl` — filter to last 7 days. Count by skill and action. Flag any skill with 3+ rejections. Calculate per-skill accept rates.

**Operational patterns:**
13. `knowledge/graph-dev.yml` — scan for `type: pattern` entities, especially those with `recurrence_count` >= 2 or matching active projects from graph-projects.yml

**Challenge history:**
14b. `knowledge/challenge-ledger.jsonl` — filter to last 7 days. Count outcomes by type (robust/weakened/urgent). Identify positions challenged more than once.

**Repo signals:**
14d. `knowledge/repo-signals.jsonl` — filter to pending signals for ATTENTION POINTS

**Recommendations:**
14c. `knowledge/recommendation-published.json` — if it exists, read published recommendations for the Recommendations section

**Optional enrichment:**
15. `knowledge/enrichment-seeds.yml` — if it exists, read for taste calibration
16. Most recent drift run from `knowledge/drift-runs/` — if it exists

### Data synthesis

After reading, build a mental model:
- **Overall vault weather**: Is the system in a period of expansion (lots of new positions), consolidation (digests refining existing), tension (contested positions fighting), or quiet?
- **Hottest territory**: Which area/domain has the most recent activity and energy?
- **Most interesting development**: What single thing would be most surprising or useful to hear about?
- **Pressure points**: What's contested, stalled, or misaligned?
- **Edges**: What's barely forming, hinted at in cross-cutting principles or drift?

## Phase 2: Narrative Synthesis

Write the briefing content as HTML fragments. The voice must be:
- **Warm but not sycophantic** — talk to the user like a thoughtful colleague who's been reading their notes
- **Honest** — name tensions, don't smooth them over
- **Occasionally wry** — a light touch of humor where it fits naturally
- **Specific** — use actual position names, evidence counts, and vault terminology
- **Never mechanical** — no "here are your metrics" phrasing

### Narrative sections

**1. THE OPENING** (`<section class="opening">`)
- Ground in real context: city (Los Angeles), date, day of week
- One-sentence vault weather: atmospheric, not metric-heavy
- Name the single most interesting recent development in 1-2 sentences
- If something is barely visible at the edges, hint at it

**2. TERRITORIES** (`<section class="territories">`)
- For each active area/domain with recent activity, write 2-3 sentences as landscape with emotional weather
- Example tone: "Career is hot — you flipped a position this week. The consulting thesis lost its footing; hiring-first is the new gravity. Filmmaking is quiet but present."
- Mention specific evidence shifts, questions that advanced, decisions that were made
- Use `<details><summary>` for deeper position-by-position breakdowns within each territory

**3. PRESSURE POINTS** (`<section class="pressure-points">`)
- Contested positions (evidence fighting itself) — name them, explain the tension
- Weakening positions — what's losing ground and why
- Stalled questions — questions with no recent advances
- Belief-action gaps — if bridge data exists, mention misalignments
- Inbox depth — if inbox > 5, mention it
- **Adversarial pressure** (from challenge-ledger) — if any positions were challenged in the last 7 days:
  - Name positions with `challenge_outcome: weakened` or `urgent`
  - If a position was challenged and found `robust`, mention it as validation: "X held up under challenge"
  - If `urgent` outcomes exist, lead the pressure points section with them
  - Tone: "The challenge system flagged X as urgent — the counter-evidence is worth reading."
  - If no challenge data exists, skip this sub-section entirely
- **Repo signals** — if pending signals exist with `require_human_review` categories (dependency-shift, pattern-discovered, architecture-shift):
  - "{repo}: {category} — {summary}. Needs your call."
  - Tone: operational. "Apollo changed its CLAUDE.md. Worth checking."
- Tone: slightly more direct, gentle confrontation. "You should look at this."

**4b. OPERATIONAL WISDOM** (`<section class="wisdom">`)
- Surface 2-3 patterns from graph-dev.yml (`type: pattern`) that are relevant to current active projects
- If any pattern has `recurrence_count` >= 3, highlight it: "This keeps happening: {pattern}"
- If a pattern was followed or violated in recent daily notes, note it
- Tone: pragmatic, coach-like. "You've seen this before."
- **Skip this section entirely if no relevant patterns exist** — don't force it
- **System learning** (from feedback-ledger) — if notable patterns exist in the last 7 days:
  - Name skills with 3+ rejections: "/{skill} has been rejected {N} times this week — {common reason if available}."
  - Name skills with high accept rates as validation: "/{skill} is landing consistently."
  - If edit patterns cluster (e.g., "tags were wrong" appears 3x), surface the pattern as an actionable insight
  - Tone: pragmatic, self-aware. "The system is learning: {pattern}."
  - If insufficient feedback data (fewer than 5 events in 7 days), skip this sub-section entirely

**5. EMERGING** (`<section class="emerging">`)
- Cross-domain convergences from cross-cutting principles
- Unnamed themes from drift (if any)
- Ghost links — things that almost connect but haven't been named
- Tone: dawn-breaking, tentative, intriguing. "There's something forming between..."

**5b. ABSORPTION PATTERNS** (`<section class="absorption">`)
- Read `knowledge/absorption-log.jsonl` and group entries by `domain_tags` and `source_author`
- Entries have `intent` (applied|evaluative) and `absorption_history` (state transition log). Distinguish applied vs evaluative in pattern reporting.
- Surface consumption clusters: domains with 3+ items consumed but no corresponding position
- Surface heavy sources: authors with 3+ items consumed
- Format: "What you're consuming:"
  - "{domain}: {N} items from {M} sources this week ({N} evaluative, {N} applied). No position formed."
  - "{author}: {N} items ingested. Status: {most common absorption_state}"
- Tone: curious, non-judgmental. "You keep returning to {domain}. Something forming?"
- **If absorption-log is empty or missing, skip this section entirely** — don't show an empty placeholder

**5c. PORTFOLIO STATUS** (`<section class="portfolio">`)
- Read `knowledge/graph-projects.yml` for project state snapshots
- Categorize projects by temperature:
  - **Hot** — `last_worked` within 3 days
  - **Warm** — `last_worked` within 7 days
  - **Cooling** — `last_worked` 8-14 days ago
  - **Cold** — `last_worked` 15+ days ago (only mention if the project is not parked)
- For each project: "{project name} — {1-line status from graph}"
- Group by temperature with subtle visual indicators
- Mention blocked projects explicitly: "{project} — waiting on {blocker}"
- Tone: operational, concise. Dashboard-adjacent but still narrative.
- **If graph-projects.yml is empty or missing, skip this section entirely**

**6. RECOMMENDATIONS** (`<section class="recommendations">`)
Three altitude bands, each with 2-3 concrete items:

- **Tactical** (do today) — If `knowledge/recommendation-published.json` has published recommendations, use them as the primary source for Tactical items — they are pre-scored and pre-grounded. Otherwise derive from vault state: "Read the counter-evidence on X." "Question Y has 4 advances — it's ready to resolve." "Triage the inbox."
- **Strategic** (pursue this week) — If published recommendations include strategic-level items, use them. Supplement with your own judgment: "Seek adversarial evidence for A." "Name the pattern forming between B and C." "Run /bridge to check alignment."
- **Enrichment** (feed your mind) — Claude-generated recommendations calibrated to vault themes. Books, documentaries, essays, thinkers, podcasts. Be surprising and specific. "You keep circling the tension between legibility and craft — here's Richard Sennett's *The Craftsman*, which names it precisely." Read `knowledge/enrichment-seeds.yml` if it exists for calibration.

### Mini-visualizations (inline, subtle)

Include small inline visual indicators where they add signal:
- **Position health dots**: colored circles (green=strengthening, amber=contested, red=weakening, gray=stable) next to position names
- **Question proximity bars**: thin progress indicators (far/approaching/ready)
- **Thesis layer health**: one-line summary with colored indicator per layer
- These are CSS-only, no JavaScript required

## Phase 3: HTML Assembly

Build a single self-contained HTML file using the clean-90s design system.

### Template structure

```html
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>The Mirror — {YYYY-MM-DD}</title>
<link href="https://fonts.googleapis.com/css2?family=Instrument+Serif&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
<style>
  /* clean-90s CSS custom properties (both themes) */
  /* Layout: max-width 640px, centered, generous padding */
  /* Typography: Instrument Serif for headings, Inter for body */
  /* Sections with subtle borders, not cards */
  /* Progressive disclosure via details/summary */
  /* Mini-visualization styles */
  /* Dark mode default, light mode toggle */
  /* Mobile-friendly: touch targets, no horizontal scroll */
  /* Grain overlay for texture */
</style>
</head>
<body>
  <header class="briefing-header">
    <div class="briefing-meta">{Day}, {Month} {Date}, {Year}</div>
    <h1 class="briefing-title">The Mirror</h1>
    <div class="briefing-subtitle">Los Angeles</div>
  </header>
  <main>
    <section class="opening">...</section>
    <section class="territories">...</section>
    <section class="pressure-points">...</section>
    <section class="emerging">...</section>
    <section class="absorption">...</section>
    <section class="portfolio">...</section>
    <section class="recommendations">...</section>
  </main>
  <footer class="briefing-footer">
    <div class="briefing-stats">
      {position count} positions · {question count} questions · {ledger event count} events · {inbox count} inbox
    </div>
    <div class="briefing-generated">Generated {timestamp}</div>
  </footer>
  <script>
    /* Theme toggle only — click header to switch light/dark */
  </script>
</body>
</html>
```

### CSS requirements

Use the clean-90s design system tokens from `~/.claude/styles/clean-90s.md`:

**Dark mode (default):**
- bg: `#0d0d0d`, bg-panel: `#161616`, text: `#d4d0c8`, muted: `#9a9690`, faint: `#4a4840`
- ink-blue: `#6a90c0`, ink-amber: `#c4a35a`, ink-red: `#c47070`, ink-green: `#6aaa90`, ink-violet: `#9a8ac8`, ink-teal: `#5aadad`
- border: `#2a2826`, border-strong: `#3a3836`

**Light mode:**
- bg: `#f5f0e8`, bg-panel: `#faf7f2`, text: `#1a1a18`, muted: `rgba(26,26,24,.65)`, faint: `rgba(26,26,24,.40)`
- ink-blue: `#4a6fa5`, ink-amber: `#9e7c3a`, ink-red: `#a85656`, ink-green: `#4d8a74`, ink-violet: `#7b6bab`, ink-teal: `#3a8a8a`
- border: `rgba(26,26,24,.10)`, border-strong: `rgba(26,26,24,.18)`

**Typography:**
- Headings: `Instrument Serif`
- Body: `Inter`, 15px, line-height 1.65
- Labels: 11px uppercase, letter-spacing 0.14em, faint color
- Section titles: `Instrument Serif`, ~20px, with hairline bottom border

**Layout:**
- `max-width: 640px`, centered, 24px horizontal padding
- Section spacing: 2.5rem between sections
- Progressive disclosure: `<details>` styled with subtle marker and indented content
- Grain overlay: fractalNoise SVG at 0.024 opacity, pointer-events none

**Indicators:**
- Health dots: 8px circles, inline with text
- Trajectory colors: `ink-green`=strengthening, `ink-amber`=contested, `ink-red`=weakening, `faint`=stable
- Progress bars for question proximity: thin (3px) horizontal bars
- Thesis layer strip: horizontal row of 3 mini cards (one per layer)

**If $ARGUMENTS contains "light"**, set `data-theme="light"` as default instead of dark.

## Phase 4: Write Output

Write the complete HTML file to:
```
studio/briefing/{today-date}.html
```

If the file already exists (rerun), overwrite it.

## Phase 4b: Update recommendation memory

After writing the HTML briefing, update the session memory file at `~/.claude/projects/-Users-ritual-Projects-Development-brain/memory/recommendations.md` with the top 3-5 recommendations from the briefing in plain markdown format:

```markdown
---
name: vault-recommendations
description: Top vault recommendations — what deserves attention today. Auto-refreshed by recommendation pipeline.
type: project
---

Last refreshed: {today's date and time}

1. **{title}** — {why_now}
   Action: {label}

2. ...
```

This ensures the next conversation starts with fresh recommendations even if the launchd pipeline hasn't run.

## Phase 5: Report

Tell the user:
- Output path
- Brief summary of what the briefing covers (2-3 sentences)
- Remind them they can open it in a browser, AirDrop to phone, or serve with `python3 -m http.server 8080 -d studio/briefing/`

## Voice calibration notes

The briefing should feel like reading a letter from someone who genuinely understands your thinking — not a system report, not a therapy session, not a product dashboard.

**Good examples:**
- "Your architectural layer is untouchable — six positions, zero challenges. That's either very right or very untested."
- "Career is where the action is. You flipped consulting-now-peer-with-hiring this week — two contradictions outweighed the original thesis. Hiring-first is the new gravity."
- "The inbox has 12 notes. That's not a crisis, but it's starting to smell."

**Bad examples (never write like this):**
- "Here is a summary of your epistemic state across 44 belief-state entities..."
- "Great job this week! You processed 98 events!"
- "Based on my analysis of your knowledge graph, I recommend..."

## Rules

- One briefing per day. Overwrites on rerun.
- Do NOT read every note in the vault — be selective. Read subgraphs for breadth, individual notes only for the 3-5 most interesting cases.
- The narrative must be grounded in actual data — don't make claims you can't trace to a file.
- Keep the HTML self-contained — no external JS, no build step, just open in a browser.
- Total HTML file should be under 30KB — this is a document, not an app.
