---
title: "Kill tests K15/K16: Day 1 subscriber funnel math — can we hit 500?"
type: reference
tags: [dezibel, funnel, subscribers, conversion, marketing, kill-test, guardian]
created: 2026-03-30
area: "[[writing-and-film]]"
source: "Funnel modeling against industry benchmarks for each acquisition channel."
---

# Day 1 Subscriber Funnel Model

**Question:** Can dezibel hit 500 paid subscribers on Day 1 with no existing audience?

**Method:** Channel-by-channel funnel modeling using industry conversion benchmarks. Each step modeled independently: reach → click-through → landing page visit → paid conversion.

**Key constraint:** $49 price point. This is 3-5x a typical ebook ($9.99-$14.99), which compresses conversion rates at every stage. Buyers need stronger conviction. The product is also novel (serialized iMessage fiction) — no category precedent means no shortcut to trust.

---

## Benchmark Summary

| Metric | Source | Range | Value Used |
|--------|--------|-------|------------|
| News article outbound link CTR | Center for Media Engagement (1.8M observations) | 1-2% | 1.5% |
| Long-form feature engagement premium | Pew Research | 2-3x vs. standard article | 2x applied |
| Substack free→paid conversion (internal) | Industry consensus 2024-2025 | 1-3% typical, 5% strong | 3% (strong) |
| Substack free→external product conversion | Email marketing benchmarks | 1-2% for $50 products | 1.5% |
| Landing page conversion (ecommerce, $30-50) | Unbounce Q4 2024; Shopify 2025 | 2-5% median | 3% (base), 5% (optimistic) |
| Cold traffic purchase rate ($49 digital) | Funnel benchmark data | 1-3% first visit | 2% |
| Word-of-mouth viral coefficient (books) | Reforge; Publishers Weekly | K = 0.1-0.3 for most books | K = 0.2 |
| BookTok conversion to purchase | Industry data 2024 | Highly variable, genre-dependent | Unquantifiable for launch |

---

## Channel 1: Guardian Long-Form Piece

**Assumptions:** Adrienne Matei writes a 2,000+ word feature. Guardian long-form section gets ~1.3M weekly readers. A single feature captures a fraction of that weekly audience.

### Funnel

| Step | Metric | Value | Running total |
|------|--------|-------|---------------|
| Weekly section readers | Reach | 1,300,000 | 1,300,000 |
| % who see/read this specific article | Article penetration | 15-25% | 195,000-325,000 |
| % who read to completion (long-form) | Completion rate | 40-60% | 78,000-195,000 |
| % who click embedded link to dezibel | Outbound CTR | 1.5-3% | 1,170-5,850 |
| % who convert on landing page at $49 | Purchase conversion | 2-5% | 23-293 |

### Scenarios

| Scenario | Article readers | Completions | Clicks | Conversions |
|----------|----------------|-------------|--------|-------------|
| **Bear** | 195,000 | 78,000 | 1,170 | 23 |
| **Base** | 260,000 | 130,000 | 2,600 | 78 |
| **Bull** | 325,000 | 195,000 | 5,850 | 293 |

**Base case: ~78 subscribers from the Guardian piece.**

**Why the existing estimate of 200-300 (K15) or 390 is too high:**
- The 390 figure in the strategy doc appears to apply a ~0.03% direct conversion rate to 1.3M readers. But 1.3M is the *weekly section audience*, not the readership of a single article.
- Outbound link CTR from news articles is empirically 1-2% (Center for Media Engagement, n=1.8M). Even with a compelling CTA embedded by the author, 3% is optimistic.
- At $49, landing page conversion for cold traffic from editorial content runs 2-5%. The product is unfamiliar, the price is high relative to ebooks, and there's no social proof at launch.
- The 200-300 estimate requires ~5,000-6,000 landing page visitors from the article. That implies 3-4% outbound CTR on 150,000+ completions. Possible but optimistic.

**Critical dependency confirmed:** The article must include a direct, prominent link to the purchase page (not just a mention of "dezibel"). Author-embedded links in long-form features get 2-3x the CTR of sidebar/footer links.

### What would make 200+ realistic from Guardian alone

- Article goes viral beyond Guardian's core readership (shared on social, picked up by aggregators) — adds 50-200K additional readers
- Landing page has video trailer + social proof (beta reader quotes) at launch
- Price point is $29 instead of $49 (roughly doubles conversion rate)
- Guardian includes the link as a call-to-action, not a passing reference

---

## Channel 2: oBitchuary Substack

**Assumptions:** oBitchuary runs 6-8 months pre-launch under "Emma Jensen" byline. Free Substack column building an audience of feminist cultural criticism readers.

### How many free subscribers can oBitchuary realistically build?

| Growth scenario | 8-month free subs | Basis |
|-----------------|-------------------|-------|
| Weak | 200-400 | No viral moment, niche content, slow organic growth |
| Base | 500-1,000 | Consistent quality, some social sharing, 1-2 pieces get traction |
| Strong | 1,500-3,000 | One piece goes viral, cross-promotion from other Substacks |

Building 500+ free Substack subscribers from zero in 8 months with no existing platform is itself a meaningful achievement. The median new Substack grows very slowly without an existing audience.

### Conversion: free oBitchuary subscriber → paid dezibel subscriber

This is NOT a standard Substack free→paid conversion. The subscriber is being asked to buy a *different product* ($49 serialized novel) from what they signed up for (free cultural criticism column). This is closer to email list → external product conversion.

| Step | Metric | Value | Running total |
|------|--------|-------|---------------|
| Free subscribers at launch | List size | 500-1,000 | 500-1,000 |
| Open rate on "launch announcement" email | Open rate | 40-60% | 200-600 |
| Click-through to dezibel landing page | CTR | 10-20% | 20-120 |
| Purchase conversion at $49 | Conversion | 5-10% | 1-12 |

**Higher conversion rate justification:** These are warm leads — they already follow "Emma" and have emotional investment. The 5-10% landing page conversion is justified by warmth, not cold traffic benchmarks.

### Scenarios

| Scenario | Free subs | Clicks to LP | Conversions |
|----------|-----------|-------------|-------------|
| **Bear** | 300 | 20 | 1 |
| **Base** | 700 | 60 | 5 |
| **Bull** | 2,000 | 200 | 20 |

**Base case: ~5 subscribers from oBitchuary.**

**Why the conversion is low despite warm audience:** The audience signed up for a free column. They're being asked to pay $49 for a novel by someone they don't know is fictional. The reveal that "Emma" is a character may alienate some subscribers. The price is high. The product is unfamiliar. Most Substack audiences resist being monetized for external products.

**Upside scenario:** If the oBitchuary reveal is handled as a marketing moment (not a betrayal), and the audience is primed with escalating hints, the conversion could reach 20. But this requires deliberate funnel design in the Substack itself.

---

## Channel 3: Clandestine Marketing / Ecosystem Breadcrumbs

**Components:** Hot Ghost incense (Brooklyn retail), Shit Eyes album (Spotify), salon seeding, breadcrumb trail connecting products.

### The problem with quantifying this channel

This is brand awareness, not direct acquisition. The Longlegs playbook works because:
1. Horror fans actively decode and share mysteries (literary fiction readers do not behave this way — kill test A5 flags this)
2. Longlegs had a studio marketing budget behind the breadcrumbs
3. The decode-and-share behavior requires a critical mass of simultaneous participants

### Realistic contribution

| Asset | Reach | Discovery-to-LP | LP-to-purchase | Conversions |
|-------|-------|-----------------|----------------|-------------|
| Hot Ghost in-store (100 units sold) | 100 buyers | 2-5% find dezibel connection | 5% | 0-1 |
| Shit Eyes on Spotify (organic) | 500-2,000 listeners | 1-2% follow breadcrumbs | 3% | 0-1 |
| Salon seeding (5-10 salons) | 50-100 people hear about it | 20% visit LP | 5% | 1-2 |
| Combined breadcrumb trail | — | — | — | **1-4** |

**Base case: ~2 subscribers from clandestine marketing.**

This channel's value is brand texture and press narrative, not Day 1 conversions. It gives journalists something to write about. It does not drive purchases at scale.

---

## Channel 4: Beta Reader Word-of-Mouth

**Assumptions:** 5-7 beta readers receive Day 1. They share organically. Word-of-mouth viral coefficient K ≈ 0.2 for literary products (each reader generates 0.2 new readers on average).

### Funnel

| Step | Value |
|------|-------|
| Beta readers | 7 |
| People each beta reader tells | 5-10 |
| Total reached | 35-70 |
| % who visit landing page | 30-50% (warm referral) |
| Landing page visitors | 11-35 |
| Conversion at $49 (warm referral) | 10-15% |
| Conversions | 1-5 |

**Base case: ~3 subscribers from beta reader WOM.**

Word-of-mouth is the highest-converting channel per visitor (warm referral + personal recommendation), but the reach is tiny. With 7 beta readers, the ceiling is ~5 subscribers on Day 1. This channel matters for Days 2-42 as the story generates its own advocacy, not for Day 1.

---

## Channel 5: BookTok / Literary Social

**Reality check:** BookTok drove ~59M print sales in 2024 and has 370B+ total views. But:
- It overwhelmingly favors romantasy, romance, and genre fiction — not literary fiction
- It favors $10-$16 paperbacks, not $49 digital products
- Organic BookTok traction requires either a creator with existing following or a viral moment
- No creator has been identified for this channel
- Launch day social traction for an unknown product from an unknown creator is near-zero

**Base case: 0 subscribers from BookTok on Day 1.**

This channel could matter in weeks 2-6 IF the product generates genuine reader enthusiasm and someone with reach posts about it. It is not a Day 1 channel.

---

## Channel 6: Press Beyond Guardian

**Assumptions:** No other press confirmed. Adrienne's piece may generate follow-on coverage, but timing is uncertain and Day 1 impact is speculative.

| Scenario | Additional press | Conversions |
|----------|-----------------|-------------|
| No additional press | 0 | 0 |
| 1-2 literary blogs/podcasts mention it | 500-2,000 impressions | 1-5 |
| Culture section pickup (NYT, Vulture, etc.) | 50,000-200,000 readers | 15-60 |

**Base case: 0-5 subscribers from additional press on Day 1.** Culture section pickups are plausible but unconfirmed. Cannot count them in a base case.

---

## Consolidated Funnel Model

### Base Case (realistic)

| Channel | Landing Page Visitors | Conversions | Confidence |
|---------|-----------------------|-------------|------------|
| Guardian piece | 2,600 | 78 | Medium-High |
| oBitchuary Substack | 60 | 5 | Medium |
| Clandestine/ecosystem | 30 | 2 | Low |
| Beta reader WOM | 20 | 3 | Medium |
| BookTok/social | 0 | 0 | N/A |
| Press beyond Guardian | 0 | 0 | Unconfirmed |
| **Total** | **~2,710** | **~88** | — |

### Bull Case (everything breaks right)

| Channel | Landing Page Visitors | Conversions |
|---------|-----------------------|-------------|
| Guardian piece (viral, shared widely) | 5,850 | 293 |
| oBitchuary (2,000 free subs, strong reveal) | 200 | 20 |
| Clandestine/ecosystem | 40 | 4 |
| Beta reader WOM | 35 | 5 |
| BookTok/social (lucky break) | 200 | 10 |
| Additional press (1 major outlet) | 1,500 | 45 |
| **Total** | **~7,825** | **~377** |

### Bear Case (Guardian underperforms)

| Channel | Landing Page Visitors | Conversions |
|---------|-----------------------|-------------|
| Guardian piece (low penetration, poor link placement) | 1,170 | 23 |
| oBitchuary (300 free subs, weak conversion) | 20 | 1 |
| Clandestine/ecosystem | 10 | 0 |
| Beta reader WOM | 11 | 1 |
| **Total** | **~1,211** | **~25** |

---

## Sensitivity Analysis: Landing Page Visitors Needed for 500

| Conversion Rate | Visitors Needed | Feasibility |
|-----------------|-----------------|-------------|
| 1% | 50,000 | Requires major press coverage or paid acquisition |
| 2% | 25,000 | Requires viral moment + multiple press outlets |
| 3% | 16,667 | Requires Guardian viral + 2-3 additional major outlets |
| 5% | 10,000 | Requires Guardian viral + warm pre-launch audience |
| 10% | 5,000 | Only achievable with exclusively warm/referred traffic |

**Current base-case traffic estimate: ~2,710 visitors.** At 3% conversion, that yields ~81 subscribers. To reach 500 at 3% conversion, you need 6x the current estimated traffic.

---

## What If the Guardian Piece Underperforms?

The Guardian piece is 80-90% of Day 1 traffic in every scenario. If it underperforms:

| Guardian scenario | Guardian conversions | Total Day 1 (with other channels) |
|-------------------|---------------------|-----------------------------------|
| Strong (viral, 5,850 clicks) | 293 | ~332 |
| Base (2,600 clicks) | 78 | ~88 |
| Weak (1,170 clicks) | 23 | ~25 |
| No article / delayed | 0 | ~10 |

**Without the Guardian piece, Day 1 is effectively dead.** The other channels combined produce ~10 subscribers.

---

## Minimum Viable Day 1 Number

**Economics question:** Below what subscriber count does the model break?

At $49/subscriber:
- 500 subscribers = $24,500 Day 1 revenue
- 88 subscribers = $4,312 Day 1 revenue
- 25 subscribers = $1,225 Day 1 revenue

The Day 1 number doesn't need to sustain the economics alone — it needs to:
1. **Generate social proof** for press and word-of-mouth amplification
2. **Validate demand** for ongoing marketing investment
3. **Create enough concurrent readers** for organic sharing to kick in

**Minimum viable:** ~100 subscribers. Below this, there aren't enough simultaneous readers to generate word-of-mouth momentum. The product feels dead. Press won't write follow-up stories about a product with invisible traction.

**Comfortable launch:** ~200 subscribers. Enough for social proof, enough for word-of-mouth to compound over 42 days, enough to tell a "growing" story to press.

**The 500 target was aspirational.** It requires the bull case across multiple channels simultaneously.

---

## The Gap: What's Missing

To get from ~88 (base case) to 500, you need ~412 additional subscribers. Options:

### 1. Paid acquisition ($8,000-$20,000)
At $49 product price and 2% conversion rate on paid traffic:
- Cost per landing page visitor (Instagram/Facebook literary audience): $1.50-$3.00
- Visitors needed for 412 conversions at 2%: 20,600
- Cost: $31,000-$62,000 at cold traffic rates
- With retargeting (warmer): $15,000-$30,000

**Verdict:** Expensive. Not in current budget. But if $20K marketing line exists, this is the most controllable lever.

### 2. Pre-launch email list (not just oBitchuary)
Build a dedicated dezibel waitlist via:
- Guardian article CTA → email signup (not purchase) → nurture → launch day email
- Landing page collects emails for 4-8 weeks pre-launch
- Email list of 5,000 at launch → 40% open → 15% click → 5% purchase = 15 conversions

**Verdict:** Modest but additive. The real value is converting Guardian article interest into retargetable leads rather than expecting same-session purchase.

### 3. Influencer seeding (not BookTok — literary/culture influencers)
- 5-10 culture writers/podcasters with 10K-100K followers each
- If 3 post about it: ~50,000 combined reach → 500-1,000 LP visitors → 15-30 conversions

**Verdict:** Plausible if relationships exist. Not currently planned.

### 4. Price adjustment
- At $29: conversion rate roughly doubles (2% → 4%). Base case moves from ~88 to ~176.
- At $19: conversion rate ~3x. Base case moves to ~264.
- Trade-off: lower revenue per subscriber, different audience signal.

### 5. Two-step funnel (biggest unlock)
Instead of article → landing page → $49 purchase (cold), use:
- Article → free first chapter/Day 1 preview → email capture → nurture sequence → purchase
- This changes the article CTR target from "click to buy" to "click to try" — dramatically higher conversion at each step
- Industry benchmark: free trial → paid conversion for digital products: 15-25%

**If 2,600 Guardian visitors sign up for free preview (10% of readers) and 15% convert to paid:**
2,600 × 10% = 260 free signups × 15% = 39 paid
But if the free preview is frictionless and compelling, signup rate could be 20-30%:
2,600 × 25% = 650 free signups × 15% = 98 paid

**This is the single highest-leverage change.** A free Day 1 preview converts "interested reader" into "invested reader" before asking for $49.

---

## Verdict

### K16: Is 500 Day 1 subscribers achievable?

**NO — not with current channels and approach.**

- Base case: ~88 subscribers
- Bull case: ~377 subscribers
- Even the bull case doesn't reach 500
- 500 requires either (a) paid acquisition budget of $15-30K, (b) multiple confirmed press outlets beyond Guardian, (c) a pre-launch email list of 5,000+, or (d) a fundamental funnel redesign (free preview → paid conversion)

**Classification: 500 is ASPIRATIONAL. 100-200 is realistic. Below 50 is the failure case.**

### K15: Does the Guardian piece convert 200-300?

**UNLIKELY at $49 with a direct-purchase funnel.**

- Base case: ~78 conversions from Guardian
- Bull case (article goes viral): ~293 conversions — the top of the range, not the expectation
- The 200-300 estimate requires either (a) the article reaching well beyond Guardian's core audience, (b) a lower price point, or (c) a two-step funnel (free preview → paid)
- With a two-step funnel and Guardian traffic, 200 from this channel alone becomes plausible

**Classification: 200-300 from Guardian alone is a STRETCH target. 50-100 is the realistic range. The estimate should be revised downward or the funnel should be redesigned.**

### Recommendation

The most impactful change is not more channels — it's funnel architecture. Shift from:

> Article → $49 purchase (1-3% conversion on cold traffic)

To:

> Article → free Day 1 preview → email capture → 3-day nurture → purchase (15-25% conversion on warm leads)

This single change could move the realistic Day 1 number from ~88 to ~200+, making the 500 target achievable with modest paid acquisition on top.

---

## Sources

- [Center for Media Engagement — Using Links to Keep Readers on News Sites](https://mediaengagement.org/research/links/) — 1.42% link CTR across 1.8M observations
- [Pew Research — Long-Form Reading](https://www.pewresearch.org/journalism/2016/05/05/long-form-reading-shows-signs-of-life-in-our-mobile-news-world/)
- [Simon Owens — Realistic conversion rate for paid newsletters](https://simonowens.substack.com/p/whats-a-realistic-conversion-rate) — 1-3% typical, 5% strong
- [Really Good Business Ideas — Substack average paid conversion](https://www.reallygoodbusinessideas.com/p/substack-average-paid-subscriber-conversion-rate)
- [Unbounce — Average conversion rates landing pages (Q4 2024)](https://unbounce.com/average-conversion-rates-landing-pages/) — 6.6% average, 2-5% for ecommerce
- [Shopify — Landing page conversion rate benchmarks 2025](https://www.shopify.com/blog/landing-page-conversion-rate)
- [Reforge — Word of Mouth Coefficient](https://www.reforge.com/blog/word-of-mouth-coefficient)
- [WriteStats — BookTok driving 59M book sales](https://writestats.com/booktok-for-authors-how-tiktok-is-driving-59-million-book-sales/)
- [Publishers Weekly — BookTok sales trajectory](https://www.publishersweekly.com/pw/by-topic/industry-news/bookselling/article/93014-booktok-helped-book-sales-soar-how-long-will-that-last.html)
- [Newsletter Operator — Newsletter benchmarks](https://www.newsletteroperator.com/p/newsletter-benchmarks)
- [LinkJolt — CTR benchmarks by industry 2025](https://www.linkjolt.io/blog/click-through-rate-benchmarks-by-industry)
- [Databox — Funnel conversion rate benchmarks](https://databox.com/improve-your-funnel-conversion-rate)
