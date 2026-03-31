#!/bin/bash
# PostToolUse hook: validate note schema after Edit
# Warns (does not block) if an edit leaves a note with broken frontmatter
# Complements the PreToolUse Write validator — catches edits that break schema

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only validate Edit tool
if [ "$TOOL_NAME" != "Edit" ]; then
  exit 0
fi

# Only validate files under notes/
case "$FILE_PATH" in
  */notes/*) ;;
  *) exit 0 ;;
esac

# Must be a .md file
case "$FILE_PATH" in
  *.md) ;;
  *) exit 0 ;;
esac

# File must exist (edit succeeded)
if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Read the actual file from disk (post-edit state)
CONTENT=$(cat "$FILE_PATH")

# Check for YAML frontmatter delimiters
if ! echo "$CONTENT" | head -1 | grep -q '^---'; then
  echo "WARNING: $(basename "$FILE_PATH") is missing YAML frontmatter (must start with ---)" >&2
  exit 0
fi

# Extract frontmatter (between first and second ---)
FRONTMATTER=$(echo "$CONTENT" | sed -n '2,/^---$/p' | sed '$d')

MISSING=""
for FIELD in title type tags created; do
  if ! echo "$FRONTMATTER" | grep -q "^${FIELD}:"; then
    MISSING="$MISSING $FIELD"
  fi
done

if [ -n "$MISSING" ]; then
  echo "WARNING: $(basename "$FILE_PATH") is missing required frontmatter fields:$MISSING — please fix before committing" >&2
  exit 0
fi

# Validate type
TYPE=$(echo "$FRONTMATTER" | grep '^type:' | sed 's/type: *//' | tr -d '"' | tr -d ' ')
case "$TYPE" in
  project|area|concept|reference|journal|daily|decision|inbox|conversation|position|question) ;;
  *)
    echo "WARNING: $(basename "$FILE_PATH") has invalid note type '$TYPE'" >&2
    exit 0
    ;;
esac

exit 0
