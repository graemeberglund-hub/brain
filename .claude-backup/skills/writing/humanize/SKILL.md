---
name: humanize
description: Evaluate and rewrite AI-sounding text to read like a human wrote it. Detects 24 AI patterns, 500+ vocabulary terms across 3 tiers, and statistical tells. Shows before/after examples, then rewrites. Use when user says "humanize", "make more human", "less AI", "de-AI", "sounds like a robot", or wants natural-sounding writing.
allowed-tools: Read, Write, Edit, Glob, Bash(date *), Bash(ls *), Bash(wc *)
argument-hint: "<file-path> [--eval-only]"
---

input = $ARGUMENTS

# /humanize — Make AI Writing Sound Human

You are a writing editor. Your job: find the parts that scream "AI wrote this" and fix them. Not every sentence needs rewriting — surgical strikes on the worst offenders.

Based on [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing), Copyleaks stylometric research, and real-world pattern analysis.

## 1. Parse arguments

- **File path**: the file to humanize
- **--eval-only**: if present, only show the evaluation and examples — don't rewrite

Read the file.

## 2. Evaluate — the 24 patterns

Scan for all of these. Be honest and specific — quote the actual offending text with line numbers.

### Content patterns

| # | Pattern | What to watch for |
|---|---------|-------------------|
| 1 | Significance inflation | "marking a pivotal moment in the evolution of..." |
| 2 | Notability name-dropping | Listing media outlets or authorities without specific claims |
| 3 | Superficial -ing chains | "...showcasing... reflecting... highlighting..." |
| 4 | Promotional language | "nestled", "breathtaking", "stunning", "renowned" |
| 5 | Vague attributions | "Experts believe", "Studies show", "Industry reports" |
| 6 | Formulaic challenges | "Despite challenges... continues to thrive" |

### Language patterns

| # | Pattern | What to watch for |
|---|---------|-------------------|
| 7 | AI vocabulary | See tier lists below |
| 8 | Copula avoidance | "serves as", "boasts", "features" instead of "is", "has" |
| 9 | Negative parallelisms | "It's not just X, it's Y" |
| 10 | Rule of three | "innovation, inspiration, and insights" |
| 11 | Synonym cycling | "protagonist... main character... central figure..." (rotating words for the same thing) |
| 12 | False ranges | "from the Big Bang to dark matter" (sounds sweeping, means nothing) |

### Style patterns

| # | Pattern | What to watch for |
|---|---------|-------------------|
| 13 | Em dash overuse | More than 2–3 per section |
| 14 | Boldface overuse | Mechanical emphasis on every other phrase |
| 15 | Inline-header lists | `- **Topic:** Topic is discussed here` |
| 16 | Title Case headings | Every Main Word Capitalized In Headings |
| 17 | Emoji overuse | Professional text decorated with emojis |
| 18 | Curly quotes | "smart quotes" in contexts where straight quotes are normal |

### Communication patterns

| # | Pattern | What to watch for |
|---|---------|-------------------|
| 19 | Chatbot artifacts | "I hope this helps!", "Let me know if..." |
| 20 | Cutoff disclaimers | "As of my last training...", "While details are limited..." |
| 21 | Sycophantic tone | "Great question!", "You're absolutely right!" |

### Filler patterns

| # | Pattern | What to watch for |
|---|---------|-------------------|
| 22 | Filler phrases | "In order to", "Due to the fact that", "At this point in time" |
| 23 | Excessive hedging | "could potentially possibly", "might arguably perhaps" |
| 24 | Generic conclusions | "The future looks bright", "Exciting times lie ahead" |

## 3. Vocabulary tiers

### Tier 1 — Dead giveaways (always flag)

delve, tapestry, vibrant, crucial, comprehensive, meticulous, embark, robust, seamless, groundbreaking, leverage, synergy, transformative, paramount, multifaceted, myriad, cornerstone, reimagine, empower, catalyst, invaluable, bustling, nestled, realm, landscape (metaphorical), showcase, harness, navigate (metaphorical), foster, bolster, spearhead, underscore, pivotal

### Tier 2 — Suspicious in density (flag when clustered)

furthermore, moreover, paradigm, holistic, utilize, facilitate, nuanced, illuminate, encompasses, catalyze, proactive, ubiquitous, quintessential

### AI phrases (flag on sight)

"In today's digital age", "It is worth noting", "plays a crucial role", "serves as a testament", "in the realm of", "delve into", "harness the power of", "embark on a journey", "without further ado"

## 4. Statistical signals

Beyond pattern matching, check these. You don't need to compute exact numbers — use them as mental models for what to look for.

| Signal | Human range | AI range | What it means |
|--------|-------------|----------|---------------|
| Burstiness | High (0.5–1.0) | Low (0.1–0.3) | Humans write in bursts of short and long. AI is metronomic. |
| Type-token ratio | 0.5–0.7 | 0.3–0.5 | AI reuses the same vocabulary more. |
| Sentence length variation | High CoV | Low CoV | AI sentences are all roughly the same length. |
| Trigram repetition | Low (<0.05) | High (>0.10) | AI reuses 3-word phrases. |

## 5. Show the evaluation

Output a report to the user (NOT to the file):

### Score
Rate 1–10. 1 = obviously AI, 10 = sounds fully human. Be honest.

### Worst offenders
5–10 most AI-sounding passages. Quote the exact text with line numbers and which pattern it matches. Be specific — "line 47: 'This serves as a testament to...'" not "some parts sound formal."

### Before/after examples
For each offender, show what you'd change it to:

```
BEFORE: "This serves as an enduring testament to humanity's commitment to..."
AFTER:  "Solar panel costs dropped 90% between 2010 and 2023."
WHY:    Copula avoidance + significance inflation. Replace vague grandeur with a specific fact.
```

Show at least 5 examples covering different pattern types.

### Statistical notes
- Flag if sentences are suspiciously uniform in length
- Flag em dash density (more than ~3 per 500 words)
- Flag mechanical bold usage (every paragraph opens with bold)
- Flag excessive structural parallelism (every section follows the same template)
- Flag synonym cycling (same concept, rotating words)

## 6. Rewrite (unless --eval-only)

Apply the fixes. Core principles:

### Be direct
- Use "is" and "has" — stop avoiding simple verbs
- One qualifier per claim, max
- Say the thing. Don't introduce the thing, then say the thing.
- Name your sources or drop the claim

### Sound like a person
- Vary sentence length. Short ones. Then a longer one that actually explains something.
- Have opinions where appropriate — "this is the hard part" not "this represents a significant challenge"
- Acknowledge mess, uncertainty, mixed feelings — real humans do
- Let structure be slightly imperfect. Not every section needs to mirror every other section.
- Add actual personality — sterile text is just as obvious as slop
- If you wouldn't say it in conversation, don't write it

### Cut fat
- "In order to" → "to"
- "Due to the fact that" → "because"
- "It is important to note that" → just say it
- Kill hedging stacks
- If a sentence adds nothing, delete it
- Shorter > longer when meaning is preserved

### Preserve
- Technical accuracy — don't simplify away important detail
- The author's actual point and intent
- Specific numbers, names, citations
- Tone direction (formal doc stays formal-ish, casual stays casual)

### Don't over-correct
- Not every em dash is bad — just reduce density
- Bold emphasis is fine when used sparingly for actual key points
- Lists are fine when they're genuinely lists, not disguised prose
- Some structure is good — the goal isn't chaos, it's natural rhythm

## 7. Show what changed

After rewriting, output a summary:

- Score before → score after
- Count of changes by category (vocabulary, structure, filler, style, communication)
- Any passages you left alone that were borderline, and why

## 8. Save

Write the edited file back to the same path (overwriting), or to a new path if the user specified one.
