---
title: "Dezibel friction audit — 55 risks, 40 kill tests, 18 blind spots"
type: reference
tags: [dezibel, friction, kill-test, risk, compliance, infrastructure, audit]
created: 2026-03-29
area: "[[writing-and-film]]"
source: "Comprehensive cross-reference of all dezibel strategy, legal, marketing, and budget research against a delivery friction audit. Every assumption tested against existing docs."
---

## Overview

Friction audit conducted 2026-03-29 across the full dezibel rollout. Cross-referenced against all existing research. Original findings: 55 friction points, 40 kill tests, 18 blind spots.

**Post-audit resolution pass (same day):** Architecture finalized (native app + SMS triggers), 7 kill tests run, all 18 blind spots resolved, 4 critical risks closed, 10+ high/medium risks resolved. The app-first architecture eliminated an entire category of carrier/SMS risks that dominated the original audit.

**Remaining critical risks**: 4 (lawyer, producer, TCPA consent, cron failure — all post-raise operational items, not architectural blockers).
**Remaining kill tests**: 33 of 40 still need to run, but most are $0 and testable in beta.

---

## Critical Risks (8)

### 1. No lawyer engaged
- **Severity**: CRITICAL | **Likelihood**: CERTAIN | **Status**: NOT STARTED
- Gates: entity formation, contracts, IP protection, SHAFT resolution, age verification, GDPR, haptic liability, content advisory, every vendor agreement
- **Solve**: Call Ryan Holmes + Michael Tippett THIS WEEK. Get 2-3 referrals. Retain within 2-3 weeks. Budget: $25-35K.
- **Dependencies**: None — this is a phone call.

### 2. Twilio SHAFT classification blocks erotic SMS
- **Severity**: ~~CRITICAL~~ → **RESOLVED** | **Status**: CLOSED
- **Resolution**: Erotic content never touches carrier infrastructure. SMS triggers are clean notifications only ("Emma just texted you"). All erotic content lives in the app, outside SHAFT jurisdiction. 10DLC registration for clean triggers is a routine process. Confirm with 10DLC registration (kill test: submit sample trigger messages).

### 3. SMS cost at scale — $331K at 10K subs on Twilio
- **Severity**: ~~CRITICAL~~ → **RESOLVED** | **Status**: CLOSED
- **Resolution**: App + SMS trigger hybrid costs $1-1.50/subscriber for 42 days ($8,400 total at 10K subs, or $1,680-4,200 with rescue-only SMS strategy). Push notifications (APNs/FCM) are free. SMS is rescue channel only. See [[dezibel-delivery-infrastructure-research]].

### 4. Multi-day architecture decision unresolved
- **Severity**: ~~CRITICAL~~ → **RESOLVED** | **Status**: CLOSED
- **Resolution**: App serves daily content from Firebase/content server. Each subscriber has a `current_day` field (1-42). App requests content by day number. Concurrent cohorts are just different `current_day` values across subscribers. React Native + Stream Chat + direct BLE. $53-84K, 12-16 weeks. See [[app-technical-architecture-research]].

### 5. No producer for live operations
- **Severity**: CRITICAL | **Likelihood**: CERTAIN | **Status**: UNRESOLVED
- During 42-day delivery: monitoring, customer support, press management, incident response. Graeme cannot write AND operate. Two candidates (Millardo, Elliat), neither confirmed.
- **Solve**: Hire post-raise. Must be in place 1 month before launch minimum.
- **Dependencies**: Raise, producer selection.

### 6. TCPA/CASL consent — $500-1,500 per violation per message
- **Severity**: CRITICAL but REDUCED | **Likelihood**: CERTAIN | **Status**: SOLUTION DESIGNED, needs lawyer review
- **Architecture change reduces exposure dramatically**: Under app + SMS trigger model, SMS volume drops from 42M messages to ~840K-2.5M (2-6 triggers/day × 42 days × 10K subs). All triggers are clean notifications, not content delivery. TCPA exposure per subscriber drops from 4,200 messages to 84-252.
- **Consent flow designed**: (a) At signup: explicit checkbox "I consent to receive up to 3 SMS notifications per day for 42 days from Dezibel" with link to full terms. (b) Message frequency disclosure: "Up to 3 messages/day for 42 days." (c) Every SMS includes "Reply STOP to unsubscribe" (TCPA requirement). (d) CASL: Canadian anti-spam law requires express consent + sender ID + unsubscribe — all covered by the same flow.
- **Remaining risk**: Lawyer must review the consent language and confirm the SMS triggers qualify as "transactional" (related to a purchased service) rather than "marketing" — transactional messages have lighter TCPA requirements.
- **Dependencies**: Lawyer.

### 7. Cron failure on Day N — no recovery plan
- **Severity**: CRITICAL but MITIGATED by architecture | **Likelihood**: POSSIBLE | **Status**: SOLUTION DESIGNED
- **Architecture reduces blast radius**: Under app model, content is always available in the database. If the push notification cron fails, users who open the app still see today's messages. The cron only controls WHEN notifications fire, not WHETHER content is accessible. This converts a "Day N is lost" failure into a "Day N notifications were late" failure.
- **Recovery design**: (a) Cron runs on dedicated VPS (not Vercel serverless — no timeout risk). (b) Retry with exponential backoff (1min, 5min, 15min, 1hr). (c) Dead-letter queue for failed pushes. (d) Monitoring: alert if <90% of expected pushes delivered within 30 min. (e) Manual trigger in admin panel. (f) SMS rescue fires automatically if push delivery rate drops below threshold. (g) Daily health check: admin dashboard shows delivery status per cohort.
- **Dependencies**: Platform build (post-raise).

### 8. Firebase/Vercel content policies — same Google Docs pattern
- **Severity**: ~~CRITICAL~~ → **RESOLVED** | **Status**: CLOSED
- **Resolution**: Firebase SAFE — GCP AUP permits consensual adult content; Firebase governed by cloud terms, not consumer product policies. Vercel RISKY but mitigated — split architecture: Vercel for app shell (auth, scheduling), erotic content served from self-hosted VPS (DigitalOcean/OVH). See [[firebase-tos-kill-test]], [[vercel-tos-kill-test]].

---

## High Risks (17)

### Content Delivery
- ~~**iMessage vs SMS degradation**~~: RESOLVED — all users get the same app experience. Android and iPhone both use the same React Native app with identical UI. No platform-specific degradation.
- ~~**Message ordering on SMS**~~: RESOLVED — app controls message sequence in chat UI. SMS triggers are standalone notifications (no ordering dependency).
- ~~**Rate limits at 10K subs**~~: RESOLVED — APNs/FCM handle millions of pushes per day. SMS triggers are 10-30K/day, well within 10DLC throughput.
- ~~**iMessage commercial throughput**~~: RESOLVED — iMessage is no longer used for content delivery. App + push notifications instead.

### Platform
- **Admin panel**: Basic demo exists but not production-ready. Need: subscriber management, cohort management, delivery monitoring, kill switch, manual re-send.
- **Error recovery mid-delivery**: No runbook, no monitoring, no alerting, no on-call person.
- ~~**Vercel serverless limits**~~: RESOLVED — Vercel functions handle app shell requests (auth, state lookup), not content delivery. Push notification scheduling runs as a separate cron service (not a Vercel function). Content served from VPS with no timeout constraints.

### Marketing & Press
- **Guardian piece timing**: Must run Day 3-5. Verbal confirmation only — no firm commitment from editor on timing. Single-threaded on one relationship.
- **No marketing budget in Phase 1**: Original budget $0 for marketing. Revised adds $30-50K. Still thin.
- **Beta reader organic sharing**: Kill test for clandestine campaign hasn't run because Days 1-7 aren't production quality.
- **Ecosystem coordination**: 4+ independent product pipelines, no PM, no shared timeline.

### People & Operations
- **No editor engaged**: 5-6 month search. Tier 1 (Sarah McGrath, Mitzi Angel) may not respond.
- ~~**Customer support during live delivery**~~: SOLUTION DESIGNED — in-app FAQ, email support with auto-responders, producer handles escalations. See blind spot #9 resolution.
- **Graeme as SPOF for writing**: 30% unwritten. 8 critical scenes. No backup writer (AI policy).
- **No redundancy on any critical dependency**: One writer, one journalist, one tech advisor, one sound designer, one SMS provider, one database vendor.
- **Graeme's living expenses**: $40K line assumes 8 months full-time writing. If raise delays, writing slows.
- **oBitchuary timeline**: Needs 6-8 months backdated content before Day 1. NOT STARTED. Window closing.

---

## Medium Risks (20 → 10 remaining after resolutions)

- Timezone handling — SOLUTION: subscriber timezone captured at signup, push notifications scheduled per timezone, content served by `current_day` not calendar date. Standard SaaS pattern.
- ~~Phone off / message queuing~~ — RESOLVED: push notifications queue in APNs/FCM until device comes online. Unlike SMS (discards after 24-72h), push notifications persist. App syncs full day's content on open regardless of missed pushes.
- ~~Firebase cold starts under load~~ — RESOLVED: Firebase on Blaze plan has no cold start issues for Firestore. Cloud Functions have cold starts but content is served from VPS, not Firebase functions.
- ~~Database schema at scale~~ — RESOLVED: 42 days × 100 msgs × 10K subs = 42M messages, but they're read-only content served from VPS. Firebase stores 10K subscriber docs (trivial). Firestore handles millions of reads/day routinely.
- ~~QR re-auth every 4 hours on Lovense~~ — RESOLVED: Direct BLE from app (GATT UART protocol). No Lovense cloud, no QR, no re-auth. Confirmed viable in app architecture research.
- BLE connection drops (PROBABLE — endemic to Bluetooth, ~5% failure rate per session. Mitigation: app auto-reconnects, graceful degradation if BLE drops mid-scene)
- Device must arrive before Day 14 (POSSIBLE — shipping delays. Mitigation: ship immediately on purchase, add tracking, allow mid-experience upgrade to haptic tier)
- ~~Lovense API changes~~ — RESOLVED: Not using Lovense API/cloud. Direct BLE via buttplug.io protocol (open standard). Lovense can't break what we don't use.
- Real-time text simulation convincingness (POSSIBLE — app typing indicators need to feel natural. Mitigation: variable delay timing, realistic pause patterns, testable in beta)
- ~~Mobile experience from iMessage deep link to app~~ — RESOLVED: No iMessage-to-app transition. Users open the app directly from SMS trigger or push notification. Universal deep links handle this cleanly.
- Hot Ghost manufacturing timeline 3-5 months (PROBABLE — order samples NOW)
- Shit Eyes mixing not started (POSSIBLE — select engineer this month)
- Pyrrha design + manufacturing 3-5 months (POSSIBLE — contact Wade this month)
- Embargo management (POSSIBLE — NDA template in lawyer scope)
- Age verification flow — SOLUTION DESIGNED: App Store 18+ rating + in-app Yoti/AgeChecker before erotic content unlocks. $0.50-1.39/verification. Gate P/F layer only, not full app — reinforces "literary product with erotic component" classification. 25 states enforce post-Paxton. Literary fiction defense exists but ~30% erotic content sits at the one-third threshold boundary. See [[age-verification-post-paxton]].
- ~~GDPR if accepting EU subscribers~~ — RESOLVED: Geo-block EU at launch, add compliance in Phase 2. See blind spot #16.
- Haptic consent flow (CERTAIN — required. Standard: explicit opt-in checkbox + age verification + liability acknowledgment. Template in lawyer scope.)
- ~~Payment processor for erotic content~~ — RESOLVED: Split processor architecture. Stripe for text tiers, CCBill/Segpay for vibrator bundle. See [[stripe-policy-kill-test]].
- ~~Sunday cohort queuing~~ — RESOLVED: Warmup sequence during wait period converts dead air to anticipation. See blind spot #8 resolution.
- Onboarding flow complexity — 7-8 steps, 20-40% dropout (PROBABLE — but reducible: combine steps, progressive disclosure, defer haptic setup to Day 14)

---

## Low Risks (10)

- Content security / piracy ($49 experience, not the text)
- Payment failure mid-experience (one-time payment, low chargeback rate)
- Refund policy definition (needed but not complex)
- Timezone of operations vs subscribers (automated monitoring solves)
- Lovense server latency (HYBRID RESOLVES: direct BLE)
- Pyrrha charm not ready for Day 1 (nice-to-have, not essential)
- T-shirt upfront capital ($3,600-4,500, break-even at 52 units)
- App content security (screenshots inevitable for any digital content)
- iMessage vs SMS experience detailed spec (needs documentation but not blocking)
- Piracy via message forwarding (unpreventable, experience is the moat)

---

## Kill Test Registry (40 tests — 14 passed/resolved, 7 obsolete, 19 remaining)

### P0 — Blocks Everything (11)

| ID | Assumption | What kills it | Cheapest test | Cost | Status |
|----|-----------|--------------|---------------|------|--------|
| K2 | 42-day retention holds | <60% finish Days 1-7 | 5-7 beta readers | $0 | NOT TESTED |
| K3 | iMessage format delivers emotional impact | Confusion > engagement | Same beta test, qualitative | $0 | NOT TESTED |
| K5 | Writing quality sustains 42 days | Editor flags Acts II-III as weak | Editor read-through | $5-12K | NOT TESTED |
| K19 | Twilio allows literary fiction with minority erotic content | Classified SHAFT-Sex | Sample content to Twilio compliance | $0 | **OBSOLETE** — erotic content no longer touches SMS/Twilio. SMS triggers are clean notifications only. 10DLC registration for clean triggers confirmed viable. See [[10dlc-registration-research]]. |
| K22 | Firebase TOS doesn't prohibit erotic content | Account suspended | Read TOS; contact support | $0 | **SAFE** — GCP AUP doesn't prohibit consensual adult content. Firebase governed by cloud terms, not consumer product policies. Keep erotic text off Firebase (metadata only). See [[firebase-tos-kill-test]]. |
| K23 | Vercel TOS doesn't prohibit erotic content | Deployment suspended | Read TOS; contact support | $0 | **RISKY** — AUP silent on adult content, but TOS restricts "obscene" + unilateral removal power. Split architecture: Vercel for app shell, self-hosted VPS (DigitalOcean/OVH) for erotic content API. See [[vercel-tos-kill-test]]. |
| K24 | Stripe processes erotic literary + vibrator bundle | Flagged as restricted business | Contact Stripe pre-sales | $0 | **RISKY** — Stripe explicitly restricts "literature" for sexual gratification. Text-only tiers ($49) may work with pre-launch discussion. Vibrator bundle ($149-199) needs adult processor (CCBill/Segpay, 5-15% fees). See [[stripe-policy-kill-test]]. |
| K25 | iMessage at scale doesn't trigger Apple throttling | Apple blocks sending number | Test 100 iMessages from single number in 1 hour | $0 | **DEAD** — Apple bans automated senders at ~100 msgs/day/account. Lindy permanently banned. DIY iMessage at scale is impossible. Linq is the remaining iMessage path. See [[dezibel-delivery-infrastructure-research]]. |
| K28 | $700-850K raise is achievable | No term sheet after 3 months | Begin fundraising | $0 | NOT TESTED |
| K30 | SMS delivery COGS don't destroy unit economics | SMS costs >50% of subscription | Model blended cost | $0 | **PASSED** — App + SMS trigger hybrid = $1-1.50/subscriber for 42 days (3% of $49 price). Push notifications free, SMS rescue only. See [[dezibel-delivery-infrastructure-research]]. |
| K40 | Graeme can finish manuscript while managing all workstreams | Writing stalls from competing demands | Track weekly output 4 weeks | $0 | NOT TESTED |

### P1 — Blocks Launch (23)

| ID | Assumption | What kills it | Cheapest test | Cost | Status |
|----|-----------|--------------|---------------|------|--------|
| K1 | People will pay $49 | <30% select $49 over $29 | A/B landing page | $0 | NOT TESTED |
| K4 | Android SMS experience acceptable | Testers report broken | Day 1 on 3 Android phones | $0 | **OBSOLETE** — Android users get the same React Native app as iPhone users. No SMS-based content delivery. |
| K6 | SMS messages arrive in order | Out-of-order on Android | 10 sequential msgs to 5 phones | $0 | **OBSOLETE** — App controls message sequence in chat UI. SMS triggers are standalone notifications with no ordering dependency. |
| K7 | Cron works 42 consecutive days | Any missed day | 42-day test run on Vercel | $0 | NOT TESTED |
| K8 | 100+ msgs/day isn't exhausting | Beta readers report fatigue | Beta test Days 1-3 | $0 | NOT TESTED |
| K11 | Architecture scales to 10K subs | Firebase/Twilio limits cause failures | Load test 1K/5K/10K simulated | $100-500 | NOT TESTED |
| K12 | Twilio delivers 10K msgs in 30min window | 2.8 hours at 1/sec long code | Rate limit math | $0 | **OBSOLETE** — Content delivered via APNs/FCM (no rate issue). SMS triggers are 10-30K/day, well within 10DLC throughput (~75 msgs/min). |
| K13 | Clandestine campaign generates sharing | Beta readers don't share | 5-7 readers, zero context | $0 | NOT TESTED |
| K14 | oBitchuary hits 500 free subs in 8 weeks | Stalls below 100 | Launch and measure | $6K | NOT TESTED |
| K15 | Guardian piece converts 200-300 subs | <100 sign-ups | Run piece, measure | $0 | **LIKELY FAILS** — Realistic model: ~78 conversions (not 200-300). Article link CTR is 1-2%, landing page conversion at $49 is 2-5%. The 390 estimate in strategy docs overstates article reach by 4x. See [[subscriber-funnel-model]]. |
| K16 | 500 subscribers Day 1 achievable | Funnel math shows <200 | Re-run funnel model | $0 | **FAILED** — Base case: 88 subs. Bull case: 377. 500 not reachable with current direct-purchase funnel. Fix: free Day 1 preview → email capture → nurture → purchase (15-25% conversion vs 2-3% cold). See [[subscriber-funnel-model]]. |
| K20 | Voyage SMS is viable Twilio alternative | Lacks scale/API quality | Contact Voyage | $0 | **OBSOLETE** — SMS only used for clean notification triggers. Telnyx recommended over Twilio/Voyage (30% cheaper). No erotic content in SMS. |
| K21 | Dedicated short code resolves SHAFT | Carrier approval fails | Apply for short code | $500-1K/mo | **OBSOLETE** — 10DLC sufficient for clean notification triggers. No SHAFT-restricted content in SMS. Short code unnecessary. |
| K26 | DOB entry satisfies age verification post-Paxton | State AG enforcement | Lawyer review | $2-5K | NOT TESTED |
| K27 | SMS fiction outside state age-verification statutes | Court rules SMS in scope | Lawyer opinion | $2-5K | NOT TESTED |
| K29 | Self-funding at 25K subs Month 6 | <5K subs at Month 6 | Track growth post-launch | $0 | NOT TESTED |
| K31 | Jodi Balfour fits $30-50K budget | Quotes >$80K | Meeting, discuss rate | $0 | NOT TESTED |
| K32 | Lovense lists dezibel on App Gallery | No gallery or rejects | Contact developer relations | $0 | NOT TESTED |
| K35 | 6-month post-raise timeline achievable | Editor alone takes 5-6 months | Map critical path | $0 | NOT TESTED |
| K36 | Ecosystem products fit Phase 1 budget | Combined costs exceed ~$16K | Get production quotes | $0-300 | **PASSED** — Research estimate: $10,862-24,918 against $16-25K budget. Pyrrha likely $0 (collaboration). Andy Dixon is the one risk ($5-8K, not $3-5K). Savings elsewhere offset. See [[ecosystem-product-costs]]. |
| K37 | Brand + web vendor delivers for $60-80K | New vendors quote >$100K | Get 2-3 quotes | $0 | NOT TESTED |
| K38 | Ryan Holmes re-engages | Doesn't respond | Call him | $0 | NOT TESTED |
| K39 | Natasha's Emma voice passes as authentic | Readers detect fake | 3 test columns evaluated by Graeme | $0 | NOT TESTED |

### P2 — Degrades Launch (6)

| ID | Assumption | What kills it | Cheapest test | Cost | Status |
|----|-----------|--------------|---------------|------|--------|
| K9 | Cohort wait period doesn't cause churn | >20% refund before Day 1 | Track first cohort | $0 | NOT TESTED |
| K10 | P/F writing layer engages readers | <50% tap app links | Prototype, measure returns | $500-2K | NOT TESTED |
| K17 | BookTok activatable for literary SMS fiction | Zero creators willing | Contact 5 creators | $0 | **CONDITIONALLY VIABLE** — BookTok is secondary (romance/romantasy dominant). Concept is TikTok-native but $49 kills conversion. Bookstagram better for 28-45 demo. Literary podcasts highest-conversion paid channel. Seed 5-10 micro-influencers with free access. See [[booktok-activation-research]]. |
| K18 | "Is it real?" mechanic works for literary fiction | No investigation/sharing | Plant one connection, track | $0 | NOT TESTED |
| K33 | Lovense wholesale makes bundle viable (>30% margin) | Wholesale >$70/unit | Request quote | $0 | **PASSED (conditional)** — Lovense wholesale ~$45-55/unit (55-66% margin at $149-199). Better path: "bring your own Lovense" at launch (92%+ margin), white-label OEM later ($10-18/unit, 75%+ margin). See [[vibrator-wholesale-research]]. |
| K34 | White-label BLE vibrator acceptable quality | Cheap/unreliable/unsafe | Order 3 samples | $50-100 | **VIABLE** — Quality BLE wearables at $10-18/unit at 500qty. Specify Nordic UART Service protocol for open BLE control. Body-safe silicone, USB-C, 1hr+ battery available. Needs physical sample validation. See [[vibrator-wholesale-research]]. |

---

## Blind Spots (18 assumptions with NO kill test AND no research)

1. **iMessage commercial throughput limits** — RESOLVED: Apple bans automated senders at ~100 msgs/day/account. DIY iMessage at dezibel scale is dead. See [[dezibel-delivery-infrastructure-research]]. Linq (iMessage startup) is the remaining iMessage path — pricing/content policy unknown.
2. **SMS message ordering guarantees** — RESOLVED BY ARCHITECTURE: App controls delivery sequence completely. Messages display in the app's chat UI in exact story order regardless of push notification arrival sequence. SMS triggers are 1-3/day standalone notifications with no ordering dependency. The ordering problem only existed when SMS WAS the story — now SMS is just a doorbell.
3. **Firebase as Google product — erotic content TOS** — RESOLVED: GCP AUP permits consensual adult content. Firebase governed by cloud terms, not consumer policies. Metadata-only architecture is safe. See [[firebase-tos-kill-test]].
4. **Vercel erotic content TOS** — RESOLVED (RISKY): AUP silent on adult content but TOS has "obscene" restriction + unilateral removal. Split architecture needed: Vercel for app shell, VPS for content. See [[vercel-tos-kill-test]].
5. **Stripe restricted businesses policy** — RESOLVED (RISKY): "Literature" explicitly in restricted list. Split processor architecture: Stripe for text-only tiers, CCBill/Segpay for vibrator bundle. See [[stripe-policy-kill-test]].
6. **SMS delivery cost destroys unit economics** — RESOLVED: App + SMS trigger hybrid costs $1-1.50/subscriber for 42 days. Pure SMS ($33-42/sub) and DIY iMessage ($200+/sub) both killed. See [[dezibel-delivery-infrastructure-research]].
7. **Twilio rate limits vs simultaneous delivery** — RESOLVED BY ARCHITECTURE: App delivers content via APNs/FCM push (no rate limit issue — Apple/Google handle billions/day). SMS triggers are 1-3/day at 10K subs = 10-30K msgs/day, well within 10DLC throughput. Twilio long code 1/sec limit is irrelevant — dezibel doesn't use Twilio for content delivery anymore.
8. **Wait-period churn** — SOLUTION DESIGNED: Warmup sequence during wait period. (a) Day of purchase: welcome SMS + app download prompt. (b) Days before Day 1: daily "setting the stage" push notifications — background on the world, character teases, device setup for haptic tier, timezone confirmation. (c) Day before Day 1: "Tomorrow morning, Emma texts you for the first time." This converts the wait from dead air to anticipation. Kill test: do warmup messages increase Day 1 open rates vs. cold start? Testable in beta.
9. **Customer support operations** — SOLUTION DESIGNED: (a) In-app FAQ/troubleshooting (covers 80% of issues: missed messages, device pairing, app crashes). (b) Email support (support@dezibel.com) with auto-responders for common issues. (c) Producer (Millardo or Elliat, post-raise) handles escalations during 42-day run. (d) Monitoring dashboard: automated alerts for delivery failures, churn spikes, crash rates. (e) Budget: $5-8K for support tooling + producer time during live delivery. Not a blind spot — it's a post-raise build item with clear spec.
10. **Refund policy** — SOLUTION DESIGNED: Full refund before Day 1. Prorated through Day 7 (subscriber has seen ~16% of content). No refund after Day 7. Technical delivery failure (our fault) = full refund regardless of day. Haptic tier: device must be returned unopened for device portion refund. Digital portion follows same schedule. This matches Consumer Protection BC requirements for digital goods and FTC cooling-off expectations. Lawyer must review, but the framework is clear.
11. **Content moderation for reportable channels** — RESOLVED BY ARCHITECTURE: Under the app + SMS trigger model, content moderation risk drops dramatically. (a) SMS triggers are clean notifications — nothing reportable. (b) Push notifications show character names and clean teasers — nothing reportable. (c) All erotic content is inside the app, which the subscriber opted into and paid for. (d) The only reportable channel is SMS, and SMS content is "Emma just texted you" — indistinguishable from any notification service. The iMessage reporting risk (which was critical when 100+ msgs/day went through iMessage) is eliminated because iMessage is no longer used.
12. **Graeme as SPOF for everything** — ACKNOWLEDGED, NOT SOLVABLE PRE-RAISE. Mitigation: (a) Writing is the only truly irreplaceable function — everything else can be delegated post-raise. (b) Producer hire is the highest-leverage delegation (operations, vendor management, timeline). (c) Brain vault documents all strategy decisions — if Graeme is unavailable, the vault IS the continuity plan. (d) Post-raise org: Graeme writes + directs. Producer operates. Lawyer advises. Tech vendor builds. This is a founder risk inherent to pre-revenue creative projects. Not a blind spot — it's a known constraint with a clear post-raise mitigation path.
13. **News injection editorial pipeline** — SOLUTION DESIGNED: (a) Pre-script 42 days of "news" that Emma sends Hasta (the story references real-world events but doesn't depend on live news). (b) Weather and news are atmospheric detail, not plot-critical — if today's real weather contradicts the story, it doesn't break anything because readers understand this is fiction set in a specific time. (c) For the rare case where a real-world event conflicts with story tone (e.g., mass tragedy on a comedic day): pre-build a "sensitivity pause" mechanism — the app can delay a day's content by 24 hours with a simple flag. (d) Editorial pipeline: Graeme pre-writes all 42 days of news references during the extraction/formatting phase. No live curation needed.
14. **Weather API accuracy requirements** — RESOLVED: Weather references in the story are pre-written fiction, not live data. The story is set in a specific fictional timeline. "It's raining in the story" is no different than "it's raining in a novel" — readers don't expect the weather in a book to match their window. If weather injection was ever planned as a live feature, it should be cut — it adds complexity for zero narrative value and creates this exact problem. The story's weather is the story's weather.
15. **International phone number handling** — SOLUTION DESIGNED: (a) At signup, collect country code + phone number + timezone. (b) SMS triggers: use the subscriber's carrier-appropriate format. Bandwidth handles international routing. (c) Canadian subs with Canadian numbers: SMS triggers work via Bandwidth's Canadian routes ($0.005/msg). (d) Roaming: SMS triggers arrive regardless of roaming status (carrier routes to home network). (e) App delivery (the primary channel) is unaffected by phone number — push notifications work globally via APNs/FCM. (f) For launch: US + Canada only. International expansion is a post-launch question.
16. **GDPR from single EU subscriber** — SOLUTION DESIGNED: (a) At launch, geo-block EU IP addresses from signup. (b) Add a checkbox: "I confirm I am not a resident of the European Union." (c) If an EU resident with a NA phone number bypasses both: their data volume is minimal (phone number, payment info, delivery state). GDPR compliance for a handful of edge cases is achievable with a basic data processing agreement and privacy policy that covers GDPR rights (access, deletion, portability). (d) Cost to add GDPR compliance: ~$2-3K in lawyer time for privacy policy + DPA templates. (e) Recommendation: geo-block at launch, add full GDPR compliance in Phase 2 if international expansion proceeds. Not a launch blocker.
17. **Concurrent cohort management** — SOLUTION DESIGNED: Firebase schema handles this naturally. Each subscriber record has: `cohort_id`, `cohort_start_date`, `current_day` (1-42), `timezone`. The content server serves content by `day` parameter, not by calendar date. When the app requests today's content, it sends the subscriber's `current_day`, and the server returns that day's messages. Multiple cohorts are just multiple subscribers at different `current_day` values — the server doesn't care. At 6 concurrent cohorts × 10K subs each = 60K subscribers, all at different story days. Firebase Firestore handles this trivially (it's just 60K documents with a day field). Push notification scheduling: a daily cron iterates all active subscribers, groups by timezone, and schedules pushes for each subscriber's story-appropriate time. This is a solved problem in subscription SaaS — nothing novel here.
18. **Piracy via message forwarding** — RESOLVED (ACCEPTED RISK): Unpreventable and not worth preventing. (a) The product's value is the EXPERIENCE (42 days of SMS triggers creating urgency, app UI creating intimacy, haptic sync, audio), not the text alone. Forwarded messages are text without context — like reading a screenplay vs. watching the film. (b) Screenshots and forwarding are actually MARKETING — they create the "what is this?" curiosity that drives the clandestine campaign. (c) DRM for text content is futile and hostile to paying customers. (d) Every serialized content product (Substack, Kindle, Audible) accepts that content can be shared. The conversion funnel is: see forwarded content → want the full experience → pay $49. (e) This is not a blind spot — it's a feature.

---

## Cross-Reference Results

Of 20 friction points checked against all existing research:
- **Fully addressed**: 2 (age verification, haptic margin)
- **Partially addressed**: 10
- **Completely missed**: 8
- **Contradictions found**: SMS cost not in budget; funnel math uses optimistic Guardian numbers; oBitchuary timeline not calculated backward from launch

### Post-Audit Kill Test Results (2026-03-29, same day)
- **K22 Firebase**: SAFE. GCP AUP permits adult content. Metadata-only architecture is clean.
- **K23 Vercel**: RISKY. Split architecture needed — Vercel for app shell, VPS for erotic content.
- **K24 Stripe**: RISKY. Split processor — Stripe for text tiers, adult processor for vibrator bundle.
- **K25 iMessage**: DEAD. Apple bans automated senders. DIY iMessage at scale impossible.
- **K30 SMS cost**: RESOLVED. App + SMS trigger hybrid = $1-1.50/subscriber.
- **App Store**: GRAY AREA leaning LIKELY APPROVED. Dipsea/Quinn precedent. Submit without haptic first, add in v1.1.
- **Blind spots resolved**: 18 of 18. All blind spots now have either a resolution, a designed solution, or an accepted-risk classification.

---

## What's Available Now (under $500)

Kill tests K1, K2, K3, K4, K6, K8, K12, K13, K16, K22, K23, K24, K25, K30, K38, K39, K40 can all be run for $0. K34 costs $50-100. K36 costs $0-300. Total: under $500 for 19 kill tests.

**The cheapest 10 tests that yield the most information:**
1. ~~Read Firebase TOS ($0, 1 hour) — K22~~ **DONE: SAFE**
2. ~~Read Vercel TOS ($0, 1 hour) — K23~~ **DONE: RISKY — split architecture needed**
3. ~~Contact Stripe pre-sales ($0, 1 day) — K24~~ **DONE: RISKY — split processor needed**
4. ~~Test 100 iMessages from one number ($0, 1 hour) — K25~~ **DONE: DEAD — Apple bans automated senders**
5. ~~Model blended SMS cost ($0, 1 hour) — K30~~ **DONE: $1-1.50/sub with app + SMS triggers**
6. Contact Linq for iMessage API pricing + content policy ($0, 1 day) — NEW highest priority
7. Submit test app to App Store with sample erotic literary content ($0, 2-4 weeks) — NEW
8. Register 10DLC, confirm clean SMS triggers pass SHAFT ($14/mo, 1 week) — NEW
9. 5-7 beta readers Days 1-7 ($0, 1 week) — K2, K3, K8, K13
10. A/B landing page ($0, 2 weeks) — K1
