---
title: "Kill test K24: Stripe restricted businesses — erotic literary + vibrator bundle"
type: reference
tags: [dezibel, stripe, payments, compliance, kill-test, erotic-content]
created: 2026-03-29
area: "[[writing-and-film]]"
source: "Web research against Stripe Terms of Service, Restricted Businesses policy, and alternative payment processors."
---

# Kill Test K24: Stripe Restricted Businesses — Erotic Literary + Vibrator Bundle

## The Question

Can dezibel process payments through Stripe given: (a) serialized literary fiction with ~30% explicit erotic content, (b) a pricing tier that bundles a Lovense vibrator ($149-199), and (c) subscription pricing at $49-199/subscriber?

## Stripe's Exact Policy Language

From Stripe's [Prohibited and Restricted Businesses](https://stripe.com/legal/restricted-businesses) page, the relevant restriction:

> "Pornography and other mature audience content (including literature, imagery, and other media) designed for the purpose of sexual gratification"

Also prohibited:

> "Any artificial-intelligence generated content that meets the above criteria"

Also prohibited under adult services:

> "Prostitution, escorts, pay-per-view, sexual massages, fetish services, mail-order brides, and adult live-chat features"

The critical phrase is **"including literature"** — Stripe explicitly names literary content in the restriction. The test is whether the content is **"designed for the purpose of sexual gratification."**

## Analysis by Component

### Component 1: Literary Fiction with Erotic Content (~30% explicit)

**Classification question:** Is dezibel "designed for the purpose of sexual gratification"?

Dezibel is a 42-day serialized literary novel. Erotic content is approximately 30% of the total — embedded in narrative, character development, and thematic structure. It is not a pornographic product with narrative wrapper. However, Stripe's policy language does not distinguish between "primarily" and "partially" designed for sexual gratification. The presence of explicit sexual content in literature is enough to trigger the restriction.

**Precedent — Ream Stories:** Ream (subscription platform for fiction authors) [secured a specific exception from Stripe](https://storytellersruletheworld.com/on-payment-processing-for-steamy-romance-authors-a-message-from-the-ceo-of-ream/) to process payments for erotic literature and NSFW art. Key details:
- Ream negotiated directly with Stripe's team for this exception
- The exception covers "steamy romance" — erotic literary fiction
- Ream built their financial backend to allow migration to other processors if Stripe changes policy
- Ream actively monitors policy shifts and maintains backup processor relationships

**Precedent — Nifty Archives (2012):** Stripe [reinstated the Nifty Archives](https://www.eff.org/deeplinks/2012/11/payment-provider-stripe-upholds-free-speech-reactivates-nifty-archives) after initially shutting them down, adopting a position that constitutionally protected fiction should not be censored. This was a direct free-speech carve-out for literary content.

**Precedent — Substack:** Substack uses Stripe and hosts serialized erotic fiction via email newsletters. No documented mass shutdowns of erotic fiction on Substack as of this research date.

**VERDICT: RISKY.** The policy literally says "including literature." Exceptions exist (Ream, Nifty Archives, Substack) but they are negotiated case-by-case, not guaranteed. Dezibel as a standalone subscription service (not operating under an approved platform's umbrella) would need to either: (a) negotiate its own exception with Stripe, or (b) position itself as literary fiction that is not "designed for the purpose of" sexual gratification — a defensible but not bulletproof argument at 30% explicit content.

### Component 2: Lovense Vibrator Bundle ($149-199 tier)

**Classification question:** Does selling a sex toy through Stripe violate restricted businesses policy?

Stripe's policy does not explicitly list "sex toys" or "sexual wellness products" as a prohibited category. The restrictions target content (pornography, literature for sexual gratification) and services (escorts, sexual massages), not physical wellness/consumer electronics products.

**Market reality:**
- Lovense products are sold on Amazon, eBay, and Etsy — all of which use mainstream payment processors
- Stripe's own blog post ["Why some businesses aren't allowed"](https://stripe.com/blog/why-some-businesses-arent-allowed) acknowledged that restrictions on sex toys are "often outdated and overly moralizing" and expressed intent to "broaden the set" of supported businesses
- Multiple sources confirm that some sex toy retailers operate on Stripe, though with elevated risk classification
- One source noted the distinction: "the sale of a sex toy is fine, but if you encourage people to use it, they won't allow it"

**Risk factor:** As sales volume increases, acquiring banks (Wells Fargo, PNC for Stripe) may flag the account, particularly after revenue exceeds ~$50K. The combination of a vibrator with explicit literary content creates a stronger "designed for sexual gratification" signal than either component alone.

**VERDICT: RISKY but more defensible than the content component.** Sex toys sold as consumer products are a gray area Stripe has shown willingness to support. The risk escalates when bundled with explicit content because the bundle reinforces the "sexual gratification" framing.

### Component 3: Combined — Erotic Literary Subscription + Vibrator Bundle

The combination is the real problem. Each component individually sits in Stripe's gray area. Together, they create a product that is much harder to argue is not "designed for the purpose of sexual gratification":

- A serialized novel with 30% explicit sexual content
- Bundled with a vibrator
- Marketed as an immersive sensory experience

This combination would likely be classified as adult content by Stripe's compliance team, even if the literary merit is genuine. The vibrator bundle essentially eliminates the "it's literature, not pornography" defense.

**VERDICT: HIGH RISK / LIKELY DEAD for the combined bundle tier.** The $49 text-only tier has a defensible path. The $149-199 vibrator bundle tier almost certainly triggers Stripe's restrictions.

## Alternative Payment Processors

If Stripe won't work (or as a backup), these processors specialize in adult/high-risk content:

### Tier 1: Established Adult Processors

| Processor | Rate | Strengths | Notes |
|-----------|------|-----------|-------|
| **CCBill** | 10.8-14.5% | Industry standard for adult subscriptions. Built-in age verification, subscription billing, compliance handling. | Best fit for dezibel's subscription model. Most popular adult processor. |
| **Segpay** | 4-15% | Fast onboarding (24-72 hours). Good for streaming and content. | Transparent pricing, quick approval. |
| **Epoch** | 5-15% | Strong recurring billing engine. Complex membership tiers. | Good for subscription models with multiple tiers. |

### Tier 2: Newer/Hybrid Options

| Processor | Notes |
|-----------|-------|
| **Vendo Services** | Full adult payment orchestration. Recurring billing focus. |
| **MyntPay** | Custom integrations. Good for non-standard product bundles. |
| **NOWPayments** | Crypto-based. No content restrictions. Limited mainstream adoption. |

### Pricing Reality

- Stripe: 2.9% + $0.30 per transaction
- Adult processors: 5-15% per transaction, plus potential rolling reserves (0-20% held for 90-180 days)
- **Cost impact on dezibel:** At $49/subscriber, Stripe takes ~$1.72. CCBill at 12% takes ~$5.88. At $199/subscriber, Stripe takes ~$6.07. CCBill takes ~$23.88. This is a significant margin difference, especially at scale.

## Recommended Strategy

### Split-processor approach

1. **Text-only tiers ($49-99):** Attempt Stripe. Position dezibel as literary fiction subscription, not adult content. The 30% explicit content is a risk, but precedent exists (Ream, Substack, Nifty Archives). Contact Stripe proactively to discuss classification before launch.

2. **Vibrator bundle tier ($149-199):** Use a dedicated adult/high-risk processor (CCBill or Segpay) from day one. Do not attempt Stripe for this tier. The bundle makes the "sexual gratification" classification nearly certain.

3. **Backup plan:** Maintain a CCBill or Segpay integration as a warm standby for all tiers. If Stripe shuts down the text-only tiers, migration should take hours, not weeks. Ream's architecture (Stripe primary, alternative processor ready) is the model to follow.

### Pre-launch actions

- [ ] Contact Stripe directly to discuss dezibel's classification before account setup
- [ ] Apply for CCBill or Segpay merchant account in parallel (lead time: 1-4 weeks)
- [ ] Design payment architecture to support processor switching without subscriber disruption
- [ ] Review whether the vibrator can be sold through a separate legal entity / storefront to isolate the content subscription from the physical product

## Overall Verdict

| Component | Verdict | Confidence |
|-----------|---------|------------|
| Literary fiction with 30% erotic content on Stripe | **RISKY** | Medium — precedent exists both ways |
| Vibrator sales on Stripe | **RISKY** | Medium — gray area, Stripe has shown openness |
| Combined bundle on Stripe | **LIKELY DEAD** | High — combination eliminates plausible deniability |
| Text-only tiers on Stripe with proactive engagement | **VIABLE** | Medium — requires Stripe conversation pre-launch |
| All tiers on CCBill/Segpay | **SAFE** | High — designed for this exact use case, but 3-5x processing cost |

**Kill test K24 result: NOT DEAD, but requires architectural mitigation.** Stripe is not a guaranteed path for any tier, and is almost certainly blocked for the vibrator bundle. The business is viable with a split-processor strategy or full migration to adult-specialized processors, at the cost of higher payment processing fees (5-15% vs 2.9%).

## Sources

- [Stripe Prohibited and Restricted Businesses](https://stripe.com/legal/restricted-businesses)
- [Stripe Restricted Businesses FAQs](https://support.stripe.com/questions/prohibited-and-restricted-businesses-list-faqs)
- [Ream CEO on Payment Processing for Steamy Romance Authors](https://storytellersruletheworld.com/on-payment-processing-for-steamy-romance-authors-a-message-from-the-ceo-of-ream/)
- [EFF: Stripe Upholds Free Speech, Reactivates Nifty Archives](https://www.eff.org/deeplinks/2012/11/payment-provider-stripe-upholds-free-speech-reactivates-nifty-archives)
- [Stripe Blog: Why Some Businesses Aren't Allowed](https://stripe.com/blog/why-some-businesses-arent-allowed)
- [Corepay: Can Adult Merchants Use Stripe?](https://corepay.net/articles/stripe-adult-merchants/)
- [Signature Payments: Does Stripe Allow Adult Content](https://signaturepayments.com/does-stripe-allow-adult-content/)
- [ATLOS: 7 Best Payment Gateways for Adult Sites 2025](https://atlos.io/blog/best-payment-gateways-for-adult-sites)
- [Scrile: Adult Payment Processing 2025](https://www.scrile.com/blog/adult-payment-processing)
- [MyntPay: Best Payment Gateways for Adult Websites 2026](https://myntpay.com/top-payment-gateways-for-adult-websites/)
- [PayCompass: Stripe Restricted Business List](https://paycompass.com/blog/stripe-restricted-businesses/)
- [WiseAlt: Stripe Shutdown Adult Merchants](https://wisealt.com/stripe-shutdown-adult-merchants/)
