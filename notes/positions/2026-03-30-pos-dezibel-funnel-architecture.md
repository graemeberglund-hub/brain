---
title: "2026-03-30 Dezibel needs a free preview funnel, not a direct purchase funnel"
type: position
classification: belief
testable: true
tags: [dezibel, funnel, marketing, conversion, guardian, launch]
created: 2026-03-30
updated: 2026-03-30
stage: forming
confidence: high
parent: "[[dezibel-marketing-validation]]"
repos: [dezibel]
ai_generated: "2026-03-30"
ai_model: "claude-opus-4-6"
---

## Thesis

Dezibel's current acquisition funnel (press article → $49 purchase) will not hit 500 Day 1 subscribers. Funnel modeling against industry benchmarks projects 88 subscribers (base case) to 377 (bull case). The fix is not more channels — it's funnel architecture. A free Day 1 preview → email capture → nurture sequence → purchase converts at 15-25%, vs. 2-3% for cold traffic direct purchase at $49. This single change could move Day 1 from ~88 to ~200+ subscribers.

The 500 target may also need revision. Minimum viable Day 1 is ~100 (below this, not enough concurrent readers for word-of-mouth). Comfortable launch is ~200.

## The Math

**Current funnel (direct purchase):**
- Guardian article: 195-325K readers → 1-2% click outbound link → 2-5% convert at $49 = **39-163 subscribers** (midpoint: ~78)
- oBitchuary Substack: 500 free subs → 1-3% convert to $49 external product = **5-15**
- All other channels combined: **~10**
- **Total base case: ~88. Bull case: ~377.**

**Revised funnel (free preview → nurture → purchase):**
- Same traffic → free Day 1 preview (much higher opt-in: 10-20% of article readers) → email nurture over 1-2 weeks → 15-25% convert to paid
- Guardian alone: 195-325K readers → 10% opt-in to free preview = 19,500-32,500 → 15% convert = **2,925-4,875**
- Even at conservative 5% opt-in and 10% conversion: **975-1,625**

The gap between 88 and 2,925 is not a marginal improvement. It's a different business.

## Evidence For

- [[subscriber-funnel-model]] — full channel-by-channel analysis with industry benchmarks
- Guardian outbound link CTR: 1-2% (Center for Media Engagement, n=1.8M observations)
- Cold traffic conversion at $49 digital product: 2-5% (industry benchmarks for high-priced digital)
- Free trial → paid conversion: 15-25% for digital products (Substack, apps, SaaS)
- Dezibel's product IS its own best salesperson — Day 1 is designed to hook. Giving it away as a free preview lets the product sell itself.

## Evidence Against

- **Free preview devalues the product**: Giving away Day 1 for free sets an expectation of free content. Some users may expect more free days.
- **Spoiler risk**: Free preview readers who don't convert have seen Day 1. They could share/screenshot without paying.
- **Operational complexity**: Running a free preview cohort alongside paid cohorts adds engineering and support load.
- **The $49 price point IS a filter**: People who pay $49 cold are more committed readers. Free preview may attract casual browsers who churn after Day 7.

## Kill Test

Build the free preview funnel and A/B test against direct purchase. Run 50% of Guardian traffic to each. If free preview → nurture → paid converts at >3x the direct purchase rate, the thesis is validated. Cost: $0 (landing page variants). Timeline: 2 weeks to build, results after Guardian piece runs.

## Related

- [[dezibel-marketing-validation]] — parent position on 3-day demo as cheapest validation
- [[dezibel-pricing-model]] — price point affects conversion rate directly
- [[clandestine-marketing-dezibel]] — ecosystem marketing is brand texture, not a conversion channel (~2 subs)

## Evolution

- **2026-03-30** — Position formed from funnel modeling (kill tests K15, K16). The existing strategy assumed 200-300 conversions from the Guardian piece alone. Modeling against empirical CTR and conversion data shows ~78. The insight is not that the Guardian piece is weak — it's that cold traffic at $49 converts poorly regardless of source. The product itself (Day 1) is the best sales tool. Let it sell itself via free preview. Starting at forming/high — the math is clear but the A/B test must run.
