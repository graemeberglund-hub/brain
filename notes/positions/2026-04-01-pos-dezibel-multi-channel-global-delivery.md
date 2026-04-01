---
title: "Multi-Channel Global Delivery — WhatsApp, SMS, Signal, App + Spanish/Mandarin Expansion"
type: position
classification: testable
tags: [dezibel, delivery, global, translation, whatsapp, sms, multilingual]
created: 2026-04-01
updated: 2026-04-01
stage: emerging
confidence: medium
projects: [dezibel]
kill_test: "WhatsApp Business API blocks erotic content; translation costs exceed per-market revenue potential; Signal has no bulk API"
---

## Thesis

Dezibel should offer readers a choice of delivery channel — WhatsApp, SMS, app, and potentially Signal — with transparent pricing that reflects delivery cost. The product is the story, not the pipe. Let the reader pick their pipe.

This also unlocks global rollout. English-first, then Spanish and Mandarin. The global romance/erotica market dwarfs the English-only addressable market.

## Multi-Channel Delivery

The engineering abstraction is straightforward: a message queue that routes to the reader's chosen channel. Each channel adapter (WhatsApp Business API, Twilio SMS, APNs/FCM push, Signal if viable) receives the same content payload and delivers it in the native format. Claude can scaffold all adapters in parallel.

Transparent pricing by channel:
- **App (push notifications):** Cheapest. ~$0.03/day delivery cost.
- **WhatsApp Business API:** ~$0.005-0.08/message. Cost depends on message category and region. Potentially $21-336/subscriber for 42 days at 100 msgs/day.
- **SMS:** ~$0.80-1.00/day. $33-42/subscriber for 42 days. Most expensive.
- **Signal:** No business API exists (as of April 2026). Likely dead unless this changes.

Reader-facing pricing could reflect these tiers openly: "SMS delivery is $79, WhatsApp is $59, app is $49." Transparency builds trust and frames the value as the experience, not the channel.

## Global Expansion — Language Priority

### Spanish (HIGH PRIORITY)
- WhatsApp is dominant across Latin America and Spain
- Massive romance readership — Latin America is one of the largest romance markets globally
- No erotic content censorship at the platform or government level
- Cultural adaptation is real work but achievable — conversational Spanish texting culture is rich and distinct
- Combined addressable population: ~500M+ Spanish speakers

### Mandarin (COMPLEX)
- China doesn't use WhatsApp or SMS for messaging — it's WeChat
- WeChat has strict content censorship (CCP content regulations)
- Erotic literary content in mainland China is a regulatory problem, not a delivery problem
- Taiwan (23M, no censorship) and overseas Chinese diaspora are more viable initial markets
- May require fundamentally different content adaptation, not just translation

## Critical Distinction: Translation vs Cultural Adaptation

Dezibel is conversational literary fiction — texting voice, slang, rhythm, humor, cultural references. Translating this is not language conversion. It is cultural rewriting. A Spanish Dezibel isn't a translated Dezibel — it's a rewritten one that captures equivalent intimacy in a different cultural register.

This means:
- Professional literary translators, not AI translation
- Cultural consultants for each target market
- Potentially different character dynamics or references to achieve the same emotional effect
- Cost and timeline per language is significant — this is closer to commissioning a new adaptation than running a file through translation

UNVERIFIED: Whether AI-assisted translation (human translator + Claude for drafts/iteration) can reduce cost while maintaining literary quality. Worth testing on a single day's content.

## Kill Tests

1. **WhatsApp erotic content policy** — Email Meta Business API sales. Describe the product. Ask explicitly about erotic literary text content. One email, kills or opens. ($0, 30 min)
2. **Signal bulk sending** — Research current Signal API capabilities. If no business/bulk API exists, Signal is dead as a channel. ($0, 15 min)
3. **Spanish market translation cost** — Get a quote from a literary translator for one day's content (100+ messages, conversational register). Extrapolate to 42 days. If >$15K/language, test whether AI-assisted workflow reduces it. ($0-500)
4. **WeChat content policy** — Research erotic literary content on WeChat. If blocked, Mandarin expansion is limited to Taiwan + diaspora via other channels. ($0, 1 hour)

## What This Changes

- Delivery architecture is reopened — no longer locked to "native app + SMS rescue triggers"
- The investor pitch gains a global expansion story beyond English
- Unit economics vary by channel — the deck needs to show per-channel margins, not a single blended number
- Spanish-language markets become the obvious second-market play (WhatsApp dominant, no censorship, massive readership)
- Mandarin is a longer-term play with significant regulatory and platform constraints

## Sources

- WhatsApp Business API pricing: Meta developer documentation
- SMS costs: Twilio pricing ($0.0079/segment outbound US)
- Signal API status: Signal developer documentation (no business API as of 2026)
- Romance market global: PublishDrive, Shelf Awareness (2024-2025)
