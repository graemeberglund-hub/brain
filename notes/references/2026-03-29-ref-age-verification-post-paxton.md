---
type: reference
title: "Age verification requirements: post-Paxton landscape for erotic literary apps"
created: 2026-03-29
tags: [dezibel, age-verification, legal, compliance, paxton, erotic-content]
area: "[[writing-and-film]]"
source: "Web research on US state age verification laws post-Free Speech Coalition v. Paxton (2025)."
status: active
---

# Age Verification: Post-Paxton Landscape for Erotic Literary Apps

Research compiled 2026-03-29. All figures sourced from web search; verification status noted per section. This is legal research, not legal advice. Counsel review required before implementation.

---

## 1. Free Speech Coalition v. Paxton — What the Supreme Court Decided

**Case:** Free Speech Coalition, Inc. v. Paxton, 606 U.S. 461 (2025). Decided June 27, 2025, 6-3.

**Majority:** Thomas, joined by Roberts, Alito, Gorsuch, Kavanaugh, Barrett.
**Dissent:** Kagan, joined by Sotomayor, Jackson (argued strict scrutiny should apply).

### What was upheld

- Texas HB 1181 survives constitutional challenge. States **can** require commercial websites featuring sexual material harmful to minors to verify user ages.
- The Court applied **intermediate scrutiny** (not strict scrutiny), treating age verification as an incidental burden on protected adult speech rather than a direct content restriction.
- The "harmful to minors" standard (variable obscenity) is constitutionally valid: material can be obscene for children while protected for adults.

### What the law requires (HB 1181 model)

- Commercial entities whose content is **more than one-third "sexual material harmful to minors"** must implement age verification.
- "Harmful to minors" uses a modified Miller test: (a) appeals to prurient interest of minors under community standards, (b) patently offensive for minors, (c) **taken as a whole, lacks serious literary, artistic, political, or scientific value for minors**.
- Entities must use "reasonable age verification methods" — digital ID is the primary method specified.
- **No retention of identifying information** after verification is complete.
- Penalties: $10,000/day for non-compliance; $250,000 per instance of minor access due to non-compliance.

### What was NOT decided

- The Court did not define which specific verification methods satisfy the requirement beyond "reasonable."
- The Court did not address app-specific questions (the case involved websites).
- The Court did not strike down or limit the one-third threshold, but noted concerns about overbreadth in concurrences.

---

## 2. US States with Age Verification Laws (as of March 2026)

**25 states** now have age verification laws for adult content in effect or approaching enforcement. Most follow the HB 1181 template (one-third threshold, harmful-to-minors standard).

### Currently enforced or in effect

| State | Law | Effective | Notes |
|-------|-----|-----------|-------|
| Louisiana | Act 440 | Jan 2023 | First state; triggered the wave |
| Arkansas | SB 66 | Jul 2023 | |
| Virginia | HB 1181 | Jul 2023 | |
| Utah | SB 287 | May 2024 | Pornhub exited the state |
| Montana | SB 544 | Jan 2024 | |
| Texas | HB 1181 | Sep 2023 | Upheld by SCOTUS Jun 2025 |
| North Carolina | HB 8 | Jan 2024 | |
| Indiana | SB 17 | Jul 2024 | |
| Idaho | HB 242 | Jul 2024 | |
| Mississippi | HB 1126 | Jul 2024 | |
| Kentucky | HB 278 | Jul 2024 | |
| Florida | HB 3 | Jan 2025 | |
| Georgia | SB 351 | Jan 2025 | |
| Nebraska | LB 383 | 2025 | |
| Alabama | — | 2024-2025 | |
| Kansas | — | 2024-2025 | |
| Oklahoma | — | 2024-2025 | |
| South Carolina | — | 2024-2025 | |
| South Dakota | — | 2024-2025 | |
| Wyoming | — | 2024-2025 | |
| North Dakota | — | 2024-2025 | |
| Missouri | 15 CSR 60-18 | Nov 2025 | Administrative rule |
| Arizona | HB 2112 | May 2025 | |
| Ohio | HB 96 | Sep 2025 | |

**Note:** Exact bill numbers for several states could not be independently confirmed from search results. The total count of ~25 states with enforced laws is consistent across multiple sources (EFF, Ondato, Breached.Company, World Population Review). An additional ~10 states have legislation pending as of early 2026.

### States without age verification laws (as of March 2026)

California, Colorado, Connecticut, Delaware, Hawaii, Illinois, Iowa, Nevada, New Hampshire, New Jersey, New Mexico, Oregon, Pennsylvania, Rhode Island, and several others have not enacted adult-content age verification requirements (though some have social media age verification laws).

**Canada:** Bill S-210 (Online Harms Act) includes age verification provisions for adult content but enforcement mechanisms were still under development as of late 2025. Dezibel would need to monitor this separately.

---

## 3. Apps vs. Websites — Does Platform Matter?

### The short answer: yes, apps are covered too

Most state age verification laws use language like "commercial entity that **publishes or distributes** material on the Internet" — this is platform-agnostic and covers apps, websites, and any internet-connected distribution channel.

### App Store Accountability Acts (ASAAs)

A separate but overlapping wave of laws specifically targets app distribution:

- **Texas SB 2420** (preliminary injunction issued; enforcement paused during litigation)
- **Utah** and **Louisiana** have app store age verification bills taking effect mid-2026
- **California AB 1043** requires DOB entry during device setup (effective Jan 2027)

### Apple & Google responses (as of early 2026)

- **Apple:** Updated age ratings to include 13+, 16+, 18+. Introduced Declared Age Range API and Significant Change API. Starting Feb 2026, blocks 18+ app downloads in Australia, Brazil, and Singapore unless adult status confirmed. US enforcement expected to follow.
- **Google Play:** "Play Age Signals" API allows developers to read age-related account information to tailor experiences.

### Dezibel implication

An app delivering erotic content to US subscribers falls under both:
1. **State adult-content age verification laws** (content-focused — triggered by the harmful-to-minors threshold)
2. **App Store Accountability Acts** (distribution-focused — triggered by app store presence)

Being app-only does NOT create an exemption. If anything, it adds a layer (app store compliance) on top of content laws.

---

## 4. "Literary Fiction" vs. "Pornography" — Does Classification Matter?

### The legal standard: Miller test adapted for minors

The "harmful to minors" test (Ginsberg v. New York, 1968; reinforced by Paxton) asks:
1. Does the material, **taken as a whole**, appeal to prurient interest of minors?
2. Is it patently offensive for minors?
3. Does it, **taken as a whole**, lack **serious literary, artistic, political, or scientific value** for minors?

### The "taken as a whole" and "serious literary value" protections

This is dezibel's strongest legal argument. The Miller test and its minors variant require evaluation of the **entire work**, not isolated passages. A 42-day serialized novel with ~30% erotic content and ~70% literary narrative, character development, and thematic exploration has a strong claim to "serious literary value" even for minors under prong (c).

Key precedent: literary classics with explicit content (Lady Chatterley's Lover, Tropic of Cancer, Ulysses) are not classified as obscene precisely because of prong (c).

### However: the one-third threshold creates exposure

Most state laws trigger verification when **more than one-third of content** is "sexual material harmful to minors." Dezibel's ~30% erotic content is right at the boundary. This creates two risks:

1. **Threshold calculation ambiguity:** How is "one-third" measured? By word count? Page count? Episode count? Scene count? The laws are not precise. A 30% figure could be argued above or below the line depending on methodology.
2. **Selective enforcement:** Even if dezibel has a strong "serious literary value" defense, the defense requires litigation. Being right is expensive.

### Assessment

Dezibel's literary-fiction classification provides meaningful legal protection under the Miller test's "serious literary value" prong, but **does not create an exemption from age verification**. The prudent approach is to implement verification regardless, because:
- The one-third threshold is ambiguous and dezibel is near the line
- The cost of verification is far lower than the cost of defense
- Verification is becoming table stakes for any app with sexual content

---

## 5. Acceptable Age Verification Methods

State laws generally require "reasonable age verification" without specifying a single method. The following methods appear across various state statutes:

### Methods by compliance strength

| Method | Accepted? | Notes |
|--------|-----------|-------|
| **Self-declared DOB** | Weakest | Some states explicitly reject this as insufficient. Not recommended as sole method. |
| **Credit card verification** | Moderate | Accepted in some states as proof of adult status. Privacy concerns. |
| **Government-issued ID upload** | Strong | Widely accepted. Privacy/data retention concerns. Most laws prohibit retaining ID data after verification. |
| **Third-party age verification service** (Yoti, Persona, AgeChecker) | Strong | Preferred by most compliance frameworks. Offloads liability and data handling. |
| **AI facial age estimation** (Yoti) | Emerging | No ID required. Used by OnlyFans, Pornhub (where operational), Meta. Not yet tested in court as "reasonable." |
| **Device-level / OS-level age signals** | Emerging | Apple and Google APIs. Not yet sufficient as standalone method for content laws. |

### Recommended approach for dezibel

A **layered verification flow**:
1. App Store age rating set to 18+ (baseline, required by Apple/Google)
2. In-app age gate at signup using third-party verification service (Yoti, Persona, or AgeChecker)
3. No ID data retained by dezibel — verification handled entirely by the third-party provider
4. Periodic re-verification option if required by future regulations

---

## 6. Canadian Company, US State Laws — Compliance Required?

### Yes. Jurisdiction attaches to the user, not the company.

US state age verification laws apply to any entity that **publishes or distributes content accessible to residents of that state**, regardless of where the company is incorporated or headquartered.

Key principles:
- These laws assert jurisdiction based on **where the content is consumed**, not where it is produced
- A Canadian company distributing an app through US app stores to US subscribers is unambiguously within scope
- Courts have consistently held that companies doing business with state residents must comply with state consumer protection laws
- The dormant commerce clause and extraterritoriality arguments are weaker when the law protects state residents (children)

### Enforcement mechanism

- State attorneys general enforce these laws
- Enforcement against foreign companies is practically difficult but not impossible — app store presence creates a lever (states can pressure Apple/Google to enforce)
- Apple and Google are already building compliance infrastructure (age APIs, store-level blocking), which effectively forces compliance regardless of enforcement

### Dezibel exposure

As a Canadian company selling via US app stores to US subscribers: **full compliance required**. The app store distribution channel creates both legal jurisdiction and practical enforcement leverage.

---

## 7. Recommended Age Verification Flow for Dezibel

### Legally defensible implementation

```
User downloads app (18+ rated in App Store / Google Play)
    ↓
Account creation: email + payment method
    ↓
Age verification gate (before any erotic content is accessible):
    Option A: Third-party facial age estimation (Yoti) — frictionless, no ID needed
    Option B: Government ID verification via third-party (Persona, AgeChecker) — fallback
    ↓
Verification result stored as boolean (is_adult: true/false)
    ↓
NO identifying information, ID images, or biometric data retained by dezibel
    ↓
User accesses content
```

### Design considerations

1. **Gate placement:** Before any erotic content, not at app download. The literary (non-erotic) content could potentially be accessible without verification, with verification required to unlock erotic chapters/scenes. This strengthens the "serious literary value" argument.
2. **One-time verification:** Most laws require verification at access, not per-session. A single verification at signup is likely sufficient.
3. **Privacy-first:** Texas and most state laws **prohibit retaining identifying information** after verification. Use a third-party service that handles the data and returns only a pass/fail signal.
4. **Geographic targeting:** Could implement verification only for users in states with active laws, but the trend is toward universal coverage (~25 states now, ~35 expected by 2027). Simpler and safer to verify all US users.
5. **Canadian users:** Monitor Bill S-210 for requirements. Implement verification for Canadian users when/if required.

---

## 8. Cost of Third-Party Age Verification Services

### Per-verification pricing (as of late 2025)

| Provider | Method | Cost per verification | Notes |
|----------|--------|----------------------|-------|
| **AgeChecker** | ID verification | ~$0.50/accepted + $25/mo base | Public pricing. Only charges for successful verifications. |
| **Veriff** | ID + biometric | ~$1.39/verification | Charges for all attempts including failures. |
| **Sumsub** | ID + biometric | ~$1.35/verification | Charges for all attempts including failures. |
| **Yoti** | Facial age estimation | Custom pricing (not public) | Used by OnlyFans, Pornhub. Enterprise quotes only. |
| **Persona** | ID verification | Custom pricing (not public) | Used by X (Twitter), Reddit. |
| **Didit** | Various | Public pricing, lower cost | Newer entrant positioning as affordable alternative. |
| **Everypixel Age Recognition API** | Facial estimation | ~$0.0006/request | Cheapest option; accuracy/compliance status UNVERIFIED. |

### Cost modeling for dezibel

Assumptions: 10,000 subscribers in year one, each verified once.

| Scenario | Provider type | Est. cost |
|----------|--------------|-----------|
| Conservative | AgeChecker ($0.50 + $25/mo base) | ~$5,300/year |
| Mid-range | Veriff/Sumsub (~$1.35) | ~$13,500/year |
| Enterprise | Yoti/Persona (estimated $0.50-1.00) | ~$5,000-10,000/year |

At dezibel's scale, age verification is a **negligible cost** — likely $5,000-15,000/year depending on provider. This is not a meaningful budget concern.

---

## 9. Dezibel Exposure Assessment

### Risk matrix

| Factor | Status | Risk level |
|--------|--------|------------|
| Erotic content percentage (~30%) | At the one-third threshold boundary | **Medium** — ambiguous, could be argued either way |
| Literary fiction classification | Strong "serious literary value" defense | **Low** — but defense requires litigation if challenged |
| App distribution (not website) | Covered by both content laws and ASAAs | **Medium** — no exemption from being app-only |
| Canadian company, US users | Full compliance required | **High** if non-compliant; **Low** if verified |
| Age verification implementation cost | $5,000-15,000/year | **Negligible** |
| Data retention liability | Third-party provider eliminates this | **Low** with proper architecture |

### Bottom line

1. **Implement age verification.** The cost is trivial relative to the legal risk. Dezibel's ~30% erotic content puts it at the threshold boundary, and the "serious literary value" defense, while strong, is an argument you make in court — not a substitute for compliance.

2. **Use a third-party provider.** Yoti or AgeChecker are the most common choices for content platforms. This eliminates data-retention liability and provides a compliance paper trail.

3. **Gate erotic content, not the entire app.** Allow access to non-erotic literary content without verification. Require verification before unlocking erotic scenes/chapters. This architecturally reinforces the argument that dezibel is a literary product with some erotic content, not a pornography platform.

4. **Apply verification to all US users.** With 25 states enforcing and more coming, state-by-state gating is more complex than universal verification.

5. **Monitor Canada's Bill S-210.** Age verification requirements for Canadian users are likely coming.

6. **Get counsel review.** This research identifies the landscape but does not substitute for legal advice. The one-third threshold question, in particular, needs a lawyer's analysis of how dezibel's content maps to the statutory language.

### Unresolved questions (require counsel)

- How is the one-third threshold calculated for serialized content? Per episode? Across the full 42-day arc?
- Does gating erotic content behind verification while leaving literary content open change the threshold calculation?
- What constitutes "reasonable" age verification in states that don't specify methods?
- Does Apple's 18+ rating plus in-app third-party verification satisfy all 25 state laws, or do some require specific methods?

---

## Sources

- [Free Speech Coalition v. Paxton — Oyez](https://www.oyez.org/cases/2024/23-1122)
- [Free Speech Coalition v. Paxton — Wikipedia](https://en.wikipedia.org/wiki/Free_Speech_Coalition_v._Paxton)
- [SCOTUS Opinion (PDF)](https://www.supremecourt.gov/opinions/24pdf/23-1122_3e04.pdf)
- [Congress.gov — Supreme Court Upholds Age Verification](https://www.congress.gov/crs-product/LSB11354)
- [Perkins Coie — What the Decision Could Mean](https://perkinscoie.com/insights/blog/free-speech-coalition-v-paxton-what-supreme-courts-age-verification-decision-could)
- [Cato — Free Speech Coalition v. Paxton Analysis](https://www.cato.org/supreme-court-review/2024-2025/free-speech-coalition-v-paxton-departure-not-roadmap)
- [Harvard Law Review — Free Speech Coalition v. Paxton](https://harvardlawreview.org/print/vol-139/free-speech-coalition-inc-v-paxton/)
- [Harmful to Minors Laws — First Amendment Encyclopedia](https://firstamendment.mtsu.edu/article/harmful-to-minors-laws/)
- [State Age Verification Map — Kindbridge](https://kindbridge.com/online-pornography-age-verification-laws-by-state-map/)
- [Porn Site Verification Laws by State 2026 — World Population Review](https://worldpopulationreview.com/state-rankings/porn-site-verification-states)
- [Half of US States Enforce Age Verification — Breached.Company](https://breached.company/half-of-us-states-now-enforce-age-verification-laws-the-2026-mass-rollout-of-digital-id-requirements/)
- [2026 Outlook on US Age Verification Laws — Ondato](https://ondato.com/reports/the-us-age-verification-laws-2026-outlook/)
- [EFF — 2025 in Review](https://www.eff.org/deeplinks/2025/12/year-states-chose-surveillance-over-safety-2025-review)
- [App Store Age Verification Laws — Privacy World](https://www.privacyworld.blog/2025/10/app-store-age-verification-laws-your-questions-answered/)
- [App Store Accountability Acts — Loeb & Loeb](https://www.loeb.com/en/insights/publications/2025/12/app-store-age-verification-laws-trigger-new-federal-and-state-childrens-privacy-requirements)
- [Apple Developer — Age Requirements Update](https://developer.apple.com/news/?id=f5zj08ey)
- [Google Play — App Store Bill Changes](https://support.google.com/googleplay/android-developer/answer/16569691?hl=en)
- [AgeChecker Pricing](https://agechecker.net/pricing)
- [Yoti — Age Verification for Adult Content](https://www.yoti.com/adult-content-age-verification/)
- [Yoti — Business Age Verification](https://www.yoti.com/business/age-verification/)
- [Texas Age Verification Law — Ondato](https://ondato.com/blog/new-texas-age-verification-law/)
- [Sidley Austin — Texas Age Verification Upheld](https://www.sidley.com/en/insights/newsupdates/2025/07/texas-age-verification-law-upheld)
