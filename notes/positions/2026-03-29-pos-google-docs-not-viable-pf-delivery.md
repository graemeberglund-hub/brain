---
title: "2026-03-29 Google Docs is not viable as the collaborative writing delivery platform for dezibel's P/F layer"
type: position
classification: decided
testable: false
tags: [dezibel, platform, google-docs, compliance, content-delivery, erotic-content]
created: 2026-03-29
updated: 2026-03-29
stage: acted-on
confidence: high
parent: "[[dezibel-multi-day-architecture]]"
repos: [dezibel]
ai_generated: "2026-03-29"
ai_model: "claude-opus-4-6"
---

## Thesis

Google Docs cannot be used as the delivery platform for dezibel's P/F collaborative writing layer. The feature concept — subscribers receiving a Google Doc link at Day 14 and watching Emma and Hasta co-write the novella in real time — fails on four independent grounds, any one of which is disqualifying:

1. **Explicit content policy violation**: Google Docs policies prohibit "sexually explicit material." The P/F novella contains explicit sexual content. Romance authors writing far tamer content have been locked out of accounts without warning (documented March 2024 — author lost 200,000+ words). Google's "artistic purposes" exception is discretionary and has not protected writers.

2. **Commercial integration TOS prohibition**: Google Workspace TOS explicitly states customers "may not integrate the Google Workspace Services into Customer Applications." Programmatically creating docs via API and delivering them as a feature of a $49 product is exactly what this prohibits. Free accounts are worse — commercial use is banned entirely.

3. **Unilateral account termination risk**: Google can disable accounts without warning for "egregious violations." Sexually explicit content distribution qualifies. Termination means all subscriber docs go dark simultaneously (500-10,000 paying customers lose access), the entire Google account is lost (Gmail, Drive, everything), and there is no SLA, no recourse, and no liability on Google's part.

4. **Scale triggers automated detection**: 500-10,000 programmatically created shared docs with explicit content is a detectable pattern. Automated content moderation plus the "Report Abuse" button on every shared doc (any viewer can flag it) makes enforcement near-certain at scale.

Additional concerns: Google Docs concurrent viewer limits (~100 editors, ~200 viewers per doc), inability to simulate realistic typing/cursor movement via API, immersion breaks from Google UI chrome, trivial piracy (File > Download), GDPR joint data controller obligations, and mobile experience friction.

The creative concept — subscribers watching two fictional characters co-write in real time — is strong and should be built on self-hosted infrastructure.

## Viable Alternatives

1. **Custom web page styled like a collaborative doc**: Built on dezibel's domain. Simulates cursors, typing, edit history. Full control over content, pacing, mobile UX. No content policy risk. Lives inside the $60K tech budget.
2. **Self-hosted collaborative editor (Etherpad, CKEditor)**: Open-source, real collaborative editing UX without platform dependency. Etherpad is free and lightweight.
3. **"Writing feed" in dezibel web experience**: A feed showing writing fragments appearing over time — stays closer to the iMessage idiom. Less "document," more "watching a conversation about prose."
4. **Hybrid launch approach**: Test engagement with cheapest viable prototype first. Key kill test: do beta readers voluntarily check a collaborative writing space more than once? If not, the feature is a novelty, not a retention driver — don't invest in a custom build.

## Evidence For

- Google Docs Abuse Program Policies explicitly prohibit sexually explicit material
- Google Workspace TOS prohibits integration into Customer Applications
- [[dezibel-twilio-erotic-compliance]] — parallel finding: explicit content creates compliance risk across third-party platforms (Twilio SHAFT policy)
- Documented enforcement: romance author locked out of Drive, lost 200K words (March 2024, Android Headlines)
- Franklin Veaux documented Google flagging shared docs via Report Abuse button (March 2024)
- Ongoing bans reported on writing forums (Questionable Questing) for shared explicit content
- Google APIs TOS: can terminate access "for any reason and at any time without liability"
- Zero precedent found for commercial products using Google Docs as consumer-facing content delivery at scale
- Google Docs concurrent viewer cap (~100 editors, ~200 viewers) breaks at dezibel's subscriber targets

## Evidence Against

- Google Docs is the most universally understood collaborative writing UX — maximum audience familiarity
- $0 cost vs. custom build ($15-30K estimated)
- The "artistic purposes" exception theoretically exists (though it has not protected similar use cases)

## Related

- [[dezibel-multi-day-architecture]] — parent question: how does multi-day content delivery work technically?
- [[dezibel-twilio-erotic-compliance]] — same pattern: third-party platform + explicit content = compliance risk
- [[dezibel-launch-timeline]] — custom build adds engineering scope to an already tight timeline

## Evolution

- **2026-03-29** — Position formed from TOS research + enforcement case analysis. Classified as decided/acted-on at high confidence — the evidence is unambiguous across multiple independent failure modes. No kill test needed; the TOS language and enforcement precedent are conclusive.
