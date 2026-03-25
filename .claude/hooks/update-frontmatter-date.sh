#!/bin/bash
# PostToolUse hook: auto-update `updated:` frontmatter date on Edit/Write
# Reads tool_input from stdin (JSON), checks if file is under notes/ and not type: daily

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Skip if no file path or not under notes/
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

case "$FILE_PATH" in
  */notes/*) ;;
  */knowledge/modes/*) ;;
  *) exit 0 ;;
esac

# Must be a .md file
case "$FILE_PATH" in
  *.md) ;;
  *) exit 0 ;;
esac

# Skip if file doesn't exist (might have been a failed write)
if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Skip type: daily notes (they have no updated: field)
if grep -q '^type: daily' "$FILE_PATH" 2>/dev/null; then
  exit 0
fi

TODAY=$(date +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)

# Only update if the file has an updated: field and it's not already today
if grep -q '^updated:' "$FILE_PATH" 2>/dev/null; then
  CURRENT=$(grep '^updated:' "$FILE_PATH" | head -1 | sed 's/updated: *//' | tr -d '"')
  if [ "$CURRENT" != "$TODAY" ]; then
    sed -i '' "s/^updated: .*/updated: $TODAY/" "$FILE_PATH"
    echo "Updated frontmatter date to $TODAY in $(basename "$FILE_PATH")"
  fi
fi

exit 0
