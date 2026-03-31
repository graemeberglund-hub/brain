---
title: "Adult payment processors: CCBill, Segpay, alternatives for dezibel vibrator tier"
type: reference
tags: [dezibel, payments, ccbill, segpay, stripe, compliance, erotic-content]
created: 2026-03-29
area: "[[writing-and-film]]"
source: "Web research on adult-friendly payment processors as Stripe alternative for vibrator bundle tier."
---

# Adult Payment Processors for Dezibel Vibrator Bundle Tier

## Context

Dezibel's vibrator bundle tier ($149-199) combines serialized erotic literary fiction (~30% explicit content) with a Lovense vibrator. Per kill test K24, this combination is **LIKELY DEAD on Stripe** — the bundle eliminates plausible deniability against Stripe's "designed for the purpose of sexual gratification" restriction. The text-only tier ($49) has a defensible Stripe path. This research evaluates dedicated processors for the bundle tier.

Dezibel is a **one-time purchase** ($49-199), not a recurring subscription. This matters because most adult processors are subscription-optimized.

---

## Processor Comparison Table

| Factor | CCBill | Segpay | Epoch | Verotel | Sticky.io |
|--------|--------|--------|-------|---------|-----------|
| **Transaction fee** | 3.9% + $0.55 (standard); 10.8-14.5% (adult IPSP) | 5-15% (custom quoted) | 5-15% (custom quoted, all-inclusive) | 13-15.5% | Custom quoted |
| **Monthly/annual fee** | None (IPSP); varies by plan | None documented | None (setup free) | €500/year (Basic); €25/mo min (Premium) | Custom |
| **Setup cost** | None | None | $1,000 card network registration (US) | Included in annual fee | Custom |
| **Rolling reserve** | 5% for 13-26 weeks | 5% for 6 months | Standard (% varies) | 10% for 6 months | Unknown |
| **Chargeback fee** | $25 per chargeback | Not published | Not published | Not published | Unknown |
| **Payout schedule** | 9 days after billing period | Weekly | Not published | Not published | Unknown |
| **International/Canada** | Yes, CAD supported, no cross-border fees | USD/EUR/GBP only (no CAD direct) | Yes | EUR-focused | US-focused |
| **One-time purchase** | Yes, but may need separate sub-account from subscription | Yes | Yes | Yes | Subscription-focused |
| **API quality** | RESTful API + JS widget; adequate docs | SOAP + REST APIs; comprehensive docs | Basic | Basic | REST API |
| **React Native SDK** | None — web JS widget only, needs WebView wrapper | None — would need WebView or backend API | None | None | None |
| **Onboarding speed** | 1-4 weeks | 24-72 hours post-KYC | 1-2 weeks | 1-2 weeks | Unknown |
| **Content policy** | Explicitly supports adult content + physical products | Explicitly supports adult merchants | Explicitly supports adult content | Explicitly supports adult (50K+ merchants) | Supports "high-risk" but adult policy unclear |
| **Statement descriptor** | "CCBILL.COM" or "CCBILLEU" (customizable to generic name) | "SEGPAY*" or "SP*" + merchant name (customizable) | "EPOCH.CO" variants | "VEROTEL" or "CARDBILLING" | Merchant name |

### Processors That Are OUT

| Processor | Status | Reason |
|-----------|--------|--------|
| **Paddle** | REJECTED | Explicitly prohibits "sexually-oriented or pornographic products or services" and "any material of a lewd and lascivious nature." No exceptions process documented. |
| **LemonSqueezy** | REJECTED | Explicitly prohibits "sexually-oriented or pornographic content." Digital goods only — cannot sell physical vibrator. |
| **Stripe** (for bundle tier) | REJECTED | "Including literature" in the sexual gratification restriction. Bundle with vibrator eliminates any gray area. See kill test K24. |

---

## Detailed Processor Analysis

### CCBill — Industry Standard

**Pricing:** The published "3.9% + $0.55" rate is for their standard/low-risk tier. Adult content merchants using CCBill as an IPSP (Internet Payment Service Provider) pay significantly more — typically 10.8-14.5% all-in. At $199/transaction, that's $21.49-$28.86 per sale vs Stripe's $6.07. Additional card network registration fees: ~$500 (Mastercard) + $950 (Visa) annually.

**Integration:** RESTful API with an "Advanced Widget" JavaScript library for web checkout. The widget handles PCI compliance by sending card data directly to CCBill (never touches your server). No native React Native SDK exists. For a React Native app, you'd either: (a) embed a WebView pointing to CCBill's hosted checkout, or (b) call CCBill's REST API from your backend and build a custom payment form (increases PCI scope). The WebView approach is simpler and maintains PCI compliance.

**Content policy:** Explicitly built for adult content. No ambiguity. They handle Visa/Mastercard adult content registration on your behalf.

**Chargebacks:** Built-in fraud detection using proprietary database with 10+ years of transaction history. $25 per chargeback. Industry target: keep chargebacks under 0.75%. CCBill's fraud tools help — they catch patterns before they become disputes.

**Payouts:** 9 days after billing period ends. Supports CAD payouts with no cross-border fees. Wire transfer or ACH.

**Statement descriptor:** Shows "CCBILL.COM" by default but can be customized to a generic business name. This is important — CCBill is widely recognized as an adult payment processor. A subscriber's partner seeing "CCBILL.COM" on a statement knows exactly what it means. Custom descriptors mitigate this but aren't guaranteed across all card issuers.

**One-time purchases:** Supported but CCBill is subscription-optimized. One-time payments may require a separate sub-account configuration. Their system treats subscriptions and single purchases as different billing models internally.

**Verdict:** Most established option. Higher fees are the trade-off for zero content policy risk. The CCBILL statement descriptor stigma is real but manageable with custom descriptors.

### Segpay — Best Onboarding Speed

**Pricing:** Custom quoted, typically 5-15% depending on volume and risk assessment. Rolling reserve of 5% for 6 months is standard. Card network registration fees apply ($950 Visa, $500 Mastercard as of April 2024).

**Integration:** Offers both SOAP-based reporting services and REST processing APIs. Documentation is comprehensive — gateway integration guide, processing API guide, and merchant portal docs all available. No React Native SDK; same WebView approach needed as CCBill.

**Content policy:** Explicitly serves adult and dating merchants globally. US and EU licensed. No ambiguity about erotic fiction + sex toy bundles.

**Chargebacks:** 3D Secure support. Multiple acquiring bank relationships for transaction stability (if one bank has issues, traffic routes to another). Chargeback handling details are custom per merchant agreement.

**Payouts:** Weekly payouts after settlement. Supports USD, EUR, GBP. **No direct CAD settlement documented** — would likely receive USD and convert through your Canadian bank. Wire, ACH, Paxum, or Payoneer options.

**Statement descriptor:** Shows "SEGPAY*" followed by merchant name. Customizable. Same stigma considerations as CCBill — Segpay is recognized in the adult payment space, though less widely known to mainstream consumers than CCBill.

**One-time purchases:** Supported. Less subscription-centric than CCBill in architecture.

**Onboarding:** 24-72 hours post-KYC completion — significantly faster than CCBill's 1-4 week timeline. Good for testing.

**Verdict:** Strong alternative to CCBill. Faster onboarding is a real advantage for launch timelines. Lack of direct CAD settlement is a minor friction.

### Epoch — Subscription Specialist

**Pricing:** All-inclusive rates (custom quoted, 5-15% range). No setup fees. Card network registration: $1,000 initial + $1,000 annual renewal (covers both Visa and Mastercard). Rolling reserves are standard but percentage varies by merchant risk profile.

**Integration:** Basic API compared to CCBill and Segpay. Documentation is less developer-friendly. IPSP model means they handle PCI compliance as the merchant of record.

**Content policy:** 20+ year track record serving adult content. Explicitly supports adult digital content and membership sites.

**Chargebacks:** Reports of punitive pricing (up to 5x rates) for merchants with high chargeback or fraud history. Aggressive on protecting their acquiring bank relationships.

**Payouts:** Schedule not publicly documented. International support available but details require direct inquiry.

**One-time purchases:** Supports VOD (video-on-demand) single-purchase model, which maps well to dezibel's one-time purchase structure.

**Verdict:** Viable but less attractive than CCBill or Segpay. Weaker developer experience. 5x rate penalty for chargebacks is concerning for a first-time adult merchant.

### Verotel — European Focus

**Pricing:** Most transparent published pricing of the group, and the most expensive. Basic plan: €500/year + 15.5% per transaction + 10% rolling reserve for 6 months. Premium plan: 13-14% transaction fee based on volume, but requires €1,000/week minimum processing or pays €25/month minimum fee. No early termination fees.

**Integration:** Basic API. EUR-focused. Licensed as Electronic Money Institute by Dutch Central Bank — strong regulatory standing in EU.

**Content policy:** 50,000+ adult merchants since 1998. Explicit adult support. Also serves nutraceuticals and other high-risk verticals.

**Payouts:** EUR-focused. International payouts available but optimized for European merchants. Not ideal for a Canadian entity primarily serving North American customers.

**One-time purchases:** Supported via FlexPay system.

**Verdict:** Best for European market expansion. Not ideal as primary processor for a Canadian entity serving North American audience. Highest published transaction fees. The €1,000/week minimum on Premium would require ~5-7 bundle sales per week minimum — tight for launch phase.

---

## Split-Processor Architecture

### The Recommended Approach

**Stripe for text-only tiers ($49-99) + CCBill or Segpay for vibrator bundle ($149-199).**

This is architecturally sound and common in e-commerce. The implementation:

1. **Single checkout UI** — user selects tier, your frontend routes to the appropriate processor
2. **Stripe handles** the lower-risk text-only purchase (2.9% + $0.30)
3. **CCBill/Segpay handles** the vibrator bundle (10-15%)
4. **Your backend** manages order state, fulfillment, and user accounts regardless of which processor charged them

### Can You Make It Seamless?

Yes, with caveats:

- **Different checkout experiences:** Stripe Checkout is a polished, customizable embedded form. CCBill's checkout is a hosted page or WebView widget. Users will notice the difference in UI unless you invest in custom styling. Segpay offers similar hosted page approach.
- **Unified order management:** Your backend needs to handle webhooks/postbacks from both processors and unify them into a single order/fulfillment system.
- **User accounts:** The user's account and content access should be managed by your system, not the payment processor. Payment is just the gate.

### PCI Compliance with Multiple Processors

Using multiple processors does **not** double your PCI burden if you follow these rules:

1. **Never handle raw card data.** Use each processor's hosted checkout or JavaScript widget. Card numbers go directly from the user's browser to the processor's servers.
2. **Use tokenization.** Both Stripe and CCBill support payment tokens — your server never sees the card number.
3. **SAQ-A qualification.** If you fully outsource card handling to hosted checkouts, you qualify for the simplest PCI self-assessment (SAQ-A) regardless of how many processors you use.
4. **Track your scope.** Document which systems touch cardholder data (ideally: none). The compliance burden increases only if you build custom payment forms that route card data through your servers.

**Net PCI impact of split processing: minimal** if using hosted checkouts from both processors.

---

## Statement Descriptor Stigma Assessment

This is a real concern for dezibel's audience. The vibrator bundle tier targets women 25-45 who may share bank accounts or credit card statements with partners.

| Processor | Default Descriptor | Customizable? | Stigma Risk |
|-----------|-------------------|---------------|-------------|
| Stripe | Your business name | Yes, fully | None |
| CCBill | "CCBILL.COM" | Yes, to generic name | **HIGH** — widely recognized as adult processor. Google "CCBILL charge on credit card" and every result says adult content. |
| Segpay | "SEGPAY*MERCHANTNAME" | Yes, to generic name | **MEDIUM** — less consumer recognition than CCBill, but still searchable. |
| Epoch | "EPOCH.CO" | Yes | **MEDIUM-HIGH** — known in adult space. |
| Verotel | "VEROTEL" or "CARDBILLING" | Yes | **MEDIUM** — "CARDBILLING" is neutral. |

### Mitigation Strategies

1. **Custom descriptor:** Set it to something neutral like "DEZIBEL MEDIA" or "DEZIBEL LITERARY." Both CCBill and Segpay allow this, though it may not propagate to all card issuers.
2. **Separate legal entity:** Process the vibrator purchase through a separate business entity with a neutral name. The descriptor shows the entity name, not the processor name.
3. **Pre-purchase disclosure:** Tell customers what will appear on their statement at checkout. Reduces chargebacks from confused/embarrassed customers.
4. **Apple Pay / Google Pay:** If the processor supports these wallet methods, the descriptor shows the wallet transaction, not the underlying processor. CCBill supports Apple Pay.

---

## Cost Impact Analysis for Dezibel

### Per-Transaction Cost Comparison

| Tier | Price | Stripe Cost | CCBill Cost (12%) | Segpay Cost (est. 10%) |
|------|-------|-------------|-------------------|----------------------|
| Text-only | $49 | $1.72 (3.5%) | $5.88 (12%) | $4.90 (10%) |
| Text + extras | $99 | $3.17 (3.2%) | $11.88 (12%) | $9.90 (10%) |
| Vibrator bundle | $149 | $4.62 (3.1%) | $17.88 (12%) | $14.90 (10%) |
| Vibrator bundle (high) | $199 | $6.07 (3.0%) | $23.88 (12%) | $19.90 (10%) |

### Annual Fixed Costs (Adult Processor)

- Card network registration: $1,450/year (Visa $950 + Mastercard $500)
- CCBill rolling reserve: 5% of revenue held for 13-26 weeks (returned, but impacts cash flow)
- No monthly minimums on CCBill standard plans

### Break-Even Consideration

At 500 vibrator bundle sales ($199): Stripe would cost ~$3,035. CCBill at 12% costs ~$11,940 + $1,450 registration = ~$13,390. **The adult processor costs ~$10,355 more annually** — the price of compliance certainty.

At 2,000 sales: Stripe ~$12,140 vs CCBill ~$49,210. Delta: ~$37,070/year.

This is a significant margin hit. It reinforces the split-processor strategy: use Stripe where you can, adult processor only where you must.

---

## Recommendation for Dezibel

### Primary Architecture

1. **Stripe** for text-only tiers ($49-99). Proactively contact Stripe pre-launch to discuss classification. Position as literary fiction, not adult content. Have CCBill integration ready as fallback.

2. **Segpay** (recommended over CCBill) for vibrator bundle tier ($149-199).
   - Faster onboarding (24-72 hours vs 1-4 weeks)
   - Competitive pricing in the 5-15% range
   - Weekly payouts (vs CCBill's 9-day cycle)
   - Lower consumer recognition = less statement stigma
   - Good API documentation

3. **CCBill** as secondary/backup adult processor. Apply for merchant account in parallel. Having two adult processor relationships provides redundancy if one has issues with acquiring banks.

### Integration Path (React Native)

Since neither CCBill nor Segpay offers a React Native SDK:

1. **WebView approach** (recommended): Embed the processor's hosted checkout page in a React Native WebView. Maintains PCI compliance, works with both processors, minimal custom code.
2. **Backend API approach** (more work): Call processor's REST API from your Node/backend, build custom payment form in React Native. Requires PCI SAQ-A-EP compliance instead of SAQ-A. Only justified if checkout UX customization is critical.

### Pre-Launch Checklist

- [ ] Apply for Segpay merchant account (24-72 hour approval)
- [ ] Apply for CCBill merchant account in parallel (1-4 week approval)
- [ ] Contact Stripe to discuss text-only tier classification
- [ ] Set custom billing descriptors on all processors ("DEZIBEL MEDIA" or similar)
- [ ] Build unified order management that handles webhooks from Stripe + Segpay/CCBill
- [ ] Test WebView checkout flow in React Native for adult processor
- [ ] Implement pre-purchase statement descriptor disclosure at checkout
- [ ] Consider separate legal entity for vibrator bundle processing

---

## Key Unknowns (UNVERIFIED)

1. **Segpay's exact rate for dezibel's profile** — requires custom quote. The 5-15% range is wide.
2. **CCBill's exact adult IPSP rate for one-time purchases** — their published 3.9% + $0.55 is for standard merchants, not adult IPSP.
3. **CAD payout options from Segpay** — USD settlement confirmed, CAD direct unclear.
4. **Custom descriptor propagation** — both CCBill and Segpay allow custom descriptors, but propagation to all card issuers is not guaranteed.
5. **Sticky.io adult content policy** — could not confirm explicit adult support. Custom quote required.
6. **Whether Segpay's one-time purchase flow is truly seamless** or requires workarounds like CCBill's sub-account setup.

---

## Sources

- [Stripe Prohibited and Restricted Businesses](https://stripe.com/legal/restricted-businesses)
- [CCBill RESTful API Guide (GitHub)](https://github.com/CCBill/restful-api-guide)
- [CCBill Review — Merchant Maverick](https://www.merchantmaverick.com/reviews/ccbill-review/)
- [CCBill Review — CardFellow](https://www.cardfellow.com/blog/ccbill-review)
- [CCBill Pricing and Fees — Oreate AI](https://www.oreateai.com/blog/navigating-the-nuances-understanding-ccbill-pricing-and-fees-for-adult-payment-processing/4b3e82dc5fa01b8db12bd9a0ce927492)
- [CCBill Alternatives — Corepay](https://corepay.net/articles/cc-bill-alternatives/)
- [Segpay Processing API Guide](https://gethelp.segpay.com/docs/Content/DeveloperDocs/ProcessingAPI/Home-ProcessingAPI.htm)
- [Segpay Developer Docs](https://gethelp.segpay.com/docs/Content/DeveloperDocs/Home-DevDocs.htm)
- [Segpay Getting Paid](https://gethelp.segpay.com/docs/Content/GettingStarted/GettingPaid.htm)
- [Segpay Visa Pricing Tiers](https://segpay.com/blog/understanding-visas-new-pricing-high-risk-tiers/)
- [What is SegPay on my bank statement](https://yourbankstatementconverter.com/blog/what-is-segpay-on-my-bank-statement/)
- [Epoch Payment Solutions — FinRate](https://thefinrate.com/epoch-payment-solutions/)
- [Epoch Review — Merchant Machine](https://merchantmachine.co.uk/high-risk/epoch/)
- [Verotel Review — Corepay](https://corepay.net/articles/verotel-review-alternatives/)
- [Verotel Review — Card Payment Options](https://www.cardpaymentoptions.com/credit-card-processors/verotel/)
- [Paddle Acceptable Use Policy](https://www.paddle.com/help/start/intro-to-paddle/what-am-i-not-allowed-to-sell-on-paddle)
- [LemonSqueezy Prohibited Products](https://docs.lemonsqueezy.com/help/getting-started/prohibited-products)
- [7 Best Payment Gateways for Adult Sites 2025 — ATLOS](https://atlos.io/blog/best-payment-gateways-for-adult-sites)
- [Adult Payment Processing 2025 — Scrile](https://www.scrile.com/blog/adult-payment-processing)
- [Best Payment Gateways for Adult Websites 2026 — MyntPay](https://myntpay.com/top-payment-gateways-for-adult-websites/)
- [Stripe vs PayPal vs CCBill — MyntPay](https://myntpay.com/stripe-vs-paypal-vs-ccbill-adult-payments-guide/)
- [PCI Compliance with Multiple Processors — IXOPAY](https://www.ixopay.com/blog/maintaining-pci-compliance-when-using-multiple-processors)
- [Stripe PCI Compliance Guide](https://stripe.com/guides/pci-compliance)
