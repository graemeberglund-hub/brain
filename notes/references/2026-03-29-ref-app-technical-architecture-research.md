---
title: "Dezibel app technical architecture: framework, chat UI, BLE, push"
type: reference
tags: [dezibel, app, react-native, flutter, ble, push-notifications, architecture, technical]
created: 2026-03-29
area: "[[writing-and-film]]"
source: "Web research on native app frameworks, chat UI libraries, BLE integration, and push notification architecture for serialized fiction delivery."
---

# Dezibel App Technical Architecture Research

## Framework Recommendation: React Native

**Verdict: React Native, strongly recommended over Flutter and native.**

### Why React Native wins for this project

1. **Chat UI ecosystem is decisive.** Stream Chat SDK has a production-ready, open-source iMessage clone sample app (blue/gray bubbles, typing indicators, read receipts, avatars). Flutter has no equivalent. Building iMessage-quality chat UI from scratch in Flutter or native would add 4-8 weeks and $15-30K.

2. **BLE support is sufficient.** react-native-ble-plx (by dotintent) is the most full-featured React Native BLE library. react-native-ble-manager is a simpler alternative. Both support GATT read/write operations needed for Lovense's ASCII-over-UART protocol. Flutter's flutter_blue_plus is marginally more stable for BLE, but not enough to offset the chat UI advantage.

3. **Rich push notifications fully supported.** iOS Notification Service Extension works identically whether the app is React Native or native Swift -- it runs as a separate target. Character avatars in notifications: confirmed possible. You download the image in the extension's 30-second window and attach it to the notification content.

4. **Offline-first has mature tooling.** WatermelonDB (SQLite-based, lazy-loading, reactive) handles 10,000+ records with sub-millisecond queries on a separate native thread. Perfect for pre-loading a day's messages.

5. **Code sharing with web.** react-native-web enables ~70-80% code reuse for a PWA fallback (minus BLE, which doesn't work on iOS Safari -- confirmed). Business logic, message rendering, and audio playback all portable.

6. **Developer availability.** 42% of enterprise mobile teams use React Native (2025 Statista). Larger hiring pool than Flutter (38%) or native specialists.

7. **Cost advantage.** Single codebase for iOS + Android. The $60K tech line in the deck is tight but possible with React Native; it would be impossible with separate native builds.

### Why not Flutter

- No production-ready iMessage clone UI library. Would need to build from scratch.
- Dart ecosystem smaller than JS/TS for web integration.
- BLE support (flutter_blue_plus) is slightly better, but BLE is not the bottleneck -- chat UI is.
- Smaller freelancer pool in North America.

### Why not native Swift/Kotlin

- Two codebases doubles cost and timeline. $120K+ minimum.
- BLE and push are marginally better on native, but the marginal gain doesn't justify 2x cost for a content delivery app (not a BLE-critical medical device).
- Apple provides vendor support for native BLE issues; React Native relies on library maintainers. Acceptable risk for this use case.

---

## 1. Chat UI Libraries

### Stream Chat React Native SDK (recommended)

- Open-source iMessage clone in their [react-native-samples](https://github.com/GetStream/react-native-samples) repo. Also has WhatsApp and Slack clones.
- Components: message bubbles (customizable colors), avatars, timestamps, read receipts, typing indicators, reactions, threads.
- Self-hosted backend possible -- Stream's SDK can be used as UI-only with a custom backend. You'd use Stream's UI components but point them at your own API.
- **Cost: Free for the SDK. Stream's hosted chat service costs $0.02/MAU beyond free tier, but you don't need their backend -- just their UI components.**
- Caveat: Verify that Stream's UI layer can be fully decoupled from their backend API. If not, use it as a reference implementation and extract the component patterns.

### React Native Gifted Chat (fallback)

- Most popular open-source chat UI for React Native (13K+ GitHub stars).
- Supports: message bubbles, avatars, timestamps, send button, composer, custom message rendering.
- Missing out of box: read receipts, typing indicators (need add-on: react-native-typing-animation), iMessage-specific styling.
- Would require significant custom styling to match iMessage aesthetic.
- **Better as a starting point if Stream's backend coupling is too tight.**

### Custom build (last resort)

- If neither library matches the exact iMessage feel, build on FlashList v2 (Shopify's list renderer -- maintains 60 FPS, auto-handles scroll position on new messages, no item size estimates needed).
- Timeline impact: +3-5 weeks over using Stream.

---

## 2. BLE / Lovense Integration

### Lovense BLE Protocol (documented, no cloud required)

The Lovense protocol is well-documented by the reverse-engineering community (buttplug.io/stpihkal) and partially by Lovense themselves:

- **Protocol:** ASCII commands over BLE UART-like GATT service. Commands are semicolon-terminated strings.
- **Service UUIDs** (vary by firmware generation):
  - Gen 1: `0000fff0-0000-1000-8000-00805f9b34fb` (rx: fff1, tx: fff2)
  - Gen 2 (Nordic UART): `6e400001-b5a3-f393-e0a9-e50e24dcca9e` (tx: 0002, rx: 0003)
  - Newer: `XY300001-...` family
- **Key commands:** Vibrate (intensity 0-20), pattern playback, battery check, device info.
- **No cloud dependency.** Direct BLE write to the device's TX characteristic. This is critical -- no Lovense server in the loop, no QR re-auth, no 4-hour token expiry.

### Implementation path

1. **react-native-ble-plx** for BLE communication (scan, connect, discover services, write characteristics).
2. Write a thin Lovense adapter layer that:
   - Scans for Lovense device names (LVS-*)
   - Discovers the correct service/characteristic UUIDs for the connected device
   - Sends vibration commands as ASCII strings
   - Maps story haptic patterns to command sequences
3. **Buttplug.io** as reference implementation (Rust core with JS/TS bindings, supports 750+ devices). Not directly usable in React Native, but the protocol knowledge is invaluable. Their [Lovense protocol docs](https://buttplug.io/stpihkal/protocols/lovense/) are the best available.

### Latency and reliability

- BLE write latency: 7-20ms typical for a single GATT write.
- Lovense devices respond to vibration commands within ~50ms.
- Total latency (app command to physical response): ~70-120ms. Imperceptible for story-synced haptics (you're syncing to reading pace, not musical beats).
- **Reliability concern:** BLE connections drop if the phone's Bluetooth stack is under load (e.g., AirPods connected simultaneously). Implement reconnection logic with exponential backoff.

### Lovense SDK vs. direct BLE

Lovense offers an official Android SDK and Standard JS API, but both route through Lovense's cloud or their Connect app. **For dezibel, direct BLE is mandatory** -- erotic content on Lovense's servers is an unnecessary dependency and privacy risk. The reverse-engineered protocol is stable across firmware versions (documented across 3 generations).

---

## 3. Rich Push Notifications

### iOS (APNs + Notification Service Extension)

- **Character avatars: confirmed possible.** The Notification Service Extension runs before the notification is displayed, with ~30 seconds to modify content. Download the character's avatar image, create a UNNotificationAttachment, and attach it. The avatar appears as a thumbnail in the notification.
- **Message preview:** Standard notification body text. Can show character name as title, message preview as body.
- **Implementation:** Separate Xcode target (Notification Service Extension) with its own App ID and provisioning profile. React Native apps add this as a native iOS extension -- not managed by React Native, but trivial to set up.
- **Rich media:** Can also attach audio clips for voice note notifications.

### Android (FCM)

- **Custom notification layouts:** Android supports RemoteViews for notifications. Character avatars via large icon (setLargeIcon) or custom layout.
- **FCM data messages:** Use data-only messages (not notification messages) so the app's notification handler runs even in background. This gives full control over presentation.
- **Channels:** Create per-character notification channels so users can control which characters notify them.

### Both platforms

- **Self-hosted API sends push payloads** to APNs/FCM directly (not through Firebase Cloud Messaging dashboard). The erotic content VPS sends the notification payload; Firebase is only used for device token management and subscriber state.
- **Notification grouping:** Group by story day so 100+ daily messages don't overwhelm notification center. Show latest message, with "12 more messages" summary.

---

## 4. Typing Indicators / Real-Time Simulation

### Architecture: Local timer, not WebSocket

For pre-scripted content, typing indicators are a UI illusion. No server communication needed.

**Implementation:**

```
Message schedule (loaded from SQLite/WatermelonDB):
  10:14:00 - Show typing indicator for "Emma" (1.2s)
  10:14:01.2 - Display Emma's message
  10:14:03 - Show typing indicator for "Emma" (0.8s)
  10:14:03.8 - Display Emma's follow-up
  10:17:00 - Show typing indicator for "Hasta" (2.1s)
  10:17:02.1 - Display Hasta's message
```

- **Typing duration** scales with message length (short messages = 0.5-1.5s, long messages = 2-4s). Adds realism.
- **react-native-typing-animation** provides the three-dot bounce animation.
- **Gifted Chat** has built-in isTyping prop and customizable footer for typing indicators.
- **All timing is local.** The day's message schedule is pre-loaded. A local timer fires events. No network dependency for the illusion.

### Variation to prevent mechanical feel

- Add random +-200ms jitter to typing durations.
- Occasionally show typing indicator, then "cancel" it (typing stops, no message appears, then typing resumes). Mimics real texting behavior.
- Vary delivery gaps between messages (not perfectly uniform intervals).

---

## 5. Offline-First Architecture

### Pattern: Pre-load today's messages at midnight (or on app open)

**Database: WatermelonDB** (recommended over raw SQLite)

- Built on SQLite, adds reactive queries and lazy loading.
- 10,000+ records: sub-millisecond query times (separate native thread).
- Adds only ~2MB to app size.
- Observable: when a message record is marked "delivered," UI auto-updates without manual refresh.

**Sync strategy:**

1. **Nightly pre-load:** At midnight (or first app open of the day), fetch today's message schedule from the self-hosted API. Store in WatermelonDB.
2. **Message schedule format:** Each message has: `id`, `day`, `scheduled_time`, `sender`, `content_type` (text/audio/image), `content`, `haptic_pattern_id` (nullable), `typing_duration_ms`.
3. **Audio pre-cache:** Download all audio files for the day during pre-load. Store as local files. Use react-native-fs or expo-file-system.
4. **Playback engine:** A local scheduler reads from WatermelonDB, fires typing indicators and message reveals at scheduled times. Zero network dependency after pre-load.
5. **Catch-up on reconnect:** If app was offline during pre-load window, fetch and cache on next network availability. Messages that were scheduled while offline appear immediately in sequence (catch-up mode).

**What requires network:**

- Initial day pre-load (once per day, ~50-200KB of message data + audio files)
- Push notification delivery (but messages also appear in-app without push)
- Cohort state sync (which day the subscriber is on)
- Purchase/authentication

**What works fully offline:**

- Reading all pre-loaded messages
- Typing indicator animations
- Audio playback
- BLE haptic control
- Message history browsing

---

## 6. Deep Linking from SMS

### Implementation

- **iOS Universal Links + Android App Links.** Configure with an AASA file (iOS) and assetlinks.json (Android) hosted on dezibel's domain.
- **URL scheme:** `https://dezibel.app/story/day/{N}` opens the app to the relevant story day.
- **SMS trigger flow:** Twilio sends SMS with deep link → user taps → app opens to specific day/message → if app not installed, link falls back to web landing page with app store links.
- **Expo Router** (if using Expo) makes deep linking configuration file-system based -- significantly simpler than manual React Navigation linking config.

---

## 7. App Size and Performance

### Message volume: 4,200+ messages over 42 days

- **Storage:** ~2-4MB for all text messages (42 days x 100 messages x 500 chars average). Negligible.
- **Audio:** The real size concern. ~120 audio pieces. At 128kbps AAC, 30-second clips = ~480KB each. 120 clips = ~57MB total. **Strategy:** Pre-load only current day's audio (5-10 clips, ~2-5MB). Download upcoming days in background.
- **Total app size:** ~50-80MB installed (React Native bundle + UI assets + initial content). Within normal range for iOS/Android.

### List performance

- **FlashList v2** (Shopify): Maintains 60 FPS even with complex item components. Automatic item sizing (no estimatedItemSize needed in v2). Built-in `maintainVisibleContentPosition` for chat interfaces -- scroll position stays stable when new messages arrive.
- **4,200 total messages is not a performance problem.** Only the current day's messages (~100) render at once. Historical days load on-demand. FlatList/FlashList virtualizes the list -- only visible items are in memory.
- **Per-day rendering:** 100-150 messages with avatars, timestamps, and typing indicators. Well within FlashList's comfortable range (it handles 10,000+ items at 60 FPS on mid-range devices).

---

## 8. Open Source Chat Fiction Apps

### Finding: No production-quality open source exists

- **Hooked** (Telepathic Inc., 2015) was the category creator -- chat fiction delivered as tappable message sequences. 20M+ teen users. **Closed source, company appears inactive.**
- **Yarn** (Science Mobile), **Tap** (Wattpad), **Amazon Rapids** -- all closed-source competitors. Most have shut down.
- **Twine** -- open-source interactive fiction tool, but it's a branching narrative engine, not a chat UI. Wrong paradigm.
- **TextingStory** -- chat-to-video converter. Not a delivery platform.
- **FictionLab** -- AI story platform. Wrong category entirely.

**Implication:** No off-the-shelf open-source chat fiction delivery app exists. The Stream Chat iMessage clone is the closest foundation -- it provides the UI layer, and dezibel's innovation is the scheduling/delivery engine on top.

---

## 9. PWA Fallback

### What's possible

- **react-native-web** enables running React Native apps in the browser.
- **Shared code:** Business logic (message scheduling, state management), UI components (chat bubbles, message list), audio playback -- all portable.
- **Service workers** enable offline caching for the PWA.
- **Estimated code reuse: 70-80%** between native app and PWA.

### What's lost in PWA

| Feature | PWA Status | Impact |
|---------|-----------|--------|
| BLE/Lovense | Not available on iOS Safari. Chrome Android only. | Haptic tier requires native app. |
| Push notifications | Supported since iOS 16.4 (2023). | Works, but less reliable than native APNs. |
| Background audio | Limited. Tab must remain active on iOS. | Voice notes work; ambient/binaural degraded. |
| Deep linking from SMS | Works via standard HTTPS links. | No issue. |
| Offline capability | Service workers cache assets. | Works for pre-loaded content. |
| App icon / home screen | Supported via manifest.json. | Works. |

**Recommendation:** Build React Native first. PWA is a good fallback for users who resist app installation, but the haptic tier (a major revenue driver at $149-159) requires the native app. Do not prioritize PWA until post-launch.

---

## 10. Estimated Development Cost and Timeline

### Cost breakdown (React Native, single codebase, iOS + Android)

| Component | Estimate | Hours |
|-----------|----------|-------|
| Chat UI (Stream-based, iMessage styling) | $8-12K | 80-120h |
| Message scheduling engine + local playback | $6-10K | 60-100h |
| Push notifications (APNs + FCM, rich) | $4-6K | 40-60h |
| Offline-first (WatermelonDB, pre-load, sync) | $5-8K | 50-80h |
| BLE / Lovense integration | $6-10K | 60-100h |
| Audio playback (voice notes, binaural) | $3-5K | 30-50h |
| Deep linking + SMS triggers | $2-3K | 20-30h |
| Authentication + cohort management | $4-6K | 40-60h |
| Self-hosted API integration | $5-8K | 50-80h |
| Admin panel (content management) | $5-8K | 50-80h |
| Testing, QA, App Store submission | $5-8K | 50-80h |
| **Total** | **$53-84K** | **530-840h** |

### The $60K line in the deck

**Tight but achievable** if:
- You hire a senior React Native freelancer at $60-80/hr (North American rate) who has BLE experience.
- You use Stream Chat's UI components rather than building from scratch.
- Admin panel is minimal (content upload + cohort management only).
- No scope creep.

**Risks to $60K target:**
- BLE integration with Lovense is the highest-risk line item. If the developer has no BLE experience, add $5-10K for learning curve.
- "iMessage-exact" styling obsession can eat budget. Define "good enough" early.
- Audio/binaural requires specific expertise. May need a separate audio engineer consultation ($2-3K).

### Timeline

| Phase | Duration | Notes |
|-------|----------|-------|
| Architecture + setup | 2 weeks | Tech stack, project structure, CI/CD |
| Chat UI + message engine | 4-5 weeks | Core experience. Can demo after this. |
| Push + offline + sync | 3-4 weeks | Can overlap with chat UI |
| BLE integration | 3-4 weeks | Highest risk. Start prototype early. |
| Audio playback | 2 weeks | Parallelize with BLE |
| Admin panel + API | 3-4 weeks | Can start early if API spec is ready |
| Testing + polish | 3-4 weeks | Device testing, App Store prep |
| **Total** | **12-16 weeks** | With 1 senior dev full-time |

**With 2 developers:** 8-12 weeks (one on chat/UI, one on BLE/push/offline).

### Hiring recommendation

- **Senior React Native freelancer with BLE experience.** This is the critical filter. Chat UI developers are common; BLE developers who also do React Native are rare.
- **Rate:** $60-100/hr USD for the right person. $40-60/hr from Eastern Europe or Latin America.
- **Where to find:** Toptal (vetted, expensive), Arc.dev, React Native-specific job boards, or direct outreach to contributors of react-native-ble-plx.
- **Avoid:** Agencies quoting $150K+ for "enterprise chat app." This is a content delivery app with a chat skin, not a real-time messaging platform with user-generated content.

---

## Key Technical Risks

### 1. BLE reliability across device fragmentation (HIGH)
Android BLE stacks vary wildly by manufacturer. Samsung, Pixel, and OnePlus behave differently. Lovense firmware versions change GATT UUIDs. **Mitigation:** Test on 5+ Android devices early. Build device compatibility matrix. Keep Lovense firmware version detection in the adapter layer.

### 2. App Store rejection for erotic content (HIGH)
Apple's App Store Review Guidelines 1.1.4: apps with sexual content can be rejected. Lovense's own app navigates this by being classified as a "health" app. **Mitigation:** Content API is self-hosted (not bundled in app binary). App is a "literary fiction reader." Erotic content loads dynamically. Haptic integration framed as "accessibility feature." Review existing erotic fiction apps (Literotica, Dipsea) for precedent. [See also: ref-app-store-erotic-content-kill-test.md]

### 3. Lovense protocol changes (MEDIUM)
Lovense could change BLE GATT UUIDs or command format in firmware updates. **Mitigation:** Abstract the protocol behind a versioned adapter. Monitor buttplug.io's Lovense protocol docs for changes. Stock a few devices at known firmware versions for testing.

### 4. Push notification delivery at scale (MEDIUM)
100+ notifications/day per user for 10,000 users = 1M+ notifications/day. APNs and FCM can handle this, but your sending infrastructure needs to be robust. **Mitigation:** Use a push notification service (OneSignal, Pusher, or raw APNs/FCM with a queue). Rate limit per-user to avoid spam classification.

### 5. Offline-to-online sync conflicts (LOW)
If a user is offline for multiple days, catch-up logic needs to deliver messages in order without overwhelming the UI. **Mitigation:** Cap catch-up to one day at a time. Show "You have 3 days to catch up" with a day selector.

---

## Architecture Summary

```
┌─────────────────────────────────────────────────┐
│                 React Native App                 │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌───────────────┐ │
│  │ Chat UI  │  │  Audio   │  │  BLE/Lovense  │ │
│  │ (Stream) │  │  Player  │  │   Adapter     │ │
│  └────┬─────┘  └────┬─────┘  └───────┬───────┘ │
│       │              │                │          │
│  ┌────┴──────────────┴────────────────┴───────┐ │
│  │        Message Scheduling Engine            │ │
│  │     (local timer, haptic sync, jitter)      │ │
│  └────────────────┬───────────────────────────┘ │
│                   │                              │
│  ┌────────────────┴───────────────────────────┐ │
│  │         WatermelonDB (SQLite)               │ │
│  │    Pre-loaded messages, audio refs,         │ │
│  │    haptic patterns, subscriber state        │ │
│  └────────────────┬───────────────────────────┘ │
└───────────────────┼─────────────────────────────┘
                    │ (daily sync)
        ┌───────────┴───────────┐
        │   Self-Hosted API     │
        │  (erotic content VPS) │
        │  Messages, audio,     │
        │  haptic patterns      │
        └───────────┬───────────┘
                    │
        ┌───────────┴───────────┐
        │   Firebase            │
        │  Auth, subscriber     │
        │  state, cohort mgmt,  │
        │  device tokens        │
        └───────────────────────┘
```

---

## Sources

- [React Native BLE in 2026 (Medium)](https://react-developer.medium.com/react-native-in-2026-shipping-bulletproof-bluetooth-ble-companion-apps-scanning-c01e962bd71e)
- [Native vs. Cross-Platform for BLE (Novel Bits)](https://novelbits.io/native-vs-cross-platform-bluetooth-low-energy-mobile-app-platforms/)
- [Flutter vs React Native 2026 (Tech Insider)](https://tech-insider.org/flutter-vs-react-native-2026/)
- [Stream Chat React Native SDK](https://github.com/GetStream/stream-chat-react-native)
- [Stream iMessage Clone Sample](https://getstream.io/blog/imessage-react-native/)
- [React Native Gifted Chat](https://github.com/FaridSafi/react-native-gifted-chat)
- [react-native-ble-plx](https://github.com/dotintent/react-native-ble-plx)
- [Lovense BLE Protocol (stpihkal/buttplug.io)](https://buttplug.io/stpihkal/protocols/lovense/)
- [Lovense Hardware Protocol Docs](https://metafetish.gitbooks.io/stpihkal/hardware/lovense.html)
- [Lovense BLE Protocol Gist](https://gist.github.com/lumpenspace/fa371d44498d2668b1794bc3d520c072)
- [Lovense Android SDK](https://github.com/lovense/Lovense-Android-SDK)
- [react-native-typing-animation](https://github.com/watadarkstar/react-native-typing-animation)
- [WatermelonDB](https://github.com/Nozbe/WatermelonDB)
- [Offline-First React Native with WatermelonDB (Supabase)](https://supabase.com/blog/react-native-offline-first-watermelon-db)
- [FlashList v2 (Shopify Engineering)](https://shopify.engineering/flashlist-v2)
- [React Native App Development Cost 2026](https://diligentic.com/blog/app-development-cost)
- [Expo Deep Linking Docs](https://docs.expo.dev/linking/overview/)
- [PWA iOS Limitations 2026](https://www.magicbell.com/blog/pwa-ios-limitations-safari-support-complete-guide)
- [Hooked Chat Fiction (TechCrunch)](https://techcrunch.com/2015/09/17/hooked/)
- [iOS Rich Notifications (Braze)](https://www.braze.com/docs/user_guide/message_building_by_channel/push/ios/rich_notifications)
- [FlatList Optimization (React Native Docs)](https://reactnative.dev/docs/optimizing-flatlist-configuration)
