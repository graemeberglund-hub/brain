---
title: "Dezibel"
type: project
tags: [dezibel, serialized-fiction, imessage, app, launch, fundraising]
created: 2026-03-25
updated: 2026-05-12
name: "Dezibel"
areas: [writing-and-film]
arc: deliverable
repo: dezibel
origin: "42-day multimedia literary experience — serialized fiction, video, audio, and haptics delivered via app, targeting $100M global sales"
spawned_by: null
enables:
  - Dezibel Sequel — That Night (film, potentially with Oddfellows/Phobos)
  - Dezibel International Expansion
  - Shit Eyes Album Release
  - Format Licensing / Platform Play
  - P/F Paperback (standalone)
value_note: "First-of-kind serialized fiction delivered via app + iMessage. No category exists."
parked_reason: null
repo_paths:
  - path: "/Users/graeme/Development/dezibel-editor/"
    label: Main repo (story, editor tooling, strategy)
  - path: "/Users/graeme/Development/dezibel-platform/"
    label: Platform technical architecture (React Native app, Node.js backend, scheduler, channels)
  - path: /Users/graeme/Desktop/DEVELOPMENT/dezibel-legal/
    label: Legal requirements + research
  - path: /Users/graeme/Desktop/DEVELOPMENT/dezibel-marketing/
    label: Marketing strategy + research
  - path: /Users/graeme/Desktop/DEVELOPMENT/dezibel-budget/
    label: Adversarial budget analysis
---

## About

Dezibel is a multimedia literary experience delivered across 42 days (6 weeks, Sunday to Sunday). Readers receive daily text conversations between Hasta and Emma (100+ messages/day), video content featuring the lead cast performing as their characters, an embedded erotic novella (Poppi Devours Fanzo) delivered through a companion app, audio elements, and an optional Lovense haptic tier. The governing phrase is "ascent as collapse" — direction upward, form falling apart.

**Current state (2026-05-12):** 70% through writing. Days 1-23 have prose injected into the story map editor; Days 24-42 need prose. 5-act structure across 54 files. Story map editor is the canonical writing tool (horizontal kanban, 363 beats, bulletproofing, search, prose view, DayPublish pipeline to story/days/). Old beat editor retired. Fundraising strategy rebuilt: $285K minimum raise with revenue share (8%, 2x cap), replacing the failed $875K plan. Full platform technical spec exists in dezibel-platform repo (architecture, SQL schemas, API endpoints, channel router, scheduler). No raise completed. No lawyer engaged. Cast: all potential — Jodi Balfour knows there's "something," Edo and Madison are friends aware of the project, Leda confirmed ($1,500). oBitchuary needs a hire and months of pre-work before Day 1. Community (Invizibel) is vital for the feedback loop.

## Delivery Architecture (2026-05-08, revised)

**React Native app (Expo) + iMessage (Sendblue) + push notifications:**

Full technical spec lives in `dezibel-platform/docs/architecture.md`. Key components:

- **App** (React Native / Expo): Onboarding, Stripe external checkout, channel selection, conversation-style reader view, Google Docs WebView for companion documents, Communication Notifications on iOS (push notifications that look like texts), settings.
- **Backend** (Node.js): REST API, PostgreSQL (readers, cohorts, content, deliveries, docs tables), Bull + Redis scheduling engine, channel router with Sendblue/push/WhatsApp adapters, variable resolution (day-of-week, weather), delivery logging and retry logic.
- **Channel strategy**: iMessage (Sendblue, $100/line/month, 4,000 msgs/day) as primary for iOS. Push notifications as universal free fallback. WhatsApp deferred to V1.1 (NA costs $48/reader — unviable as primary). SMS as last-resort fallback.
- **Google Docs**: WebView to published-to-web URLs for doc entries, poems, obituaries, letters. Not used for P/F erotic content (content policy risk). See [[google-docs-not-viable-pf-delivery]].
- **Payments**: Stripe external checkout (avoids Apple's 30%, saves ~$13/reader). Reader app exemption precedent (Kindle, Audible).

**CONCERN: Apple June 2026 iMessage relay crackdown.** Apple has stated it will "terminate support for non-compliant applications" as of June 2026. Sendblue uses real hardware (not protocol hacks like Beeper Mini) and has operated 5+ years, but Apple's TOS technically prohibits automated iMessage use. Architecture is channel-agnostic — push notifications are the fallback. If Apple moves, the launch channel is push from day one. See `dezibel-platform/docs/risks-and-problems.md` for full risk assessment.

**Cost per subscriber: $0-1.50 for 42 days** (push is free, iMessage ~$0.50/reader). Unit economics: 95%+ gross margins on text tiers.

## Critical Path

```
1. RAISE CAPITAL ($285K revenue share) → 2. HIRE PRODUCER + TECH TEAM
     ↓                                              ↓
3. FINISH WRITING (Days 15-42)        4. PLATFORM BUILD (two-person team, 8-12 weeks)
     ↓                                              ↓
5. ENGAGE EDITOR (structural + line)  6. LAUNCH oBITCHUARY (needs months of pre-work — HIRE SOMEONE)
     ↓                                              ↓
7. PRODUCTION SHOOT (NYC + LA, 4-8 days)  8. INVIZIBEL COMMUNITY SETUP (vital for feedback loop)
     ↓
9. BETA TEST (20-50 readers) → 10. COHORT 1 LAUNCH
```

Writing (step 3) and oBitchuary hiring (step 6) can start NOW without money. Everything else requires the raise.

## Tracks

| Track | Owner | Status | Blocker |
|-------|-------|--------|---------|
| Writing (Acts I-V) | Graeme | 70% — Days 1-23 have prose. Days 24-42 need injection. 8 critical scenes unwritten. | Time + focus |
| Legal | Lawyer (TBD) | Research complete (3,000+ lines across 15 files), no counsel engaged | Need referral |
| Fundraising | Graeme | $285K minimum raise plan complete with market-verified line items. Revenue share structure (8%, 2x cap, 6-month grace). Chris Ferguson (Oddfellows) as potential funder/partner. | Finding the right person |
| Delivery Architecture | TBD | **RESOLVED**: Full technical spec in dezibel-platform repo. React Native + Node.js + PostgreSQL + Bull/Redis + Sendblue/push channel router. | Raise → hire two-person tech team |
| Casting | Graeme | All potential, not hired. Jodi Balfour (Emma) — knows there's "something." Edo (Hasta) — friend, aware. Madison (Fanciulla) — friend, aware. Leda confirmed ($1,500). Abbi Jacobson (Jane) — warm reconnect. | Legal + raise for contracts |
| Sound Design | Eugenio | Attached, waiting on raise | Raise |
| Brand + Web | TBD | Vendor search needed. $12K budgeted (per minimum-raise). | Vendor search |
| Tech/Platform | TBD | Full spec ready in dezibel-platform repo. Two-person contractor team budgeted at $90K CAD (frontend + backend in parallel, 8-12 weeks). Producer manages them. | Raise |
| Editor | TBD | No candidate identified. Need to hire. | Writing 80%+ complete |
| oBitchuary | TBD (need to hire) | Needs a writer who can inhabit Emma's voice. 6 months of pre-work before Day 1 (20-26 entries back-dated). $6K flat for pre-launch, $1K/mo ongoing. | Hire someone — sequencing is tight |
| Trailer | Graeme directs | Shot list exists, no production. Combined shoot with story content. | Raise + cast |
| Community (Invizibel) | TBD | Vital for feedback loop. Circle $219/month. Weekly topics tied to story beats. Cohort discussion spaces. Alumni space. | Raise |
| Marketing | Graeme + coordinator TBD | Research complete. Ecosystem products (album, incense, charm) ARE the marketing. No publicist, no paid social at launch. | Raise + beta test data |

## Team

| Person | Role | Status | Budget |
|--------|------|--------|--------|
| Jodi Balfour | Emma (lead voice + video) | Potential — knows there's "something." Apple TV+ connection. | ACTRA scale (~$991/day) |
| Edo Van Breemen | Hasta (lead voice + music + video) | Friend, aware of project. | ACTRA scale |
| Madison Isolina | Fanciulla | Friend, aware | TBD |
| Leda Paige | Leda (Day 7 vibrator monologue) | **CONFIRMED** (2026-03-27). $1,500. | $1,500 |
| Abbi Jacobson | Jane (photos + audio only) | Warm reconnect. Married to Jodi IRL. | TBD |
| Eugenio Battaliaga | Sound design | Attached, across the street | $5K (per minimum-raise) |
| TBD | oBitchuary writer | Need to hire — Emma's voice, weekly obituary column | $6K flat pre-launch + $1K/mo |
| TBD | Brand + web | Vendor search needed | $12K |
| TBD | Producer (partner track) | Need someone strong. $35K cash + 5-8% equity vesting 24 months. | $35K + equity |
| TBD | Tech team (2 contractors) | Frontend (React Native) + backend (Node.js), managed by producer | $90K CAD |
| Chris Ferguson / Oddfellows | Potential funder/partner | Backrooms (A24, tracking $20-30M opening), Longlegs ($128M), The Monkey ($69M). Graeme made the Backrooms artwork. Vancouver-based. New company Phobos with NEON first-look. | Worth approaching as funder/partner |
| Michael Tippett | Business advisor | Multiple exits, active. Advised against $875K — led to $285K restructure. | $0 |
| Adrienne Matei | Guardian journalist + editor referral | 1M+ readers/week, close friend | $0 (article on traction) |

## Fundraising (2026-05-12, rebuilt)

**$285K minimum raise. Revenue share, not SAFE.**

Governing document: `dezibel-editor/strategy/minimum-raise.md`

| Term | Value |
|------|-------|
| Investment | $285,000 |
| Structure | Revenue share — 8% of monthly adjusted gross |
| Cap | 2x ($570,000 total return) |
| Grace period | 6 months (no payments until Month 12) |
| Buyout option | Graeme can pay remaining cap at any time |
| EP credit | Executive Producer on all Dezibel titles |
| Duration | Until cap hit or 7 years |

**Revenue waterfall:** $285K (raise) → Phase 2 $30-50K from revenue (months 7-9) → Phase 3 $50-75K (months 10-14) → Phase 4 $200-350K (months 15-24) = $485-685K total deployed. Same total as the $875K plan, but $200-400K came from the product earning its own growth.

**Honest return math:** At "likely" scenario (30-50 readers/week), 8% monthly payment = $468-780/month. Return timeline is measured in decades, not years, for a single title. The investor is part patron, part investor. The EP credit, cultural association, and option on future titles are part of the value.

**Dead end: $875K plan.** Presented to Michael Tippett, who reacted negatively. $875K triggers institutional-grade scrutiny from individuals. The plan front-loaded scaling costs (marketing $150-300K, full website $40-60K) into the launch budget. Each reduction ($500K, $325K, $125K) was achieved by loading more work onto Graeme rather than re-researching actual costs. See knowledge graph dead-end entity `875k-fundraise-plan`.

**Open question: multi-city production.** Talent lives in LA, needs NYC + LA locations. Production budget ($32K in minimum-raise) may be understated for multi-city shoot — could be $60-80K. Pushes total to ~$310-330K.

**Chris Ferguson / Oddfellows approach:** Worth talking to as a funder/partner. Different from a friend-investor — Ferguson understands creative risk, has capital, is Vancouver-based, and Graeme has a working relationship (made Backrooms artwork). Backrooms tracking $20-30M opening at A24.

## Market Position

**TAM $12.2B** (web fiction + audio erotica) → **SAM $1.6B** (English-language romance/erotica digital) → **SOM $15-45M** (Year 1-2, 100-300K subs at $49-159 blended).

The category dezibel enters is littered with failures — Radish ($440M acquisition, shut down Dec 2025), Kindle Vella (shut down Feb 2025), Wattpad (MAU declining 10.5% YoY). The failure mode is micropayment/ad-supported libraries. The outlier is Quinn: $11M ARR on $3.2M raised, 440% YoY growth, premium subscription, female-gaze, audio-first. Dezibel's model aligns with what's working (premium, single-title experience, multi-sensory) not what's dying (library, micropayment, volume).

## Revenue Model

| Tier | Price | Includes |
|------|-------|----------|
| Standard | $49 | 42-day app delivery + push/iMessage + P/F writing layer, audio |
| Haptic | $149-159 | + Lovense Ferri synced to erotic scenes via app BLE |
| Premium Edition | $199-249 | + Hot Ghost incense + Pyrrha charm + printed card |

**UNVERIFIED**: $49 price point. Zero people have paid. A/B test on landing page is the cheapest validation.

## Open Decisions (tracked as positions)

### Decided
- [[division-of-labor-dezibel]] — Graeme writes, AI manages (acted-on)
- [[google-docs-not-viable-pf-delivery]] — Google Docs ruled out for P/F erotic content, used for companion literary docs via WebView (2026-03-29)

### Revised
- ~~[[oddfellows-approach-sequencing]] — Approach post-launch with sales data~~ → **REVERSED (2026-05-12).** Chris Ferguson worth approaching pre-launch as funder/partner. Relationship basis: Graeme made Backrooms artwork. Ferguson has capital (Longlegs $128M, The Monkey $69M, Backrooms $20-30M tracking). Different from the original position which assumed a cold investor pitch.

### Active Beliefs
- [[dezibel-hybrid-delivery-architecture]] — Native app + push notifications primary. iMessage via Sendblue secondary. Architecture channel-agnostic. (2026-03-29, revised 2x)
- [[dezibel-pricing-model]] — Experience pricing ($49-199) vs content pricing
- [[dezibel-aspirational-positioning]] — Aspirational framing, not oppositional
- [[dezibel-funnel-architecture]] — Free Day 1 preview → nurture → purchase

### Open Questions
- [[dezibel-launch-timeline]] — 6 months optimistic from raise close
- [[dezibel-raise-strategy]] — $285K revenue share from one person. Chris Ferguson as potential alternative funder/partner.
- [[dezibel-casting-emma]] — Jodi Balfour: potential, knows there's "something," not formally approached
- [[dezibel-brand-web-vendor]] — Brand + web vendor search open. $12K budgeted.
- [[dezibel-100m-goal]] — $100M requires multiple titles, international expansion, and years of compounding
- Apple June 2026 iMessage relay risk — imminent. Push notifications as fallback. Architecture handles this.
- oBitchuary hire — who writes as Emma? Sequencing requires starting months before Day 1.

## Key Artifacts

- **Minimum raise plan**: `dezibel-editor/strategy/minimum-raise.md` ($285K, market-verified)
- Plan to launch: `dezibel-editor/strategy/plan-to-launch.md` (needs update — still references $725-850K)
- Story map editor: `dezibel-editor/artifacts/readable/dezibel-story-map.html` (363 beats, 5 acts, DayPublish pipeline)
- **Platform architecture**: `dezibel-platform/docs/architecture.md` (full spec: SQL schemas, API endpoints, scheduler, channel router)
- **Platform channels**: `dezibel-platform/docs/channels.md` (iMessage/push/WhatsApp comparison)
- **Platform cost analysis**: `dezibel-platform/docs/cost-analysis.md` (build options, operating costs)
- **Platform risks**: `dezibel-platform/docs/risks-and-problems.md` (ranked risk assessment)
- **Platform build plan**: `dezibel-platform/docs/build-plan.md` (phased development, 10-12 weeks)
- Label strategy: `dezibel-editor/strategy/indivizibel-label-strategy.md`
- Ecosystem brief: `dezibel-editor/strategy/indivizibel-ecosystem-brief.md`
- Budget audit: `dezibel-budget/analysis/budget-audit.md`
- Legal sequence: `dezibel-legal/checklists/legal-sequence.md`
- Novella structure: `dezibel-editor/story/notes/novella-structure.md` (12-part Poppi Devours Fanzo)
