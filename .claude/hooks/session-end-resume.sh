#!/bin/bash
# Stop hook: auto-write knowledge/last-handoff.md for /pickup
# Zero tokens — pure shell + python. Captures basic resume context from vault state.
# /handoff writes a richer version; this is the safety net when handoff is skipped.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

if [ -z "$SESSION_ID" ]; then
  exit 0
fi

BRAIN_DIR="$(git rev-parse --show-toplevel)"
HANDOFF_FILE="$BRAIN_DIR/knowledge/last-handoff.md"
TODAY=$(date +%Y-%m-%d)
NOW=$(date +%H:%M)
NOW_ISO=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Determine repo slug
REPO_SLUG="unknown"
if [ -n "$CWD" ]; then
  case "$CWD" in
    */brain|*/brain/*) REPO_SLUG="brain" ;;
    *) REPO_SLUG=$(basename "$CWD") ;;
  esac
fi

# Never overwrite a rich /handoff with a basic auto-generated version.
# Check: if existing file was NOT auto-generated, it's from /handoff — preserve it.
if [ -f "$HANDOFF_FILE" ]; then
  IS_AUTO=$(grep "^auto_generated:" "$HANDOFF_FILE" 2>/dev/null | head -1)
  if [ -z "$IS_AUTO" ] || [[ "$IS_AUTO" != *"true"* ]]; then
    # Existing handoff was written by /handoff (rich version) — don't overwrite
    exit 0
  fi
fi

# Extract recent decisions from today's daily note (last 5)
DAILY_NOTE="$BRAIN_DIR/notes/daily/$TODAY.md"
RECENT_DECISIONS=""
if [ -f "$DAILY_NOTE" ]; then
  RECENT_DECISIONS=$(python3 -c "
import sys
in_decisions = False
decisions = []
try:
    with open('$DAILY_NOTE') as f:
        for line in f:
            if line.strip() == '## Decisions':
                in_decisions = True
                continue
            if in_decisions and line.startswith('## '):
                break
            if in_decisions and line.strip().startswith('- '):
                decisions.append(line.strip())
    for d in decisions[-5:]:
        print(d)
except:
    pass
" 2>/dev/null)
fi

# Check for active workstream
WORKSTREAM_STATUS=""
for ws_dir in "$BRAIN_DIR"/.claude/workstreams/*/state/progress.json; do
  if [ -f "$ws_dir" ]; then
    WS_NAME=$(basename "$(dirname "$(dirname "$ws_dir")")")
    WS_STATUS=$(python3 -c "
import json
try:
    progress = json.load(open('$ws_dir'))
    phases = progress.get('phases', {})
    complete = sum(1 for p in phases.values() if p.get('status') == 'complete')
    total = len(phases)
    pending = sum(1 for p in phases.values() if p.get('status') == 'pending')
    print(f'$WS_NAME: {complete}/{total} complete, {pending} pending')
except:
    pass
" 2>/dev/null)
    if [ -n "$WS_STATUS" ]; then
      WORKSTREAM_STATUS="$WS_STATUS"
    fi
  fi
done

# Write the basic resume file
cat > "$HANDOFF_FILE" << HEREDOC
---
session_end: "${TODAY}T${NOW}"
repo: "${REPO_SLUG}"
auto_generated: true
---

# Resume — ${TODAY} at ${NOW}

## What happened
(Auto-captured by SessionEnd hook — run /handoff for richer context)

## Decisions made
${RECENT_DECISIONS:-None captured in daily note}

## Next actions
(Not available — run /handoff to capture next actions explicitly)

## Active workstream
${WORKSTREAM_STATUS:-None detected}

## Files to read for context
- notes/daily/${TODAY}.md
HEREDOC

# Append to handoff log
python3 -c "
import json
from datetime import datetime
entry = {
    'timestamp': '$NOW_ISO',
    'repo': '$REPO_SLUG',
    'decisions': 0,
    'next_actions': [],
    'workstream': None,
    'workstream_phases_completed': [],
    'session_summary': '(auto-captured by SessionEnd hook)',
    'auto_generated': True,
}
with open('$BRAIN_DIR/knowledge/handoff-log.jsonl', 'a') as f:
    f.write(json.dumps(entry) + '\n')
" 2>/dev/null

exit 0
