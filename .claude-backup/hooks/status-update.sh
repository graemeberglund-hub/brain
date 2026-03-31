#!/bin/bash
# Stop hook: update STATUS.md in the session's repo
# Two layers: mechanical (always, 0 tokens) + intent (best-effort claude --print)
# Also supports CLI mode: status-update.sh --mechanical-only --cwd /path

BRAIN_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
TODAY=$(date +%Y-%m-%d)
NOW_TS=$(date +%Y-%m-%dT%H:%M:%S)
MECHANICAL_ONLY=false

# --- Mode detection ---
if [ "$1" = "--mechanical-only" ] && [ "$2" = "--cwd" ] && [ -n "$3" ]; then
  CWD="$3"
  SESSION_ID="recovery"
  STOP_HOOK_ACTIVE="false"
  MECHANICAL_ONLY=true
else
  # Stop hook mode: read JSON from stdin
  INPUT=$(cat)
  SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
  CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
  STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
fi

# --- Guards ---
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

if [ -z "$CWD" ]; then
  exit 0
fi

STATUS_FILE="$CWD/STATUS.md"

if [ ! -f "$STATUS_FILE" ]; then
  exit 0
fi

# Skip brain — its STATUS.md has a different structure and is manually maintained
case "$CWD" in
  */brain|*/brain/*)
    exit 0
    ;;
esac

# --- MECHANICAL LAYER (always runs, 0 tokens) ---

cd "$CWD" || exit 0

# Gather git facts
LAST_COMMIT_DATE=$(git log -1 --format=%ci 2>/dev/null | cut -c1-16 || echo "none")
ACTIVE_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
COMMITS_7D=$(git log --oneline --since="7 days ago" 2>/dev/null | wc -l | tr -d ' ')
FILES_7D=$(git log --since="7 days ago" --name-only --pretty=format: 2>/dev/null | sort -u | grep -c . 2>/dev/null || echo "0")
RECENT_COMMITS=$(git log --oneline -5 2>/dev/null || echo "")

# Build recent commits list
RECENT_LINES=""
if [ -n "$RECENT_COMMITS" ]; then
  while IFS= read -r line; do
    HASH="${line%% *}"
    MSG="${line#* }"
    RECENT_LINES="${RECENT_LINES}- \`${HASH}\` ${MSG}
"
  done <<< "$RECENT_COMMITS"
fi

# Build State section
STATE_SECTION="## State
<!-- AUTO-UPDATED by status-update.sh — do not edit -->
| Metric | Value |
|--------|-------|
| Last commit | ${LAST_COMMIT_DATE} |
| Active branch | ${ACTIVE_BRANCH} |
| Commits (7d) | ${COMMITS_7D} |
| Files changed (7d) | ${FILES_7D} |

### Recent
${RECENT_LINES}
_Updated: ${NOW_TS}_
"

# Replace ## State section in STATUS.md
export STATUS_FILE
export STATE_SECTION
python3 << 'PYEOF'
import re, sys, os

status_file = os.environ.get("STATUS_FILE", "")
state_section = os.environ.get("STATE_SECTION", "")

if not status_file or not os.path.isfile(status_file):
    sys.exit(0)

with open(status_file, 'r') as f:
    content = f.read()

# Match from '## State' to the next '## ' heading (exclusive) or EOF
pattern = r'## State\n.*?(?=\n## |\Z)'
if re.search(pattern, content, re.DOTALL):
    content = re.sub(pattern, state_section, content, count=1, flags=re.DOTALL)
else:
    # No existing ## State — insert after first heading + description block
    lines = content.split('\n')
    insert_idx = len(lines)
    for i, line in enumerate(lines):
        if i < 2:
            continue
        if line.startswith('## '):
            insert_idx = i
            break
    lines.insert(insert_idx, '\n' + state_section + '\n')
    content = '\n'.join(lines)

with open(status_file, 'w') as f:
    f.write(content)
PYEOF

# --- INTENT LAYER (best-effort, uses claude --print) ---

if [ "$MECHANICAL_ONLY" = "true" ]; then
  exit 0
fi

# Find session activity log
ACTIVITY_LOG="$BRAIN_DIR/knowledge/session-activity/$TODAY-$SESSION_ID.log"
if [ ! -f "$ACTIVITY_LOG" ]; then
  # Try most recent log for today
  ACTIVITY_LOG=$(ls -t "$BRAIN_DIR/knowledge/session-activity/$TODAY"-*.log 2>/dev/null | head -1)
fi

# Build context
ACTIVITY_TAIL=""
if [ -n "$ACTIVITY_LOG" ] && [ -f "$ACTIVITY_LOG" ]; then
  ACTIVITY_TAIL=$(tail -50 "$ACTIVITY_LOG" 2>/dev/null)
fi
GIT_LOG_SHORT=$(git log --oneline -10 2>/dev/null)
GIT_DIFF_STAT=$(git diff --stat HEAD~3 HEAD 2>/dev/null | tail -20)
CURRENT_STATUS=$(cat "$STATUS_FILE" 2>/dev/null)

# Only attempt if we have context
if [ -z "$ACTIVITY_TAIL" ] && [ -z "$GIT_LOG_SHORT" ]; then
  exit 0
fi

# Call claude --print with full STATUS.md context for substantive updates
PROMPT="You are auto-updating a repo's STATUS.md after a session ended. You have the current STATUS.md, session activity, and recent commits.

Your job: produce a COMPLETE updated STATUS.md that:
1. Updates the ## Session section with Now/Next/Blocked based on what happened
2. Updates ANY substantive sections where the session's work changed the status (e.g., validation items moving from PARTIALLY RESOLVED to RESOLVED, new findings, completed experiments)
3. Preserves all sections you have no evidence to change — do NOT remove or rewrite content speculatively
4. Keeps ## State and ## Change Log sections exactly as-is (mechanical layer handles State)

Rules:
- Only update items where session activity or commits provide clear evidence of change
- If unsure whether something changed, leave it alone
- Keep the same markdown structure and formatting
- Add _Auto-updated: ${NOW_TS}_ at the bottom of ## Session

CURRENT STATUS.md:
${CURRENT_STATUS}

Session activity (last 50 tool calls):
${ACTIVITY_TAIL}

Recent commits:
${GIT_LOG_SHORT}

Files changed (last 3 commits):
${GIT_DIFF_STAT}

Respond with ONLY the complete updated STATUS.md content. No preamble, no code fences."

UPDATED=$(echo "$PROMPT" | timeout 30 claude -p --bare --model sonnet --output-format text 2>/dev/null)
CLAUDE_EXIT=$?

# If claude --print failed or timed out, fall back to Session-only update
if [ $CLAUDE_EXIT -ne 0 ] || [ -z "$UPDATED" ]; then
  # Fallback: just update Session with a simpler prompt
  FALLBACK_PROMPT="Based on the session activity and commits below, write exactly 3 lines:
NOW: [what was being worked on — 1 sentence]
NEXT: [what should happen next — 1 sentence]
BLOCKED: [any blockers, or 'None']

Session activity (last 50 tool calls):
${ACTIVITY_TAIL}

Recent commits:
${GIT_LOG_SHORT}

Respond with ONLY the 3 lines. No preamble."

  INTENT=$(echo "$FALLBACK_PROMPT" | timeout 15 claude -p --bare --model sonnet --output-format text 2>/dev/null)
  CLAUDE_EXIT=$?

  if [ $CLAUDE_EXIT -ne 0 ] || [ -z "$INTENT" ]; then
    exit 0
  fi

  FORMATTED_INTENT=$(echo "$INTENT" | sed 's/^NOW:/**Now**:/' | sed 's/^NEXT:/**Next**:/' | sed 's/^BLOCKED:/**Blocked**:/')

  SESSION_SECTION="## Session
<!-- AUTO-UPDATED by status-update.sh intent layer or /handoff -->
${FORMATTED_INTENT}

_Source: auto-fallback | ${NOW_TS}_"

  export STATUS_FILE
  export SESSION_SECTION
  python3 << 'PYEOF'
import re, sys, os

status_file = os.environ.get("STATUS_FILE", "")
session_section = os.environ.get("SESSION_SECTION", "")

if not status_file or not os.path.isfile(status_file):
    sys.exit(0)

with open(status_file, 'r') as f:
    content = f.read()

pattern = r'## Session\n.*?(?=\n## |\Z)'
if re.search(pattern, content, re.DOTALL):
    content = re.sub(pattern, session_section, content, count=1, flags=re.DOTALL)
else:
    state_match = re.search(r'_Updated: [^_]+_', content)
    if state_match:
        insert_pos = state_match.end()
        content = content[:insert_pos] + '\n\n' + session_section + '\n' + content[insert_pos:]
    else:
        content += '\n\n' + session_section + '\n'

with open(status_file, 'w') as f:
    f.write(content)
PYEOF

  exit 0
fi

# Sanity check: updated content should contain key structural markers
# If sonnet hallucinated or produced garbage, fall back silently
if ! echo "$UPDATED" | grep -q "## Session"; then
  exit 0
fi

# Additional guard: updated content should be at least 50% the length of original
# (prevents sonnet from accidentally truncating the file)
ORIG_LEN=${#CURRENT_STATUS}
NEW_LEN=${#UPDATED}
if [ "$ORIG_LEN" -gt 0 ] && [ "$NEW_LEN" -lt $((ORIG_LEN / 2)) ]; then
  exit 0
fi

# Write the updated STATUS.md
echo "$UPDATED" > "$STATUS_FILE"

exit 0
