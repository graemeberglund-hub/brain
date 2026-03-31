#!/bin/bash
# Build a portable .claude/ update package for onboarded brain users.
# Run from the brain repo root after any config changes.
# Output: ~/Desktop/brain-claude-update.tar.gz

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
OUT="$HOME/Desktop/brain-claude-update.tar.gz"

# Verify no hardcoded user paths leaked in
if grep -rl "/Users/ritual" "$REPO_ROOT/.claude/hooks/" "$REPO_ROOT/.claude/settings.json" "$REPO_ROOT/.claude/statusline.sh" 2>/dev/null; then
    echo "ERROR: Hardcoded /Users/ritual paths found. Fix before packaging."
    exit 1
fi

cd "$REPO_ROOT"
tar czf "$OUT" \
    .claude/skills/ \
    .claude/agents/ \
    .claude/hooks/ \
    .claude/rules/ \
    .claude/reference/ \
    .claude/settings.json \
    .claude/statusline.sh \
    .claude/build-update-package.sh

FILE_COUNT=$(tar tzf "$OUT" | wc -l | tr -d ' ')
SIZE=$(du -h "$OUT" | cut -f1)

echo "Built: $OUT ($SIZE, $FILE_COUNT files)"
echo ""
echo "User instructions:"
echo "  1. cd into your brain repo"
echo "  2. mv .claude .claude-backup"
echo "  3. tar xzf ~/Downloads/brain-claude-update.tar.gz"
echo "  4. Start a new Claude Code conversation"
