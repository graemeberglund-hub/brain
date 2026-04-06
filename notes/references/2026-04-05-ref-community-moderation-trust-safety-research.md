# Community Moderation & Trust/Safety for Small Ephemeral Cohorts

**Context:** Dezibel — premium serialized fiction over iMessage. Weekly cohorts of 50-200 readers, 6-week lifecycle, 52 simultaneous cohorts/year. Single creator, no dedicated moderator. One toxic participant can destroy a cohort's entire experience.

**Research date:** 2026-04-05

---

## 1. Spoiler Prevention Across Cohorts

### The Problem

At any given time, 6 cohorts are active simultaneously at different story positions (Week 1 through Week 6). A Week 6 reader discussing the climax in a shared space destroys the Week 1 reader's experience. With 52 cohorts/year, this compounds — alumni who finished months ago could spoil newcomers indefinitely.

### How Existing Communities Handle This

**TV Show Subreddits (e.g., r/HouseOfTheDragon, r/TheLastOfUs):**
- Create per-episode megathreads. Discussion is confined to the thread for that episode.
- Spoiler tagging system: posts marked as spoilers blur content and images until the reader clicks to reveal.
- Title protection rules: no spoilers in post titles (the one thing you can't hide).
- Moderator enforcement + AutoMod keyword filters for known plot points.
- Effectiveness: moderate. Relies on community buy-in + active moderation. Fails at scale without mod teams.

**Book Clubs with Staggered Reading (e.g., r/bookclub, Goodreads groups):**
- Section-by-section discussion threads (e.g., "Chapters 1-5 only").
- Honor system with social enforcement — members call out spoilers.
- Works well at small scale (20-50 people) because social pressure is high.

**MMO Guild Forums (WoW, FFXIV):**
- Content is structurally gated by progression — you literally cannot access raid discussions until you've cleared prerequisite content.
- Guild forums often have tiered channels: "cleared" vs "progressing" sections.
- This is the strongest model: structural impossibility of seeing spoilers, not honor system.

**Cohort-Based Course Platforms (Maven, Circle, Teachfloor):**
- Circle offers gated spaces — each cohort gets its own discussion area, invisible to other cohorts.
- Maven creates per-cohort communities with separate syllabi and discussion feeds.
- Content release is time-locked: Week 3 content doesn't appear until Week 3 of that cohort's timeline.
- This is the closest analog to Dezibel's needs.

### What Works: Structural Separation > Honor System > Content Moderation

| Approach | Effectiveness | Effort | Failure Mode |
|---|---|---|---|
| **Structural separation** (each cohort in its own walled space) | Highest | Low once built | Over-isolation — no cross-cohort energy |
| **Progression gating** (content/discussion unlocks with story progress) | High | Medium to build | Technical complexity |
| **Honor system + spoiler tags** | Low-Medium | Lowest | One careless person ruins it |
| **Active moderation** (keyword filters, mod review) | Medium | Highest ongoing | Unsustainable for solo creator at 52 cohorts |

### Recommendation for Dezibel

**Structural separation is the only viable approach at scale.** Each cohort gets its own discussion space. No cross-cohort visibility during the active 6-week run. This eliminates the spoiler problem entirely without requiring moderation labor.

Optional: a "graduates" space for completed cohorts, where spoilers are unrestricted. This also builds long-term community for repeat buyers.

---

## 2. Automated Moderation at Small Scale

### Available Tools

| Tool | Price | Type | Best For | Status |
|---|---|---|---|---|
| **OpenAI Moderation API** | Free | Text + image classification | Small communities needing zero-cost baseline | Active, recommended |
| **Perspective API** (Google/Jigsaw) | Free | Text toxicity scoring | Nuanced toxicity detection with bridging attributes | Sunsetting after 2026 — do not build on this |
| **Hive Moderation** | $49-$499/mo | Text, image, video | Larger platforms needing enterprise features | Active, overkill for 50-person cohorts |
| **Discord AutoMod** | Free (built-in) | Keyword + spam filters | Discord-based communities | Active, good baseline |
| **CleanSpeak** | Tiered monthly | Text moderation | User-base-size pricing | Active |

### OpenAI Moderation API (Recommended Baseline)

- **Cost:** Free for all OpenAI API users.
- **Categories detected:** Hate, harassment, self-harm, sexual content, violence, plus subcategories.
- **Model:** omni-moderation-latest (built on GPT-4o) — 42% better on multilingual content than previous version.
- **Integration:** Simple POST to /v1/moderations endpoint.
- **Limitation:** Designed for screening, not fully automated moderation. OpenAI explicitly says it's "not intended for fully automated moderation."
- **False positive concern:** At 50-200 users discussing fiction that involves conflict, romance, and emotional intensity, expect false positives on violence and sexual content categories. Threshold tuning required.

### Is Automated Moderation Overkill at 50 People?

**No, but not for the reason you'd expect.** At 50 people, you don't need automated moderation to handle volume — one person can read 50 messages. You need it because:

1. **You can't be present.** With 52 simultaneous cohorts, you cannot monitor any single cohort in real time.
2. **Speed matters.** A toxic message at 2am sits there for 8 hours until you wake up. Automated flagging + removal buys you time.
3. **It's invisible insurance.** Run it silently in the background. If it never triggers, it cost you nothing. If it catches the one message that would have ruined a cohort, it paid for itself.

### The Surveillance Feel Problem

The key insight: **don't tell users their messages are being scanned.** Instead:
- State in community guidelines that the space is moderated.
- Use automated tools as a silent first pass that flags content for review, not auto-deletion.
- Auto-delete only for clear-cut cases (slurs, spam links, explicit threats).
- For borderline content, queue for human review.

---

## 3. Structural Moderation (Prevention by Design)

### Design Patterns That Reduce Toxicity Without Active Moderation

**Friction-Based Patterns:**

| Pattern | Mechanism | Evidence | Dezibel Fit |
|---|---|---|---|
| **Invite-only / application** | Selection pressure filters bad actors before entry | Soho House, FWB DAO — reported higher-quality interactions | High — paying customers are already filtered by price |
| **Slow mode** | Rate-limit messages (e.g., 1 message per 30 seconds) | Riot Games reported "measurable improvement" in players feeling respected after limiting communication | Medium — useful for heated moments |
| **Ephemeral messages** | Messages auto-delete after set period | Reduces permanence anxiety, encourages authentic sharing | High — matches 6-week lifecycle |
| **Small group size** | Dunbar-adjacent (50-150) enables social self-regulation | Consistent across research — accountability increases with recognition | Built-in for Dezibel |
| **Paid access** | Financial stake creates accountability | Premium communities report lower toxicity than free ones | Built-in for Dezibel |

**Identity-Based Patterns:**

| Pattern | Mechanism | Evidence | Dezibel Fit |
|---|---|---|---|
| **Real-name policy** | Accountability through identifiability | Evidence is AGAINST this — trolls become more toxic, policy weaponized for harassment of vulnerable groups, especially trans users | Do not use |
| **Pseudonymous + verified** | Stable identity without real name exposure | Best balance — people maintain reputation without doxxing risk | Recommended |
| **Token/stake gating** | Must hold tokens or deposit to access | FWB DAO requires 75 $FWB tokens (~$750+ at various points) for full access. Creates financial accountability | Already achieved through subscription price |

**Structural Design Patterns:**

| Pattern | Mechanism | Dezibel Fit |
|---|---|---|
| **Structured prompts** | Instead of open chat, prompt specific discussions ("What did you think of Day 12's revelation?") | High — guides conversation, reduces drift into toxicity |
| **Reaction-first, reply-second** | Default interaction is emoji reactions; replies require extra step | Medium — reduces low-effort noise |
| **No DMs between members** | Removes vector for harassment, keeps all interaction visible | High — prevents private harassment that's invisible to you |
| **Asynchronous by default** | Discussion threads, not live chat — removes real-time escalation dynamics | High — matches fiction discussion cadence |

### What Premium Communities Do Differently

**Friends With Benefits DAO:**
- Token-gated access (75 FWB tokens for full membership).
- Application process even after token purchase — having money isn't enough.
- Optimizes app for "positive group dynamics, digital socializing, meaning-making."
- Combines digital community with in-person events.

**Soho House Digital:**
- Application and approval process identical to physical membership.
- Core criterion: cultural fit — "will they bring something to the party?"
- Over 200,000 members globally but maintains intimate feel through sub-communities.
- Digital tier connects to physical spaces, creating real-world accountability.

**Private Discord Communities (Patreon-gated, creator-run):**
- Role-based access tiers.
- AutoMod + custom bot enforcement.
- Community norms set by creator's existing audience relationship.
- Works because members already have parasocial trust with creator.

### Key Insight: The Hinge vs Tinder Principle

Hinge's design reduces low-effort interaction: you must comment on a specific part of someone's profile to match. Tinder's swipe mechanic enables rapid, thoughtless engagement. The Dezibel equivalent: **don't build a general chat room. Build structured discussion spaces where the prompt is story-specific.** This architecturally prevents most off-topic toxicity.

---

## 4. Community Guidelines That Work

### Minimum Viable Ruleset for Fiction Discussion

Based on book club norms, Letterboxd community policy, and fan fiction community standards, the minimum viable set:

**1. No spoilers outside your cohort's current week.**
Enforcement: structural (separate spaces per cohort). No moderation needed.

**2. Respect the room.**
One sentence that covers: no harassment, no hate speech, no personal attacks. Don't over-specify — long rule lists create rules-lawyering.

**3. Stay on story.**
This is a discussion about the book. Personal conversations, promotion, and off-topic content don't belong here.

**4. No screenshots or copying of story content outside this space.**
Protects the premium experience and IP.

**5. One warning, then removal.**
Clear escalation path. No ambiguity about consequences.

### Enforcement Without a Moderator

| Mechanism | How It Works | Effectiveness |
|---|---|---|
| **Peer reporting** | Flag button → notification to creator | Medium — works if reporting is easy (one tap). Letterboxd model: "moderators don't see every line; report via the flag icon." |
| **Community self-policing** | Social pressure in small group | High at 50 people — everyone knows everyone. Drops rapidly above 150. |
| **Algorithmic detection** | OpenAI Moderation API as silent backstop | Medium — catches clear violations. Misses context-dependent toxicity. |
| **Rotating community leads** | Designate 1-2 active readers per cohort as volunteer leads | High — distributes labor. Works in book clubs and course cohorts. |

### The Rotating Lead Model

This is the most promising approach for Dezibel at scale:
- At cohort start, identify 1-2 enthusiastic early participants.
- Give them a "discussion lead" role with ability to flag/mute.
- They get a small perk (early access to next story, credit, merch).
- You handle escalations only. 52 cohorts x 1 lead each = 52 volunteers managing day-to-day tone.

---

## 5. The "One Bad Actor" Problem

### The Math

At 50 people, one toxic participant is 2% of the cohort but can generate 80% of the negative energy. Research consistently shows that one toxic member "becomes divisive quickly, and if severely alienating, can start to affect members' engagement." In a 6-week premium experience, lost engagement = lost value = refund requests from the other 49.

### Intervention Speed Hierarchy

| Intervention | Speed | Visibility | Risk |
|---|---|---|---|
| **Instant ban** | Immediate | High — everyone sees someone disappeared | Clean but may feel authoritarian. Best for clear violations (threats, slurs, harassment). |
| **Mute/cool-down** (24-48 hour timeout) | Fast | Low — person can still read, just can't post | De-escalates without permanence. Good first step. |
| **Shadow ban** | Immediate effect, slow discovery | Invisible to bad actor — their messages only visible to them | Ethically questionable. Legal risk in EU under DSA (Dutch court ruled platforms must give "clear and specific statement of reasons" for content demotion). Not recommended for paid product. |
| **Private warning** | Fast | Zero — only bad actor knows | Effective: studies show 85% of recidivism disappeared when people were told specifically why they were warned/banned. |
| **Community vote** | Slow (days) | Maximum — everyone involved | Democratic but traumatic for small group. Creates drama that's worse than the original problem. Do not use. |

### Recommended Escalation Path for Dezibel

1. **Automated detection flags message** → queued for review.
2. **Private DM to offender** within 4 hours: "Hey, this message [quote] doesn't meet our community guidelines. Here's why: [specific reason]. Please keep the space respectful for everyone's experience."
3. **If second offense:** 48-hour mute + private message explaining the mute.
4. **If third offense:** Permanent removal from cohort.
5. **Severe violations** (threats, hate speech, harassment): Skip to permanent removal immediately.

### Legal Considerations for Paid Communities

**Terms of Service are your shield.** Key elements to include:

- **Right to remove:** "We reserve the right to remove any member who violates community guidelines, at our sole discretion, without refund." This is standard and legally defensible if clearly stated before purchase.
- **No refund on ban for cause:** Most membership businesses withhold refunds for termination due to policy violation. The key is having the policy clearly stated and agreed to at signup.
- **Prorated refund option:** Some platforms offer prorated refunds for the remaining term as a goodwill gesture. This reduces chargeback risk.
- **FTC "Click to Cancel" rule:** Cancellation must be as easy as signup. This applies to voluntary cancellation, not bans, but your process should account for it.
- **Document everything:** Keep records of the violating content and warnings issued. If a banned member disputes the charge, you need evidence.

**Recommended approach:** Ban without refund for clear violations (stated in ToS), prorated refund for borderline cases (reduces chargeback risk and shows good faith).

---

## 6. Premium Community Experience Design

### The "Empty vs Exclusive" Problem

A 50-person discussion space either feels like an intimate salon or a dead forum. The difference is entirely design and cadence.

### What Signals "Curated" vs "Ghost Town"

| Signal | Curated Feel | Ghost Town Feel |
|---|---|---|
| **Onboarding** | Welcome message, introduction prompt, Week 1 discussion starter already posted | Empty feed, "be the first to post!" |
| **Activity cadence** | New discussion prompt every day or every story beat | Sporadic, user-initiated only |
| **Member count visibility** | Show "47 readers in Week 3" (small but specific) | Show "47 members" on a page with 2 posts |
| **Creator presence** | Creator drops in occasionally with a comment or reaction | Creator never appears |
| **Constraints** | "Discussions close at end of each week" (urgency) | Open-ended, no time pressure |
| **Visual design** | Rich, branded, matches story aesthetic | Generic platform template |

### Lessons from Premium Communities

**Soho House:** Cultural fit criteria in application. Not just "can you pay?" but "will you contribute?" The filtering itself creates perceived exclusivity.

**Clubhouse (early days):** Invite-only + ephemeral (rooms disappeared) created FOMO and urgency. People showed up because the moment was fleeting. Directly analogous to Dezibel's 6-week window.

**FWB DAO:** Token cost as filter. But also: they built their own app rather than using Discord, because the platform itself signals premium. A custom branded experience > a Discord server.

### Dezibel-Specific Recommendations

1. **Seeded discussion.** Pre-post a discussion prompt for every major story beat (every few days). Don't wait for users to start conversations. The prompt itself is content.

2. **Creator presence, minimal but consistent.** Drop a reaction or short comment 2-3x per week per cohort. At 6 active cohorts, that's 12-18 micro-interactions per week. Not zero, not full-time.

3. **Timed windows.** Each week's discussion space opens when that week's content delivers and closes (read-only) at end of the 6-week run. Urgency drives participation. Matches the ephemeral nature.

4. **Completion ritual.** At Week 6, a "graduation" moment — thank-you message, invitation to alumni space, maybe a hidden story detail only available in the discussion space. Makes the ending intentional, not just... silence.

5. **Branded environment.** If using a platform like Circle, theme it heavily to match Dezibel's aesthetic. If building custom, even better — the container signals the experience's value.

6. **No member count inflation.** Show who's active, not total members. "12 readers discussing today" is more alive than "50 members" with 2 posts.

---

## Recommended Moderation Stack

### Three Layers: Structural + Automated + Human Escalation

```
Layer 1: STRUCTURAL (prevents 80% of problems)
├── Separate space per cohort (eliminates spoilers)
├── Paid access (filters low-effort trolls)
├── Structured discussion prompts (reduces off-topic drift)
├── Async-first design (prevents real-time escalation)
├── No cross-member DMs (prevents invisible harassment)
├── Ephemeral lifecycle (6-week expiry reduces stakes of conflict)
└── Pseudonymous + stable identity (accountability without doxxing)

Layer 2: AUTOMATED (catches the 15% that slip through)
├── OpenAI Moderation API — free, silent backstop
│   ├── Auto-remove: slurs, explicit threats, spam links
│   └── Flag for review: borderline toxicity, sexual content
│       (threshold tuned for fiction discussion context)
├── Keyword filter for story-specific spoiler terms
│   (updated per week as new content releases)
└── Rate limiting: slow mode during first 24 hours
    of each new content drop (peak emotion period)

Layer 3: HUMAN ESCALATION (handles the 5% that need judgment)
├── Peer reporting (one-tap flag button)
├── Rotating community leads (1-2 per cohort, volunteer)
├── Creator review queue (flagged items, aim for <4hr response)
└── Escalation path: warning → mute → removal
```

### Cost Estimate

| Component | Cost |
|---|---|
| Community platform (Circle) | $89-$199/month |
| OpenAI Moderation API | Free |
| Creator time (review queue + drops) | ~3-5 hrs/week across all cohorts |
| Community lead perks | ~$0-20/cohort (early access, merch) |
| **Total** | **~$100-220/month + time** |

### Decision Matrix: Moderation Approaches

| Factor | Structural Prevention | Automated Moderation | Human Moderation | Peer Moderation |
|---|---|---|---|---|
| **Setup cost** | Medium (one-time) | Low | Zero | Low |
| **Ongoing cost** | Zero | Zero (OpenAI free tier) | High (your time) | Low (volunteer perks) |
| **Scales to 52 cohorts** | Yes | Yes | No — breaks at ~6 cohorts | Yes, if leads recruited |
| **Catches nuance** | No (prevents categories, not instances) | Low (false positives on fiction content) | High | Medium |
| **User experience** | Invisible — best UX | Invisible if done right | Visible, can feel heavy-handed | Visible, can feel collaborative |
| **False positive risk** | None | Medium (fiction content triggers filters) | Low | Low-Medium |
| **Spoiler prevention** | Solves completely | Cannot solve | Labor-intensive | Partially |
| **"One bad actor" response** | Prevents some, not all | Catches obvious cases | Best for judgment calls | Slow, can create drama |

### Priority Order

1. **Build structural prevention first.** Separate cohort spaces, structured prompts, paid access. This is non-negotiable and handles most problems.
2. **Add OpenAI Moderation API as silent backstop.** Free, easy to integrate, catches the obvious stuff.
3. **Design the community lead program.** This is your force multiplier for scaling to 52 cohorts.
4. **Build the escalation workflow.** Private warning → mute → removal. Template the messages. Make it repeatable.
5. **Write ToS with explicit removal rights.** Get this right before launch. Include no-refund-for-cause clause.

---

## Platform Recommendation

**Circle** is the strongest fit for Dezibel's community layer:

- Gated spaces per cohort (structural spoiler prevention).
- Cohort-based course features with timed content release.
- Custom branding to match Dezibel's aesthetic.
- Built-in moderation tools (member roles, reporting).
- API access for integrating OpenAI Moderation.
- Starts at $89/month.
- Scales: you create a new space per cohort, archive it after 6 weeks.

**Alternatives considered:**
- **Discord:** Free, powerful AutoMod, but signals "gaming community" not "premium fiction experience." Channel organization gets unwieldy at 52 simultaneous cohorts.
- **Telegram:** Signal group-level simplicity but limited moderation tools, no gated spaces.
- **Signal:** Encryption-first, but admin tools are minimal (can't delete others' messages yet). No spaces/threads. Not suitable.
- **Custom build:** Maximum control but months of development time. Consider only after validating the community model works on Circle.

---

## Key Uncertainties (UNVERIFIED)

These assumptions need kill tests before building:

1. **Will 50-person cohorts generate enough discussion to feel alive?** Kill test: survey existing audience about discussion appetite. Or: run a single test cohort on a free platform before committing to Circle.

2. **Will volunteer community leads reliably show up for 6 weeks?** Kill test: recruit 3 leads for a pilot cohort. Track their engagement over the full cycle.

3. **Will OpenAI Moderation API's false positive rate be acceptable for fiction discussion?** Kill test: run 100 sample messages from the story through the API. Check if emotional/violent/sexual story discussion triggers false flags.

4. **Is Circle's $89+/month justified before revenue validates the community model?** Kill test: can you achieve 80% of the same result with a private Discord server for free?

---

## Sources

- [Reddit Episode Discussion Structure](https://joeyplunkett.ghost.io/reddit-episode-discussion-hack-join-the-conversation-without-spoilers/)
- [ACM: Spoiler Alert! Understanding and Designing for Spoilers in Social Media (2025)](https://dl.acm.org/doi/10.1145/3706370.3727861)
- [Perspective API](https://perspectiveapi.com/)
- [Perspective API Sunsetting Info](https://www.lassomoderation.com/blog/what-is-perspective-api/)
- [OpenAI Moderation API Guide](https://www.eesel.ai/blog/openai-moderation-api)
- [OpenAI Moderation API - Free Confirmation](https://help.openai.com/en/articles/4936833-is-the-moderation-endpoint-free-to-use)
- [Discord AutoMod](https://discord.com/safety/auto-moderation-in-discord)
- [Discord AutoMod FAQ](https://support.discord.com/hc/en-us/articles/4421269296535-AutoMod-FAQ)
- [Hive Moderation Pricing](https://thehive.ai/pricing)
- [Hive Alternatives Comparison](https://getstream.io/blog/hive-alternatives/)
- [12 Best AI Content Moderation APIs Compared](https://estha.ai/blog/12-best-ai-content-moderation-apis-compared-the-complete-guide/)
- [Moderation & Toxicity Prevention Techniques](https://adjourn.audent.io/moderation-toxicity-prevention-techniques-3fe9baba3e65/)
- [5 Principles for Designing Better Moderation](https://messythoughtstotangibletakes.medium.com/5-principles-for-designing-better-moderation-9b937f630d55)
- [Higher Logic: Handling Toxic Members](https://www.higherlogic.com/blog/tips-for-handling-a-toxic-association-member-in-your-online-community/)
- [Discourse: Dealing with Toxicity](https://blog.discourse.org/2022/12/dealing-with-toxicity-in-online-communities/)
- [Dealing with Toxicity - Sarah Hawk](https://www.linkedin.com/pulse/dealing-toxicity-online-communities-sarah-hawk)
- [Letterboxd Community Policy](https://letterboxd.com/legal/community-policy/)
- [Letterboxd Comment Control](https://letterboxd.com/journal/comment-control/)
- [Silent Book Club Community Guidelines](https://silentbook.club/pages/community-guidelines)
- [Shadow Banning - Wikipedia](https://en.wikipedia.org/wiki/Shadow_banning)
- [Shadow Ban Legal Risks](https://www.influencers-time.com/navigating-legal-challenges-of-shadow-banning-on-platforms/)
- [Shadow Ban - GetStream Definition](https://getstream.io/glossary/shadow-ban/)
- [Real-Name Policies: The War Against Pseudonymity](https://www.privacyguides.org/articles/2025/10/15/real-name-policies/)
- [Riot Limiting Communication to Fight Toxicity](https://medium.com/@daxwaxarn/riot-limiting-communication-to-fight-toxicity-8f41905925a2)
- [Whatnot: Real-time Chat Rate Limiting](https://medium.com/whatnot-engineering/moving-slow-to-move-fast-real-time-chat-rate-limiting-d60bed11d65d)
- [Soho House Membership Guide](https://candaceabroad.com/soho-house-membership/)
- [Soho House: Decoding Membership](https://sohohouse.co/blog/membership/decoding-the-soho-house-membership-a-guide-for-creatives)
- [Friends With Benefits DAO](https://www.alchemy.com/dapps/friends-with-benefits)
- [FWB Grows Up (CoinDesk 2025)](https://www.coindesk.com/tech/2025/04/18/friends-with-benefits-grows-up)
- [Circle Community Platform Guide](https://linodash.com/circle-community-guide/)
- [Circle Pricing](https://circle.so/pricing)
- [Circle.so Review 2026](https://www.learningrevolution.net/circle-review/)
- [Signal Group Management](https://support.signal.org/hc/en-us/articles/360050427692-Manage-a-group)
- [TermsFeed: Terms and Conditions for Memberships](https://www.termsfeed.com/blog/terms-conditions-memberships/)
- [Memberful: Membership Refund Policy](https://memberful.com/blog/membership-refund-policy/)
- [FTC Click-to-Cancel Legal Requirements](https://www.destinicopp.com/blog/membership-site-legal)
- [Private Online Community Platforms](https://bettermode.com/blog/private-online-community-platforms)
- [Micro-Events: The Trend of Intimate Events](https://weandgoliath.com/micro-events/)
- [Cohort Platforms with Community 2026](https://www.disco.co/blog/best-cohort-platforms-with-community-2026)
- [Ephemeral Communities in Disasters (ScienceDirect)](https://www.sciencedirect.com/science/article/pii/S2212420925007289)
