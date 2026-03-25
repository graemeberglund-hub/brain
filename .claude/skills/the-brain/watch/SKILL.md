---
name: watch
description: "Monitor files, URLs, or RSS feeds for changes — creates inbox notes when sources update. Use when setting up automated intake from external sources."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *), Bash(mkdir *), Bash(curl *), Bash(shasum *), Bash(diff *), Bash(wc *), AskUserQuestion
argument-hint: "add url|file|rss 'target' [--interval 1h] | list | check | remove 'target'"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`
Vault root: /Users/graeme/Desktop/DEVELOPMENT/brain

(At start of execution, use Read to check: whether .claude/automation/watches.yml exists and count watch entries in it.)

# /watch — Event-Driven Intake Monitor

You are managing a watch list of external sources. When monitored sources change, inbox notes are created automatically. This turns the vault from pull-only to event-driven.

## Commands

### `add` — Register a new watch target

Parse: `add {type} '{target}' [--interval {duration}] [--label {name}]`

Types:
- **url** — web page. Track content changes via hash comparison.
- **file** — local file. Track modification time or content hash.
- **rss** — RSS/Atom feed. Track new entries.

Create or update `.claude/automation/watches.yml`:

```yaml
# watches.yml — monitored sources for event-driven intake
# Checked by: /watch check (manual) or launchd scheduler
updated: {today}

watches:
  - target: "{url or path}"
    type: "{url|file|rss}"
    label: "{human-readable name}"
    interval: "{1h|6h|1d|1w}"
    added: "{today}"
    last_checked: null
    last_hash: null
    last_change: null
    notify: inbox  # inbox | daily | both
```

Default interval: `1d` for URLs, `1h` for files, `6h` for RSS.

### `list` — Show all watches

Read `watches.yml` and display:

```
=== Active Watches ===

{label} ({type})
  Target: {target}
  Interval: {interval}
  Last checked: {date or "never"}
  Last change: {date or "never"}
  Status: {active|stale|error}

Total: {count} watches
```

### `check` — Run all watches now

For each watch entry:

**URL type:**
1. Fetch the URL content: `curl -sL '{url}'`
2. Hash the content: `echo '{content}' | shasum -a 256`
3. Compare against `last_hash` in watches.yml
4. If different → create inbox note, update hash and timestamps

**File type:**
1. Check file modification time
2. Hash content if modified
3. Compare against stored hash
4. If different → create inbox note, update timestamps

**RSS type:**
1. Fetch the feed
2. Parse for entries newer than `last_checked`
3. For each new entry → create inbox note

**Inbox note format:**

```yaml
---
title: "Watch: {label} changed"
type: inbox
tags: [watch, {type}, {label-slug}]
created: {today}
source_type: watch
watch_target: "{target}"
---

## Change Detected

- **Source:** {target}
- **Type:** {type}
- **Detected:** {timestamp}

## Content
{For URLs: brief diff summary or new content excerpt}
{For files: what changed}
{For RSS: new entry titles and links}
```

Update `watches.yml` with new `last_checked`, `last_hash`, `last_change` values.

### `remove` — Remove a watch

Find the watch by target or label, remove from `watches.yml`.

## Check Output

```
=== Watch Check — {date} {time} ===

Checked: {count} watches
Changed: {count}
{For each change: "- {label}: changed → inbox note created"}
Errors: {count}
{For each error: "- {label}: {error}"}

Next suggested check: {based on shortest interval}
```

## Scheduler Integration Note

This skill runs on-demand via `/watch check`. For automated scheduling, the user should create a launchd job that runs `/watch check` at the shortest watch interval. Future enhancement: auto-generate the plist file.
