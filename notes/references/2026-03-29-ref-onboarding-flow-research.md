---
title: "Onboarding flow optimization: reducing 7-8 steps to maximum conversion"
type: reference
tags: [dezibel, onboarding, ux, conversion, app]
created: 2026-03-29
area: "[[writing-and-film]]"
source: "Web research on mobile app onboarding best practices and conversion optimization."
---

## Context

Dezibel requires 7-8 onboarding steps: phone number, payment ($49-199), age verification (DOB), timezone, app download, push notification opt-in, and optional haptic device pairing. At 20-40% dropout per screen, a naive 7-screen flow retains only 3-13% of visitors. This note synthesizes industry data and comparable app teardowns to design a flow that maximizes conversion.

## 1. Dropout rates: the math

Industry benchmarks:
- **15% completion drop per screen beyond five** (Appcues 2025-2026 data)
- **20-40% dropout per additional screen** is widely cited across mobile onboarding literature
- **72% of users abandon apps** if onboarding requires too many steps
- **B2C onboarding completion rates**: 30-50% is considered good; top performers reach 70-80%
- **80% of users who don't complete onboarding disappear after day one**
- **Skippable flows have 25% higher completion** (UserIQ data)

Modeled dropout for dezibel (assuming 25% dropout per screen):

| Screens | Survivors (of 1,000 visitors) | Conversion |
|---------|-------------------------------|------------|
| 3       | 422                           | 42%        |
| 4       | 316                           | 32%        |
| 5       | 237                           | 24%        |
| 7       | 134                           | 13%        |
| 8       | 100                           | 10%        |

Every screen removed recovers ~25% of lost conversions. The target is 3-4 mandatory screens before the user reaches the app.

## 2. What top apps do

### Calm (meditation, $69.99/year)
- Opens with a **breathing exercise** — value delivery before any signup screen.
- Asks what users are looking for (multi-select personalization), then prompts account creation.
- Payment appears after users are "relaxed and excited about the possible benefits."
- One more personalization question (meditation comfort level), then content.
- ~4-5 screens. Key lesson: **lead with an experience, not a form**.

### Duolingo (gold standard for onboarding)
- **Personalization before signup**: users choose a language, set goals, and complete a sample lesson before creating an account. Registration is deferred until the user has already invested effort and experienced value.
- **Gradual engagement**: postpone registration as long as possible — until the moment users must register to progress.
- Signup prompt appears at a logical moment after the user's first win (completed exercise).
- Self-attribution question ("where did you hear about us?") collects first-party data without feeling like friction.
- Key lesson for dezibel: **show value before asking for commitment**. Dezibel's "value preview" equivalent is the story premise, voice samples, or a Day 0 teaser.

### Headspace
- Welcome screen → one-click signup (Google/Apple) → 3 personalization questions → value proposition screen → sample session → paywall.
- ~5-6 screens, but personalization questions feel like engagement, not friction.
- Key lesson: **frame data collection as personalization**, not as bureaucratic gates.

### Dipsea (closest comparable: paid erotic audio)
- Multiple sign-up options (Email, Apple, Google, Facebook) to minimize friction.
- **4 personalization questions** after account creation to recommend content.
- **Soft paywall immediately after account creation**: 7-day free trial, $69.99/year ($5.83/month) or $12.99/month.
- Content library accessible after trial activation.
- Key lesson: Dipsea asks personal questions but frames them as "help us recommend stories for you." The intimacy of the content category makes this framing essential — it converts data collection into a personalization promise.

### Key difference from dezibel
All three apps use **recurring subscriptions**. Dezibel uses a **one-time purchase ($49-199)**. This changes the calculus: there's no free trial to defer payment. The full price commitment happens upfront, which means the pre-payment value pitch must be significantly stronger.

## 3. Payment: web checkout vs. in-app purchase

Recent data (RevenueCat, post-App Store ruling):
- **In-app purchase conversion**: 27-30% of users who reach the paywall complete purchase
- **Web checkout conversion**: 17-19% (a 25-45% relative drop)
- **71% of users who tap "Subscribe" complete IAP** vs. **44% who tap a web CTA**
- Web checkout nets ~93 cents per dollar of IAP revenue

**Recommendation for dezibel**: Web checkout first, then app download. Rationale:
- Dezibel is a **one-time purchase**, not a subscription. Apple's 30% cut on a $49-199 product is $15-60 per sale. That's significant.
- The product doesn't start immediately — there's a warmup period. This means the user isn't expecting instant access, so the web-to-app handoff friction is tolerable.
- Web checkout allows full control of the purchase experience: pricing tiers, bundle selection (standard vs. haptic), upsells.
- The conversion penalty of web vs. IAP matters less when you're saving 30% on every sale and have full control of the payment UX.

**Flow**: Landing page → pricing tier selection → web checkout (Stripe) → account creation → app download link via SMS/email → app login.

## 4. Recommended onboarding flow

### Pre-purchase (web — 2 screens)

**Screen 1: Landing page / value pitch**
- Story premise, voice samples, social proof
- "Start your 42-day experience" CTA
- Auto-detect timezone from browser (no user input needed)

**Screen 2: Pricing + checkout**
- Three tiers displayed: Standard ($49), Premium ($149), Collector ($199)
- Haptic bundle description for premium tiers
- Age verification: DOB field integrated into checkout form (not a separate screen)
- Phone number field: "Where should we send your story?" (frames SMS as delivery, not data collection)
- Payment via Stripe
- Single page: tier selection + DOB + phone + payment = one screen

### Post-purchase (app — 2 screens)

**Screen 3: App download + login**
- Immediate SMS/email with app download link after purchase
- Magic link or code-based login (no password creation)
- App detects timezone automatically from device

**Screen 4: Push notification opt-in**
- Pre-permission priming screen: "Dezibel sends you new chapters as they arrive. Turn on notifications so you never miss a message from Emma or Hasta."
- "Enable notifications" → triggers iOS system prompt
- "Not now" option (can be prompted again later)
- This is the final mandatory screen. User lands on a "welcome" or Day 0 preview.

### Deferred (progressive — during the 42-day experience)

**Day 1 (in-app)**: Welcome message. No additional setup.

**Day 14 (in-app, haptic bundle purchasers only)**: Haptic device pairing
- By Day 14, the first erotic scene arrives. This is the natural moment to prompt pairing.
- "Your Ferri is about to come alive. Pair it now." + visual setup wizard.
- Deferring this avoids: (a) a complex Bluetooth pairing flow during initial onboarding, (b) asking users to handle a physical device before they care about the story, (c) adding a screen that only applies to premium-tier users.
- IoT best practice confirms: visual wizard with discrete steps, progress indicators, and the ability to skip/defer works best.

**Ongoing (contextual)**: Push notification re-prompt
- If user declined push notifications at Screen 4, re-prompt after a meaningful moment (e.g., after they read their first chapter and might want to know when the next one arrives).
- Pre-permission prompts have no iOS limit — only the system prompt is one-shot per app install context.

### Screen count summary

| When | Screen | Content | Dropout risk |
|------|--------|---------|-------------|
| Web | 1 | Landing + value pitch | Low (browsing) |
| Web | 2 | Pricing + checkout + DOB + phone | HIGH (payment) |
| App | 3 | Download + login | Medium (platform switch) |
| App | 4 | Push notification opt-in | Low (soft prompt) |
| Day 14 | 5 | Haptic pairing (premium only) | Low (invested user) |

**Mandatory screens before first content: 4** (down from 7-8).
**Expected conversion at 25% dropout/screen: ~32%** (vs. ~10% for 8 screens).

## 5. Age verification: what converts best

Three approaches ranked by conversion:

1. **DOB field embedded in checkout form** (recommended): Lowest friction. User enters DOB alongside other purchase info. No separate screen. Use **three separate input fields** (MM / DD / YYYY) — not a native date picker, not a single text field. Three fields are unambiguous, easier to type on mobile, and easier to validate inline. Legal teams generally accept DOB self-declaration for age-gated content that isn't regulated like alcohol/cannabis. Conversion impact: minimal when combined with other fields.

2. **"Are you 18+?" toggle/checkbox**: Highest conversion but weakest legal standing. Courts and regulators increasingly view self-declaration toggles as insufficient, especially for sexual content. Not recommended for dezibel given the erotic content and potential regulatory scrutiny.

3. **Third-party ID verification (Yoti, Incode, etc.)**: Strongest legal protection but heaviest friction. One source reports 40% conversion improvement when using passive methods (email/phone-based age estimation) vs. document upload. Reserve this as an escalation path if regulators require it in specific markets.

**Recommendation**: DOB field in checkout form. If regulatory requirements tighten, layer in passive age estimation (phone number or email-based) before escalating to document verification. A layered approach — least invasive first, escalate only when needed — maximizes both conversion and compliance.

## 6. Push notification timing

- **89% opt-in rate** when users trigger the prompt themselves after understanding the value
- Pre-permission priming (custom in-app prompt before system prompt) increases opt-in by **20-30%** vs. cold system prompt
- Pre-permission screens should appear **after a meaningful action** (purchase, first content consumption), not during cold onboarding
- **82% of trial starts happen on installation day** — if the push prompt doesn't happen in session one, the window narrows fast
- Best practice: explain what notifications will contain ("new chapters," "messages from characters"), how often ("daily during your story"), and include a "later" button
- Two-step process: custom pre-permission screen → if user taps "Enable," immediately show iOS system prompt. No delay between.

**Dezibel-specific recommendation**: Post-purchase, pre-first-content. The user has paid and downloaded the app. They understand the product delivers content over time. This is the moment where "you'll miss chapters without notifications" is most credible.

## 7. Phone number collection

Dezibel needs the phone number for SMS triggers (Twilio), even though the app is the primary delivery channel. Framing matters:

- **"Where should we send your story?"** — frames phone number as delivery address, not data extraction
- Collect during web checkout alongside payment (not a separate screen)
- Send the app download link to this number immediately after purchase — this proves the number works and establishes the SMS channel before the story begins
- SMS verification (OTP) can double as account verification, eliminating a separate email confirmation step

## 8. Progressive onboarding across the 42-day experience

Dezibel's serialized structure is itself a progressive onboarding vehicle. Defer non-essential prompts to moments when the user is invested and the prompt is contextually relevant.

| Timing | Action | Rationale |
|--------|--------|-----------|
| Purchase | Payment + phone + DOB | Mandatory. Capture at peak intent. |
| App install | Push notification pre-prompt | After download, before Day 1. User understands content arrives over time. |
| Day 1 | Welcome message, no setup | Let the story do the work. No friction. |
| Day 2-3 | Push notification system prompt (if pre-prompt accepted) | User has received first messages, understands what notifications deliver. |
| Day 7 | Optional profile/preference prompt | User is committed (one week in). Good moment for personalization. |
| Day 14 | Haptic device pairing (premium tier only) | Act II transition. First erotic scene arrives. Natural moment for "your Ferri is about to come alive." |
| Day 14 | Referral/share prompt | Users who lasted 2 weeks are advocates. Offer reread discount to share. |
| Day 35 | oBitchuary Substack cross-sell | Before Act III emotional climax. Peak engagement moment. |
| Ongoing | Push re-prompt (if declined) | After meaningful story moments, re-offer with custom pre-prompt. No iOS limit on custom prompts. |

## 9. Dezibel-specific considerations

**The warmup period is an asset, not a liability.** Most apps need onboarding to happen fast because users expect immediate value. Dezibel's structure — purchase now, story starts on a Monday — creates a natural gap where additional setup (app download, notification opt-in, device pairing) can happen without time pressure. Use this gap for a "getting ready" sequence via SMS:

- Purchase confirmation + app download link (immediate)
- "Your story begins Monday. Download the app and enable notifications so you're ready." (1-2 days before Day 1)
- Day 1: First chapter arrives

**Three pricing tiers complicate the checkout screen.** Mitigate with:
- Default to middle tier (highlighted/recommended)
- Collapse tier details behind expandable sections
- Show tier comparison only if user hesitates (scroll-triggered or "compare tiers" link)

**One-time payment psychology differs from subscriptions.** No free trial means the value pitch must be stronger. Consider:
- Story trailer / voice sample accessible from the landing page
- Social proof (reviews, media mentions)
- Money-back guarantee language ("Not for you? Full refund within the first 7 days")

## 10. Expected conversion model

Assumptions: 1,000 visitors reach the landing page.

| Scenario | Screens | Est. conversion | Paying users |
|----------|---------|----------------|-------------|
| Naive (all steps upfront) | 8 | 10% | 100 |
| Optimized (this proposal) | 4 mandatory | 28-32% | 280-320 |
| Aggressive (2-screen web + deferred app) | 2+2 deferred | 35-40% | 350-400 |

The "aggressive" scenario treats app download and push opt-in as post-purchase steps that don't count against checkout conversion — the user has already paid. Dropout at those stages means a paying user who hasn't installed the app yet, which can be recovered via SMS/email nudges.

## 11. Unresolved decisions

1. **Refund policy**: Does offering a 7-day refund guarantee increase checkout conversion enough to offset refund costs? TESTABLE. Kill test: A/B the checkout page with and without refund language.

2. **Day 0 preview content**: Should there be a free "Day 0" teaser before purchase? Duolingo's model (value before commitment) suggests yes, but dezibel's content is the story itself — giving away content may undermine the purchase. TESTABLE. Kill test: landing page with vs. without audio teaser, measure checkout rate.

3. **App-optional flow**: Could dezibel work SMS-only for users who don't download the app? This would reduce onboarding to 2 screens (landing + checkout). TESTABLE. Kill test: what percentage of the story experience degrades without the app (haptic sync, rich media, reading interface)?

4. **Haptic pairing success rate**: What percentage of premium users actually pair the device on Day 14? If low, the premium tier value proposition weakens. Need post-launch data.

## Sources

- [App Onboarding Rates 2025 — Business of Apps](https://www.businessofapps.com/data/app-onboarding-rates/)
- [100+ User Onboarding Statistics — UserGuiding](https://userguiding.com/blog/user-onboarding-statistics)
- [Mobile App Conversion Rate Benchmarks — UXCam](https://uxcam.com/blog/mobile-app-conversion-rate/)
- [Headspace Onboarding Sequence — Appcues](https://goodux.appcues.com/blog/headspaces-mindful-onboarding-sequence)
- [Headspace Onboarding — App Fuel](https://theappfuel.com/examples/headspace_onboarding)
- [Calm Onboarding — App Fuel](https://www.theappfuel.com/examples/calm_onboarding)
- [Duolingo Onboarding — Appcues](https://goodux.appcues.com/blog/duolingo-user-onboarding)
- [Duolingo Onboarding UX — UserGuiding](https://userguiding.com/blog/duolingo-onboarding-ux)
- [Dipsea App Teardown — ScreensDesign](https://screensdesign.com/showcase/dipsea-spicy-romantic-fiction)
- [Dipsea Paywall — Adapty](https://adapty.io/paywall-library/dipsea/)
- [Dipsea — App Fuel](https://theappfuel.com/apps/dipsea)
- [Web vs. In-App Subscriptions — RevenueCat](https://www.revenuecat.com/blog/growth/iap-vs-web-purchases-conversion-test/)
- [App-to-Web Conversion Rates — Superwall](https://superwall.com/blog/initial-data-is-in-app-to-web-conversion-rates-after-the-app-store-ruling)
- [iOS Push Notification Permissions — Hurree](https://blog.hurree.co/ios-push-notification-permissions-best-practises)
- [Push Notification Opt-In Rates — OneSignal](https://onesignal.com/blog/how-to-create-more-compelling-opt-in-messages-for-ios-push/)
- [Mobile Permission Priming — Appcues](https://www.appcues.com/blog/mobile-permission-priming)
- [Progressive Onboarding — Userpilot](https://userpilot.com/blog/progressive-onboarding/)
- [Progressive Onboarding — UserGuiding](https://userguiding.com/blog/progressive-onboarding)
- [Smart Device Onboarding — NN/g](https://www.nngroup.com/articles/smart-device-onboarding/)
- [IoT Onboarding UX — grandcentrix](https://grandcentrix.net/en/blog/iot-onboarding/)
- [Subscription Onboarding Patterns — DEV](https://dev.to/paywallpro/subscription-onboarding-15-patterns-you-must-know-4n4f)
- [Mobile App Onboarding — Adapty](https://adapty.io/blog/mobile-app-onboarding/)
- [Drop-Off Rate — Userpilot](https://userpilot.com/blog/drop-off-rate/)
