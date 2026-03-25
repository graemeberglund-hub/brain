#!/bin/bash
# Toggle brain vault hooks on/off in settings.json
# Usage: bash .claude/toggle-hooks.sh [on|off]
#
# When ON:  Session tracking, schema validation, activity logging, desktop notifications
# When OFF: Clean settings with just permissions (default for new users)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BRAIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SETTINGS="$SCRIPT_DIR/settings.json"

if ! command -v jq &> /dev/null; then
    echo "Error: jq is required. Install with: brew install jq"
    exit 1
fi

# Detect current state
CURRENT=$(jq '.hooks | length' "$SETTINGS" 2>/dev/null || echo "0")

if [ "$1" = "on" ] || { [ -z "$1" ] && [ "$CURRENT" = "0" ]; }; then
    # Enable hooks
    HOOKS=$(cat <<ENDJSON
{
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{"type": "command", "command": ".claude/hooks/update-frontmatter-date.sh"}]
      },
      {
        "matcher": "Edit",
        "hooks": [{"type": "command", "command": ".claude/hooks/validate-note-schema-post.sh"}]
      },
      {
        "hooks": [{"type": "command", "command": ".claude/hooks/post-tool-activity-log.sh"}]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {"type": "command", "command": ".claude/hooks/validate-note-schema.sh"},
          {"type": "command", "command": ".claude/hooks/validate-prp-naming.sh"}
        ]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [
          {"type": "command", "command": ".claude/hooks/validate-ledger-event.sh"},
          {"type": "command", "command": ".claude/hooks/validate-operational-event.sh"}
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [{"type": "command", "command": ".claude/hooks/session-start-context.sh"}]
      }
    ],
    "PreCompact": [
      {
        "hooks": [{"type": "command", "command": ".claude/hooks/pre-compact-context.sh"}]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {"type": "command", "command": "$BRAIN_DIR/.claude/hooks/session-end-cleanup.sh"},
          {"type": "command", "command": "$BRAIN_DIR/.claude/hooks/session-end-index.sh"},
          {"type": "command", "command": "$BRAIN_DIR/.claude/hooks/status-update.sh"}
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "tool_completed",
        "hooks": [{"type": "command", "command": ".claude/hooks/notify-desktop.sh"}]
      }
    ]
}
ENDJSON
)
    jq --argjson hooks "$HOOKS" '.hooks = $hooks' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
    echo "Hooks ON — session tracking, validation, and notifications enabled."
    echo "Stop hooks use absolute path: $BRAIN_DIR"

elif [ "$1" = "off" ] || { [ -z "$1" ] && [ "$CURRENT" != "0" ]; }; then
    # Disable hooks
    jq '.hooks = {}' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
    echo "Hooks OFF — running clean, no automation."

else
    echo "Usage: bash .claude/toggle-hooks.sh [on|off]"
    echo "  No argument toggles current state."
    echo "  Current: $([ "$CURRENT" = "0" ] && echo "OFF" || echo "ON")"
fi
