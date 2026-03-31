#!/usr/bin/env bash
BRAIN_DIR="$(git rev-parse --show-toplevel)"
TODAY=$(date +%Y-%m-%d)
DAILY_PATH="$BRAIN_DIR/notes/daily/$TODAY.md"
INBOX_DIR="$BRAIN_DIR/notes/inbox"

if [ -f "$DAILY_PATH" ]; then
  LINES=$(wc -l < "$DAILY_PATH" | tr -d ' ')
  DAILY_STATUS="Daily: exists (${LINES}L)"
else
  DAILY_STATUS="Daily: none"
fi

INBOX_COUNT=$(find "$INBOX_DIR" -name "*.md" -not -name ".gitkeep" 2>/dev/null | wc -l | tr -d ' ')

printf "🧠 %s | %s | Inbox: %s\n" "$TODAY" "$DAILY_STATUS" "$INBOX_COUNT"
