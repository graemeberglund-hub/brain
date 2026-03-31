#!/bin/bash
# freeze.sh — Edit scope lock hook
# Blocks Edit and Write tool calls to files outside the frozen directory.
# Activated by writing a path to ~/.claude/freeze-scope
# Deactivated by deleting ~/.claude/freeze-scope

FREEZE_FILE="$HOME/.claude/freeze-scope"

# If no freeze file exists, allow everything
if [ ! -f "$FREEZE_FILE" ]; then
  exit 0
fi

ALLOWED_DIR=$(cat "$FREEZE_FILE")

# Read the tool input from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check Edit and Write tools
if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

# If no file_path in the tool input, allow (shouldn't happen but be safe)
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Check if the file path starts with the allowed directory
case "$FILE_PATH" in
  "$ALLOWED_DIR"*)
    exit 0
    ;;
  *)
    echo "FREEZE: Edit blocked. Scope locked to: $ALLOWED_DIR"
    echo "File attempted: $FILE_PATH"
    echo "Run /unfreeze to remove the scope lock."
    exit 2
    ;;
esac
