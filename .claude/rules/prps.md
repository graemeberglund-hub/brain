---
paths:
  - "PRPs/**"
---

When editing PRPs:
- Filename must match Convention v2: `YYYY-MM-DD-prp-{slug}.md`
- Required frontmatter: title, type (must be "prp"), status, created
- Must contain: Goal, Scope, and Acceptance Tests sections
- Status values: planning, in_progress, blocked, completed, archived
- When moving to completed: update status and add completion_date to frontmatter
