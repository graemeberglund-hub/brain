---
title: "Dezibel"
type: project
tags: [dezibel, serialized-fiction, imessage, sms, launch, fundraising]
created: 2026-03-25
updated: 2026-03-29
name: "Dezibel"
areas: [writing-and-film]
arc: deliverable
repo: dezibel
origin: "42-day serialized novel delivered over iMessage — multi-product literary experience targeting $100M global sales"
spawned_by: null
enables:
  - Dezibel Sequel — That Night (film, Oddfellows Pictures)
  - Dezibel International Expansion
  - Shit Eyes Album Release
  - Format Licensing / Platform Play
  - P/F Paperback (standalone)
value_note: "First-of-kind iMessage-delivered serialized fiction. No category exists."
parked_reason: null
repo_paths:
  - path: "/Users/graeme/Development/dezibel-editor/"
    label: Main repo (story, editor tooling, strategy)
  - path: /Users/graeme/Desktop/DEVELOPMENT/dezibel-legal/
    label: Legal requirements + research
  - path: /Users/graeme/Desktop/DEVELOPMENT/dezibel-marketing/
    label: Marketing strategy + research
  - path: /Users/graeme/Desktop/DEVELOPMENT/dezibel-budget/
    label: Adversarial budget analysis
---

## About

Dezibel is a serialized novel delivered over iMessage across 42 days (6 weeks, Sunday to Sunday). Readers receive daily text conversations between Hasta and Emma (100+ messages/day), with an embedded erotic novella (Poppi Devours Fanzo) delivered through a companion app, audio elements, and an optional Lovense haptic tier. The governing phrase is "ascent as collapse" — direction upward, form falling apart.

**Current state:** 70% through writing. Functional Day 1 demo (Next.js/Firebase/Twilio/Vercel). No raise completed. No lawyer. Cast identified via relationships, not contracts. Leda confirmed ($1,500). Comprehensive strategy research complete across 4 repos (~7,700 lines). Zero kill tests run.

## Delivery Architecture (2026-03-29, revised)

**Native app + SMS triggers — all content in app, SMS creates urgency:**

- **App layer** (React Native, iOS + Android): iMessage-like chat UI (Stream Chat components). 100+ msgs/day delivered free via APNs/FCM push notifications. P/F writing space, audio player, haptic BLE integration (direct GATT, no Lovense cloud), all erotic content.
- **SMS trigger layer**: 1-3 real SMS/day ("Emma just texted you") as engagement triggers. Clean content — passes SHAFT. Push notifications primary, SMS rescue for users dark >24h.
- **Content server** (self-hosted VPS — DigitalOcean/OVH): Hosts P/F novella, audio, media. No third-party content policy exposure.
- **App hosting**: Vercel for app shell (auth, scheduling). Erotic content API on separate VPS.
- **Database**: Firebase for subscriber state/schedules only. No erotic text in Firebase.

**Cost per subscriber: $1-1.50 for 42 days** (vs. $33-42 pure SMS). App build: $53-84K (within $60K budget line if tight).

**Split infrastructure pattern** — erotic content always on infrastructure you own:
- Vercel → app shell only (TOS "obscene" restriction)
- Firebase → metadata only (GCP AUP is safe, but stay clean)
- Stripe → text-only tiers ($49). Vibrator bundle → CCBill/Segpay (5-15% fees)
- App Store → submit v1 without haptic, add BLE in v1.1 (Dipsea/Quinn precedent for erotic literary)

**Killed paths**: DIY iMessage automation (Apple bans at ~100 msgs/day/account), SMS/RCS/WhatsApp (SHAFT), Signal/Matrix (no API/audience), Google Docs (content policy). See [[dezibel-delivery-infrastructure-research]].

**Linq wildcard**: iMessage startup ($20M, 30M msgs/month). Same Mac hardware approach Apple blocks. AUP prohibits "obscene" content. Worth one email to sales — kills or opens the path. Not the primary plan.

**Decided**: Google Docs is not viable for the P/F writing layer. See [[google-docs-not-viable-pf-delivery]].

## Critical Path

```
1. GET A LAWYER → 2. RUN KILL TESTS ($0-500) → 3. LOCK DEMO → 4. RAISE CAPITAL ($700-850K staged)
     ↓                                                              ↓
5. FINISH WRITING (8 critical scenes)              6. LAUNCH oBITCHUARY (needs 6-8mo lead time)
     ↓                                                              ↓
7. EXTRACT + FORMAT 42 DAYS → 8. ENGAGE EDITOR → 9. ENGAGE VENDORS
     ↓
10. CAST FORMALIZATION → 11. PLATFORM + APP BUILD → 12. TRAILER → 13. MARKETING
```

Steps 5-6 can run NOW without money. Step 2 costs under $500. Everything after 4 requires money. Everything before 4 requires a lawyer.

## Tracks

| Track | Owner | Status | Blocker |
|-------|-------|--------|---------|
| Writing (Acts I-V) | Graeme | 70% — Act I tight, Act II mixed, Act III thin. 8 critical scenes unwritten. | Time + focus |
| Legal | Lawyer (TBD) | Research complete (3,000+ lines across 15 files), no counsel engaged | Need referral (Ryan Holmes / Tippett) — CALL THIS WEEK |
| Fundraising | Graeme | Budget audited ($700-850K staged recommended), no meetings booked | Needs locked demo + lawyer |
| Delivery Architecture | TBD | **RESOLVED**: Native app (React Native + Stream Chat) + SMS triggers. DIY iMessage dead. 10-path research complete. Split infra pattern defined. | App Store content review (submit test app) |
| Casting | Graeme | Leda confirmed ($1,500). Edo confirmed. Jodi target (LA meeting planned). Madison confirmed. | Legal + raise for contracts |
| Sound Design | Eugenio | Attached, waiting on raise | Raise |
| Brand + Web | TBD | Alex Nelson OUT (2026-03-25). No replacement identified. | Vendor search needed |
| Tech/Platform | TBD | Demo functional. Architecture finalized: React Native + Stream Chat + direct BLE. $53-84K, 12-16 weeks. | Raise + App Store approval |
| Editor | TBD | No candidate identified. Tier 2 (Liz Johnston) most accessible. | Writing 80%+ complete |
| oBitchuary | Natasha | Ready, email drafted. URGENT: needs 6-8 months lead time before Day 1. | Launch NOW — only costs $6K (budgeted) |
| Trailer | Graeme directs | Shot list exists, no production. $55-65K. | Raise + cast |
| Marketing | Graeme + coordinator TBD | Research complete. Clandestine campaign thesis UNVERIFIED. | Raise + beta test data |
| Ecosystem Products | Various | Hot Ghost: no samples ordered. Shit Eyes: mix engineer not selected. Pyrrha: Wade not contacted. | Pre-raise actions available ($0-300) |

## Team

| Person | Role | Status | Budget |
|--------|------|--------|--------|
| Jodi Balfour | Emma (lead voice) | Target — LA meeting planned. Apple TV+ connection. | $30k (may be low) |
| Edo Van Breemen | Hasta (lead voice + music) | Confirmed | $20k |
| Madison Isolina | Fanciulla | Friend, confirmed | TBD |
| Leda Paige | Leda (Day 7 vibrator monologue) | **CONFIRMED** (2026-03-27). $1,500. Her home. Acting background. | $1,500 |
| Abbi Jacobson | Jane (photos + audio only) | Warm reconnect. Married to Jodi IRL — press story. | TBD |
| Eugenio Battaliaga | Sound design | Attached, across the street | $8k |
| Natasha | oBitchuary writer + poem selector | Ready pending launch signal | $6k flat (Phase 1), $1k/mo (Phase 2) |
| TBD | Brand identity | Vendor search needed (Alex Nelson out) | $15-25k (estimated) |
| TBD | Website build | Vendor search needed | $15-25k (estimated) |
| Michael Millardo | Producer candidate (operations) | Passionate, not confirmed | TBD |
| Elliat | Producer candidate (creative) | Berlin, VAG event production | TBD |
| Ryan Holmes | Tech advisor + lawyer referral | Haven't spoken in a year | $0 |
| Michael Tippett | Business advisor | Multiple exits, active | $0 |
| Adrienne Matei | Guardian journalist + editor referral | 1M+ readers/week, close friend | $0 (article on traction) |

## Revenue Model

| Tier | Price | Includes |
|------|-------|----------|
| Standard | $49 | 42-day iMessage delivery + app access (P/F writing layer, audio) |
| Haptic | $149-159 | + Lovense Ferri synced to erotic scenes via app BLE |
| Premium Edition | $199-249 | + Hot Ghost incense + Pyrrha charm + printed card |

Delivery COGS: $1-1.50/subscriber for 42 days (push notifications free, SMS rescue triggers ~$0.17-0.42/sub). Unit economics: 95%+ gross margins on text tiers. Vibrator bundle margins reduced by adult payment processor fees (5-15% vs Stripe's 2.9%).

**UNVERIFIED**: $49 price point. Zero people have paid. A/B test ($29/$49/$69) on landing page is the cheapest validation.

## Open Decisions (tracked as positions)

### Decided
- [[division-of-labor-dezibel]] — Graeme writes, AI manages (acted-on)
- [[google-docs-not-viable-pf-delivery]] — Google Docs ruled out, self-hosted P/F layer required (2026-03-29)
- [[oddfellows-approach-sequencing]] — Approach post-launch with sales data, not projections (acted-on)

### Active Beliefs
- [[dezibel-hybrid-delivery-architecture]] — Native app + SMS triggers. iMessage dead. Architecture finalized. (2026-03-29, revised 2x)
- [[dezibel-apple-imessage-partnership]] — Apple partnership worth pursuing, unlikely but high upside (2026-03-29)
- [[dezibel-pricing-model]] — Experience pricing ($49-199) vs content pricing
- [[dezibel-aspirational-positioning]] — Aspirational framing, not oppositional
- [[dezibel-marketing-validation]] — 3-day demo as cheapest demand validation
- [[clandestine-marketing-dezibel]] — Ecosystem breadcrumbs as marketing (UNVERIFIED)

### Open Questions
- [[dezibel-launch-timeline]] — 6 months optimistic, 8-10 realistic
- [[dezibel-raise-strategy]] — Staged ($511K + post-cohort) vs single ($725-850K)
- [[dezibel-casting-emma]] — Jodi Balfour: rate, availability, timeline
- [[dezibel-multi-day-architecture]] — RESOLVED by app architecture. App serves daily content from DB.
- [[dezibel-twilio-erotic-compliance]] — RESOLVED. Erotic content never touches carrier infrastructure. SMS triggers are clean notifications only.
- [[dezibel-brand-web-vendor]] — Who replaces Alex Nelson?
- [[dezibel-100m-goal]] — $100M over 2 years. Requires film deal (Oddfellows) + format licensing + 100K+ subs

## Key Artifacts

- Plan to launch: `dezibel/strategy/plan-to-launch.md` (governing document)
- Working state: `dezibel/work.md`
- Story map: `dezibel/artifacts/readable/dezibel-story-map.html` (363 beats, 5 acts)
- Editor pipeline: `dezibel/editor/` (6 Python CLI tools — scene schema, codex, reverse outline, voice fingerprint, pacing, format audit)
- Editor proposal: `dezibel/strategy/production/editor-pipeline-proposal.md`
- Budget audit: `dezibel-budget/analysis/budget-audit.md`
- Legal sequence: `dezibel-legal/checklists/legal-sequence.md`
- Platform compliance: `dezibel-legal/requirements/platform-compliance.md`
- Press strategy: `dezibel-marketing/research/press-strategy.md`
- Category creation: `dezibel-marketing/research/category-creation-strategies.md`
- Ecosystem rollout: `brain/notes/references/2026-03-27-ref-dezibel-ecosystem-rollout-strategy.md`
- Haptic market research: `brain/notes/references/2026-03-27-ref-haptic-sextech-market-research.md`
- Friction audit (55 risks, 40 kill tests): `brain/notes/references/2026-03-29-ref-dezibel-friction-audit.md`
- Delivery infrastructure (10-path kill test): `brain/notes/references/2026-03-29-ref-dezibel-delivery-infrastructure-research.md`
- Backward timeline: `brain/notes/references/2026-03-29-ref-dezibel-backward-timeline.md`
- Lawyer briefing: `dezibel-legal/requirements/lawyer-briefing.md`
- Firebase TOS kill test: `brain/notes/references/2026-03-29-ref-firebase-tos-kill-test.md`
- Vercel TOS kill test: `brain/notes/references/2026-03-29-ref-vercel-tos-kill-test.md`
- Stripe policy kill test: `brain/notes/references/2026-03-29-ref-stripe-policy-kill-test.md`
- App Store content review: `brain/notes/references/2026-03-29-ref-app-store-erotic-content-kill-test.md`
- App tech architecture: `brain/notes/references/2026-03-29-ref-app-technical-architecture-research.md`
- Push notification engagement: `brain/notes/references/2026-03-29-ref-push-notification-engagement-research.md`
- Linq iMessage API: `brain/notes/references/2026-03-29-ref-linq-imessage-api-research.md`

## Immediate Actions (under $500, no raise required)

### This week
1. Call Ryan Holmes + Michael Tippett for lawyer referral ($0)
2. Launch oBitchuary — brief Natasha, start writing ($0, she's on flat fee) — **MOST TIME-CONSTRAINED ELEMENT**
3. Email Linq sales — describe exact use case, get pricing + content policy answer ($0, 30 min)
4. Email Stripe pre-sales — describe product, ask about text-only tier pre-clearance ($0)
5. Order Hot Ghost samples from 3 manufacturers ($100-300)

### This month
6. Submit test app to App Store with sample erotic literary content ($0, validates or kills native app)
7. Register 10DLC for clean SMS triggers ($14/mo)
8. Finish Days 1-7 to production quality ($0)
9. Run beta test: 5-7 readers with push notification instrumentation ($0)
10. Select mix engineer for Shit Eyes ($0)
11. Contact Lovense developer relations ($0)
12. Contact Wade Papin at Pyrrha ($0)
13. Build A/B landing page for price test ($0)

### Completed research (2026-03-29)
- ~~Review Firebase AUP~~ → SAFE (GCP permits adult content, metadata-only architecture)
- ~~Review Vercel AUP~~ → RISKY (split hosting: Vercel for shell, VPS for content)
- ~~Research Stripe policy~~ → RISKY (split processors: Stripe text tiers, CCBill vibrator bundle)
- ~~Research iMessage automation~~ → DEAD (Apple bans at ~100 msgs/day). Linq is long shot.
- ~~Research delivery infrastructure~~ → 10 paths tested, architecture finalized (app + SMS triggers)
- ~~Research App Store erotic content~~ → GRAY AREA leaning approved (Dipsea/Quinn precedent)
- ~~Research app tech stack~~ → React Native + Stream Chat + direct BLE. $53-84K, 12-16 weeks.
