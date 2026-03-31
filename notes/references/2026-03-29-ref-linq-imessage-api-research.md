---
title: "Linq deep dive: iMessage API startup ($20M, 30M msgs/month)"
type: reference
tags: [dezibel, linq, imessage, api, delivery, infrastructure]
created: 2026-03-29
area: "[[writing-and-film]]"
source: "Web research on Linq (linqapp.com) — iMessage/RCS/SMS startup, $20M Series A Feb 2026."
---

## Summary

Linq is a Birmingham, Alabama startup that provides a REST API for sending iMessage, RCS, and SMS programmatically. Founded by ex-Shipt executives, it raised a $20M Series A in February 2026 led by TQ Ventures. The platform handles 30M+ messages/month for 100+ customers. It is the only SOC 2 Type II certified iMessage API.

The critical finding for dezibel: Linq uses **unofficial iMessage access via Mac hardware** — not Apple Business Chat. This means it operates outside Apple's sanctioned ecosystem, which carries real platform risk but also means Apple's content policies (and carrier SHAFT restrictions) do not directly apply. The content policy question shifts from "will Apple allow erotic content?" to "will Linq's own AUP allow it?" — and their AUP explicitly prohibits "obscene, pornographic, or otherwise inappropriate material."

---

## 1. How Linq technically works

**Architecture**: Linq is a managed iMessage bridge. They maintain Mac Minis and iPhones running macOS with the native Messages app. When a developer calls the REST API, Linq relays the message through real Apple hardware and Apple IDs.

**Key details**:
- Each iMessage number historically required its own Mac Mini, iPhone, and Apple account
- Linq currently operates with ~8 phone numbers, load-balanced across users
- Anti-spam strategy: daily cap per number, reciprocal conversation onboarding (users text the system first so Apple sees two-way traffic), dynamic contact card generation
- RESTful API with token-based authentication, webhook-driven architecture for inbound messages
- Supports: images, emojis, voice notes, group chats, threaded replies, typing indicators, read receipts, tapbacks, screen effects
- SMS/RCS fallback for non-iMessage recipients
- This is **not** Apple Business Chat — it exploits private, undocumented Apple APIs

**The Apple risk**: The entire unofficial iMessage API ecosystem operates under constant threat of Apple enforcement. There are no published rate limits, no documentation on what triggers a ban, and no appeals process. Apple has historically shut down similar services (Beeper, Sunbird). One source notes Apple "has clearly stated that it will terminate support for non-compliant applications in June 2026" — this date is UNVERIFIED and should be treated as a potential existential risk.

**Developer experience**: Public API docs at apidocs.linqapp.com. Free sandbox available (no credit card). CLI tool for terminal-based iMessage. GoHighLevel CRM integration. Claimed setup time: under 5 minutes.

---

## 2. Pricing model

**Model**: Linq has moved away from per-message pricing. They claim to be "90% cheaper than legacy communication APIs" (i.e., Twilio).

**What is known**:
- Pricing page exists at linqapp.com/s/pricing but specific tiers are not surfaced in search results
- Competitor Blooio claims Linq Blue has "$500+ setup fees" and "opaque pricing requiring customers to book a call"
- Enterprise plans available for high-volume teams
- Competitor benchmarks for context: Blooio starts at $89/month (shared number) or $289/month per dedicated line; Project Blue starts at $250/line for 2+ lines

**What "90% cheaper than Twilio" means in absolute terms**: Twilio SMS is ~$0.0079/segment outbound. 90% cheaper would be ~$0.0008/message. At dezibel scale (100 msgs/day x 10K users = 1M msgs/month), Twilio would cost ~$7,900/month; Linq equivalent would be ~$800/month. But Linq's flat-rate model may not work this way — the actual structure requires a sales call to confirm.

**UNVERIFIED**: Exact per-message or per-subscriber pricing. Must contact Linq sales directly.

---

## 3. Content policy

**Linq's Acceptable Use Policy** (at skywalker-next.linqapp.com/policies/acceptable-use-policy) explicitly prohibits:
- Unsolicited bulk messages (spam)
- False, misleading, fraudulent, or deceptive content
- Harassing, abusive, threatening, or hateful content
- **"Obscene, pornographic, or otherwise inappropriate material"**
- Malware, phishing, or harmful code

**Assessment for dezibel**: The "obscene, pornographic, or otherwise inappropriate material" clause is a blocker for unedited erotic fiction delivery. However:
- "Obscene" and "pornographic" have legal definitions that literary erotica may not meet (Miller test: the work must lack "serious literary, artistic, political, or scientific value")
- dezibel's P/F novella is narrative literary fiction, not pornography
- The "otherwise inappropriate" catch-all gives Linq broad discretion to refuse
- This is the same category of risk as Twilio's SHAFT policy, but with less established precedent for how Linq enforces it

**Kill test**: Contact Linq sales with a sample of dezibel content and ask directly whether literary erotic fiction triggers their AUP enforcement. This is a 30-minute test that determines whether the entire Linq path is viable.

**Note**: Because Linq uses unofficial iMessage access (not carrier SMS), carrier-level SHAFT restrictions do not apply. The restriction is Linq's own policy, not Apple's or the carriers'. If Linq says yes, the content policy question is resolved for iMessage delivery.

---

## 4. Customer examples

**Scale**: 100+ customers, 30M+ messages/month, 134K monthly active users.

**Named customer**: Poke (by Interaction, a Palo Alto startup). AI assistant that lives inside iMessage for task management, scheduling, Q&A. Raised $15M seed at $100M valuation in September 2025. 6,000 Silicon Valley insiders tested it pre-launch, sending ~200K messages/month. Poke's viral growth in September 2025 triggered the flood of API requests that drove Linq's pivot.

**Use case categories mentioned**:
- AI assistants / chatbots (primary current demand)
- Sales CRM messaging (Linq Blue product, GoHighLevel integration)
- Fitness & wellness (daily workouts, accountability check-ins)
- Hospitality (reservation management)
- Customer support agents

**Not mentioned**: Content delivery, publishing, serial fiction, entertainment, media. The customer base appears to be AI agent companies and sales teams, not content creators.

---

## 5. Rate limits

**Apple-level constraints** (applies to all unofficial iMessage APIs):
- No published rate limits from Apple
- Industry consensus: 100 outbound iMessages/day per number is the "safe ceiling"
- 50 unique new contacts/day per device is the conservative recommendation
- Spam reports kill accounts faster than volume — a handful of reports can trigger permanent blocks
- Risk factors: new account, high volume, low recipient diversity, lopsided send-to-receive ratio

**Linq's approach**:
- 8 phone numbers, load-balanced
- Daily cap per number (exact number not public)
- Reciprocal conversation requirement (users text first)
- Dynamic contact card generation

**Assessment for dezibel** (100 msgs/day to same user, 10K subscribers):
- Sending to the *same* user repeatedly is lower risk than blasting new contacts — Apple's detection focuses on new-contact spam, not ongoing conversations
- But 100 msgs/day to one user is extremely high volume for iMessage. Even human-to-human conversations rarely hit this
- At 10K subscribers, you need ~10K message threads active. With 8 numbers load-balanced, that's ~1,250 subscribers per number
- The reciprocal conversation model (user texts first) actually fits dezibel well — subscribers would opt in by texting the number

**UNVERIFIED**: Whether Linq can support 100 msgs/day/user at 10K subscriber scale. This is an extreme use case compared to their typical AI agent traffic. Must ask Linq directly.

---

## 6. Reliability / SLA

- SOC 2 Type II certified (the only iMessage API with this certification)
- Competitor Blooio advertises 99.9% uptime; Linq does not publish a specific uptime SLA in available sources
- 295% net revenue retention and zero churn suggest high customer satisfaction
- No published SLA guarantees found

**UNVERIFIED**: Specific uptime percentage or SLA terms. SOC 2 Type II requires demonstrating operational controls over time, which implies some availability commitment, but the specific number is not public.

---

## 7. API documentation

- Public docs at apidocs.linqapp.com
- RESTful API, token-based authentication (API key in request header)
- Webhook-driven architecture for real-time inbound message notifications
- Supports rich media: images, videos, documents, voice memos
- Free sandbox environment (no credit card required)
- CLI tool for terminal-based messaging
- CRM integrations: GoHighLevel, generic CRM landing page
- Claimed time to first message: under 5 minutes

---

## 8. Founders and team

**Elliott Potter** — CEO. Former Shipt executive. Helped expand Shipt's same-day delivery service nationwide before Target acquired it for $550M.

**Patrick Sullivan** — CTO. Former Shipt executive. Same background.

**Jared Mattsson** — President. Former Shipt executive. Same background.

**Investors**:
- TQ Ventures (lead) — early-stage VC led by Schuster Tanger and Andrew Marks, managing $2B+ in assets
- Mucker Capital
- Angel investors including "a former Apple and Google executive" (name not disclosed in any source found)

**Company history**:
- Originally launched as a digital business card and lead-capture tool for sales teams
- Pivoted to iMessage/RCS API in February 2025
- Poke went viral on their infrastructure September 2025
- Customer base grew 132% quarter-over-quarter after pivot
- Doubled 4 years of ARR in 8 months
- Raised $20M Series A in February 2026

---

## 9. Competitors

**Direct iMessage API competitors** (all use the same unofficial Mac-hardware approach):
- **Sendblue** — established player, per-message pricing
- **Blooio** — $89-289/month, transparent pricing, 99.9% uptime claim, RCS since launch
- **Project Blue** — $250/line (2+ lines), 50 new iMessage destinations/day, analytics, CRM integrations
- **Texting Blue** — smaller player, blog content suggests active development

**Adjacent/different approach**:
- **Apple Messages for Business** — Apple's official channel, requires Apple approval, limited to customer support use cases, not general messaging
- **Twilio** — SMS/RCS only, no iMessage, SHAFT content restrictions
- **Beeper/Sunbird** — attempted iMessage bridge for consumers, Apple actively blocked them in late 2023/early 2024

**Linq's differentiation**: SOC 2 Type II (only one), 30M msgs/month scale, AI agent focus, Series A funding ($20M vs bootstrapped competitors).

---

## 10. Risk assessment

### Platform risk (HIGH)
- Apple could shut down all unofficial iMessage APIs at any time
- Precedent: Apple blocked Beeper and Sunbird in 2023-2024
- One source mentions Apple may "terminate support for non-compliant applications in June 2026" — UNVERIFIED but worth monitoring
- Linq's mitigation: building toward omnichannel (WhatsApp, Telegram, Slack, Discord, Signal, RCS) so they're not iMessage-dependent

### Startup risk (MODERATE)
- 1 year old in current form (pivoted Feb 2025)
- $20M Series A from reputable VC (TQ Ventures, $2B+ AUM)
- Strong metrics: 295% NRR, zero churn, 132% Q/Q customer growth, doubled 4-year ARR in 8 months
- Experienced founders (Shipt exit to Target for $550M)
- Risk: pivot history (digital business cards → iMessage API) suggests they'll pivot again if the market shifts

### Content policy risk (HIGH for dezibel)
- AUP prohibits "obscene, pornographic, or otherwise inappropriate material"
- Literary erotic fiction occupies a gray area — not legally obscene under Miller test, but "inappropriate" is at Linq's discretion
- No evidence of content delivery customers in their current base
- Kill test required before any commitment

### Technical risk for dezibel's use case (MODERATE-HIGH)
- 100 msgs/day/user is far outside typical use patterns (AI agents send occasional messages, not 100/day)
- Apple's anti-spam detection could flag high-frequency same-number messaging even in reciprocal conversations
- 10K subscribers across 8 numbers = high density per number
- No evidence anyone uses Linq for this pattern of messaging

---

## Dezibel fit assessment

### What Linq solves
- Native iMessage delivery (blue bubbles, typing indicators, read receipts) — the 10/10 UX path
- No app download required
- Bypasses carrier SHAFT restrictions (iMessage is Apple-to-Apple, not carrier SMS)
- API-driven, programmable delivery
- RCS/SMS fallback for Android users

### What remains unresolved
1. **Content policy**: AUP prohibits "obscene/pornographic" — literary erotica must be explicitly cleared with Linq sales (KILL TEST)
2. **Rate limits**: 100 msgs/day/user at 10K scale is unprecedented for their platform (KILL TEST)
3. **Pricing**: Opaque, requires sales call. Could be prohibitive at dezibel scale (DISCOVERY)
4. **Apple platform risk**: June 2026 enforcement date is UNVERIFIED but could kill the entire approach (MONITOR)
5. **No content delivery precedent**: All known customers are AI agents or sales CRMs, not serial fiction delivery (RISK)

### Recommended next actions (in priority order)
1. **Email Linq sales** with dezibel use case: "literary fiction delivery via iMessage, ~100 messages/day per subscriber, 10K subscribers, content includes explicit scenes." Ask about AUP compatibility, pricing, and rate limit feasibility. This is a single email that resolves or kills the Linq path.
2. **Evaluate Blooio/Project Blue as alternatives** — same technical approach, may have different content policies. Blooio's transparent pricing ($289/month per dedicated line) gives a cost floor.
3. **Monitor Apple's June 2026 enforcement** — if Apple cracks down on unofficial iMessage APIs, the entire category dies and dezibel falls back to app-based delivery or SMS.
4. **Prototype with Linq sandbox** — free, no credit card. Send test messages to verify delivery quality, typing indicators, media support before committing.

---

## Sources

- [Linq raises $20M to enable AI assistants to live within messaging apps — TechCrunch](https://techcrunch.com/2026/02/02/linq-raises-20m-to-enable-ai-assistants-to-live-within-messaging-apps/)
- [Linq homepage](https://linqapp.com/)
- [Linq pricing page](https://linqapp.com/s/pricing)
- [Linq Acceptable Use Policy](https://skywalker-next.linqapp.com/policies/acceptable-use-policy)
- [Linq AI Agent use case](https://linqapp.com/s/use-cases/ai-agent)
- [Ex-Shipt execs' Linq raises $20M — TechFundingNews](https://techfundingnews.com/linq-20m-series-a-tq-ventures-ai-messaging-pivot/)
- [Linq Secures $20M Series A — The AI Insider](https://theaiinsider.tech/2026/02/05/linq-secures-20m-series-a-to-make-ai-to-human-communication-frictionless/)
- [Linq $20M Series A — WebWire press release](https://www.webwire.com/ViewPressRel.asp?aId=349883)
- [Birmingham startup raises $20M — Bham Now](https://bhamnow.com/2026/02/03/birmingham-startup-raises-20m-in-funding-for-ai-powered-messaging/)
- [Linq Shifts Focus to AI Messaging Agent Infrastructure — IndexBox](https://www.indexbox.io/blog/linq-pivots-to-become-infrastructure-layer-for-ai-messaging-agents/)
- [Poke launches with $15M — TechStartups](https://techstartups.com/2025/09/08/poke-com-launches-imessage-ai-assistant-with-15m-seed-funding-at-100m-valuation-now-used-by-6000-vc-insiders/)
- [iMessage API: Three Rewrites, One Apple Ban — Lindy.ai](https://www.lindy.ai/blog/imessage-api-three-rewrites-one-apple-ban-and-what-actually-works)
- [How Not to Get Blocked Using an iMessage API — Texting Blue](https://texting.blue/blog/avoid-to-imessage-blocks/)
- [Blooio vs Linq Blue comparison](https://blooio.com/compare/blooio-vs-linq-blue)
- [Project Blue vs Linq Blue](https://www.tryprojectblue.com/alternatives/linq-blue)
- [Birmingham startup Linq rapid growth — Business Alabama](https://businessalabama.com/birmingham-startup-linq-experiences-rapid-growth/)
- [Linq $20M Series A — FinSMEs](https://www.finsmes.com/2026/02/linq-raises-20m-in-series-a-funding.html)
