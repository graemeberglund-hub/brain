# /design-review — Post-Implementation Visual Audit

Audits the rendered output of an implemented UI. Uses browser tools to screenshot, inspect, and find visual quality issues. Fixes what it finds directly in code.

Unlike `/plan-design-review` (which reviews the plan), this reviews what was actually built.

## Trigger

User says: "design review", "visual audit", "check how this looks", "audit the UI", "does this look right"

## Prerequisites

- The app must be running and accessible at a URL (local or remote)
- Browser tools MCP must be available (`mcp__browser-tools__takeScreenshot`, etc.)
- If no browser tools: fall back to reading the source HTML/CSS/JSX directly and auditing structurally (no screenshots)

## Procedure

### Step 1: Screenshot Baseline

Take a screenshot of each key view:
- Primary view (the main screen)
- Empty state (if applicable)
- Error state (if applicable)
- Mobile viewport (375px width)
- Dark mode (if supported)

Use `mcp__browser-tools__takeScreenshot` for each.

### Step 2: Visual Audit Passes

Run each pass against the screenshots and source code:

#### 2a. Spacing & Rhythm
- Is vertical spacing consistent? (check for irregular gaps between sections)
- Is horizontal alignment consistent? (elements that should align but don't)
- Does the spacing follow a scale? (4px/8px/16px/24px/32px or similar)
- Are there any spacing collisions? (elements too close, overlapping, or touching)

#### 2b. Typography Hierarchy
- Is there a clear visual hierarchy? (H1 > H2 > H3 > body > caption)
- Are font sizes, weights, and colors used consistently for the same role?
- Is line height comfortable for reading? (1.4-1.6 for body text)
- Is line length readable? (45-75 characters per line)

#### 2c. Color & Contrast
- Do colors match the design system/style tokens?
- Is text readable against its background? (WCAG AA: 4.5:1 for normal text)
- Are interactive elements visually distinct from static elements?
- Is the color palette cohesive or does it feel random?

#### 2d. Interactive States
- Do buttons have hover/focus/active/disabled states?
- Are focus indicators visible for keyboard navigation?
- Do links look like links?
- Are loading states present where data is fetched?

#### 2e. Layout Integrity
- Does the layout work at the viewport sizes specified?
- Are there horizontal scrollbars that shouldn't exist?
- Do images/media maintain aspect ratio?
- Is content clipped or overflowing its container?

#### 2f. AI Slop Check
Same 6 patterns from the `/style` skill slop detector:
1. Purple gradients
2. 3-column icon grids
3. Icons in colored circles
4. Centered everything (>60% of sections)
5. Uniform bubbly radius (>12px everywhere)
6. Generic hero copy ("Revolutionize", "Transform", "Seamlessly")

### Step 3: Fix

For each finding:
1. Classify severity: **critical** (broken/unusable), **important** (noticeable quality issue), **polish** (minor refinement)
2. Fix critical and important issues directly in source code
3. Take an after-screenshot to verify the fix
4. Log each fix as an atomic change (one finding = one edit)

### Step 4: Report

```markdown
## Design Review: {project/page}

### Health Score: {0-100}
{Weighted: critical findings = -20 each, important = -10, polish = -3}

### Findings & Fixes

| # | Severity | Finding | Fixed? | Before/After |
|---|----------|---------|--------|-------------|
| 1 | critical | {description} | yes | {screenshot refs} |
| 2 | important | {description} | yes | {screenshot refs} |
| 3 | polish | {description} | no (manual) | — |

### Slop Score: {0-6 patterns detected}
{List any AI slop patterns found}

### Remaining Issues
{Anything that requires manual intervention — design decisions, content changes, etc.}
```

## Fallback Mode (No Browser Tools)

If browser MCP tools are unavailable:

1. Read all HTML/CSS/JSX/TSX files in the target directory
2. Run structural checks:
   - Spacing: grep for inconsistent margin/padding values
   - Typography: check for more than 4 font-size values, inconsistent weights
   - Color: check for hardcoded color values outside the design system
   - States: check that interactive elements have hover/focus styles
   - Slop: run the 6-pattern slop detector from source
3. Report findings with file:line references instead of screenshots
4. Fix what can be fixed structurally

## Rules

- Fix code, don't just report. This is a designer who codes, not a designer who files tickets.
- Atomic changes. One finding = one edit. Don't bundle fixes.
- Don't change functionality. Visual fixes only — spacing, colors, typography, states.
- Respect the design system. If a style file exists, use its tokens. Don't invent new values.
- If you're unsure whether something is a bug or a design choice, ask before fixing.
