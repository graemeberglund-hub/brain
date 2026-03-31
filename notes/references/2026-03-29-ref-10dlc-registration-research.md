---
title: "10DLC registration: clean SMS triggers for dezibel notifications"
type: reference
tags: [dezibel, 10dlc, sms, registration, compliance, notifications]
created: 2026-03-29
area: "[[writing-and-film]]"
source: "Web research on 10DLC registration process and provider comparison."
---

## Summary

10DLC (10-Digit Long Code) is the mandatory US carrier registration system for business-to-consumer SMS. Dezibel's use case — clean notification triggers with zero erotic content in the SMS itself — is a strong candidate for approval. The SHAFT review examines SMS message content only, not the company's app or website. This means dezibel can operate a companion app with erotic content while sending fully compliant notification-only SMS.

**Bottom line:** Register as a Standard Brand with a "Notifications" campaign. Expect 1-3 weeks for approval. Total ongoing cost is negligible (~$10-15/month in registration fees + ~$0.01-0.014 per message all-in). Telnyx is the recommended provider for cost; Twilio if dezibel wants to stay on the existing stack.

---

## 1. Registration Process — Step by Step

### Step 1: Choose a Provider

Sign up with an SMS provider (Twilio, Telnyx, or Bandwidth). The provider submits registrations to The Campaign Registry (TCR) on your behalf.

### Step 2: Brand Registration

Submit business identity information to TCR through your provider:
- Legal company name (must match tax filings / business registration)
- Business registration number (for Canadian companies: Business Number / BN)
- Company website URL
- Business address
- Contact details (name, email, phone)
- Vertical / industry classification

**Canadian company note:** As of Q3 2025, TCR requires the Business Number (BN) for Canadian brand registration. Corporation or incorporation numbers are no longer accepted.

**Timeline:** Minutes to a few days.
**Cost:** $4 (sole proprietor) or $44-46 (standard brand, one-time).

### Step 3: Trust Score Assignment

TCR's reputation algorithm assigns a Trust Score (0-100) based on company data. This score determines throughput limits. A new startup with limited history will likely score in the low-to-medium range (25-50), which is adequate for dezibel's volume.

### Step 4: Campaign Registration

Register your specific messaging use case:
- Campaign description: "Story delivery notifications for dezibel subscribers"
- Use case type: **Notifications** (see Section 3 below)
- Sample messages (5 required — see Section 4)
- Opt-in method description (how subscribers consent)
- Link to privacy policy (must be on a live website)
- Link to terms of service
- Whether messages contain embedded links (mark "Yes" if any message includes a URL)
- Opt-out keywords supported (STOP, CANCEL, etc.)

**Timeline:** 3-7 business days typical; up to 4 weeks in backlogs.
**Cost:** $15 vetting fee (one-time) + $10/month recurring campaign fee.

### Step 5: Number Assignment

After campaign approval, request a 10DLC phone number and associate it with the approved campaign. Each number maps to one campaign.

**Cost:** ~$1-2/month for the phone number.

---

## 2. Can a Canadian Company Register for US 10DLC?

**Yes.** Canadian companies can register for 10DLC to send messages to US phone numbers. Key requirements:

- Canada does not participate in 10DLC for domestic Canadian traffic, but messages sent to US numbers are subject to 10DLC registration
- As of Q3 2025, the **Business Number (BN)** is the only accepted identifier for Canadian brand registration (corporation/incorporation numbers no longer valid)
- The registration process is identical to US companies — submit through your chosen provider
- Dezibel would need a Canadian BN (available through CRA registration)
- If dezibel is incorporated in BC, the BN from the CRA filing is what TCR needs

**UNVERIFIED:** Whether a brand-new Canadian corporation with no US presence receives a lower trust score than an established US entity. Likely yes, but the throughput floor is still adequate for dezibel's volume (see Section 6).

---

## 3. Campaign Type Selection

**Recommended: "Notifications" or "Account Notifications"**

TCR standard campaign use cases relevant to dezibel:

| Use Case | Description | Fit |
|----------|-------------|-----|
| **Account Notifications** | Notifications relating to an account | Best fit — subscribers have accounts |
| **Delivery Notifications** | Status updates on product/service delivery | Good fit — "new chapter available" |
| **Alerts** | System or security alerts | Weak fit — not really alerts |
| **Mixed** | Multiple use cases | Lower throughput, avoid |
| **Marketing** | Promotional content | Avoid — triggers stricter review |

**Recommendation:** Register as **"Account Notifications"** or **"Delivery Notifications."** These are "declared" (specific) campaign types, which receive higher throughput than "mixed" campaigns for the same trust score. Avoid "Marketing" — it implies promotional intent and gets lower throughput and stricter scrutiny.

The campaign description should emphasize: subscriber-initiated opt-in, content delivery notifications only, no promotional content, no links to purchase pages.

---

## 4. Five Sample Trigger Messages (SHAFT-Compliant)

These messages contain zero sexual, hateful, alcohol, firearms, or tobacco content. They function purely as notification triggers directing the reader to the companion app.

1. **"New chapter available. Open the app to continue reading."**

2. **"Emma just texted you. Open dezibel to read the message."**

3. **"You have 3 unread messages waiting. Tap to open dezibel."**

4. **"Today's story update is ready. Open the app when you're ready to read."**

5. **"Something arrived for you in dezibel. Open the app to see it."**

### Design principles for SHAFT compliance:
- No sexual language, innuendo, or suggestive phrasing
- No mention of the erotic content that lives in the app
- No links to pages containing SHAFT content
- Messages read as generic app notifications — indistinguishable from any content delivery service
- Include opt-out language in at least the first message: "Reply STOP to unsubscribe"
- Keep messages under 160 characters (1 SMS segment) to minimize per-message cost

---

## 5. SHAFT Review Scope — SMS Only, Not App/Website

**Critical finding: The SHAFT review examines SMS/MMS message content only.**

What TCR and carriers review during campaign registration:
- The SMS message content you plan to send (sample messages)
- Your campaign use case description
- Your opt-in/opt-out procedures
- Your privacy policy and terms of service pages

What they do NOT review:
- The content inside your companion app
- The full scope of your website content
- Other products or services your company offers

**This is the key architectural insight for dezibel:** All erotic content lives exclusively in the companion app. The SMS layer is a clean notification trigger — "you have a new message" — with no SHAFT content whatsoever. This is structurally identical to how dating apps, streaming services, and social platforms send push notifications via SMS.

**Caveat:** Your privacy policy and terms pages must be live and accessible. If those pages prominently describe erotic content delivery, a reviewer could flag inconsistency. Recommendation: the privacy policy should describe dezibel as a "serialized literary fiction delivery platform" without foregrounding the erotic dimension.

---

## 6. Throughput: Messages per Second and Daily Limits

Throughput is determined by Trust Score and varies by carrier.

### T-Mobile Daily Caps (per brand, all campaigns combined)

| Trust Score | Daily Message Cap |
|-------------|-------------------|
| 75-100 | 200,000 |
| 50-74 | 40,000 |
| 25-49 | 10,000 |
| 1-24 | 2,000 |

### AT&T Throughput (per campaign, messages per second)

AT&T enforces sending speed (MPS) based on trust score and campaign use case. "Declared" campaigns (like Notifications) get higher MPS than Mixed/Marketing for the same trust score. Specific MPS ranges from ~4 MPS (low trust) to ~60+ MPS (high trust, declared campaign).

### Dezibel's Actual Needs

At 10,000 subscribers receiving 1-3 messages per day:
- Daily volume: 10,000-30,000 messages
- Even the lowest trust score tier (2,000/day T-Mobile cap) would handle the T-Mobile share at launch (500 subscribers)
- At the aspirational 10,000 subscriber target, a trust score of 25-49 (10,000/day T-Mobile cap) handles it if messages are spread across the day
- At 50+ trust score (40,000/day), dezibel has ample headroom

**Throughput is not a blocking concern for dezibel's projected volumes.** Even worst-case trust scores handle launch volume. The trust score can be improved over time by requesting secondary vetting.

---

## 7. Cost Breakdown

### One-Time Registration Fees

| Item | Cost |
|------|------|
| Brand registration (standard) | $44-46 |
| Campaign vetting | $15 |
| Secondary vetting (optional, improves trust score) | $40-42 |
| **Total one-time** | **$59-103** |

### Monthly Recurring Fees

| Item | Cost |
|------|------|
| Campaign fee (notifications use case) | $10/month |
| Phone number lease | $1-2/month |
| **Total monthly** | **$11-12/month** |

### Per-Message Costs (provider fee + carrier surcharge)

| Component | Twilio | Telnyx | Bandwidth |
|-----------|--------|--------|-----------|
| Provider SMS fee | $0.0079 | $0.0055 | ~$0.004 |
| AT&T surcharge | $0.002 | $0.002 | $0.002 |
| T-Mobile surcharge | $0.003 | $0.003 | $0.003 |
| Verizon surcharge | $0.004 | $0.004 | $0.004 |
| **All-in per SMS (avg)** | **~$0.011** | **~$0.0085** | **~$0.007** |

### Projected Monthly Cost at Scale

| Subscribers | Msgs/Day | Monthly Msgs | Twilio | Telnyx | Bandwidth |
|-------------|----------|-------------|--------|--------|-----------|
| 500 | 1,000 | 30,000 | $341 | $267 | $222 |
| 2,000 | 4,000 | 120,000 | $1,332 | $1,032 | $852 |
| 10,000 | 20,000 | 600,000 | $6,612 | $5,112 | $4,212 |

*Assumes 2 messages/subscriber/day average. Includes $12/month base fees.*

**At 10,000 subscribers, Telnyx saves ~$1,500/month vs Twilio and ~$900/month vs Bandwidth.** At 500 subscribers (launch), the difference is ~$75/month — negligible.

---

## 8. Approval Timeline and Common Rejection Reasons

### Timeline

| Stage | Duration |
|-------|----------|
| Brand registration | Minutes to 2 days |
| Trust score assignment | Included in brand registration |
| Campaign vetting | 3-7 business days (up to 4 weeks) |
| Number provisioning | Same day after campaign approval |
| **Total end-to-end** | **1-3 weeks typical** |

### Common Rejection Reasons

1. **Business data mismatch** — Legal name doesn't match tax filings / BN records
2. **Missing privacy policy** — Must be on a live, accessible website
3. **Unclear opt-in method** — Must describe exactly how subscribers consent (e.g., "user signs up on dezibel.com and checks the SMS notification box")
4. **Sample message / use case mismatch** — If sample messages include links but you marked "embedded links: No"
5. **Inconsistency between website and campaign description** — Brand name, business type, and messaging purpose must align
6. **SHAFT content in messages** — Any sexual, hateful, alcohol, firearms, or tobacco content
7. **Purchased/shared contact lists** — Must be organic opt-in only

### Dezibel-Specific Risk Assessment

- **Low risk:** Message content is clean notification triggers — no SHAFT content
- **Low risk:** Opt-in is clear — subscribers purchase the product and consent to SMS notifications
- **Medium risk:** New company with limited history may get a lower trust score (mitigated by secondary vetting)
- **Low risk:** Canadian registration is supported with BN

**If rejected:** Edit and resubmit without additional vetting fee. Common fix is to improve the campaign description, add missing privacy policy link, or correct business data mismatch.

---

## 9. Provider Comparison: Notification-Only SMS

### Twilio

| Factor | Assessment |
|--------|------------|
| Per-SMS cost | $0.0079 (highest) |
| 10DLC registration markup | None (pass-through) |
| Existing dezibel stack | Yes — already integrated |
| Documentation | Excellent |
| Canadian company support | Full support |
| DX / API quality | Industry standard |
| **Verdict** | Best if staying on existing stack. Premium pricing. |

### Telnyx

| Factor | Assessment |
|--------|------------|
| Per-SMS cost | $0.0055 (30% cheaper than Twilio) |
| 10DLC registration markup | None (pass-through at cost) |
| Owns infrastructure | Yes — licensed carrier, no middlemen |
| Documentation | Good |
| Canadian company support | Full support |
| DX / API quality | Comparable to Twilio |
| **Verdict** | Best value. Recommended for cost-conscious operation. |

### Bandwidth

| Factor | Assessment |
|--------|------------|
| Per-SMS cost | ~$0.004 (cheapest) |
| 10DLC registration | Supported |
| Owns infrastructure | Yes — tier 1 carrier |
| Documentation | Good but enterprise-focused |
| Canadian company support | Supported |
| DX / API quality | More enterprise, less startup-friendly |
| **Verdict** | Cheapest per-message but higher integration complexity. Better for high volume. |

### Recommendation

**For dezibel: Telnyx.**

Rationale:
- 30% cheaper than Twilio per message, which compounds at scale
- At launch volume (500 subs), the savings are small (~$75/month) but at 10K subs it is $1,500/month
- Licensed carrier (owns infrastructure like Bandwidth) but with better developer experience
- No markup on 10DLC fees
- Full Canadian company support
- If dezibel is already deeply integrated with Twilio for the main story delivery, a hybrid approach works: Twilio for iMessage/app delivery, Telnyx for SMS notification triggers only

**If switching cost is too high:** Stay on Twilio. The per-message premium is real but not a launch blocker. At 500 subscribers, it is $75/month — not worth re-engineering for.

---

## 10. Fallback if 10DLC Rejected

If 10DLC registration is rejected (unlikely given clean notification content), alternatives in priority order:

### Option A: Fix and Resubmit (First Choice)
- Edit the existing campaign registration — no new vetting fee
- Most rejections are documentation issues (missing privacy policy, business data mismatch), not content issues
- Turnaround: 3-7 business days for re-review

### Option B: Toll-Free Number Verification
- Register a toll-free number (1-800/1-888) for SMS
- Separate verification process from 10DLC (not through TCR)
- Throughput: ~3 MPS (adequate for dezibel)
- Verification timeline: 3-4 weeks
- Monthly cost: ~$2-3/month for the number
- Same carrier surcharges apply
- **Good fallback** — similar capability, different registration path

### Option C: Dedicated Short Code
- 5-6 digit number (e.g., 54321)
- Highest throughput: 400-500 MPS
- Approval: 4-6 weeks (carrier review)
- Cost: $500-1,000/month lease + per-message fees
- **Only justified at very high volume** — overkill and expensive for dezibel

### Option D: Push Notifications Only (No SMS)
- Eliminate SMS entirely — use app push notifications for all triggers
- Zero carrier involvement, zero SHAFT review
- Requires subscribers to have the dezibel app installed with notifications enabled
- Downside: lower engagement than SMS (push notifications are easier to ignore/disable)
- **Viable if SMS proves intractable,** but SMS has higher open rates (~98% vs ~50% for push)

### Option E: Email Triggers
- Use email as the notification layer instead of SMS
- Zero carrier compliance
- Lower urgency/open rate than SMS
- Could work as a supplement, not a replacement for the "text from a friend" experience

---

## Action Items

1. **Register the Canadian company** and obtain the Business Number (BN) from CRA — required for 10DLC brand registration
2. **Build a live website** (even a landing page) with privacy policy and terms of service before submitting campaign registration
3. **Sign up with Telnyx** (or stay on Twilio if integration cost is too high) and submit brand registration
4. **Submit campaign registration** as "Account Notifications" or "Delivery Notifications" with the 5 sample messages above
5. **Set up opt-in flow:** Subscriber purchases dezibel, enters phone number, checks SMS consent box. Document this flow for the campaign registration.
6. **Budget:** ~$100 one-time + ~$12/month base + per-message costs. At launch volume (500 subs), total SMS cost is ~$220-340/month depending on provider.

---

## Relationship to Existing Position

This research resolves part of the open question in `[[2026-03-25-pos-dezibel-twilio-erotic-compliance]]`. The key insight: **decouple the SMS layer from the content layer.** SMS is clean notification triggers only. All erotic content lives in the companion app/iMessage. The SHAFT review only examines SMS content, not the app. This architectural separation eliminates the SHAFT compliance risk for the notification channel entirely.

The original question about delivering erotic content via SMS remains relevant for the iMessage story delivery path (which bypasses carriers entirely) and any future consideration of SMS-based content delivery. But for the notification trigger use case, 10DLC with clean messages is straightforward.
