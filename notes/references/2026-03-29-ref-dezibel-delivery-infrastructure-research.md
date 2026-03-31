---
type: reference
title: "Dezibel Delivery Infrastructure: 10-Path Kill Test"
created: 2026-03-29
tags: [dezibel, delivery, infrastructure, iMessage, SMS, RCS, WhatsApp, Telegram, PWA, cost-analysis]
status: active
---

# Dezibel Delivery Infrastructure Research

**Context:** Dezibel delivers 100+ messages/day/subscriber over 42 days. Scale: 500-10,000+ subscribers. Content: erotic literary fiction. Messages must feel like real person-to-person texts. Delivery COGS must be under $5/subscriber for 42 days.

**Math baseline:** 100 msgs/day x 42 days = 4,200 messages per subscriber. At 10K subscribers = 42 million total messages.

---

## PATH 1: Mac-Based iMessage Automation

### How it works
AppleScript or CLI tools (imsg, BlueBubbles) control Messages.app on a physical Mac to send iMessages programmatically. Messages go through Apple's iMessage relay servers at zero per-message cost.

### Tools researched
- **imsg** (steipete/imsg): CLI tool, open source, tested 10+ months, 5,000+ messages sent with 99.6% delivery rate, 1.2s average send latency. Uses public macOS APIs and AppleScript — no private APIs. [Source: GitHub steipete/imsg]
- **BlueBubbles**: Open-source JavaScript-based iMessage bridge server. More mature than custom solutions. Lindy migrated to this after their custom Swift daemon got banned. [Source: BlueBubbles GitHub, Lindy blog]
- **AirMessage**: Simpler alternative to BlueBubbles, fewer features. [Source: XDA Developers comparison]
- **pypush**: Python iMessage client, undergoing major rewrite, not stable. UNVERIFIED if it can send at scale without a Mac. [Source: GitHub JJTech0130/pypush]

### Apple's Rate Limiting (THE CRITICAL CONSTRAINT)
- **No published limits.** No documentation on triggers. No appeals process. [Source: Lindy blog]
- **Practical safe threshold:** ~100 outbound iMessages/day per Apple ID. Risk climbs exponentially above this. [Source: Texting Blue, HN discussion]
- **Lindy's experience:** Sent 10,000 messages in 12 hours from one Apple ID. Permanently banned. They expected a few hundred/day and overshot 40x. [Source: Lindy blog post "Three Rewrites, One Apple Ban"]
- **200 messages/hour sustained for 3 hours** reportedly triggers inability to send any iMessages, even to yourself. [Source: Apple Community forums]
- **Spam reports kill faster than volume.** A handful of reports = immediate permanent block. [Source: Texting Blue blog]
- **Ban factors:** New account, high volume, low recipient diversity, lopsided send-to-receive ratio (~4:1 triggers detection). [Source: Lindy blog, HN]
- **Bans are permanent.** New account on same hardware gets banned faster. [Source: HN discussion]

### Throughput per Mac
- 1.2 seconds per message send latency (imsg benchmarks)
- = ~50 messages/minute theoretical max
- = ~3,000 messages/hour theoretical max
- **BUT:** Apple will ban you long before you hit this. Practical safe limit: ~100 messages/day per Apple ID.

### Hardware & Hosting
- **Mac Mini M2:** $599 purchase
- **MacStadium colocation:** $199/month per Mac Mini M4 (10-core, 24GB). 99.99% uptime. No contracts. [Source: MacStadium pricing page]
- **macminicolo.net:** Merged with MacStadium.
- **macOS VM legality:** Apple EULA allows max 2 VMs per physical Mac, only for development/testing/server/personal non-commercial use. Service bureau/time-sharing explicitly prohibited. Using VMs to multiply iMessage accounts would violate EULA. [Source: Apple Community, EULA discussions]
- **Multiple Apple IDs per Mac:** One account active at a time per user session. Could create multiple macOS user accounts but only one active simultaneously. [Source: Apple Community]

### Scale Math (10K subscribers)
- 10K subscribers x 100 msgs/day = 1,000,000 messages/day
- At safe limit of 100 msgs/day/Apple ID = **10,000 Apple IDs needed**
- At 200 msgs/day (risky) = 5,000 Apple IDs
- Each Apple ID needs its own Mac or at minimum its own user session
- 10,000 Mac Minis x $199/mo = **$1,990,000/month** in hosting alone
- Even at 500 subscribers: 500 Apple IDs, 500 Macs = $99,500/month

### Linq (The Startup That Solved This)
- **Linq** (linqapp.com) raised $20M Series A (Feb 2026) specifically for iMessage/RCS/SMS API. [Source: TechCrunch]
- 100+ customers, 30M+ messages/month. [Source: TechCrunch]
- Claims 90% cheaper than legacy APIs (Twilio). [Source: Linq website]
- No per-message pricing (subscription model). Specific pricing not public — requires sales contact.
- Founded by ex-Shipt executives. Backed by TQ Ventures + ex-Apple executive.
- **This is the most promising iMessage path** but: pricing unknown, content policy unknown, startup risk (1 year old).

### Kill Test Results
| Metric | Value |
|--------|-------|
| Per-message cost | $0 (iMessage) but hardware/hosting is the cost |
| 42-day cost at 10K subs | **$1.99M+/month** (DIY) or UNKNOWN (Linq) |
| Content restrictions | None (Apple doesn't scan iMessage content, E2E encrypted) |
| Technical feasibility | PROVEN at small scale (<100 msgs/day/account). UNPROVEN at dezibel scale. |
| UX quality | **10/10** — literally real iMessage |
| Platform shutdown risk | **CRITICAL.** Apple actively bans automated senders. No appeals. |
| Rate limits | ~100 msgs/day/Apple ID safe. Permanent ban above. |
| What kills this | Apple's undocumented rate limiting makes scale impossible without Linq-scale infrastructure |
| Status | **EXPERIMENTAL** (DIY) / **EXPERIMENTAL** (Linq — unproven for content delivery) |

### VERDICT: DEAD for DIY. INVESTIGATE Linq — they may be the path, but content policy and pricing are unknown. The fundamental problem is that Apple treats any automated high-volume sending as spam, and they're right to do so from their perspective. Dezibel needs to send 100 messages/day to the SAME person, which looks exactly like harassment to Apple's detection.

---

## PATH 2: Bandwidth / Tier 1 Carrier Direct

### How it works
Bandwidth owns their own telecom network (CLEC — Competitive Local Exchange Carrier). They're not a reseller like Twilio. They sell directly to enterprises and power Twilio, RingCentral, and others underneath.

### Pricing
- SMS outbound: **$0.004/message** for 10DLC [Source: Bandwidth pricing page]
- Short code SMS outbound: **$0.008/message** [Source: Bandwidth pricing page]
- Plus carrier surcharges: T-Mobile $0.0045, AT&T $0.004 per message (10DLC) [Source: Bandwidth carrier surcharges]
- Total effective cost per SMS: **~$0.008-0.012/message** (base + surcharges)
- Short code monthly lease: ~$500-1,000/month from CSCA
- 10DLC registration: $4 brand + ~$10/campaign/month

### Content Restrictions — THE KILLER
- **SHAFT restrictions apply to ALL US SMS/MMS carriers.** SHAFT = Sex, Hate, Alcohol, Firearms, Tobacco. [Source: 10DLC.org, CTIA guidelines]
- Erotic/sexual content is **explicitly prohibited** on 10DLC, toll-free, AND short code. [Source: 10DLC.org]
- "Explicit references to adult content, sex acts, or pornography, even if legal, are prohibited." [Source: 10DLC.org SHAFT page]
- Even having SHAFT content on your website can get your 10DLC campaign rejected. [Source: 10DLC.org]
- Fines: up to **$10,000 per violation.** [Source: SMS compliance guides]
- This applies to Bandwidth, Twilio, Telnyx, and every US SMS provider — it's a CTIA (carrier industry body) rule, not a provider choice.

### Dedicated Short Code Exception?
- Dedicated short codes historically allowed age-gated SHAFT content with proper compliance.
- However: carriers have been tightening restrictions. Pre-vetting and whitelisting required. [Source: Telnyx docs]
- Cost: $1,000-2,000/month for the short code + per-message fees.
- Even with a dedicated short code, erotic fiction content delivery at 100 msgs/day is extremely high risk.

### Scale Math (10K subscribers)
- 4,200 msgs/subscriber x 10K = 42M messages
- At $0.01/msg (conservative): **$420,000 total**
- At $0.008/msg (optimistic): **$336,000 total**
- Per subscriber: **$33.60-$42.00** for 42 days
- This is within the $49 price point but leaves almost nothing for other costs.

### Kill Test Results
| Metric | Value |
|--------|-------|
| Per-message cost | $0.008-0.012 |
| 42-day cost at 10K subs | **$336,000-$504,000** |
| Content restrictions | **FATAL.** Erotic content explicitly prohibited by CTIA/SHAFT across all carriers. |
| Technical feasibility | PROVEN at scale. Bandwidth handles billions of messages. |
| UX quality | **7/10** — SMS works but no typing indicators, read receipts, or rich features |
| Platform shutdown risk | **CRITICAL** for erotic content. Fines of $10K/violation. |
| Rate limits | High throughput, millions/day possible |
| What kills this | SHAFT content restrictions + cost ($33-42/subscriber eats entire revenue) |
| Status | **DEAD** for erotic content delivery. Viable only for non-erotic notifications. |

### VERDICT: DEAD. SHAFT kills this path for the primary content. Could work for non-content notifications ("new chapter available") but not for delivering the actual story text.

---

## PATH 3: RCS (Rich Communication Services)

### How it works
RCS is the carrier-level successor to SMS. Google's Jibe platform powers most global RCS infrastructure. Messages go through carrier networks but support rich features (images, read receipts, typing indicators, branded sender).

### Adoption
- **1.3 billion active RCS users** worldwide as of 2025. [Source: GSMA]
- **70%+ of Android users** have RCS enabled. [Source: Industry reports]
- **Apple adopted RCS in iOS 18** (September 2025). iPhone users CAN now receive RCS from businesses. [Source: Apple iOS 18 announcement, MessageFlow]
- RCS appears with green bubbles on iPhone (same as SMS). RCS indicator in composer.
- **Projected $15 billion market by 2027.** [Source: Juniper Research]

### Programmatic API
- Google's RCS Business Messaging (RBM) API exists. [Source: Google for Developers]
- Available through Sinch, Infobip, Bandwidth, and other providers.
- Requires carrier approval and brand verification.
- Supports rich cards, carousels, suggested replies, images, video.

### Pricing
- **Not standardized.** Carrier-controlled pricing. [Source: Sinch, Google RBM billing FAQ]
- Basic text RCS: **$0.0075-$0.015/message** [Source: Decision Telecom, Sinch]
- Rich media RCS: **$0.012-$0.03/message** [Source: Decision Telecom]
- 20-50% more expensive than SMS per message. [Source: Industry guides]
- Conversational RCS: ~2x SMS price but includes 24-hour session window.
- November 2025: Google simplified billing to two categories (conversational and non-conversational). [Source: Google RBM billing FAQ]

### Content Restrictions
- **SAME SHAFT restrictions as SMS.** RCS goes through carrier networks, subject to CTIA rules.
- Erotic literary fiction would be prohibited under the same content policies.
- UNVERIFIED whether RCS Business Messaging has separate content review, but carrier-level filtering applies.

### Scale Math (10K subscribers)
- At $0.01/msg: $420,000 total ($42/subscriber)
- At $0.015/msg: $630,000 total ($63/subscriber)

### Kill Test Results
| Metric | Value |
|--------|-------|
| Per-message cost | $0.0075-0.03 |
| 42-day cost at 10K subs | **$315,000-$1,260,000** |
| Content restrictions | **FATAL.** Same SHAFT restrictions as SMS — carrier-level enforcement. |
| Technical feasibility | PROVEN. Major brands using RCS at scale. |
| UX quality | **8/10** — Rich features, branded sender, but still green bubble on iPhone |
| Platform shutdown risk | **CRITICAL** for erotic content |
| Rate limits | High throughput via carrier infrastructure |
| What kills this | SHAFT restrictions + cost (worse than SMS) |
| Status | **DEAD** for erotic content delivery. |

### VERDICT: DEAD. Same content restrictions as SMS with higher per-message cost. RCS's rich features are attractive but irrelevant if you can't send the content.

---

## PATH 4: WhatsApp Business API

### How it works
Meta's WhatsApp Business API allows programmatic messaging to WhatsApp users. Per-message pricing for business-initiated templates; free replies within 24-hour customer service windows.

### Pricing (Post July 2025 restructure)
- Moved from conversation-based to **per-message pricing** for business-initiated templates. [Source: Meta developer docs, WhatsApp Business Platform]
- Marketing messages: **$0.02-0.22/message** depending on region. [Source: WhatsApp pricing guides]
- Utility messages within 24-hour customer window: **FREE.** [Source: Meta docs]
- Utility messages outside window: reduced rates, volume-tiered discounts. [Source: Meta docs]
- Volume-based pricing tiers available for high-volume senders. [Source: Meta July 2025 update]

### Rate Limits
- New accounts: 250 unique users/day
- Tier 1: 1K unique users/24hr
- Tier 2: 10K unique users/24hr
- Tier 3: 100K unique users/24hr
- Tier 4: Unlimited
- **Key distinction:** Limits are on UNIQUE USERS, not total messages. Sending 100 msgs to the same user counts as 1 toward the limit.
- Throughput: 80 messages/second default, upgradeable to 1,000 MPS. [Source: Meta developer docs]

### Content Restrictions — THE KILLER
- **Sexually explicit materials or nudity are PROHIBITED.** [Source: WhatsApp Business Policy]
- "Businesses are prohibited from engaging in transactions related to the sale or use of adult products or services." [Source: WhatsApp Commerce Policy]
- Repeated violations: 1 or 3-day blocks, escalating to permanent ban. [Source: WhatsApp policy enforcement docs]
- Erotic literary fiction = explicit prohibition.

### Scale Math (10K subscribers, marketing category)
- If classified as marketing: $0.025/msg x 4,200 = $105/subscriber = $1,050,000 total
- If classified as utility (debatable): potentially much cheaper with volume tiers
- Content policy makes this moot.

### Kill Test Results
| Metric | Value |
|--------|-------|
| Per-message cost | $0.02-0.22 (marketing) or potentially free (utility in window) |
| 42-day cost at 10K subs | **$840,000-$1,050,000** (marketing) |
| Content restrictions | **FATAL.** Adult/sexual content explicitly prohibited. |
| Technical feasibility | PROVEN at massive scale globally. |
| UX quality | **8/10** — Rich features, read receipts, images, audio. But not iMessage. |
| Platform shutdown risk | **CRITICAL.** Meta actively enforces content policies. |
| Rate limits | Tiered system, manageable for 10K subscribers |
| What kills this | Content restrictions. Erotic fiction = instant policy violation. |
| Status | **DEAD** for erotic content. Could work for non-erotic notifications only. |

### NOTE ON INTERNATIONAL: WhatsApp dominates outside the US (2B+ users). If dezibel ever does international, WhatsApp would be the channel — but only if content is non-explicit or the policy changes.

### VERDICT: DEAD for primary content delivery. Policy is unambiguous.

---

## PATH 5: Telegram Channels/Bots

### How it works
Telegram Bot API allows programmatic messaging. Channels can broadcast to unlimited subscribers. Bots can send messages, media, and manage conversations. Free infrastructure.

### Cost
- **Free.** Telegram Bot API has no per-message fees. [Source: Telegram Bot API docs]
- Paid broadcast option: 0.1 Telegram Stars/message for 1,000 msg/sec throughput. [Source: Telegram Bot API 7.0]
- 1 Star ≈ $0.013 USD (varies with TON cryptocurrency price). [Source: starsrate.org]
- Paid broadcast cost: ~$0.0013/message — negligible.
- At 42M messages: ~$54,600 (paid broadcast) or $0 (standard rate-limited)

### Rate Limits
- Standard: 30 messages/second to different users. [Source: Telegram Bot FAQ]
- Per-chat: 1 message/second. [Source: Telegram Bot FAQ]
- Group: 20 messages/minute. [Source: Telegram Bot FAQ]
- Paid broadcast: 1,000 messages/second at 0.1 Stars/msg. [Source: Telegram Bot API 7.0]
- For dezibel: 100 msgs/day to same user = trivial. No rate limit issues.

### Content Restrictions
- **Very permissive.** Telegram does not prohibit consensual adult content. [Source: Telegram TOS, moderation page]
- Prohibited: CSAM, non-consensual intimate imagery, bestiality. [Source: Telegram TOS]
- Erotic literary fiction: **ALLOWED.** [Source: Telegram content policy analysis]
- Sensitive content can be age-gated via Telegram's built-in sensitive content filter. [Source: Telegram settings docs]
- Telegram explicitly allows NSFW channels and bots with age-gating. [Source: Multiple Telegram guides]

### Simulating Two-Person Conversation
- A Telegram bot CAN send messages that look like they come from the bot itself.
- A channel CAN be used to broadcast content.
- **BUT:** You cannot simulate a natural two-person text conversation in Telegram. Messages come from a bot or channel, not from "Emma" and "Hasta" as separate contacts. You'd need custom formatting (names, colors) within the message text.
- A dedicated bot could send messages styled with character names and formatting, but it won't look like a real conversation between two people texting. It'll look like a bot delivering formatted content.

### User Adoption
- 950M+ monthly active users globally. [Source: Telegram stats]
- **US adoption among target demographic (28-45, literary, female) is LOW.** Telegram skews tech-forward, male, younger, and crypto/privacy-oriented. [UNVERIFIED but consistent with market positioning]
- Target reader persona: "35, female, educated, reads Sally Rooney" — this person uses iMessage, not Telegram.

### Scale Math (10K subscribers)
- Standard (free): $0 total
- Paid broadcast: ~$54,600 total ($5.46/subscriber)
- Per subscriber: **$0-5.46** for 42 days

### Kill Test Results
| Metric | Value |
|--------|-------|
| Per-message cost | $0 (standard) or ~$0.0013 (paid broadcast) |
| 42-day cost at 10K subs | **$0-$54,600** |
| Content restrictions | **NONE relevant.** Erotic literary fiction allowed. |
| Technical feasibility | PROVEN. Telegram handles billions of messages. |
| UX quality | **4/10** — Not iMessage. Not SMS. Requires app install. Can't simulate real texting. |
| Platform shutdown risk | **LOW.** Telegram is permissive. |
| Rate limits | Trivial for this use case |
| What kills this | **UX mismatch** (doesn't feel like real texts) + **audience mismatch** (target demo doesn't use Telegram) |
| Status | **VIABLE but WRONG AUDIENCE.** |

### VERDICT: ALIVE but WRONG FIT. Cost is perfect, content policy is perfect, but the UX destroys the core product promise ("a novel that texts you"). Telegram messages feel like bot broadcasts, not intimate texts from a person. Could serve as a supplementary channel for tech-forward international users.

---

## PATH 6: Progressive Web App (PWA) with Push Notifications

### How it works
A web application installable on home screen. Push notifications via APNs (iOS) and FCM (Android) alert users when new messages arrive. The "reading experience" happens in the PWA, which can be designed to look exactly like iMessage.

### Cost
- **APNs: FREE.** Apple does not charge per notification. Only cost: $99/year Apple Developer Program. [Source: Apple Developer docs, multiple pricing guides]
- **FCM: FREE.** Google does not charge for Firebase Cloud Messaging. [Source: Google Firebase docs]
- Hosting: standard web hosting costs. Minimal at 10K users.
- Total infrastructure: **< $100/month** at 10K subscribers (hosting + CDN).
- Per subscriber: **< $0.01** for 42 days.

### Push Notification Engagement (THE PROBLEM)
- Push notification open rate: **8-10.7%** (iOS 8%, Android 10.7%). [Source: Business of Apps, CleverTap]
- SMS open rate: **98%.** [Source: industry benchmarks]
- Push notification CTR: ~7.8% average. [Source: CleverTap]
- **Push notifications are 10x less reliable than SMS for reaching users.** [Source: Mobiloud, Omnisend comparisons]
- Users frequently disable push notifications. iOS requires explicit opt-in.

### Can You Simulate iMessage UI?
- **Yes.** PWA can replicate iMessage's visual design perfectly: blue/gray bubbles, typing indicators, read receipts, timestamps. No technical limitation.
- Templates exist (Chatzy, Dreams Chat PWA templates on ThemeForest). [Source: ThemeForest]
- PWAs in 2025-2026 can use native UI components, making them feel very close to native apps. [Source: MDN, dev community guides]
- **The reading experience can be 9/10.** The problem is getting people TO the app.

### No App Store Review
- PWA bypasses Apple App Store and Google Play content review policies.
- No SHAFT restrictions. No content policy gatekeepers.
- Erotic literary fiction: **ALLOWED.** You host it, you control the content.

### iOS PWA Limitations
- iOS Safari supports push notifications for PWAs (added in iOS 16.4, March 2023).
- But: requires user to "Add to Home Screen" first — significant friction.
- Push notification reliability on iOS PWAs is lower than native apps. [UNVERIFIED — anecdotal reports]

### The Deep Link Hybrid
- Send ONE real SMS per day: "Chapter 12 is ready" with a link to the PWA.
- User opens PWA, reads 100+ messages in iMessage-like UI.
- SMS cost: 1 msg/day x 42 days x 10K subs x $0.01 = **$4,200 total** for SMS triggers.
- All content delivered free via PWA.
- Total: ~$4,200 + hosting = **< $5,000 for 42 days at 10K subscribers.**

### Scale Math (10K subscribers)
- Pure PWA: < $100/month hosting
- Hybrid (1 SMS trigger/day + PWA): ~$4,200 total
- Per subscriber: **$0.01-$0.50** for 42 days

### Kill Test Results
| Metric | Value |
|--------|-------|
| Per-message cost | $0 (push) or $0.01/day (SMS trigger hybrid) |
| 42-day cost at 10K subs | **< $5,000** (hybrid) or **< $500** (pure PWA) |
| Content restrictions | **NONE.** Self-hosted, no platform review. |
| Technical feasibility | PROVEN technology. PWAs are mature. |
| UX quality | **6/10** (pure PWA, requires app install + notification opt-in) / **7/10** (hybrid with SMS trigger) |
| Platform shutdown risk | **ZERO.** You own the infrastructure. |
| Rate limits | None relevant |
| What kills this | **Doesn't feel like real texts.** User knows they're opening an app, not receiving a text from someone. The illusion breaks. Push notification engagement is 10x worse than SMS. |
| Status | **PROVEN technology, UNPROVEN for this UX.** |

### VERDICT: ALIVE as cost solution. DEAD as primary "it feels like someone is texting you" experience. The product promise is "a novel that texts you" — a PWA is "a novel you open." These are fundamentally different emotional experiences. However, as a READING ENVIRONMENT (where the actual text conversation is displayed), PWA is excellent and nearly free. The question becomes: how do you trigger the user to open it?

---

## PATH 7: Signal / Matrix / Other Encrypted Messaging

### Signal
- No public API for sending messages. [Source: Signal documentation, community research]
- signal-cli exists as unofficial CLI tool but is not supported for business use. [Source: GitHub bbernhard/signal-cli-rest-api]
- No bot platform. No business API. No content delivery infrastructure.
- **DEAD.** Signal is designed for privacy, not content delivery.

### Matrix
- Open protocol with bot SDK (matrix-bot-sdk). [Source: Matrix.org docs]
- Self-hostable (Synapse server). Free infrastructure.
- Very low adoption outside tech community.
- Target demographic has never heard of Matrix.
- **DEAD** for audience reach reasons.

### Kill Test Results
| Metric | Value |
|--------|-------|
| Per-message cost | $0 |
| Content restrictions | None (self-hosted) |
| What kills this | **No audience.** Target demo doesn't use Signal/Matrix. No business API for Signal. |
| Status | **DEAD** |

### VERDICT: DEAD. No audience, no infrastructure for content delivery at scale.

---

## PATH 8: Custom App + Direct APNs/FCM

### How it works
Build a native iOS/Android app. Use APNs (Apple Push Notification Service) and FCM (Firebase Cloud Messaging) to deliver rich notifications containing full message text. The "app" is essentially a notification reader with an iMessage-like UI.

### Cost
- **APNs: FREE.** No per-message fees at any scale, including millions/day. [Source: Apple Developer docs]
- **FCM: FREE.** No per-message fees. [Source: Firebase docs]
- Apple Developer Program: $99/year
- Google Play Developer: $25 one-time
- App development cost: included in existing $60K tech budget
- Per subscriber: **< $0.01** for 42 days

### Rich Notification Capabilities
- iOS rich notifications support: text (up to 178 chars visible, 4096 bytes payload), images, audio, video, interactive buttons. [Source: Apple developer docs]
- Notification Service Extension can modify content before display.
- Can show character name, avatar, and message preview — mimicking a real text.
- **Live Activities** (iOS 16+) could show ongoing "conversation" on lock screen. [Source: Apple developer docs 2026]

### App Store Review — THE RISK
- Apple App Store has content guidelines. Erotic content is restricted.
- App Store Review Guideline 1.1.4: "Overtly sexual or pornographic material" is not allowed.
- **Literary fiction with erotic scenes is a gray area.** The Kindle app delivers erotic novels. Audible delivers erotic audiobooks. But these are platform apps, not single-title apps.
- Dezibel as a "literary experience app" with erotic content could be rejected.
- **Mitigation:** Frame as literary fiction app (like Kindle/Audible), not erotica app. Content is text-only, not visual. Submit to App Store review early to test.
- **Google Play** is more permissive but has similar restrictions.

### UX Quality
- **If approved:** 8-9/10. Rich notifications with character avatars, message previews on lock screen. Opening the app shows iMessage-like conversation. Very close to the real thing.
- **Key difference from real iMessage:** Notifications come from "Dezibel" app, not from a phone number contact. User knows it's an app. The illusion is partial.

### Push Notification Engagement Problem
- Same issue as PWA: push notification open rates are 8-10%, vs 98% for SMS.
- But: a dedicated app with a 42-day engagement pattern may train higher open rates.
- Users who pay $49 are opted-in and motivated. Not cold marketing pushes.
- UNVERIFIED: paid subscriber push engagement rates for serialized content.

### Scale Math (10K subscribers)
- Infrastructure: < $200/month (server + CDN)
- Per subscriber: **< $0.01** for 42 days
- App development: one-time cost within existing tech budget

### Kill Test Results
| Metric | Value |
|--------|-------|
| Per-message cost | $0 |
| 42-day cost at 10K subs | **< $1,000** (hosting only) |
| Content restrictions | **MEDIUM RISK.** App Store may reject erotic content. |
| Technical feasibility | PROVEN. APNs/FCM handle billions of notifications daily. |
| UX quality | **8/10** — Close to real texts, but user knows it's an app |
| Platform shutdown risk | **MEDIUM.** App Store rejection possible but not certain. |
| Rate limits | None relevant (APNs handles massive scale) |
| What kills this | App Store rejection for erotic content + doesn't fully deliver "real text" illusion |
| Status | **VIABLE. Needs App Store content review test.** |

### VERDICT: STRONGEST COST-EFFECTIVE PATH. Free delivery, rich UX, proven infrastructure. Two risks: (1) App Store rejection for content, (2) doesn't fully create "someone is texting you" illusion. Kill test: submit a test app with sample erotic literary content to App Store review. If approved, this path opens up.

---

## PATH 9: Email as Delivery Layer

### How it works
Serialized content delivered as emails via Amazon SES or similar. Each "message" or batch of messages arrives as an email.

### Cost
- Amazon SES: **$0.10 per 1,000 emails** ($0.0001/email). [Source: AWS SES pricing]
- At 42M messages: **$4,200 total.** Per subscriber: **$0.42.**
- High volume (50M+): drops to $0.02/1,000 = $840 total.
- Cheapest option by far.

### Content Restrictions
- **None relevant.** Email has no SHAFT-type content restrictions. CAN-SPAM requires opt-in and unsubscribe link, which dezibel already provides.
- Erotic literary fiction: **ALLOWED.** Email platforms deliver erotica (Kindle, Substack, newsletters).

### Can Email Simulate Texting Intimacy?
- **No.** Email is fundamentally different from texting. [TASTE — not testable]
- Email open rates: 20-40% for engaged lists. Substack fiction: 40%+ open rates for engaged subscribers. [Source: Substack serialization guides]
- But: the emotional register of email is "newsletter" not "person texting you."
- 100 emails/day would be absurd and result in spam filtering.
- Could batch messages into daily or twice-daily emails showing the "conversation" — but this is a book chapter, not a text message experience.

### Serialized Fiction on Email (Proven Model)
- Substack fiction serialization is a growing category. [Source: Writing Workshops guide]
- Authors with 6,000+ subscribers, $19K first-year revenue. [Source: Substack community data]
- Serial (the podcast) proved serialized storytelling works. Email is a viable delivery mechanism for the CONTENT, not for the EXPERIENCE.
- Pricing: Substack fiction $5-8/month. Dezibel at $49 total is comparable to a 6-8 month subscription.

### Scale Math (10K subscribers)
- Per subscriber: **$0.42** for 42 days (at SES rates, 1 email/day batching messages)
- If 100 emails/day per subscriber: $4.20/subscriber — still cheap but will be spam-filtered

### Kill Test Results
| Metric | Value |
|--------|-------|
| Per-message cost | $0.0001 |
| 42-day cost at 10K subs | **$4,200** (1 email/day batch) |
| Content restrictions | **NONE relevant.** |
| Technical feasibility | PROVEN at massive scale. |
| UX quality | **3/10** — Completely destroys the "someone texting you" experience. It's a newsletter. |
| Platform shutdown risk | **ZERO** (self-hosted via SES) |
| Rate limits | SES handles billions |
| What kills this | **UX.** Email is not texting. Receiving an email is categorically different from receiving a text. |
| Status | **PROVEN technology, WRONG MEDIUM for this product.** |

### VERDICT: ALIVE as supplement, DEAD as primary channel. Email is the cheapest and most proven delivery infrastructure, but it destroys the core product promise. Could work as: (1) daily recap for subscribers who missed messages, (2) marketing/onboarding channel, (3) fallback for technical issues. Not the primary experience.

---

## PATH 10: Hybrid Combinations

### RECOMMENDED HYBRID: Native App + SMS Triggers

**Architecture:**
1. **Primary reading experience:** Native iOS/Android app with iMessage-like UI (blue/gray bubbles, typing indicators, read receipts, timestamps, character avatars)
2. **Notification layer:** APNs/FCM push notifications (FREE) for real-time message delivery
3. **Engagement trigger:** 1-3 real SMS per day ("Emma just texted you") linking to the app — the SMS creates the "someone texted me" sensation
4. **Content delivery:** All 100+ messages/day delivered via app (free)
5. **Email supplement:** Daily recap email for users who prefer it (free via SES)

**Cost:**
- App push notifications: $0
- SMS triggers (2/day avg): 2 x 42 x 10K x $0.01 = **$8,400**
- Email recaps: < $100
- Hosting: < $500/month
- **Total for 42 days at 10K subscribers: ~$10,000-$15,000**
- **Per subscriber: $1.00-$1.50**

**Content compliance:**
- SMS triggers contain NO erotic content — just "New messages from Emma" or "Chapter 12 is ready"
- All erotic content lives in the app, which you control
- App Store risk: submit for review early. Frame as literary fiction app.
- If App Store rejects: pivot to PWA (no review required)

**UX quality: 7-8/10**
- SMS trigger creates the "someone texted me" dopamine hit
- Opening the app reveals the full conversation in iMessage-like UI
- Not 10/10 because user knows it's an app, not real iMessage
- But: the SMS trigger bridges the gap significantly

### ALTERNATIVE HYBRID: Linq iMessage (iPhone) + App (Android)

**Architecture:**
1. **iPhone users (~55% US):** Actual iMessage delivery via Linq API
2. **Android users (~45% US):** Native app with push notifications
3. **International:** App + WhatsApp for non-erotic notifications

**Cost: UNKNOWN** (depends on Linq pricing)
- If Linq is affordable: iPhone users get 10/10 UX
- Android users get 8/10 via app
- iPhone experience IS the product promise

**Risk:** Linq is a 1-year-old startup. Single point of failure for 55% of subscribers.

### ALTERNATIVE HYBRID: PWA + SMS Triggers (No App Store Risk)

**Architecture:**
1. **Reading experience:** PWA with iMessage-like UI (no App Store review)
2. **Triggers:** 1-3 SMS/day with links
3. **Fallback:** Email

**Cost:** Same as recommended hybrid (~$10,000-15,000)
**UX:** 6-7/10 (slightly worse than native app, but no App Store risk)

### Kill Test Results (Recommended Hybrid)
| Metric | Value |
|--------|-------|
| Per-message cost | $0 (app) + $0.01/SMS trigger |
| 42-day cost at 10K subs | **$10,000-$15,000** |
| Per subscriber | **$1.00-$1.50** |
| Content restrictions | **MANAGED.** SMS triggers clean; erotic content in self-controlled app. |
| Technical feasibility | PROVEN (each component is proven technology) |
| UX quality | **7-8/10** |
| Platform shutdown risk | **LOW-MEDIUM** (App Store is the only gatekeeper) |
| Rate limits | None relevant |
| What kills this | App Store rejection for erotic content (mitigated by PWA fallback) |
| Status | **VIABLE. Best overall risk/cost/UX balance.** |

---

## COMPARATIVE TABLE

| Path | Cost/Sub (42 days) | Content OK? | UX (1-10) | Feasibility | Status |
|------|-------------------|-------------|-----------|-------------|--------|
| 1. iMessage (DIY) | $200+/mo hosting | Yes | 10 | Impossible at scale | DEAD |
| 1b. iMessage (Linq) | UNKNOWN | UNKNOWN | 10 | EXPERIMENTAL | INVESTIGATE |
| 2. Bandwidth/SMS | $33-42 | NO (SHAFT) | 7 | Proven | DEAD |
| 3. RCS | $31-126 | NO (SHAFT) | 8 | Proven | DEAD |
| 4. WhatsApp | $84-105 | NO (explicit ban) | 8 | Proven | DEAD |
| 5. Telegram | $0-5.46 | YES | 4 | Proven | WRONG AUDIENCE |
| 6. PWA | $0-0.50 | YES | 6-7 | Proven | VIABLE (supplement) |
| 7. Signal/Matrix | $0 | YES | N/A | No API/No audience | DEAD |
| 8. Native App + APNs | < $0.01 | MEDIUM RISK | 8 | Proven | VIABLE |
| 9. Email | $0.42 | YES | 3 | Proven | SUPPLEMENT ONLY |
| **10. Hybrid (App+SMS)** | **$1.00-1.50** | **YES** | **7-8** | **Proven** | **RECOMMENDED** |

---

## REFERENCE: How Did Hooked/Community.com Work?

### Hooked (40M users, chat fiction)
- **NOT delivered via SMS.** Hooked is a native app. [Source: Wikipedia, TechCrunch]
- Users tap to reveal next message in-app. No push delivery to phone.
- Stories are ~1,000-1,300 words, ~5 min read. [Source: TechCrunch]
- Business model: freemium, $2.99/week subscription. [Source: App Store]
- Hooked proves chat fiction works as a FORMAT but uses app delivery, not text messaging.
- **Key insight:** Hooked's success validates the chat UI but their delivery is an app, not SMS/iMessage. They never tried to make it feel like real texts arriving on your phone.

### Community.com
- Uses SMS, MMS, RCS, and WhatsApp — multi-channel. [Source: Community.com technology page]
- Platform for celebrities/brands to text fans.
- Specific tech stack not publicly documented.
- Likely uses carrier APIs (Bandwidth, Twilio, or similar) under the hood.
- Subject to same SHAFT restrictions for content.

### Linq (The iMessage Infrastructure Startup)
- Most relevant to dezibel's needs. $20M raised Feb 2026. [Source: TechCrunch]
- 100+ customers, 30M messages/month. [Source: TechCrunch]
- Founded by ex-Shipt team. ex-Apple executive as investor/advisor.
- Provides iMessage, RCS, and SMS APIs.
- Claims 90% cheaper than Twilio.
- **ACTION: Contact Linq sales for pricing and content policy. This is the highest-priority research action.**

### Apple's Stance on Third-Party iMessage (Beeper/Sunbird)
- Apple actively blocked Beeper Mini in Dec 2023 — "took steps to protect users by blocking techniques that exploit fake credentials." [Source: Fortune, multiple outlets]
- Sunbird returned April 2024 with new architecture but remains precarious. [Source: TechTimes, 9to5Google]
- Apple adopted RCS in iOS 18 (Sept 2025) as their concession to cross-platform messaging.
- Apple's position: iMessage is for Apple users. No third-party access. No API. No business platform. [Source: Lindy blog, industry analysis]
- **Linq appears to have found a sustainable approach** (30M msgs/month without shutdown), but their infrastructure is opaque. They may be using dedicated Mac hardware at scale.

---

## PRIORITY ACTIONS (ORDERED)

1. **Contact Linq** (linqapp.com) — Get pricing, ask about content policy for literary fiction with erotic scenes, ask about scale for 100 msgs/day/user. This is the highest-leverage research action. If Linq works and is affordable, it changes the entire calculation.

2. **Submit test app to App Store** — Build minimal iOS app with iMessage-like UI containing sample erotic literary content (a few pages of P/F). Submit for review. This kills or validates Path 8 and the recommended hybrid.

3. **Build PWA prototype** — Create iMessage-style chat UI as PWA. This is the zero-risk fallback regardless of other paths. Cost: engineering time only.

4. **Price out hybrid SMS triggers** — Register a 10DLC number for NON-erotic notification messages only ("New chapter available"). Confirm this passes SHAFT review since the SMS itself contains no erotic content.

5. **Test Telegram as supplementary channel** — Set up a Telegram bot delivering sample content to 50 testers. Measure engagement. Confirm the UX is inadequate for primary delivery (or discover it's better than expected).

---

## UNRESOLVED QUESTIONS

1. **Linq pricing and content policy** — Cannot model the iMessage path without this. CRITICAL.
2. **App Store tolerance for erotic literary fiction** — Gray area. Kindle delivers erotica via iOS. But Kindle is Amazon. Dezibel is unknown. TESTABLE.
3. **Push notification engagement for paid serialized content** — Industry data shows 8-10% open rates, but those are marketing pushes. Paid subscribers expecting daily content may have 60-80% engagement. UNVERIFIED, TESTABLE with beta.
4. **SMS trigger SHAFT compliance** — Does "Emma just texted you — open Dezibel" pass SHAFT review even though the app contains erotic content? The SMS itself is clean. TESTABLE via 10DLC registration.
5. **Hybrid UX gap** — Does "SMS trigger → open app → read in iMessage UI" feel close enough to "real person texting me"? Only beta testing answers this. TESTABLE with 5-7 beta readers.

---

## BOTTOM LINE

The $5/subscriber target is achievable. The question is UX quality vs. cost.

**$0-2/subscriber:** App or PWA with push notifications only. 6-8/10 UX.
**$1-2/subscriber:** App + SMS triggers (recommended hybrid). 7-8/10 UX.
**$33-42/subscriber:** Pure SMS. 7/10 UX but DEAD on content restrictions.
**$0/subscriber:** iMessage. 10/10 UX but DEAD on scale (without Linq).
**UNKNOWN:** Linq iMessage. Potentially 10/10 UX at viable cost. INVESTIGATE.

The recommended path is the **Native App + SMS Trigger Hybrid** with a PWA fallback. Total cost: ~$1-2/subscriber for 42 days. This is well under the $5 target. The highest-leverage next action is contacting Linq to see if actual iMessage delivery is commercially viable.
