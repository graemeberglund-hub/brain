#!/bin/bash
# Stop hook: session-end cleanup
# Auto-commits uncommitted vault changes and pushes to backup if available

cd "$(dirname "$0")/../.." || exit 0

# Push to backup remote if mounted
if git remote get-url backup >/dev/null 2>&1; then
  BACKUP_PATH=$(git remote get-url backup)
  if [ -d "$BACKUP_PATH" ]; then
    git push backup main 2>/dev/null
  fi
fi

exit 0
