---
title: "Typing indicator UX: making pre-scripted chat feel like live conversation"
type: reference
tags: [dezibel, ux, typing-indicator, chat-fiction, pacing, app]
created: 2026-03-29
area: "[[writing-and-film]]"
source: "Web research on chat fiction pacing and real-time text simulation."
---

## The core question: simulate LIVE texting or present a TRANSCRIPT?

Neither. The answer is a hybrid: **scripted playback with live-feeling pacing**. The reader knows this is fiction (they bought it), but the UX should create the *sensation* of eavesdropping on a real conversation happening now. Not a transcript (static, dead). Not truly live (impossible to sustain over 42 days). A **directed replay** — like watching a film, not reading a screenplay.

The distinction matters because dezibel delivers ~100+ messages per day across 42 days. A pure transcript is a wall of text. Pure live simulation at 100 msgs/day means constant notifications. The right model is: **batch delivery in sessions, with live-pacing playback within each session.**

---

## 1. How chat fiction apps handle pacing

### Hooked
- **Tap-to-reveal**: reader taps bottom of screen to show next message. No auto-advance.
- **Typing indicator**: brief bounce-dot animation before each message appears (mimics iMessage).
- **Story length**: ~1,000-1,300 words per story, readable in ~5 minutes.
- **Monetization gate**: first few stories free, then paywall. No time-gating.
- **Result**: 5x completion rate vs traditional text format. 2.2M downloads in 5 months (560% growth Oct 2016 - Mar 2017). Top-grossing book app iOS US.

### Yarn (Mammoth Media)
- **Tap-to-reveal**: same core mechanic as Hooked.
- **Typing indicator**: shown briefly before each message reveal.
- **Added**: Choose Your Own Adventure branching (2019).
- **Design philosophy**: "Readers aren't faced with a block of text" — the phone-native feel is the product.

### Tap (Wattpad)
- **Tap-to-reveal**: identical mechanic. 2 billion taps recorded.
- **Extended format**: "Tap Originals" added audio, images, GIFs alongside text.
- **Creator tools**: let writers publish their own chat fiction.

### Common pattern across all three
Every major chat fiction app uses **tap-to-reveal**, not auto-play. Typing indicator shown for 0.5-2 seconds before message appears. No timed delays between messages — reader controls pace entirely.

### Epistories (email epistolary fiction)
- **Drip delivery**: characters email you on unpredictable schedules — daily, weekly, or monthly.
- **Key insight**: "You'll never know precisely when. This unpredictability is part of the experience, making every notification a moment of suspense."
- Closest existing model to dezibel's daily delivery concept.

---

## 2. What makes typing indicators feel authentic vs fake

### Real iMessage behavior (the reference standard)
- Dots appear when recipient opens conversation and starts typing.
- Dots persist for **5-10 seconds** after typing stops, then disappear.
- Some reports of dots lingering up to **60 seconds** if nothing else happens.
- Dots are unreliable — they sometimes appear without typing, or don't appear during typing.
- Only works in 1:1 iMessage threads, not group or SMS.

### What makes it feel real
1. **Variable duration**: typing indicator should last proportional to message length. Short message = 0.5-1s indicator. Long message = 2-4s. A 3-word reply showing 4 seconds of typing feels wrong.
2. **The 20-25ms per character rule**: chatbot UX research recommends ~20-25ms per character for typing indicator duration. A 100-character message = ~2-2.5s indicator. Never below 500ms (feels instant/fake), never above 3000ms (feels stuck).
3. **Imperfect timing**: real typing indicators flicker — they appear, vanish (person deleted text), reappear. Occasionally simulating a "false start" (indicator appears for 1s, disappears for 2s, reappears, then message arrives) dramatically increases perceived authenticity.
4. **Dots should bounce, not pulse**: iMessage uses vertically bouncing dots with staggered animation delays. Pulsing/fading feels generic. The bounce with ~200ms stagger between dots is the established visual language.
5. **No indicator for instant replies**: in real texting, a fast reply (under 2 seconds) often arrives without the recipient ever seeing typing dots. Simulating this for short responses ("lol", "ok", emoji reactions) increases realism.

### Three-dot anxiety as a storytelling tool
Research shows typing indicators trigger the same neural pathways as physical pain and threat detection. The dots create anticipation, uncertainty, and dopamine response. This is not a bug — for dezibel, it is a **narrative instrument**:
- Show typing indicator, then have it disappear (character deleted their message) — builds tension.
- Extended typing indicator before a confession or emotional reveal — creates dread/anticipation.
- No typing indicator before a devastating message (it just arrives) — mimics the gut-punch of receiving bad news with no warning.

---

## 3. Auto-play vs tap-to-reveal

### Tap-to-reveal (what Hooked/Yarn/Tap use)
- **Pros**: reader controls pace, no notification fatigue, session-based consumption, "just one more tap" addictive loop, works for short stories (5 min).
- **Cons**: breaks immersion for longer narratives — 100+ taps in a session is finger fatigue. Reader consciously "performing" the reveal rather than experiencing it.

### Auto-play (timed message reveal)
- **Pros**: feels like watching a real conversation unfold. Reader is a voyeur, not a participant. Better for emotional pacing — the writer controls timing of reveals. Natural for dezibel's "eavesdropping" conceit.
- **Cons**: if pacing is wrong, reader is either waiting (bored) or missing messages (overwhelmed). Requires careful calibration. Can't skim or skip ahead.

### The dezibel recommendation: AUTO-PLAY with manual override

Dezibel is not a 5-minute chat story. It is a 42-day immersive experience with 100+ daily messages, audio, and emotional pacing that requires directorial control. Tap-to-reveal would reduce it to a "next message" button masher.

**Proposed model:**
- **Default mode: auto-play**. Messages appear with typing indicators and realistic timing. Reader watches the conversation unfold like a film.
- **Tap-to-advance**: if reader taps during auto-play, skip to next message immediately. Lets impatient readers move faster without breaking the system.
- **Scroll-back**: all previously revealed messages are scrollable. Reader can re-read at any time.
- **Pause/resume**: if reader leaves the app mid-session, resume from where they left off. Don't replay messages they've already seen.

This gives the writer (Graeme) control of pacing while giving the reader an escape valve.

---

## 4. Handling 100+ messages across a day

### The notification fatigue problem
- Users sending 40+ texts/day check their phone 14.3 times/hour for notifications. Dezibel cannot compete with that attention pattern by drip-feeding individual messages throughout the day.
- Applications using digest/batch notifications see **35% higher engagement** and **28% lower opt-out rates** vs individual alerts.
- Push notification average delivery rate: 14-48%. Unreliable as primary delivery.

### Delivery models ranked for dezibel

| Model | Description | Verdict |
|-------|-------------|---------|
| All at once | Full day's messages available at midnight | Kills immersion. Becomes a transcript. |
| Individual drip | Each message pushed individually throughout the day | 100 notifications/day = instant uninstall |
| Real-time playback | Messages arrive at the "real" times Hasta/Emma would text | Beautiful in theory, impractical. Reader misses messages during meetings, sleep, etc. |
| **Session batches** | 2-4 "chapters" per day, reader opens app to watch each batch play out | **Best fit for dezibel** |

### Recommended: session-batch model

**Structure each day into 2-4 narrative sessions:**

| Session | Notification | Content |
|---------|-------------|---------|
| Morning | Push: "Hasta texted you" (+ 1 SMS rescue if dark >24h) | 20-40 messages, conversation from "last night" or early morning |
| Midday | Push: "Emma sent something" | 15-25 messages, short exchange |
| Evening | Push: "New messages from Hasta & Emma" | 30-50 messages, longest session, emotional weight |
| (Optional) Late night | Push only if day has late-night content | 10-20 messages, intimate/confessional |

**Within each session**: auto-play with typing indicators. Total daily reading time: 15-25 minutes across sessions.

**Why this works:**
- 2-4 notifications/day is sustainable (matches real texting patterns with a close friend).
- Each session is a self-contained emotional beat — not a random chunk.
- The "open app to watch conversation unfold" ritual becomes habit-forming.
- Writer controls narrative pacing at both the macro (session timing) and micro (message timing) level.

---

## 5. Human texting cadence research

### Typing speed
- Average mobile typing: **36 words per minute** (2-thumb typing: 38 wpm).
- Ages 10-19: ~40 wpm. Ages 40+: ~30 wpm.
- 70% of QWERTY keyboard speed.

### What this means for typing indicator duration
At 36 wpm, a person types ~3 characters/second on mobile. A 100-character message takes ~33 seconds to type. But nobody watches someone type for 33 seconds — iMessage only shows the indicator, not the duration of actual composition.

**Realistic indicator durations for dezibel:**

| Message length | Characters | Indicator duration | Notes |
|---------------|------------|-------------------|-------|
| Very short ("lol", "ok") | <10 | 0ms (no indicator) | Instant arrival feels real |
| Short ("haha that's amazing") | 10-40 | 500-1000ms | Quick flash of dots |
| Medium (1-2 sentences) | 40-150 | 1000-2500ms | Standard typing feel |
| Long (3+ sentences, emotional) | 150-500 | 2500-4000ms | Extended contemplation |
| After a pause in conversation | Any | Add 1000-3000ms delay before indicator appears | Simulates picking up phone |

### Inter-message timing (gaps between messages)
Real texting patterns (no published research with exact ms, but observable patterns):

| Pattern | Delay | When to use |
|---------|-------|-------------|
| Rapid-fire exchange | 0.5-2s between messages | Banter, excitement, argument |
| Normal conversation | 3-8s between messages | Standard back-and-forth |
| Thoughtful reply | 10-30s gap before typing indicator appears | Heavy topic, emotional processing |
| Topic change | 15-60s gap | One person shifts subject |
| "Left on read" moment | 60s+ gap, or indicator appears and disappears | Tension, avoidance |
| Time jump | Fade/timestamp, then new session | Hours pass in story |

---

## 6. Read receipts as an immersion tool

### How iMessage read receipts work
- "Delivered" appears immediately (blue text, both iPhones).
- "Read" appears with timestamp when recipient opens the conversation.
- Not everyone has read receipts enabled — this is itself a character choice.

### Dezibel applications

**Hasta has read receipts ON** (open, present, waiting). **Emma has read receipts OFF** (guarded, unpredictable, maintains power).

Narrative uses:
- **"Read 2:47 AM"** — Hasta read her message at 3 AM but didn't reply. What kept him up?
- **"Delivered" staying for hours** — Emma hasn't opened it. Tension.
- **Double-blue-check to reply gap** — read it, waited 20 minutes, then responded. The gap IS the story.
- **Read receipt disappears** — character turned off read receipts mid-conversation. Why? What changed?

Read receipts are **metadata storytelling** — they convey emotional state without dialogue. Dezibel should render them as part of the UI, with the same timestamps and states as real iMessage.

**Implementation**: each message in the script.json can carry a `read_status` field: `sent`, `delivered`, `read`, with optional timestamps. The UI renders these below the message bubble exactly like iMessage.

---

## 7. React Native implementation notes

### Architecture for timed message reveal

```
script.json (per day, per session)
├── messages[] — ordered array of message objects
│   ├── id
│   ├── sender: "hasta" | "emma"
│   ├── content: string
│   ├── type: "text" | "audio" | "image" | "typing_fake_out"
│   ├── indicator_duration_ms: number (0 = no indicator)
│   ├── delay_before_ms: number (gap after previous message)
│   ├── read_status: "sent" | "delivered" | "read"
│   └── read_timestamp: string (optional)
```

### Key libraries
- **Stream Chat React Native SDK**: already in dezibel architecture. Has built-in `TypingIndicator` component. Supports `typing.start` / `typing.stop` events. Customizable via component override.
- **react-native-typing-animation** (npm): standalone typing dots animation using trigonometry for smooth bounce. 73 dependents. Drop-in if not using Stream's built-in.
- **react-native-reanimated**: for message entrance animations (fade/slide in from bottom). Supports `entering`/`exiting` layout animations on FlatList items.
- **Animated FlatList**: use `onViewableItemsChanged` to trigger animations only for newly visible messages. `maintainVisibleContentPosition` to keep scroll stable as messages append.

### Playback engine (pseudo-architecture)

```
MessagePlaybackEngine
├── loadSession(dayNumber, sessionIndex)
├── queue: Message[] (ordered)
├── currentIndex: number
├── state: "playing" | "paused" | "complete"
├── play()
│   ├── for each message in queue:
│   │   ├── wait(message.delay_before_ms)
│   │   ├── showTypingIndicator(message.sender, message.indicator_duration_ms)
│   │   ├── hideTypingIndicator()
│   │   ├── appendMessage(message) → triggers FlatList re-render with animation
│   │   └── scrollToBottom()
│   └── markSessionComplete()
├── skipToNext() — tap-to-advance
├── pause() — app backgrounded
└── resume() — app foregrounded, pick up from currentIndex
```

### Performance considerations
- Pre-load all messages for a session but only render up to `currentIndex`. Don't dynamically fetch.
- Use `FlatList` with `inverted={false}` (messages flow top to bottom, newest at bottom — standard chat).
- Typing indicator is a single component pinned to bottom of list, toggled by playback engine.
- Message entrance animation: `FadeInDown` from reanimated, 200-300ms duration.
- For sessions with 50+ messages, use `windowSize` and `maxToRenderPerBatch` FlatList props to prevent frame drops.

### Handling app lifecycle
- `AppState` listener: on background, pause playback. On foreground, resume.
- Persist `currentIndex` to AsyncStorage per session. If user kills app mid-session, resume from last seen message.
- Already-revealed messages render instantly on re-open (no replay).

---

## Recommended pacing model for dezibel

### The "directed replay" approach

1. **Daily content arrives in 2-4 session batches**, triggered by push notification (+ SMS rescue for disengaged users).
2. **Reader opens app** and sees a "new messages" indicator on the conversation.
3. **Session plays automatically**: typing indicators, realistic inter-message delays, read receipts — all controlled by per-message timing data in script.json.
4. **Reader can tap to skip ahead** within a session, or scroll back to re-read.
5. **Session completes** — all messages now static/scrollable. Next session locked until its scheduled time.
6. **End of day**: all sessions available for re-reading. Daily note or P/F chapter unlocks.

### Timing presets (embed in script.json authoring tool)

| Preset | delay_before_ms | indicator_duration_ms | Use case |
|--------|----------------|----------------------|----------|
| `rapid` | 300-800 | 400-700 | Banter, excitement |
| `normal` | 2000-5000 | 800-1500 | Standard conversation |
| `slow` | 5000-15000 | 1500-3000 | Heavy topics |
| `dramatic_pause` | 15000-30000 | 0 (no indicator, just silence) | Before a reveal |
| `instant` | 0 | 0 | Reactions, very short replies |
| `false_start` | 3000-8000 | show 1500ms, hide 2000ms, show again 1000ms | Character reconsidering |
| `left_on_read` | 30000-120000 | 0 | Tension, avoidance |

### What makes this feel LIVE vs SCRIPTED
- **Variable pacing**: never metronomic. Randomize +-20% on all timing values.
- **False starts**: 1 in 15 messages should show typing indicator that disappears, then reappears.
- **No indicator for very short messages**: "lol", "ok", emoji — just appear.
- **Read receipts with realistic gaps**: "Read 2:47 AM" → reply at 2:52 AM.
- **Timestamp jumps**: when hours pass in-story, show a timestamp divider (like iMessage's "Thursday 2:14 PM").
- **Sound**: optional notification sound when a new message arrives during playback. Subtle, not a real push notification sound.
- **Message grouping**: consecutive messages from same sender appear without repeated avatar/name — just like real iMessage.

---

## What to test in beta (5-7 readers, instrumented)

### Pacing validation
1. **A/B: auto-play vs tap-to-reveal** on the same Day 1 content. Measure: completion rate, session duration, qualitative feedback ("did it feel live?").
2. **Timing calibration**: run Day 1 with three timing profiles (fast/medium/slow). Ask readers which felt most natural. Track where they tap-to-skip (indicates pacing is too slow at that point).
3. **False start frequency**: test 0%, 5%, 10% false-start rate. Too many feels glitchy. Zero feels robotic.

### Engagement metrics to instrument
- Session open-to-completion rate (do they watch the whole batch?)
- Tap-to-skip frequency (proxy for "pacing too slow")
- Time between push notification and app open (engagement latency)
- Re-read rate (do they scroll back? which messages?)
- Drop-off day (which day do people stop opening?)
- Session time vs expected time (are they faster or slower than authored pacing?)

### Immersion quality
- "Did you forget these characters aren't real?" (1-5 scale, daily)
- "Did the typing indicator add or detract?" (after Day 3)
- "How many notifications per day felt right?" (end of week 1)
- "Did the read receipts matter to you?" (end of week 1)

### Technical
- Battery impact of background timers / animations
- FlatList scroll performance at 100+ messages
- Notification delivery rate (push vs SMS rescue trigger rate)
- App resume behavior (does it correctly pick up mid-session?)

---

## Competitor/reference landscape

| App | Format | Pacing | Typing indicator | Volume | Monetization |
|-----|--------|--------|-----------------|--------|-------------|
| Hooked | Chat fiction (short) | Tap-to-reveal | Yes, brief | ~200 msgs/story | Freemium + ads |
| Yarn | Chat fiction (short) | Tap-to-reveal | Yes, brief | ~200 msgs/story | Subscription |
| Tap (Wattpad) | Chat fiction + multimedia | Tap-to-reveal | Yes | Varies | In-app purchases |
| Epistories | Email epistolary | Drip (unpredictable) | N/A (email) | 1-5/day | Per-story purchase |
| Dipsea | Audio erotica | Auto-play (audio) | N/A | 5-25 min/episode | Subscription |
| **Dezibel** | **iMessage novel (42-day)** | **Auto-play + tap-override** | **Yes, variable + false starts** | **100+/day** | **Per-experience ($49-199)** |

Dezibel has no direct competitor. Hooked/Yarn/Tap are short-form (5-minute stories). Epistories is long-form but email-based. Dipsea is audio-only. Dezibel occupies an empty quadrant: **long-form, daily-delivery, chat-UI, multi-media, with directed playback pacing.** The closest analogue is a television series delivered as text messages.
