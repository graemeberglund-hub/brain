---
name: weekly-review
description: Generate canonical weekly activity YAML from daily notes and other sources. Use when user asks about their week or wants a summary.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *)
argument-hint: "[optional 'narrative' or date range]"
dashterm: true
timeout: 180
---

args = $ARGUMENTS


(At start of execution, use Glob to check: recent daily notes from notes/daily/*.md and recent week files from activity/weeks/*.yml.)

# /weekly-review — Daily Notes -> Canonical Weekly YAML

Generate the canonical `activity/weeks/YYYY-MM-DD.yml` from daily notes, decisions, and references created during the week.

## 1. Determine the week

Find the most recent Monday (ISO week start). The week runs Monday to Sunday. If a date was provided in args, use that week instead. Calculate `date_start` (Monday) and `date_end` (Sunday).

## 2. Gather sources

Read all of these for the target week:

1. **Daily notes** in `notes/daily/` with `type: daily` and dates in range
2. **Decision positions** in `notes/positions/` with `classification: decided` and `created:` in range
3. **Reference notes** in `notes/references/` with `created:` in range
4. **Inbox notes** in `notes/inbox/` with `created:` in range (flag as untriaged)

## 3. Extract and attribute activities

Read the gathered notes and understand what work was done. From daily notes, look at `## Work`, `## Decisions`, and `## Captured` sections. From decision/reference notes, use their `project:` fields.

Attribute each activity to the right project — you know the projects from `notes/projects/` and `activity/config.yml`. Use `activity/config.yml` as a reference for valid project names. Group unmatched items under `General / Brain`.

For each project, determine the `repo` value (story-dev | story-dev-clean | brain | both | external).

## 4. Generate or merge YAML

Check if `activity/weeks/{date_start}.yml` exists:

**If it exists**: merge new items with existing
- For existing projects, append only NEW items (avoid duplicates)
- For new projects, add the full block
- Preserve any manually-added items

**If it doesn't exist**: create fresh
```yaml
date_start: "YYYY-MM-DD"
date_end: "YYYY-MM-DD"
activities:
  - project: "Project Name"
    repo: story-dev-clean
    items:
      - "Activity description"
```

## 4b. Epistemic activity summary

Read `knowledge/epistemic-ledger.jsonl` and filter events with timestamps in the target week. Summarize:
- How many epistemic events were recorded
- Breakdown by verb (e.g., 5 SUPPORTS, 2 CHALLENGES, 1 ADVANCES)
- Which positions were most active (most events targeting them)
- Any positions under pressure (CONTRADICTS/CHALLENGES)
- Any questions that advanced

Add an `epistemic:` section to the YAML output:
```yaml
epistemic:
  events: 14
  positions_strengthened: ["position-slug-1", "position-slug-2"]
  positions_challenged: ["position-slug-3"]
  questions_advanced: ["question-slug-1"]
  highlights:
    - "Position X received 2 CHALLENGES from conversation and reference notes"
```

## 5. Validate

Flag any project names that don't appear in `activity/config.yml` and ask the user to resolve. Warn if the week looks incomplete.

## 6. Optional: narrative journal

If `args` contains "narrative":
- Create/update `notes/journal/YYYY-MM-DD-journal-weekly.md` with `type: journal`
- Synthesize a reflective narrative from the week's activities
- Link to relevant decision and project notes via `[[wikilinks]]`

## 7. Report

```
Weekly review for {date_start} to {date_end}:
- {n} daily notes processed
- {n} decisions referenced
- {n} references captured
- {n} projects with activity
- YAML written to: activity/weeks/{date_start}.yml
{if narrative: Journal written to: notes/journal/{date_start}-journal-weekly.md}
{if warnings: Warnings: ...}
```
