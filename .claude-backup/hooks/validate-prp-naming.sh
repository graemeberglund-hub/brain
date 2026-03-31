#!/bin/bash
# PreToolUse hook: validate PRP naming convention on Write
# Enforces Convention v2: YYYY-MM-DD-prp-{slug}.md
# Exit 2 = block the write; exit 0 = allow

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only validate Write tool
if [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

# Only validate files directly under PRPs/ (not in subdirs like completed/)
case "$FILE_PATH" in
  */PRPs/*.md) ;;
  *) exit 0 ;;
esac

# Skip files in subdirectories (completed/, in_progress/, etc.)
BASENAME=$(basename "$FILE_PATH")
DIRNAME=$(dirname "$FILE_PATH")
DIRNAME_BASENAME=$(basename "$DIRNAME")
if [ "$DIRNAME_BASENAME" != "PRPs" ]; then
  exit 0
fi

# Validate naming convention: YYYY-MM-DD-prp-{slug}.md
if ! echo "$BASENAME" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}-prp-[a-z0-9]([a-z0-9-]*[a-z0-9])?\.md$'; then
  echo "BLOCKED: PRP filename '$BASENAME' doesn't follow Convention v2." >&2
  echo "Required format: YYYY-MM-DD-prp-{slug}.md (e.g., 2026-03-24-prp-my-feature.md)" >&2
  exit 2
fi

exit 0
