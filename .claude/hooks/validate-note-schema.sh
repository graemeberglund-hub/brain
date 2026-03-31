#!/bin/bash
# PreToolUse hook: validate note schema on Write
# Blocks writes to notes/ that are missing required frontmatter fields
# Exit 2 = block the write; exit 0 = allow

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only validate Write tool
if [ "$TOOL_NAME" != "Write" ]; then
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

# Get the content being written
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')

if [ -z "$CONTENT" ]; then
  exit 0
fi

# Check for YAML frontmatter delimiters
if ! echo "$CONTENT" | head -1 | grep -q '^---'; then
  echo "BLOCKED: Note is missing YAML frontmatter (must start with ---)" >&2
  exit 2
fi

# Extract frontmatter (between first and second ---)
FRONTMATTER=$(echo "$CONTENT" | sed -n '2,/^---$/p' | sed '$d')

MISSING=""

# Check required fields
for FIELD in title type tags created; do
  if ! echo "$FRONTMATTER" | grep -q "^${FIELD}:"; then
    MISSING="$MISSING $FIELD"
  fi
done

if [ -n "$MISSING" ]; then
  echo "BLOCKED: Note is missing required frontmatter fields:$MISSING" >&2
  echo "All notes under notes/ require: title, type, tags, created" >&2
  exit 2
fi

# Validate type is one of the allowed values
TYPE=$(echo "$FRONTMATTER" | grep '^type:' | sed 's/type: *//' | tr -d '"' | tr -d ' ')
case "$TYPE" in
  project|area|concept|claim|reference|journal|daily|decision|inbox|conversation|position|question|preference) ;;
  *)
    echo "BLOCKED: Invalid note type '$TYPE'. Must be one of: project, area, concept, claim, reference, journal, daily, decision, inbox, conversation, position, question" >&2
    exit 2
    ;;
esac

exit 0
