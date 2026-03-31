#!/bin/bash
# Notification hook: desktop alert on macOS
# Fires when Claude Code sends a notification (e.g., tool completed, permission prompt)

INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Task complete"' 2>/dev/null)

osascript -e "display notification \"$MESSAGE\" with title \"Brain Vault\"" 2>/dev/null

exit 0
