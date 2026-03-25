# Template: .claude/hooks/session-start-context.sh

Session start context prints a summary banner when a Claude session opens. Customize sections, directories, and labels to match the domain. Must handle empty state gracefully.

---

```bash
#!/bin/bash
# Session start context: {repo name} summary
cd "$(dirname "$0")/../.." || exit 1

echo "=== {Repo Display Name} Context ==="

# Content counts by directory
echo ""
echo "Contents:"
for dir in {dir1} {dir2} {dir3}; do
  if [ -d "$dir" ]; then
    count=$(find "$dir" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    echo "  ${dir}: ${count} files"
  fi
done

# Recent files (last 5 modified)
echo ""
echo "Recently modified:"
recent=$(find . -name "*.md" -not -path "./.git/*" -not -path "./.claude/*" -exec stat -f '%m %N' {} + 2>/dev/null | sort -rn | head -5)
if [ -n "$recent" ]; then
  echo "$recent" | while read -r ts filepath; do
    date=$(stat -f '%Sm' -t '%Y-%m-%d' "$filepath" 2>/dev/null)
    name=$(basename "$filepath" .md)
    dir=$(dirname "$filepath" | sed 's|^\./||')
    echo "  ${date}: ${dir}/${name}"
  done
else
  echo "  (no files yet — start creating!)"
fi

# Domain-specific summary (customize this section)
echo ""
echo "{Domain-specific section header}:"
# Example: count by status, by type, by category — whatever fits the domain
echo "  (customize per domain)"

echo ""
echo "==============================="
```

Key rules:
- `cd "$(dirname "$0")/../.."` — hooks/ is TWO levels deep from repo root
- `stat -f '%m %N'` for macOS sort-by-mtime, `stat -f '%Sm' -t '%Y-%m-%d'` for display
- Wrap all find/grep in `2>/dev/null`
- `echo "=== ... ==="` banner at start and `"======="` at end
- Handle empty state: always show something helpful even with zero files
