#!/bin/bash
# PostCompact hook — re-inject vault runtime context after compaction
# Complements pre-compact-context.sh (which injects conventions before compaction)

BRAIN_DIR="$(git rev-parse --show-toplevel)"
TODAY=$(date +%Y-%m-%d)
DAILY_NOTE="$BRAIN_DIR/notes/daily/$TODAY.md"

echo "=== Brain Vault Context (Post-Compact) ==="

# Daily note status
if [ -f "$DAILY_NOTE" ]; then
    LINES=$(wc -l < "$DAILY_NOTE" | tr -d ' ')
    echo "Daily note: $DAILY_NOTE ($LINES lines)"
else
    echo "Daily note: not yet created for $TODAY"
fi

# Inbox depth
INBOX_COUNT=$(find "$BRAIN_DIR/notes/inbox" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
echo "Inbox: $INBOX_COUNT note(s) pending triage"

# Active workstreams
if [ -d "$BRAIN_DIR/.claude/workstreams" ]; then
    echo ""
    echo "Active workstreams:"
    for manifest in "$BRAIN_DIR/.claude/workstreams"/*/manifest.yml; do
        if [ -f "$manifest" ]; then
            WS_NAME=$(basename "$(dirname "$manifest")")
            echo "  - $WS_NAME"
        fi
    done
fi

# Last handoff context (if exists and recent)
HANDOFF="$BRAIN_DIR/knowledge/last-handoff.md"
if [ -f "$HANDOFF" ]; then
    HANDOFF_AGE=$(( ($(date +%s) - $(stat -f %m "$HANDOFF")) / 3600 ))
    if [ "$HANDOFF_AGE" -lt 24 ]; then
        echo ""
        echo "Last handoff (<${HANDOFF_AGE}h ago): $HANDOFF"
    fi
fi

echo ""
echo "Key paths: notes/positions/, notes/daily/, knowledge/epistemic-ledger.jsonl"
echo "Skills: /capture, /position, /question, /decision, /reference, /digest, /triage, /sync, /handoff, /boot"
echo "=========================="
