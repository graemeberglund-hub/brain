---
name: ingest
description: Thin dispatcher for ingesting content into the vault. Routes to the right extraction skill based on declared type. Use when user says "ingest {type} {path}".
allowed-tools: Read, Glob, Bash(date *), Bash(ls *), Skill
argument-hint: "{type} {path} — types: llm, youtube, phone/call, article/paper"
---

input = $ARGUMENTS

# /ingest — Content Ingestion Dispatcher

Parse the input to extract `{type}` and `{path}`.

## Routing table

| Type keyword(s) | Skill to invoke | Pass as argument |
|---|---|---|
| `youtube`, `yt` | `youtube` | the URL or path |
| `llm`, `gpt`, `claude`, `gemini`, `chatgpt`, `model` | `llm` | the path |
| `phone`, `call`, `voice`, `audio`, `conversation` | `transcribe` | the path |
| `article`, `paper`, `url`, `link`, `tool` | `reference` | the URL or path |
| `pinterest`, `pins`, `boards` | `pinterest` | the image path(s) and any --board-name args |

## Execution

1. Match the first word of input against the type keywords above (case-insensitive)
2. The remainder of input after the type keyword is the path/URL argument
3. Invoke the matched skill with the path/URL as its argument
4. If no type keyword matches, tell the user: "Unknown ingest type. Available: llm, youtube, phone, article"
5. If no path provided, tell the user: "Usage: /ingest {type} {path}"

Do NOT do any extraction work yourself. Just route.
