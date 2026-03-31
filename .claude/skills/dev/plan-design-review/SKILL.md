# /plan-design-review — Design Plan Review

Reviews design decisions BEFORE implementation. Rates each dimension, checks for AI slop risk, and ensures design system alignment. Catches "looks fine in the plan, looks terrible when built" problems early.

## Trigger

User says: "design review the plan", "review design", "check the design", "is this design solid", or presents a PRP/mockup/wireframe for design review.

## Input

Accepts any of:
- A PRP with UI/UX specifications
- A design doc or wireframe description
- Screenshots or mockups (image files)
- A style file from `~/.claude/styles/`
- Free-text description of intended UI/UX

If a style file exists for the project, load it first — all design decisions are evaluated against the active style.

## Review Dimensions

Rate each dimension 0-10. For anything below 7, explain what a 10 looks like for this specific project.

### 1. Information Architecture (0-10)
- Is content organized by user mental model or by system structure?
- Can the user find what they need without learning the system's internals?
- Is the hierarchy clear? (primary → secondary → tertiary)
- Are labels descriptive or jargon-filled?

### 2. Interaction Coverage (0-10)
- What happens on: first use, empty state, error state, loading state, success state?
- Are all interactive elements described? (hover, focus, active, disabled)
- What happens when the user does something unexpected? (double-click, navigate away, back button, refresh)
- Are transitions between states specified or left to "figure it out during implementation"?

### 3. User Journey (0-10)
- Is there a clear primary flow? (the thing 80% of users do)
- How many steps from entry to value? Can any be removed?
- Are there dead ends? (pages with no next action)
- Is the journey coherent or does it feel like separate features stitched together?

### 4. AI Slop Risk (0-10, inverted — 10 = zero slop)
Check for these patterns that signal "AI designed this":

| Pattern | Signal |
|---------|--------|
| Purple gradients | Default AI color palette |
| 3-column icon grids | "Features section" template |
| Icons in colored circles | Generic feature filler |
| Centered everything | Layout decision avoidance |
| Uniform bubbly radius | "Friendly" default |
| Generic hero copy | Zero-information headlines |
| Card-heavy layouts | Everything-is-a-card syndrome |
| Excessive whitespace | Spacing by vibes, not rhythm |
| Stock illustration style | "Flat illustration with people" |
| Modal overuse | Lazy interaction pattern |

Score: 10 = none detected, 0 = it looks like every AI landing page.

### 5. Design System Alignment (0-10)
- Does the plan reference an existing design system or style?
- Are colors, typography, spacing specified with tokens or ad-hoc values?
- Will the implementation be consistent with existing screens?
- Are new patterns introduced? If so, are they justified?

### 6. Responsive & Accessibility (0-10)
- Are breakpoints specified? (mobile, tablet, desktop at minimum)
- What happens to the layout on a 320px screen?
- Are touch targets large enough? (44x44px minimum)
- Is color contrast sufficient for text? (WCAG AA: 4.5:1 normal, 3:1 large)
- Are interactive elements keyboard-navigable?
- Are images described? Are decorative elements marked as such?

### 7. Unresolved Design Decisions (0-10, inverted — 10 = all resolved)
- Count explicit "TBD" or "figure out later" items
- Count implicit gaps (mentioned but not specified)
- Each unresolved decision is a risk of implementation-time improvisation (which always looks worse)

## Output Format

```markdown
## Design Review: {plan title}

### Scorecard
| Dimension | Score | Note |
|-----------|-------|------|
| Information Architecture | {0-10} | {one-line summary} |
| Interaction Coverage | {0-10} | {one-line summary} |
| User Journey | {0-10} | {one-line summary} |
| AI Slop Risk | {0-10} | {one-line summary} |
| Design System Alignment | {0-10} | {one-line summary} |
| Responsive & Accessibility | {0-10} | {one-line summary} |
| Unresolved Decisions | {0-10} | {one-line summary} |
| **Average** | **{avg}** | |

### What a 10 Looks Like
{For each dimension scoring below 7, describe specifically what a 10 would be for THIS project. Not generic advice — specific to the plan being reviewed.}

### Findings

#### Must Fix (score < 5)
- {specific finding with recommendation}

#### Should Fix (score 5-6)
- {specific finding with recommendation}

#### Polish (score 7-8)
- {specific finding with recommendation}

### Design Decisions Needed
{Interactive — for each unresolved decision, present the trade-off and ask the user to choose.}

1. **{Decision}**: Option A (pros/cons) vs Option B (pros/cons). Which do you prefer?

### Verdict
{APPROVE / REVISE / RETHINK}
```

## Rules

- Review design decisions, not aesthetic taste (unless taste conflicts with the active style system)
- If no style file exists, note it as a finding — design without a system produces inconsistency
- Don't review code. If the user has code, direct them to `/design-review` (post-implementation) instead
- Be specific. "The navigation could be better" is not a finding. "The nav has 12 top-level items — users can hold ~7 in working memory. Group into 4-5 categories." is.
- If the design is genuinely solid, say so and keep the review brief
