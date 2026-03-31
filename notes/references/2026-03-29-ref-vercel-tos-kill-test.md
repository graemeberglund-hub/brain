---
title: "Kill test K23: Vercel TOS — erotic content hosting"
type: reference
tags: [dezibel, vercel, hosting, tos, compliance, kill-test]
created: 2026-03-29
area: "[[writing-and-film]]"
source: "Web research against Vercel Terms of Service and Acceptable Use Policy."
---

## Verdict: RISKY

Vercel does not explicitly ban adult or erotic content in its Acceptable Use Policy, but its Terms of Service contain broad language that could be invoked against sexually explicit literary content. The risk is not immediate termination but discretionary enforcement — Vercel reserves the right to remove content it deems "obscene" at its sole discretion, with no appeal mechanism defined. For a product where ~30% of the prose is explicitly sexual, this is an unacceptable single point of failure.

**Recommendation:** Do not host content-serving components on Vercel. Use Vercel for the application shell (auth, scheduling, subscriber management) and serve the actual literary content from infrastructure with explicit adult-content tolerance (DigitalOcean VPS or OVH).

---

## Findings

### 1. Vercel Terms of Service — content restrictions

**Source:** [Vercel Terms of Service](https://vercel.com/legal/terms)

The TOS require that user content meets the following representation:

> "Your Content is not defamatory, obscene, unlawful, threatening, abusive, tortious, offensive or harassing"

The word **"obscene"** is the risk vector. In US law, obscenity is narrowly defined (Miller v. California, 1973 — the three-prong test), and literary erotic fiction with artistic merit is generally NOT obscene. However, Vercel is not a court. Their TOS uses "obscene" as a contractual term, not a legal one. They can interpret it however they wish and enforce at sole discretion.

Additionally, the TOS state:

> Vercel "may remove or disable any of your content at any time for any reason, including upon receipt of claims or allegations from third-parties or authorities relating to your content, or for no reason at all."

This is a unilateral kill switch. No hearing, no appeal, no notice requirement (outside EEA).

### 2. Vercel Acceptable Use Policy — what it actually prohibits

**Source:** [Vercel Acceptable Use Policy](https://vercel.com/legal/acceptable-use-policy) (last updated August 19, 2025)

The AUP explicitly prohibits:
- Child sexual exploitation or abuse
- Spam and clickbait/clickfraud
- Infrastructure abuse (scraping, VPN, hot-linking)
- Name-squatting
- Account circumvention
- Security/integrity attacks

**Notably absent from the AUP:** Any explicit prohibition on adult content, sexually explicit material, erotic content, NSFW material, or pornography. The AUP does NOT contain the word "obscene," "pornographic," "adult," or "sexually explicit."

This creates an ambiguity: the AUP (the specific policy) does not prohibit it, but the TOS (the general contract) uses "obscene" as a content restriction.

### 3. Vercel Integrations Marketplace Agreement — stronger language

**Source:** [Vercel Integrations Marketplace Agreement](https://vercel.com/legal/integrations-marketplace-agreement)

This agreement explicitly states Vercel can take action if a listing:

> "(c) is pornographic, obscene or otherwise violates Vercel's hosting policies"

This confirms that Vercel considers "pornographic" content a violation of their hosting policies, at least in the Marketplace context. The phrase "Vercel's hosting policies" implies a broader stance that extends beyond just Marketplace listings.

### 4. Community evidence — escort site discussion

**Source:** [Vercel Community thread](https://community.vercel.com/t/can-i-host-a-non-explicit-escort-showcase-site-on-vercel/14060) (June 2025)

A user asked whether a non-explicit escort showcase site (PG-13, legal in Denmark) could be hosted on Vercel. The existence of this thread confirms that users are uncertain about Vercel's content boundaries. Full staff responses were not accessible via search, but the thread's existence signals that the policy boundary is unclear even to users.

### 5. Documented enforcement cases

No documented cases of Vercel suspending accounts specifically for adult literary content were found. Account suspensions found in community forums relate to:
- DDoS-related abuse
- TOS violations (unspecified)
- General abuse flags

**This absence is not reassuring.** It likely reflects that few adult content providers use Vercel, not that Vercel tolerates it.

---

## Risk assessment for dezibel specifically

| Factor | Assessment |
|--------|-----------|
| TOS "obscene" clause | Applies. Erotic literary content could be classified as "obscene" under Vercel's discretionary interpretation. |
| AUP explicit prohibition | Does NOT exist. No specific prohibition on adult/erotic content in the AUP. |
| Marketplace agreement | References "pornographic" as prohibited — signals organizational stance. |
| Content removal power | Unilateral, no-reason-needed, no appeal. |
| Content type | Literary prose, not visual pornography. Stronger First Amendment protection, but irrelevant to a private TOS. |
| Percentage of explicit content | ~30% of the P/F novella. Not incidental. |
| Business impact of takedown | Catastrophic. Mid-delivery takedown would destroy subscriber trust and the product. |

**The core risk is not that Vercel WILL act, but that they CAN act, unilaterally, at any time, with no recourse.** For a subscription product delivering serialized content over 42 days, a mid-run platform takedown is an existential event.

---

## Alternative platforms

### Tier 1: Explicit adult-content tolerance (confirmed)

| Platform | Policy | Notes |
|----------|--------|-------|
| **DigitalOcean** (Droplets/VPS) | Adult content permitted at DigitalOcean's sole discretion. Explicitly prohibits only CSAM and non-consensual imagery. | [Source](https://www.digitalocean.com/legal/acceptable-use-policy). Best option for content serving. Contact sales to confirm. |
| **OVH / OVHcloud** (VPS/Cloud) | Adult content allowed if legal. | [Source](https://us.ovhcloud.com/legal/terms-of-service/). French company — age verification laws apply in France but not necessarily for non-French-targeted services. Widely used for adult hosting. |
| **Vultr** | Adult content permitted on VPS. | Commonly cited on hosting forums as adult-friendly. |

### Tier 2: Ambiguous / likely fine but unconfirmed

| Platform | Policy | Notes |
|----------|--------|-------|
| **Fly.io** | AUP says "be creative but don't negatively impact Fly.io." No explicit adult content prohibition found. | [Community thread](https://community.fly.io/t/using-fly-for-adult-websites/5506) exists asking about this — suggests ambiguity. |
| **Hetzner** | **Prohibits adult content.** Section 8.2 of their TOS. | [Source](https://www.hetzner.com/legal/terms-and-conditions/). Not viable. |

### Tier 3: Explicitly prohibits adult content

| Platform | Status |
|----------|--------|
| **Vercel** | RISKY — "obscene" clause, discretionary enforcement |
| **Hetzner** | DEAD — explicit prohibition |
| **Railway** | DEAD — prohibits adult services explicitly |
| **Netlify** | RISKY — similar TOS structure to Vercel |

---

## Recommended architecture (split hosting)

To mitigate K23 risk without abandoning Vercel entirely:

1. **Vercel** — Application shell only: authentication, subscriber management, delivery scheduling, PWA shell, marketing pages. No erotic content touches Vercel infrastructure.
2. **DigitalOcean Droplet or OVH VPS** — Content API: serves the actual novella text via API. The Vercel frontend calls this API. Content is stored and served from adult-tolerant infrastructure.
3. **Fallback**: If DigitalOcean/OVH also becomes risky, the content API is a standalone service that can be redeployed to any VPS provider in hours.

This architecture decouples the content risk from the application platform risk. Vercel never hosts or serves "obscene" material — it only hosts the application that fetches it from elsewhere.

---

## Kill test K23 status

- **Assumption tested:** "Vercel's TOS permit hosting applications that deliver erotic literary content."
- **Result:** UNVERIFIED → RISKY. The AUP does not explicitly prohibit it, but the TOS "obscene" clause and unilateral removal power create unacceptable platform risk for a serialized subscription product.
- **Mitigation:** Split architecture. Vercel for app shell, adult-tolerant VPS for content serving.
- **Kill threshold:** If Vercel is the SOLE host for both application AND content, the assumption is too risky. With split architecture, the risk is manageable.
- **Next step:** Contact DigitalOcean sales to confirm adult literary content is permitted on Droplets. Get written confirmation before committing.

---

## Sources

- [Vercel Terms of Service](https://vercel.com/legal/terms)
- [Vercel Acceptable Use Policy](https://vercel.com/legal/acceptable-use-policy)
- [Vercel Integrations Marketplace Agreement](https://vercel.com/legal/integrations-marketplace-agreement)
- [Vercel Community: escort site thread](https://community.vercel.com/t/can-i-host-a-non-explicit-escort-showcase-site-on-vercel/14060)
- [Vercel Fair Use Guidelines](https://vercel.com/docs/limits/fair-use-guidelines)
- [DigitalOcean Acceptable Use Policy](https://www.digitalocean.com/legal/acceptable-use-policy)
- [OVH Terms of Service](https://us.ovhcloud.com/legal/terms-of-service/)
- [Fly.io Acceptable Use Policy](https://fly.io/legal/acceptable-use-policy/)
- [Fly.io Community: adult websites thread](https://community.fly.io/t/using-fly-for-adult-websites/5506)
- [Hetzner Terms and Conditions](https://www.hetzner.com/legal/terms-and-conditions/)
- [Railway Terms of Service](https://railway.com/legal/terms)
- [CyberNews: Best Adult Website Hosting 2026](https://cybernews.com/best-web-hosting/adult-web-hosting/)
