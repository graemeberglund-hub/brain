# Template: .claude/statusline.sh

Statusline shows 3 metrics separated by `|`. Customize labels, directories, and grep patterns to match the domain. Must handle empty state gracefully (no errors when dirs are empty).

---

```bash
#!/bin/bash
# Statusline: {metric1 label} | {metric2 label} | {metric3 label}
cd "$(dirname "$0")/.." || exit 1

# Metric 1: Primary content count
primary=$(find {primary_dir}/ -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

# Metric 2: Last modified date
last_file=$(find {content_dirs} -name "*.md" -exec stat -f '%m %N' {} + 2>/dev/null | sort -rn | head -1 | awk '{print $2}')
if [ -n "$last_file" ]; then
  last_date=$(stat -f '%Sm' -t '%Y-%m-%d' "$last_file" 2>/dev/null)
else
  last_date="none"
fi

# Metric 3: Secondary count
secondary=$(find {secondary_dir}/ -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

echo "{Label1}: ${primary} | Last: ${last_date} | {Label2}: ${secondary}"
```

Key rules:
- `cd "$(dirname "$0")/.."` navigates from `.claude/` to repo root
- Use `stat -f` (macOS) not `stat -c` (Linux)
- `2>/dev/null` on all find/grep to suppress errors on empty dirs
- `tr -d ' '` to trim whitespace from `wc -l` output
- Single `echo` line at the end
