---
name: notify
description: "Send alerts when vault conditions are met — inbox overflow, stale positions, missed schedules. Use when setting up push-based vault monitoring."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date *), Bash(ls *), Bash(wc *), Bash(osascript *), Bash(mkdir *), Skill
argument-hint: "check | add 'condition' --channel email|desktop|log | list | test"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Current time: !`date +%H:%M`
Vault root: !`echo "$BRAIN_VAULT_PATH"`
Config exists: !`test -f $BRAIN_VAULT_PATH/.claude/automation/notifications.yml && echo "yes" || echo "no"`

# /notify — Push-Based Vault Alerts

You are managing a notification system for vault conditions. When conditions are met, alerts are sent through configured channels. This makes the vault push information to the operator instead of requiring them to check.

## Commands

### `add` — Create a notification rule

Parse: `add '{condition}' --channel {channel} [--threshold {value}] [--cooldown {duration}]`

**Built-in conditions:**
- `inbox-overflow` — inbox note count exceeds threshold (default: 10)
- `stale-positions` — positions not updated in N days (default: 30)
- `aging-questions` — open questions older than N days (default: 30)
- `scheduler-miss` — a scheduled job didn't run
- `skill-failure` — a skill produced an error
- `watch-change` — a watched source changed (integrates with /watch)
- `graph-stale` — knowledge graph files older than N days (default: 7)
- `repeated-rejection` — a single skill has 3+ rejections in last 7 days with 0 accepts in the same period (default threshold: 3 rejections)
- `position-under-pressure` — challenge-ledger has `challenge_outcome: urgent` in last 24h (default threshold: 1)

**Custom conditions:** Free-text conditions evaluated by checking vault state.

**Channels:**
- `desktop` — macOS notification via osascript
- `email` — via `/gws-gmail` skill (requires GWS setup)
- `log` — append to `knowledge/notification-log.jsonl`
- `daily` — add to daily note under `## Notifications`

Create or update `.claude/automation/notifications.yml`:

```yaml
# notifications.yml — push-based vault alerts
updated: {today}

rules:
  - condition: "{condition-name}"
    threshold: {value}
    channel: "{desktop|email|log|daily}"
    cooldown: "{1h|6h|1d}"  # Don't re-fire within this window
    added: "{today}"
    last_fired: null
    enabled: true
```

### `check` — Evaluate all rules

For each enabled rule:

1. **Evaluate condition** against current vault state:
   - `inbox-overflow`: count files in `notes/inbox/`
   - `stale-positions`: scan `notes/positions/` for old `updated:` dates
   - `aging-questions`: scan `notes/positions/` for `classification: question` with old `stage: open` entries
   - `graph-stale`: check modification dates of `knowledge/graph-*.yml`
   - `repeated-rejection`: read `knowledge/feedback-ledger.jsonl`, group by skill for last 7 days, check if any skill has `rejected` count >= threshold AND `accepted` count == 0
   - `position-under-pressure`: read `knowledge/challenge-ledger.jsonl`, filter last 24h, count entries with `challenge_outcome: "urgent"`

2. **Check cooldown** — if `last_fired` is within `cooldown` window, skip

3. **If condition met and not in cooldown → fire alert:**

**Desktop notification:**
```bash
osascript -e 'display notification "{message}" with title "Brain Vault" subtitle "{condition}"'
```

**Email:**
Invoke `/gws-gmail` to send to configured address.

**Log:**
Append to `knowledge/notification-log.jsonl`:
```json
{"timestamp": "{ISO}", "condition": "{name}", "message": "{detail}", "channel": "{channel}", "fired": true}
```

**Daily note:**
Append under `## Notifications` in today's daily note.

4. **Update `last_fired`** in notifications.yml

### `list` — Show all rules

```
=== Notification Rules ===

{condition} → {channel}
  Threshold: {value}
  Cooldown: {cooldown}
  Last fired: {date or "never"}
  Status: {enabled|disabled|cooldown}

Total: {count} rules ({active} active, {cooldown} in cooldown)
```

### `test` — Fire a test notification on each channel

Send a test alert through each configured channel to verify setup works.

## Check Output

```
=== Notification Check — {date} {time} ===

Rules evaluated: {count}
Alerts fired: {count}
In cooldown: {count}
Conditions clear: {count}

{For each fired alert: "- {condition}: {message} → {channel}"}
```
