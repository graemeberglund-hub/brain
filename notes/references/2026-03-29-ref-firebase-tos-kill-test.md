---
title: "Kill test K22: Firebase TOS — erotic content adjacency"
type: reference
tags: [dezibel, firebase, google, tos, compliance, kill-test]
created: 2026-03-29
area: "[[writing-and-film]]"
source: "Web research against Google Cloud and Firebase Terms of Service and Acceptable Use Policy."
---

# Kill Test K22: Firebase TOS — Erotic Content Adjacency

**Question:** Does Firebase/Google Cloud TOS prohibit storing subscriber state and delivery schedule data that is *associated with* erotic content delivery, even though the erotic text itself lives on a self-hosted server?

**Architecture under test:** Firebase/Firestore stores subscriber records, cohort assignments, delivery schedules, reading progress, and account state. A separate self-hosted content server stores all erotic literary text, audio, and media. Firebase never touches the erotic content itself.

---

## Finding 1: The GCP Acceptable Use Policy Does NOT Prohibit Adult Content

The Google Cloud Platform Acceptable Use Policy (last modified February 9, 2026) governs all GCP infrastructure services, including Firestore. The prohibited activities list is:

> "You agree not to use the Services to engage in, promote, or encourage illegal activity, including child sexual exploitation, child abuse, or terrorism or violence that can cause death, serious harm, or injury to individuals or groups of individuals; for any unlawful, invasive, infringing, defamatory, or fraudulent purpose including Non-consensual Explicit Imagery (NCEI), violating intellectual property rights of others, phishing, or creating a pyramid scheme; to distribute viruses, worms, Trojan horses, corrupted files, hoaxes or other items of a destructive or deceptive nature; to gain unauthorized access to, disrupt, or impair the use of the Services."

Source: [Google Cloud Platform AUP](https://cloud.google.com/terms/aup)

**What is NOT on this list:** adult content, sexually explicit material, erotic content, pornography (consensual). The AUP prohibits NCEI (non-consensual explicit imagery) and CSAM (child sexual exploitation) specifically, but does not contain a blanket prohibition on consensual adult content.

This was corroborated by a Google Cloud community discussion (gce-discussion group) where a user asked "Is Adult Content Allowed?" and found: "if it targets an adult audience it is not restricted but it's the customer's responsibility to respect local laws."

Source: [GCE Discussion — Is Adult Content Allowed?](https://groups.google.com/g/gce-discussion/c/4kL4qQ7H880)

## Finding 2: Firebase TOS Defers to Google Cloud Platform Terms

Firebase's Terms of Service explicitly state that Firebase services are governed by the Google Cloud Platform Terms of Service. From the Firebase TOS:

> "Firebase services subject to the Google Cloud Platform Terms of Service are 'Services' and/or 'Software' as defined in that agreement, and as such are subject to the Google Cloud Platform Service Specific Terms."

Source: [Firebase Terms of Service](https://firebase.google.com/terms)

This means Firestore is governed by the GCP AUP analyzed in Finding 1 — not by the more restrictive content policies that apply to consumer-facing Google products like Workspace/Docs/Drive.

A Firebase team member in the firebase-talk Google Group confirmed: "You can use Firebase for any purpose that doesn't violate the Terms of Service" and described the terms as "pretty lenient in general."

Source: [Firebase Talk — Firebase Usage Policies](https://groups.google.com/g/firebase-talk/c/Nbkythaiiyc)

## Finding 3: Content-Specific Restrictions Apply to Consumer Products, NOT Infrastructure

Google's sexually explicit content prohibitions appear in **product-specific** policies, not the core GCP AUP:

| Product | Has adult content restriction? | Applies to dezibel? |
|---------|-------------------------------|---------------------|
| Google Workspace (Docs/Drive) | YES — "inappropriate content" flagging | NO — not using Workspace |
| Google Maps Platform | YES — "sexual content, including pornography" | NO — not using Maps |
| Looker Studio | YES — "sexually explicit material" | NO — not using Looker |
| Generative AI / Vertex AI | YES — "sexually explicit content" | NO — not using AI services |
| RCS Business Messaging | YES — SHAFT restrictions | NO — not using RCS |
| **GCP Core (Compute, Firestore, Cloud Storage)** | **NO blanket prohibition** | **YES — this is what dezibel uses** |

The pattern is clear: Google restricts adult content on products where Google's brand is consumer-facing (Docs, Maps, AI). Infrastructure services (Compute Engine, Firestore, Cloud Storage) are governed by the core AUP, which does not prohibit consensual adult content.

## Finding 4: The Google Docs/Drive Precedent — Why It Matters and Doesn't

In March-May 2024, romance author K. Renee was locked out of Google Drive after Google flagged her 200,000+ words of erotic romance as "inappropriate content." Multiple romance authors reported similar lockouts from Google Docs.

Sources:
- [Dexerto — Romance author locked out of Google Docs](https://www.dexerto.com/tech/romance-author-gets-locked-out-of-google-docs-for-inappropriate-content-2713004/)
- [Android Headlines — Author loses 200,000 words](https://www.androidheadlines.com/2024/05/author-locked-out-of-google-drive-loses-200000-words.html)
- [HN Discussion](https://news.ycombinator.com/item?id=39850925)

**Why this matters:** It proves Google actively scans and flags sexually explicit content on its consumer products (Docs/Drive).

**Why this does NOT apply to dezibel's Firebase usage:** Google Docs/Drive is governed by the Google Workspace Acceptable Use Policy, which has explicit content restrictions. Firestore is governed by the GCP AUP, which does not. These are different policy regimes. The romance author incidents involved the actual erotic text being stored in Google's consumer product. Dezibel stores zero erotic text in Firebase — only subscriber metadata.

## Finding 5: The Separation Matters Legally

Dezibel's Firebase data contains:
- Subscriber email, payment status, cohort assignment
- Delivery schedule (which messages to send when)
- Reading progress (which messages have been viewed)
- Account preferences and settings

None of this is erotic content. A delivery schedule for an erotic novel is no different, in terms of stored data, from a delivery schedule for a cooking course. The data itself is anodyne metadata.

The legal question is whether Google considers "facilitating" erotic content delivery a violation. The GCP AUP's prohibition language targets using services "to engage in, promote, or encourage" prohibited activities. Storing subscriber state for a legal product does not constitute engaging in, promoting, or encouraging any prohibited activity — because consensual adult literary content is not on the prohibited list.

**Analogy:** Stripe processes payments for OnlyFans. AWS hosts the infrastructure for countless adult content platforms. Cloudflare CDN serves adult content sites. In each case, the infrastructure provider handles metadata and routing for adult content without handling the content itself. Google Cloud occupies the same market position.

## Finding 6: No Documented Firebase Terminations for Content Adjacency

Web research found zero documented cases of Firebase/Firestore accounts being terminated for storing metadata associated with adult content delivery. All documented Google content enforcement actions involved:
1. The actual explicit content being stored in a Google consumer product (Docs, Drive)
2. Google Ads accounts promoting adult content
3. Google Play apps with unmoderated adult user-generated content

No cases of GCP infrastructure (Compute Engine, Firestore, Cloud Storage) accounts terminated for hosting backends that serve legal adult content.

**Verification scope:** Web search across Google Groups, Hacker News, Stack Overflow, and general web. Absence of evidence is not evidence of absence — Google does not publish enforcement actions. But the complete lack of reported cases, combined with the AUP analysis, is consistent with the policy reading.

---

## Risk Assessment

### Factors favoring SAFE:
1. GCP AUP does not prohibit consensual adult content (verified against current policy text, last modified Feb 9, 2026)
2. Firebase TOS defers to GCP terms, not consumer product terms
3. Firebase stores zero erotic content — only subscriber metadata
4. Firebase team member confirmed permissive stance ("pretty lenient")
5. No documented terminations for content adjacency
6. Infrastructure providers (AWS, Stripe, Cloudflare) routinely serve adult content platforms without issue

### Factors favoring RISKY:
1. Google has demonstrated willingness to flag erotic content in Docs/Drive (K. Renee incident, 2024)
2. The AUP is broad enough ("defamatory or fraudulent purpose") that Google could stretch interpretation
3. Google's internal content scanning could theoretically extend to Firestore data
4. Google can modify the AUP at any time, adding adult content restrictions
5. If dezibel's Firebase project name, database fields, or metadata contain sexually explicit terms (e.g., field names like "erotic_chapter_progress"), automated scanning could flag the project

### Factors favoring DEAD:
None identified. No policy language, precedent, or documented enforcement supports termination for metadata-only usage associated with legal adult content.

---

## VERDICT: SAFE (with caveats)

**Firebase/Firestore is safe for storing dezibel's subscriber state and delivery schedules.** The GCP Acceptable Use Policy does not prohibit consensual adult content. Firebase defers to GCP terms. No erotic content touches Firebase. No documented enforcement against metadata-only usage.

### Caveats (risk mitigations to implement):

1. **Keep database field names neutral.** Use "chapter_progress" not "erotic_scene_progress." Use "content_id" not "sex_scene_id." Metadata should describe delivery state, not content nature.

2. **Never store erotic text in Firebase.** Not even excerpts, previews, or cached content. The architectural separation (Firebase = state, self-hosted server = content) is the compliance firewall. Maintain it rigorously.

3. **Maintain export capability.** Firebase data should be exportable at all times. If Google changed the AUP, dezibel needs to migrate to a different database within days, not months. Firestore export to JSON/CSV is straightforward.

4. **Monitor AUP changes.** The GCP AUP was last modified February 9, 2026. Subscribe to the Google Cloud terms update notifications. If adult content restrictions are added to the core AUP, trigger migration plan.

5. **Don't use Firebase for user-generated content.** If dezibel's P/F (collaborative writing) layer involves erotic user-generated text, that must NOT flow through Firebase. Keep it on the self-hosted content server.

### Migration fallback if needed:
- **Supabase** (PostgreSQL-based, open source, self-hostable): direct Firestore replacement, no content policy risk
- **PlanetScale** (MySQL-based): managed database, no content restrictions
- **Self-hosted PostgreSQL on a VPS**: zero platform risk, full control
- Migration effort: days, not weeks. Firestore's document model maps cleanly to any of these.

---

## Sources

- [Google Cloud Platform AUP](https://cloud.google.com/terms/aup) — current policy, last modified Feb 9, 2026
- [Firebase Terms of Service](https://firebase.google.com/terms) — confirms GCP TOS governance
- [GCE Discussion: Is Adult Content Allowed?](https://groups.google.com/g/gce-discussion/c/4kL4qQ7H880) — community confirmation
- [Firebase Talk: Usage Policies](https://groups.google.com/g/firebase-talk/c/Nbkythaiiyc) — Firebase team response
- [Google Workspace AUP](https://workspace.google.com/terms/use_policy/) — the stricter policy that does NOT apply
- [Dexerto: Romance author locked out of Google Docs](https://www.dexerto.com/tech/romance-author-gets-locked-out-of-google-docs-for-inappropriate-content-2713004/)
- [Android Headlines: Author loses 200,000 words](https://www.androidheadlines.com/2024/05/author-locked-out-of-google-drive-loses-200000-words.html)
- [HN: Google suspends romance author](https://news.ycombinator.com/item?id=39850925)
- [Google Cloud Policy Violations FAQ](https://support.google.com/cloud/answer/7002354)
