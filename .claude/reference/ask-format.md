# AskUserQuestion Format — Behavioral Standard

All skills that ask the user for decisions follow this format. One decision per question. Never batch independent decisions.

## Format

```
## [Context re-ground]
Brief reminder of what we're doing and why this question matters.
Assume user hasn't looked at this window in 20 minutes.

## [Simplification]
Plain-language framing. No jargon. What's actually being decided.

## [Recommendation]
Preferred option with reasoning. Always recommend the more complete option.

## [Options]
A) Option description — Human: ~Xh | CC: ~Ymin | Completeness: N/10
B) Option description — Human: ~Xh | CC: ~Ymin | Completeness: N/10
```

## Completeness Scoring (0–10)

Every option that involves effort estimation includes a completeness score:

| Score | Meaning |
|-------|---------|
| 0–2   | Placeholder / stub only |
| 3–4   | Core happy path, no edge cases |
| 5–6   | Happy path + known edge cases |
| 7–8   | Production-ready, tested, documented |
| 9–10  | Comprehensive, hardened, battle-tested |

The score forces honesty about what's left on the table. A quick 3/10 option is valid — but the user sees what they're trading off.

## Dual Effort Estimation

Every option includes both:
- **Human:** time the user spends (reviewing, deciding, testing, iterating)
- **CC:** Claude Code execution time (reading, writing, running tests)

This distinguishes "fast for CC but slow for human review" from "fast for everyone."

## Anti-Sycophancy Directives

Banned phrases in challenge/review/evaluation contexts:

| Banned | Replacement |
|--------|-------------|
| "That's an interesting approach" | Take a position. State what would kill it. |
| "You might consider" | "This is wrong because..." or "This works because..." |
| "There are trade-offs" | Name the trade-offs. Recommend one side. |
| "Great question" | Answer the question. |
| "I can see why you'd think that" | State whether the thinking is correct or not. |

These apply to: `/challenge`, `/review`, `/digest` tribunal, and any skill that evaluates quality.

## Rules

1. **One decision per question.** Never batch independent decisions into a single prompt.
2. **Always recommend.** Never present options without a recommendation. The user can override, but they shouldn't have to do the work of evaluating from scratch.
3. **Context re-ground is mandatory.** The user may have been away. Don't assume they remember the thread.
4. **No false balance.** If one option is clearly better, say so. Don't present equal-weight options when the evidence favors one.
5. **Completeness score is honest.** A 7/10 that's really a 4/10 undermines the entire scoring system.

## Adoption

- New skills: implement this format from the start.
- Existing skills: update on touch (when the skill is modified for other reasons). No batch update.
- Skills that already use AskUserQuestion: verify compliance at next modification.
