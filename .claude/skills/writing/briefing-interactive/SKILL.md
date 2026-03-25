---
name: briefing
description: Convert markdown documents with embedded questions into interactive HTML briefings with fillable answer boxes, copy-to-clipboard, and email-to-recipient. Use when user says "briefing", "interactive doc", "questions for [person]", or wants a document someone can fill out and send back.
allowed-tools: Read, Write, Glob, Bash(date *), Bash(ls *), Bash(mkdir *)
argument-hint: "<source-file> [to <recipient-name> <recipient-email>]"
---

input = $ARGUMENTS

Style file: !`test -f ~/.claude/styles/clean-90s.md && echo "~/.claude/styles/clean-90s.md exists" || echo "MISSING — will use fallback palette"`
Brand file: !`test -f brand/brand.md && echo "brand/brand.md exists — READ THIS for brand alignment" || echo "no brand/brand.md found"`

# /briefing — Interactive Document with Fillable Questions

Convert a markdown document containing questions or decision points into a self-contained, mobile-friendly HTML briefing with interactive answer boxes, auto-save, copy-to-clipboard, and optional email-to-recipient.

## 1. Parse arguments

Parse `$ARGUMENTS` to determine:
- **Source file**: path to the markdown file to convert
- **Recipient name**: if specified after `to` or `for`, e.g., `to Aron` or `for Sarah`. Used in the title and email button label.
- **Recipient email**: if an email address is provided, e.g., `jarett@example.com`. Used for the "Email" button's `mailto:` link.
- **Output dir**: if specified after `->`, use that. Otherwise default to `studio/readable/` relative to the project root.
- **Style override**: if specified with `style <name>` or `--style <name>`, use `~/.claude/styles/<name>.md` instead of auto-detection.

If no recipient email is provided, omit the email button and only show the copy button.

Create the output directory if it doesn't exist.

## 2. Read the source and style

Read the source markdown file.

### Style resolution (in priority order):
1. **Explicit style override**: if the user specified `style <name>` in the arguments, read `~/.claude/styles/<name>.md`
2. **Project brand**: if `brand/brand.md` exists in the project root, read it. Extract the client's palette (primary accent color, secondary colors), typography preferences, and voice/tone. Use these to override the base style's accent colors — e.g., replace `--ink-blue` or `--ink-green` with the brand's primary color. Add a `--brand-*` CSS custom property for each extracted brand color.
3. **Base style**: read `~/.claude/styles/clean-90s.md` for the structural design tokens (layout, spacing, surfaces, dark/light modes). The base style provides the skeleton; the brand provides the accent.

**Brand alignment rules:**
- The brand's primary color replaces `ink-blue` as the main accent (h3 color, textarea focus, callout borders, success states, answer labels)
- Keep semantic colors (ink-red for errors/warnings, ink-amber for decisions) unless the brand explicitly conflicts
- Add `--brand-*` CSS variables in both `:root` and `[data-theme="dark"]` (auto-generate a lighter variant for dark mode by increasing lightness ~15%)
- The brand's voice/tone notes should inform placeholder text style and any editorial framing

If no style override AND no brand file exist, read `~/.claude/styles/clean-90s.md`. If that's also missing, use fallback:

```
bg: #f5f0e8, bg-panel: #faf7f2, text: #1a1a18
muted: rgba(26,26,24,.65), faint: rgba(26,26,24,.40)
ink-blue: #4a6fa5, ink-amber: #9e7c3a, ink-red: #a85656, ink-green: #4d8a74
ink-gold: #b8960c, ink-stone: #8a7d6b, ink-purple: #7b6bab
border: rgba(26,26,24,.10), border-strong: rgba(26,26,24,.18), bg-2: #ede8df
serif: 'Instrument Serif', Georgia, serif
sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif
```

## 3. Identify questions and decisions

Scan the source document for interactive elements. These are any content that asks the reader to respond, decide, or provide input. Look for:

### Question patterns
- Lines or sections phrased as direct questions to the reader (e.g., "What is your...?", "How many...?", "Can you...?")
- Sections with headers like "Questions for [Name]", "Key Questions", "What We Need From You"
- Blockquotes or callouts that frame questions with context + the actual question
- Numbered or bulleted lists of questions

### Decision patterns
- Either/or choices the reader needs to make (e.g., "Option A vs Option B")
- Sections with headers like "Decisions Needed", "Your Call", "Choose"
- Content that presents trade-offs and asks for a preference

### Notes / open-ended
- Sections asking for "general thoughts", "reactions", "anything else", "notes"

For each detected item, extract:
- **name**: a short identifier (q1, q2, d1, d2, notes, etc.)
- **label**: the question text (short version for the submit summary)
- **section**: QUESTIONS, DECISIONS, or NOTES
- **context**: any surrounding explanation ("why we're asking this")
- **placeholder**: a helpful prompt for the textarea (specific to the question, not generic)

## 4. Build the HTML

Create a self-contained HTML document following the `/readable` conversion rules for all non-interactive content, plus these interactive elements. **Design quality bar**: the output must feel like a consulting-firm deliverable, not a form. Every section should have visual presence, motion, and clear hierarchy.

### Hero section (REQUIRED)

Every briefing starts with a hero. Never just text on a flat background.

```html
<section class="hero">
  <div class="hero-badge">CONFIDENTIAL</div>
  <h1 class="hero-title">{Document Title} for <em>{Recipient Name}</em></h1>
  <p class="hero-subtitle">{brief context line}</p>
  <div class="hero-meta">
    <span>From: {sender}</span>
    <span class="meta-sep">·</span>
    <span>For: {recipient}</span>
    <span class="meta-sep">·</span>
    <span>{date}</span>
    <span class="meta-sep">·</span>
    <span>{N} fields</span>
  </div>
</section>
```

### Stats ribbon (when source has metrics/stats)

If the source document contains stats, metrics, or key numbers, render them as an overlapping animated ribbon:

```html
<section class="stats-ribbon reveal">
  <div class="stat-card">
    <div class="stat-value" data-target="{number}">{number}</div>
    <div class="stat-label">{label}</div>
  </div>
  <!-- repeat for each stat -->
</section>
```

### Tier overview (when questions are grouped/tiered)

If questions have tiers, categories, or priority groups, render visual tier cards before the question sections:

```html
<section class="tier-overview reveal">
  <div class="tier-card" data-tier="{tier-name}">
    <div class="tier-watermark">{number}</div>
    <div class="tier-strip"></div>
    <h3 class="tier-title">{Tier Name}</h3>
    <p class="tier-desc">{description}</p>
    <span class="tier-tag">{N} questions</span>
  </div>
</section>
```

### Question cards

```html
<div class="q-card reveal" data-name="{name}">
  <div class="q-top">
    <div class="q-badge">{number}</div>
    <div class="q-header">
      <div class="q-counter">Question {n} of {total}</div>
      <h3 class="q-title">{question text}</h3>
    </div>
  </div>
  <div class="q-context">{context if available}</div>
  <div class="q-need">{what we need / why this matters}</div>
  <div class="q-why">{why we're asking}</div>
  <div class="q-answer">
    <label class="q-answer-label">Your answer</label>
    <textarea name="{name}" placeholder="{specific placeholder}"></textarea>
    <div class="q-check">
      <svg width="18" height="18" viewBox="0 0 18 18"><circle cx="9" cy="9" r="8" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M5.5 9l2.5 2.5 4.5-4.5" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
    </div>
  </div>
</div>
```

### Decision cards

```html
<div class="q-card decision-card reveal" data-name="{name}">
  <div class="q-top">
    <div class="q-badge decision-badge">{number}</div>
    <div class="q-header">
      <div class="q-counter">Decision {n}</div>
      <h3 class="q-title">{decision text}</h3>
    </div>
  </div>
  <div class="q-context">{options/trade-offs if available}</div>
  <div class="q-answer">
    <label class="q-answer-label decision-label">Your call</label>
    <textarea name="{name}" placeholder="{specific placeholder}"></textarea>
    <div class="q-check">
      <svg width="18" height="18" viewBox="0 0 18 18"><circle cx="9" cy="9" r="8" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M5.5 9l2.5 2.5 4.5-4.5" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
    </div>
  </div>
</div>
```

### Notes section

```html
<div class="q-card notes-card reveal" data-name="notes">
  <div class="q-top">
    <div class="q-badge">✎</div>
    <div class="q-header">
      <div class="q-counter">Open response</div>
      <h3 class="q-title">{hint text}</h3>
    </div>
  </div>
  <div class="q-answer">
    <label class="q-answer-label">Your notes</label>
    <textarea name="notes" placeholder="{placeholder}"></textarea>
    <div class="q-check">
      <svg width="18" height="18" viewBox="0 0 18 18"><circle cx="9" cy="9" r="8" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M5.5 9l2.5 2.5 4.5-4.5" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
    </div>
  </div>
</div>
```

### Signature block (REQUIRED)

Every briefing ends with a signature before the submit bar:

```html
<section class="signature reveal">
  <div class="sig-line"></div>
  <div class="sig-name">{Sender Name}</div>
  <div class="sig-email">{sender email}</div>
</section>
```

### Sticky header with progress ring

```html
<header class="sticky-header" id="stickyHeader">
  <div class="header-brand">
    <div class="brand-mark">{Initial}</div>
    <span class="header-title">{Short title}</span>
  </div>
  <div class="header-progress">
    <svg class="mini-ring" width="28" height="28" viewBox="0 0 28 28">
      <circle cx="14" cy="14" r="11" fill="none" stroke="var(--border)" stroke-width="2.5"/>
      <circle class="mini-ring-fill" cx="14" cy="14" r="11" fill="none" stroke="var(--brand-green)" stroke-width="2.5" stroke-dasharray="69.12" stroke-dashoffset="69.12" stroke-linecap="round" transform="rotate(-90 14 14)"/>
    </svg>
    <span class="header-count" id="headerCount">0/{N}</span>
  </div>
</header>
```

### Sticky submit bar

```html
<div class="submit-bar">
  <div class="sb-status" id="submitStatus">{N} fields — fill in what you can, send when ready</div>
  <button class="btn-copy" onclick="copyAnswers()">Copy All · <span style="font-weight:400;opacity:.7">iPhone</span></button>
  <!-- Only include if recipient email was provided: -->
  <button class="btn-send" onclick="sendAnswers()">Email {Recipient Name} · <span style="font-weight:400;opacity:.8">Desktop</span></button>
</div>
```

## 5. CSS for interactive elements

Add these styles to the stylesheet. Use the resolved style's CSS custom properties. The CSS below uses generic variable names — replace with the style's actual tokens (e.g., `--brand-green`, `--ink-amber`, etc.).

**Design quality rules embedded in CSS:**
- Every section gets `.reveal` for scroll animation
- Cards have hover lift + answered state
- Textareas have triple-state (default → focused → answered)
- Sticky elements use frosted glass
- Stats and charts animate on scroll

```css
/* ─── Scroll Reveal ─── */
.reveal {
  opacity: 0; transform: translateY(24px);
  transition: opacity 0.7s cubic-bezier(0.16, 1, 0.3, 1),
              transform 0.7s cubic-bezier(0.16, 1, 0.3, 1);
}
.reveal.revealed { opacity: 1; transform: translateY(0); }

/* ─── Hero ─── */
.hero {
  background: linear-gradient(135deg, #1a1a18 0%, #2d2d28 50%, #1a1a18 100%);
  position: relative; overflow: hidden;
  padding: 56px 32px 48px; margin: -48px -32px 0; /* bleed to edges */
  text-align: center;
}
.hero::before {
  content: ''; position: absolute; top: -50%; left: 50%; transform: translateX(-50%);
  width: 600px; height: 600px; border-radius: 50%;
  background: radial-gradient(circle, rgba(var(--brand-green-rgb, 110,191,75), 0.08) 0%, transparent 70%);
  pointer-events: none;
}
.hero-badge {
  display: inline-block; font-size: 10px; font-weight: 700; letter-spacing: 0.14em;
  text-transform: uppercase; color: rgba(255,255,255,0.7);
  border: 1px solid rgba(255,255,255,0.15); border-radius: 20px;
  padding: 4px 14px; margin-bottom: 20px;
  animation: badge-pulse 3s ease-in-out infinite;
}
@keyframes badge-pulse {
  0%, 100% { opacity: 0.7; } 50% { opacity: 1; }
}
.hero-title {
  font-family: var(--font-serif); font-size: 32px; font-weight: 400;
  color: #fff; line-height: 1.2; margin: 0 0 12px;
}
.hero-title em { font-style: italic; color: var(--brand-green); }
.hero-subtitle {
  font-family: var(--font-sans); font-size: 15px; color: rgba(255,255,255,0.55);
  margin: 0 0 20px; line-height: 1.5;
}
.hero-meta {
  font-size: 11px; color: rgba(255,255,255,0.4); text-transform: uppercase;
  letter-spacing: 0.06em; display: flex; justify-content: center; gap: 8px;
  flex-wrap: wrap;
}
.meta-sep { opacity: 0.3; }

/* ─── Stats Ribbon ─── */
.stats-ribbon {
  display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 12px; margin-top: -40px; position: relative; z-index: 10;
  padding: 0 20px;
}
.stat-card {
  background: var(--bg-panel); border: 1px solid var(--border);
  border-radius: 6px; padding: 20px 16px; text-align: center;
  box-shadow: var(--shadow-card);
}
.stat-value {
  font-family: var(--font-serif); font-size: 36px; font-weight: 600;
  color: var(--text); line-height: 1;
}
.stat-label {
  font-size: 10px; font-weight: 500; color: var(--faint);
  text-transform: uppercase; letter-spacing: 0.12em; margin-top: 6px;
}

/* ─── Tier Overview ─── */
.tier-overview {
  display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px; margin: 32px 0;
}
.tier-card {
  background: var(--bg-panel); border: 1px solid var(--border);
  border-radius: 6px; padding: 24px 20px; position: relative; overflow: hidden;
}
.tier-watermark {
  position: absolute; top: -10px; right: 8px;
  font-family: var(--font-serif); font-size: 120px; font-weight: 600;
  color: var(--text); opacity: 0.04; line-height: 1; pointer-events: none;
}
.tier-strip {
  height: 3px; width: 40px; border-radius: 2px; margin-bottom: 16px;
}
.tier-card[data-tier="1"] .tier-strip { background: var(--brand-green); }
.tier-card[data-tier="2"] .tier-strip { background: var(--ink-amber); }
.tier-card[data-tier="3"] .tier-strip { background: var(--ink-violet); }
.tier-title {
  font-family: var(--font-serif); font-size: 18px; color: var(--text); margin: 0 0 6px;
}
.tier-desc { font-size: 13px; color: var(--muted); line-height: 1.5; margin: 0 0 12px; }
.tier-tag {
  font-size: 10px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.08em;
  color: var(--faint);
}

/* ─── Sticky Header (frosted glass) ─── */
.sticky-header {
  position: sticky; top: 0; z-index: 200;
  background: rgba(250, 250, 245, 0.85);
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border-bottom: 1px solid var(--border);
  padding: 10px 24px; display: flex; align-items: center; justify-content: space-between;
}
.header-brand { display: flex; align-items: center; gap: 10px; }
.brand-mark {
  width: 28px; height: 28px; border-radius: 6px;
  background: linear-gradient(135deg, var(--brand-green), var(--brand-green-deep));
  display: flex; align-items: center; justify-content: center;
  color: #fff; font-family: var(--font-serif); font-size: 14px; font-weight: 600;
}
.header-title {
  font-family: var(--font-sans); font-size: 13px; font-weight: 600;
  color: var(--text); letter-spacing: 0.01em;
}
.header-progress { display: flex; align-items: center; gap: 8px; }
.mini-ring { display: block; }
.mini-ring-fill { transition: stroke-dashoffset 0.4s ease; }
.header-count {
  font-family: var(--font-mono, monospace); font-size: 12px; font-weight: 600;
  color: var(--muted);
}

/* ─── Question Cards ─── */
.q-card {
  background: var(--bg-panel); border: 1px solid var(--border);
  border-radius: 6px; padding: 24px; margin: 16px 0;
  box-shadow: var(--shadow-card);
  transition: transform 0.25s ease, box-shadow 0.25s ease, border-color 0.3s ease;
}
.q-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-hover); }
.q-card.answered { border-color: var(--brand-green); }
.q-card.answered .q-check { color: var(--brand-green); }

/* Decision card accent */
.decision-card { border-left: 3px solid var(--brand-green); border-radius: 0 6px 6px 0; }

.q-top { display: flex; align-items: flex-start; gap: 14px; margin-bottom: 16px; }
.q-badge {
  width: 32px; height: 32px; min-width: 32px; border-radius: 6px;
  background: var(--brand-green-light); color: var(--brand-green-deep);
  font-family: var(--font-mono, monospace); font-size: 13px; font-weight: 700;
  display: flex; align-items: center; justify-content: center;
}
.decision-badge { background: rgba(184, 134, 11, 0.1); color: var(--ink-amber); }
.q-counter {
  font-size: 10px; font-weight: 600; color: var(--faint);
  text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 2px;
}
.q-title {
  font-family: var(--font-serif); font-size: 17px; color: var(--text);
  line-height: 1.35; margin: 0;
}

.q-context, .q-need, .q-why {
  font-size: 13px; color: var(--muted); line-height: 1.55;
  margin-bottom: 8px; padding-left: 46px; /* align with title past badge */
}
.q-context::before, .q-need::before, .q-why::before {
  font-size: 10px; font-weight: 600; color: var(--faint);
  text-transform: uppercase; letter-spacing: 0.08em;
  display: block; margin-bottom: 2px;
}
.q-context::before { content: 'Context'; }
.q-need::before { content: 'What we need'; }
.q-why::before { content: 'Why this matters'; }

.q-answer { padding-left: 46px; position: relative; }
.q-answer-label {
  font-size: 11px; font-weight: 600; text-transform: uppercase;
  letter-spacing: 0.08em; margin-bottom: 6px;
  color: var(--brand-green-deep);
}
.decision-label { color: var(--ink-amber); }

.q-card textarea {
  width: 100%; min-height: 80px; padding: 12px 14px;
  font-family: var(--font-sans); font-size: 14px; line-height: 1.55;
  color: var(--text); background: var(--bg);
  border: 1px solid var(--border-strong); border-radius: 4px;
  resize: vertical; outline: none; box-sizing: border-box;
  transition: border-color 0.25s ease, box-shadow 0.25s ease, background-color 0.25s ease;
}
.q-card textarea:focus {
  border-color: var(--brand-green);
  box-shadow: 0 0 0 3px var(--brand-green-light);
  background: var(--bg-panel);
}
.q-card textarea::placeholder { color: var(--faint); font-style: italic; }

.q-check {
  position: absolute; right: 0; bottom: 12px;
  color: var(--ghost); transition: color 0.3s ease;
}

/* ─── Animated Bar Charts ─── */
.bar-chart { margin: 16px 0; }
.bar-row { display: flex; align-items: center; gap: 12px; margin: 8px 0; }
.bar-label { font-size: 12px; color: var(--muted); min-width: 100px; text-align: right; }
.bar-track {
  flex: 1; height: 24px; background: var(--bg-2); border-radius: 4px; overflow: hidden;
}
.bar-fill {
  height: 100%; width: 0%; border-radius: 4px;
  background: var(--brand-green);
  transition: width 0.8s cubic-bezier(0.16, 1, 0.3, 1);
}
.bar-value {
  font-size: 12px; font-weight: 600; color: var(--text); min-width: 40px;
}

/* ─── Signature ─── */
.signature { text-align: left; margin-top: 48px; padding: 24px 0; }
.sig-line {
  width: 80px; height: 2px; margin-bottom: 16px;
  background: linear-gradient(90deg, var(--brand-green), transparent);
}
.sig-name { font-family: var(--font-serif); font-size: 16px; color: var(--text); }
.sig-email { font-size: 13px; color: var(--muted); margin-top: 2px; }

/* ─── Submit Bar (frosted glass) ─── */
.submit-bar {
  position: sticky; bottom: 0; left: 0; right: 0;
  background: rgba(250, 250, 245, 0.85);
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border-top: 1px solid var(--border);
  padding: 14px 24px; margin: 0 -32px;
  display: flex; gap: 10px; align-items: center; justify-content: space-between;
  z-index: 100;
}
.submit-bar .sb-status { font-size: 12px; color: var(--faint); flex: 1; }
.submit-bar .sb-status.success { color: var(--brand-green); }
.submit-bar button {
  font-family: var(--font-sans); font-size: 13px; font-weight: 600;
  padding: 10px 20px; border-radius: 4px; cursor: pointer;
  border: none; transition: all 0.2s;
}
.btn-copy {
  background: var(--bg-panel); border: 1px solid var(--border-strong) !important;
  color: var(--text);
}
.btn-copy:hover { background: var(--bg-2); }
.btn-send { background: var(--brand-green); color: white; }
.btn-send:hover { opacity: 0.9; }

/* ─── Mobile ─── */
@media (max-width: 600px) {
  .hero { padding: 40px 20px 36px; margin: -28px -20px 0; }
  .hero-title { font-size: 24px; }
  .stats-ribbon { padding: 0 8px; margin-top: -28px; }
  .stat-value { font-size: 28px; }
  .tier-overview { grid-template-columns: 1fr; }
  .q-card { padding: 18px 16px; }
  .q-context, .q-need, .q-why, .q-answer { padding-left: 0; }
  .q-card textarea { font-size: 16px; min-height: 100px; }
  .sticky-header { padding: 8px 16px; }
  .submit-bar {
    margin: 0 -20px; padding: 12px 16px;
    flex-wrap: wrap; gap: 8px;
  }
  .submit-bar .sb-status { width: 100%; text-align: center; margin-bottom: 4px; }
  .submit-bar button { flex: 1; padding: 12px 16px; }
}
```

## 6. JavaScript

Add this script block at the end of `<body>`. Replace placeholder values with the actual detected questions.

**Required behaviors:**
- IntersectionObserver for scroll reveal on all `.reveal` elements
- IntersectionObserver for animated bar chart fills
- Animated counter for stat values (count up from 0)
- Progress ring update (SVG stroke-dashoffset) on textarea input
- Card `.answered` state management (add class when textarea has content)
- Header mini-ring sync
- Auto-save to localStorage
- Copy/email gather

```javascript
const questions = [
  // { name: 'q1', label: 'Short label', section: 'QUESTIONS' },
  // { name: 'd1', label: 'Short label', section: 'DECISIONS' },
  // { name: 'notes', label: 'General notes & reactions', section: 'NOTES' }
];

const STORAGE_KEY = 'briefing-' + document.title.toLowerCase().replace(/[^a-z0-9]+/g, '-');
const TOTAL = questions.length;

// ─── Scroll Reveal ───
const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach((entry, i) => {
    if (entry.isIntersecting) {
      // Stagger siblings
      const parent = entry.target.parentElement;
      const siblings = parent ? Array.from(parent.querySelectorAll('.reveal')) : [];
      const idx = siblings.indexOf(entry.target);
      const delay = idx >= 0 ? idx * 90 : 0;
      setTimeout(() => entry.target.classList.add('revealed'), delay);
      revealObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.08 });

document.querySelectorAll('.reveal').forEach(el => revealObserver.observe(el));

// ─── Animated Counters ───
function animateCounter(el, target, duration = 1200) {
  let start = null;
  const step = (ts) => {
    if (!start) start = ts;
    const progress = Math.min((ts - start) / duration, 1);
    const eased = 1 - Math.pow(1 - progress, 3); // ease-out cubic
    el.textContent = Math.round(eased * target).toLocaleString();
    if (progress < 1) requestAnimationFrame(step);
  };
  requestAnimationFrame(step);
}

const counterObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const target = parseInt(entry.target.dataset.target, 10);
      if (!isNaN(target)) animateCounter(entry.target, target);
      counterObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.3 });

document.querySelectorAll('.stat-value[data-target]').forEach(el => {
  el.textContent = '0';
  counterObserver.observe(el);
});

// ─── Animated Bar Charts ───
const barObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const bars = entry.target.querySelectorAll('.bar-fill');
      bars.forEach((bar, i) => {
        const w = bar.dataset.width || '0';
        setTimeout(() => { bar.style.width = w + '%'; }, i * 110);
      });
      barObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.2 });

document.querySelectorAll('.bar-chart').forEach(el => barObserver.observe(el));

// ─── Progress Ring ───
function updateProgress() {
  let answered = 0;
  questions.forEach(q => {
    const ta = document.querySelector(`textarea[name="${q.name}"]`);
    const card = ta ? ta.closest('.q-card') : null;
    if (ta && ta.value.trim()) {
      answered++;
      if (card) card.classList.add('answered');
    } else {
      if (card) card.classList.remove('answered');
    }
  });

  // Update mini ring in header
  const miniRing = document.querySelector('.mini-ring-fill');
  if (miniRing) {
    const circumference = 2 * Math.PI * 11; // r=11
    const offset = circumference - (answered / TOTAL) * circumference;
    miniRing.style.strokeDashoffset = offset;
  }

  // Update header count
  const headerCount = document.getElementById('headerCount');
  if (headerCount) headerCount.textContent = `${answered}/${TOTAL}`;

  // Update submit status
  const el = document.getElementById('submitStatus');
  if (el) {
    if (answered === 0) {
      el.textContent = `${TOTAL} fields — fill in what you can, send when ready`;
      el.className = 'sb-status';
    } else if (answered === TOTAL) {
      el.textContent = `All ${TOTAL} fields complete`;
      el.className = 'sb-status success';
    } else {
      el.textContent = `${answered} of ${TOTAL} filled in`;
      el.className = 'sb-status';
    }
  }

  return answered;
}

// ─── Gather & Copy/Email ───
function gatherAnswers() {
  const docTitle = document.title.toUpperCase();
  let text = docTitle + ' — ANSWERS\n';
  text += '='.repeat(50) + '\n\n';
  let answered = 0;
  let currentSection = '';
  questions.forEach((q) => {
    if (q.section !== currentSection) {
      currentSection = q.section;
      text += `\n--- ${currentSection} ---\n\n`;
    }
    const ta = document.querySelector(`textarea[name="${q.name}"]`);
    const val = ta ? ta.value.trim() : '';
    const prefix = q.name.startsWith('q') ? `Q${q.name.slice(1)}` :
                   q.name.startsWith('d') ? `Decision ${q.name.slice(1)}` : '';
    text += prefix ? `${prefix}: ${q.label}\n` : `${q.label}\n`;
    if (val) { text += val + '\n\n'; answered++; }
    else { text += '(not answered yet)\n\n'; }
  });
  return { text, answered, total: TOTAL };
}

function copyAnswers() {
  const { text, answered } = gatherAnswers();
  if (answered === 0) {
    document.getElementById('submitStatus').textContent = 'Write some answers first!';
    return;
  }
  navigator.clipboard.writeText(text).then(() => {
    const el = document.getElementById('submitStatus');
    el.textContent = 'Copied to clipboard ✓';
    el.className = 'sb-status success';
    setTimeout(updateProgress, 2500);
  }).catch(() => {
    const ta = document.createElement('textarea');
    ta.value = text;
    document.body.appendChild(ta);
    ta.select();
    document.execCommand('copy');
    document.body.removeChild(ta);
    const el = document.getElementById('submitStatus');
    el.textContent = 'Copied to clipboard ✓';
    el.className = 'sb-status success';
    setTimeout(updateProgress, 2500);
  });
}

// Only include sendAnswers if recipient email is provided
function sendAnswers() {
  const { text, answered } = gatherAnswers();
  if (answered === 0) {
    document.getElementById('submitStatus').textContent = 'Write some answers first!';
    return;
  }
  const subject = encodeURIComponent(document.title + ' — Answers');
  const body = encodeURIComponent(text);
  window.location.href = `mailto:RECIPIENT_EMAIL?subject=${subject}&body=${body}`;
}

// ─── Auto-save ───
function saveToLocal() {
  const data = {};
  questions.forEach(q => {
    const ta = document.querySelector(`textarea[name="${q.name}"]`);
    if (ta) data[q.name] = ta.value;
  });
  try { localStorage.setItem(STORAGE_KEY, JSON.stringify(data)); } catch(e) {}
}

function loadFromLocal() {
  try {
    const data = JSON.parse(localStorage.getItem(STORAGE_KEY));
    if (!data) return;
    questions.forEach(q => {
      const ta = document.querySelector(`textarea[name="${q.name}"]`);
      if (ta && data[q.name]) ta.value = data[q.name];
    });
    updateProgress();
  } catch(e) {}
}

// ─── Wire up events ───
document.querySelectorAll('textarea').forEach(ta => {
  ta.addEventListener('input', () => { updateProgress(); saveToLocal(); });
});

loadFromLocal();
updateProgress();
```

Replace `RECIPIENT_EMAIL` with the actual email from the arguments. If no email was provided, omit the `sendAnswers` function and the email button entirely.

## 7. Content conversion

Convert the rest of the markdown using the same rules as `/readable`:
- Title from `# heading` or YAML `title:` — `Instrument Serif`, 28px
- Date from YAML `created:` — uppercase label
- H2: `Instrument Serif`, 20px, bottom border
- H3: `Inter` 14px semibold, `ink-blue`
- Body: `Inter` 15px, `muted`, line-height 1.65
- Callouts, warnings, key-question blocks with appropriate left borders
- Tables, lists, code blocks, links — all per readable spec
- Max width 640px centered, mobile responsive

**Key difference from /readable**: When you encounter a question or decision in the source content, render it as an interactive card (from step 4) instead of static text. The surrounding context and explanation should still be rendered normally — only the actual question/decision becomes interactive.

## 8. Output

Write the HTML file to the output directory. Name it based on the source filename (e.g., `founder-report.md` → `founder-report.html`).

Report:
- Output file path
- Number of questions, decisions, and notes fields detected
- Recipient name/email if configured
- Remind user: open directly in browser, AirDrop to phone, or `python3 -m http.server`
