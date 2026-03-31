#!/bin/bash
# Stop hook: write session metadata to knowledge/session-index.jsonl
# Zero tokens — pure shell. Captures session_id, repo, timestamps, message count, size, micro-capture path.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

# Don't run if this is a stop-hook continuation (prevent loops)
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

# Must have session ID
if [ -z "$SESSION_ID" ] || [ -z "$TRANSCRIPT_PATH" ]; then
  exit 0
fi

BRAIN_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
INDEX_FILE="$BRAIN_DIR/knowledge/session-index.jsonl"
TODAY=$(date +%Y-%m-%d)

# Determine repo slug from CWD
REPO_SLUG="unknown"
if [ -n "$CWD" ]; then
  # Check if CWD matches brain
  case "$CWD" in
    */brain|*/brain/*) REPO_SLUG="brain" ;;
    *)
      # Try to match against registered repos
      BASENAME=$(basename "$CWD")
      if [ -f "$BRAIN_DIR/repos/$BASENAME.yml" ]; then
        REPO_SLUG="$BASENAME"
      else
        # Use directory name as slug
        REPO_SLUG="$BASENAME"
      fi
      ;;
  esac
fi

# Expand ~ in transcript path
TRANSCRIPT_PATH="${TRANSCRIPT_PATH/#\~/$HOME}"

# Extract metadata from transcript file
if [ -f "$TRANSCRIPT_PATH" ]; then
  METADATA=$(python3 -c "
import json, os
path = '$TRANSCRIPT_PATH'
size_kb = os.path.getsize(path) // 1024
lines = 0
messages = 0
start_ts = None
end_ts = None
with open(path) as f:
    for line in f:
        lines += 1
        try:
            d = json.loads(line)
            ts = d.get('timestamp')
            if ts:
                if start_ts is None:
                    start_ts = ts
                end_ts = ts
            if d.get('type') == 'user':
                messages += 1
        except:
            continue
print(json.dumps({
    'lines': lines,
    'messages': messages,
    'size_kb': size_kb,
    'start': start_ts,
    'end': end_ts,
}))
" 2>/dev/null)
else
  # Transcript not found — write minimal entry
  METADATA='{"lines":0,"messages":0,"size_kb":0,"start":null,"end":null}'
fi

# Check for micro-capture file
MICRO_CAPTURE=""
for f in "$BRAIN_DIR"/knowledge/session-captures/"$TODAY"-*.jsonl; do
  if [ -f "$f" ]; then
    MICRO_CAPTURE="$f"
  fi
done

# Build index entry
python3 -c "
import json, sys
meta = json.loads('$METADATA')
micro = '$MICRO_CAPTURE' or None
entry = {
    'session_id': '$SESSION_ID',
    'repo': '$REPO_SLUG',
    'repo_path': '$CWD',
    'start': meta.get('start'),
    'end': meta.get('end'),
    'messages': meta.get('messages', 0),
    'lines': meta.get('lines', 0),
    'size_kb': meta.get('size_kb', 0),
    'micro_capture': micro,
    'extracted': False,
    'archived': False,
}
print(json.dumps(entry))
" >> "$INDEX_FILE" 2>/dev/null

exit 0
