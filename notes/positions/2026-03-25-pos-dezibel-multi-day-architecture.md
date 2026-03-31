---
title: "Multi-day delivery: one session gated by time vs session-per-day"
type: position
classification: question
testable: true
stage: open
confidence: exploring
tags: [dezibel, tech, architecture, platform]
created: 2026-03-25
updated: 2026-03-25
area: "[[writing-and-film]]"
related_positions: ["[[dezibel-launch-timeline]]"]
suggested_tests: ["Get Ryan Holmes input on technical tradeoffs", "Prototype both approaches with Firebase schema", "Test cron reliability for 42 consecutive days"]
resolution: null
---

## Context

The single most impactful technical decision remaining. Does each of the 42 days = a new session with its own script.json, or does one long-running session deliver content day-by-day gated by real-world time? This affects Firebase schema, cron design, error handling, payment gating, and every subsequent engineering decision.

Plan-to-launch says: "Get Ryan Holmes' input on this before choosing." Ryan Holmes hasn't been contacted in a year.

## Evidence So Far

- Demo is functional for Day 1 (single session model)
- No prototype exists for multi-day delivery
- $60k tech budget assumes this decision is resolved before building
- [[kill-test-full-project]] — A4 confirms architecture unresolved, adds Android/SMS degradation as urgency factor: 45% of market gets degraded experience without iMessage features (2026-03-26, via /digest)

## Resolution
(empty until resolved)
