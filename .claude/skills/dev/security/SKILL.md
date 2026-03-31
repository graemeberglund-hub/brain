---
name: security
description: "Dual-mode security audit — daily (high-confidence only) or comprehensive (monthly deep scan). Use when user says 'security', 'security audit', or before shipping."
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(git log*), Bash(git diff*), Bash(npm audit*), Bash(pip audit*), Bash(bun audit*), Bash(cat package.json), Bash(cat requirements*.txt), Bash(cat pyproject.toml), Bash(ls *), Bash(wc *), Bash(find *), Agent, AskUserQuestion
argument-hint: "[optional: --comprehensive | --daily (default) | file paths]"
---

input = $ARGUMENTS

Today's date: !`date +%Y-%m-%d`
Repo root: !`git rev-parse --show-toplevel`
Repo name: !`basename $(git rev-parse --show-toplevel)`

# /security — Dual-Mode Security Audit

## Mode Selection

Check `input` for mode flag:
- `--comprehensive` → Comprehensive mode (confidence gate: 2/10, monthly cadence)
- `--daily` or no flag → Daily mode (confidence gate: 8/10, per-session cadence)

## Phase 1: Stack Detection

Identify the project's technology stack:
- Languages: check file extensions, shebang lines, config files
- Frameworks: package.json (Node), requirements.txt/pyproject.toml (Python), Cargo.toml (Rust), go.mod (Go)
- Deployment: Dockerfile, docker-compose, Procfile, serverless.yml, vercel.json, fly.toml
- Database: connection strings, ORM configs, migration files
- Auth: JWT, OAuth, session management, API key patterns

Output a one-paragraph stack summary. This scopes all subsequent phases.

## Phase 2: Attack Surface Census

Count and catalog:
- **Endpoints**: API routes, server handlers, webhook receivers
- **Auth boundaries**: which endpoints require auth, which are public
- **Background jobs**: cron, workers, daemons, scheduled tasks
- **File operations**: uploads, downloads, file writes, temp file creation
- **External calls**: HTTP clients, SDK calls, subprocess invocations
- **User input paths**: forms, query params, headers, cookies, file content

This is a map, not an assessment. No findings yet — just inventory.

## Phase 3: Secrets Archaeology

Scan for hardcoded secrets and credential leaks:

1. **Current state**: grep for patterns:
   - API keys: `[A-Za-z0-9_-]{20,}` near `key`, `token`, `secret`, `password`, `api_key`
   - Connection strings: `postgres://`, `mysql://`, `mongodb://`, `redis://`
   - AWS: `AKIA[A-Z0-9]{16}`
   - Private keys: `-----BEGIN (RSA |EC )?PRIVATE KEY-----`
   - JWT secrets: hardcoded strings assigned to `JWT_SECRET`, `SECRET_KEY`

2. **Config files**: check `.env.example`, `.env.local`, config files for real vs placeholder values

3. **Git history** (daily mode: last 20 commits only; comprehensive: full history):
   ```
   git log --all --diff-filter=A --name-only -- '*.env' '*.pem' '*.key' 2>/dev/null
   ```

### False positive exclusions
- Test fixtures with obviously fake values (`test-key-123`, `password123`, `sk-test-*`)
- Example values in documentation or README
- Base64-encoded non-secrets (data URIs, encoded config)
- Placeholder patterns (`YOUR_API_KEY_HERE`, `<token>`, `xxx`)
- Dev-only `.env.example` files with placeholder values
- Self-signed certs in dev config directories
- Localhost-only connection strings

## Phase 4: Supply Chain

Check dependency health:

1. **Known vulnerabilities**: run the appropriate audit command:
   - Node: `npm audit --json 2>/dev/null` or `bun audit 2>/dev/null`
   - Python: `pip audit --format json 2>/dev/null` (if installed)
   - Check for lockfile existence (missing lockfile = critical in daily mode)

2. **Suspicious packages** (comprehensive mode only):
   - Packages with post-install scripts
   - Packages with <100 weekly downloads
   - Packages last published >2 years ago

3. **Lockfile integrity**: does lockfile match package manifest?

## Phase 5: OWASP Top 10 (comprehensive mode only)

Skip in daily mode. In comprehensive mode, systematically check each category:

1. **Injection** — SQL, NoSQL, OS command, LDAP injection in user input paths
2. **Broken Authentication** — weak password policies, credential stuffing vectors, session fixation
3. **Sensitive Data Exposure** — unencrypted PII at rest/transit, verbose error messages with stack traces
4. **XML External Entities (XXE)** — XML parsing without disabling external entities
5. **Broken Access Control** — missing authorization checks, IDOR, directory traversal
6. **Security Misconfiguration** — default credentials, unnecessary features enabled, missing security headers
7. **XSS** — reflected, stored, DOM-based cross-site scripting
8. **Insecure Deserialization** — untrusted data deserialized without validation
9. **Using Components with Known Vulnerabilities** — covered by Phase 4 supply chain
10. **Insufficient Logging & Monitoring** — security events not logged, no alerting

For each finding, note the OWASP category in the output.

## Phase 6: STRIDE Threat Model (comprehensive mode only)

Skip in daily mode. For each component identified in Phase 2 (attack surface census):

| Threat | Question |
|--------|----------|
| **Spoofing** | Can an attacker impersonate a user or service? |
| **Tampering** | Can data be modified in transit or at rest? |
| **Repudiation** | Can actions be performed without audit trail? |
| **Information Disclosure** | Can sensitive data leak through errors, logs, or timing? |
| **Denial of Service** | Can the service be overwhelmed or resource-exhausted? |
| **Elevation of Privilege** | Can a low-privilege user gain higher access? |

Document threats per component. Only flag as findings those with concrete exploit paths (not theoretical).

## Phase 7: Active Verification (comprehensive mode only)

For each finding with confidence >= 5, spawn an Agent to independently verify:
1. Agent reads the flagged code in isolation
2. Attempts to construct a concrete exploit scenario
3. If the agent cannot construct a plausible exploit → downgrade confidence by 2
4. If the agent confirms → keep or upgrade confidence

Discard any finding that falls below the mode's confidence gate after verification.

## Confidence Gating

For each finding, assign a confidence score (1-10):
- **10**: Confirmed exploitable (e.g., hardcoded real API key in committed code)
- **8-9**: Very likely exploitable, standard attack vector applies
- **5-7**: Suspicious pattern, needs context to determine exploitability
- **2-4**: Possible issue, theoretical risk, or defense-in-depth concern
- **1**: Noise, style preference, or extremely unlikely scenario

**Daily mode** (default): only report findings with confidence >= 8.
**Comprehensive mode**: report all findings with confidence >= 2.

## Phase 5: Report

Write findings to `knowledge/security-reports/{date}-{HHMMSS}.json`:
```json
{
  "timestamp": "ISO8601",
  "repo": "repo-name",
  "mode": "daily|comprehensive",
  "stack": "one-line summary",
  "findings": [
    {
      "id": "SEC-001",
      "severity": "critical|high|medium|low|info",
      "confidence": 8,
      "category": "secrets|supply-chain|auth|injection|config",
      "file": "path/to/file",
      "line": 42,
      "description": "what was found",
      "exploit_scenario": "how an attacker would use this",
      "remediation": "what to do about it"
    }
  ],
  "attack_surface": {
    "endpoints": 12,
    "auth_boundaries": 3,
    "public_endpoints": 4,
    "file_operations": 2,
    "external_calls": 7
  },
  "summary": "one-line verdict"
}
```

Create `knowledge/security-reports/` directory if it doesn't exist.

## Phase 6: Console Report

```
SECURITY — {repo} ({mode} mode) at {timestamp}

Stack: {one-line summary}
Attack surface: {endpoints} endpoints, {auth_boundaries} auth boundaries

FINDINGS: {N} ({critical} critical, {high} high, {medium} medium)
{table of findings if any}

{if zero findings in daily mode: "Clear for shipping."}
{if findings: list with file:line, description, remediation}

Report: knowledge/security-reports/{filename}
```
