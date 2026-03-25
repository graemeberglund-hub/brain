#!/bin/bash
# SessionStart hook: bootstrap daily context
# Outputs daily note status + inbox count to stdout (injected into context)

BRAIN_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
TODAY=$(date +%Y-%m-%d)
DAILY_PATH="$BRAIN_DIR/notes/daily/$TODAY.md"
INBOX_DIR="$BRAIN_DIR/notes/inbox"

echo "=== Brain Vault Context ==="

# Daily note status
if [ -f "$DAILY_PATH" ]; then
  LINES=$(wc -l < "$DAILY_PATH" | tr -d ' ')
  echo "Daily note: exists ($DAILY_PATH, ${LINES} lines)"
else
  echo "Daily note: not yet created (notes/daily/$TODAY.md)"
fi

# Inbox count
if [ -d "$INBOX_DIR" ]; then
  INBOX_COUNT=$(find "$INBOX_DIR" -name "*.md" -not -name ".gitkeep" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$INBOX_COUNT" -gt 0 ]; then
    echo "Inbox: $INBOX_COUNT note(s) pending triage"
  else
    echo "Inbox: empty"
  fi
else
  echo "Inbox: directory not found"
fi

# Recent activity
RECENT_DAILY=$(ls "$BRAIN_DIR/notes/daily/"*.md 2>/dev/null | sort | tail -3 | xargs -I{} basename {} .md | tr '\n' ', ' | sed 's/,$//' || true)
if [ -n "$RECENT_DAILY" ]; then
  echo "Recent daily notes: $RECENT_DAILY"
fi

echo "=========================="

# --- Crash recovery: stale STATUS.md detection ---
STATUS_FILE="$PWD/STATUS.md"
if [ -f "$STATUS_FILE" ]; then
  LAST_UPDATED=$(grep -o '_Updated: [^_]*_' "$STATUS_FILE" 2>/dev/null | head -1 | sed 's/_Updated: //;s/_//')
  if [ -n "$LAST_UPDATED" ]; then
    LAST_COMMIT=$(git log -1 --format=%ci 2>/dev/null | cut -c1-19 | tr ' ' 'T')
    if [ -n "$LAST_COMMIT" ] && [[ "$LAST_COMMIT" > "$LAST_UPDATED" ]]; then
      # STATUS.md is stale — run mechanical-only recovery silently
      bash "$BRAIN_DIR/.claude/hooks/status-update.sh" --mechanical-only --cwd "$PWD" >/dev/null 2>&1
      echo "STATUS.md: recovered (was stale since $LAST_UPDATED)"
    fi
  fi
fi

exit 0
