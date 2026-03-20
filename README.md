# ck — Context Keeper

> **Never lose your place across Claude Code sessions.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude-Code-blueviolet)](https://claude.ai/code)
[![Version](https://img.shields.io/badge/version-1.1.0-blue)](CHANGELOG.md)

---

## The Problem

You're deep in a project with Claude Code. You've made decisions, built context, found the right approach. Then you close the terminal. Next session — **blank slate**. You're re-explaining everything from scratch. Multiply this by every project you're juggling.

**ck fixes this.**

---

## What It Does

ck gives Claude Code **persistent, per-project memory** that survives across sessions. It automatically loads your project context when you open Claude, so you can pick up exactly where you left off — in any project, from any terminal.

```
┌─────────────────────────────────────────────────────────┐
│  RESUMING: my-saas-app                                  │
│  Last session: 2 days ago  |  Sessions: 12             │
├─────────────────────────────────────────────────────────┤
│  GOAL     → Launch payment flow with Stripe             │
│  LEFT OFF → Debugging webhook signature verification    │
│  NEXT     → Test with Stripe CLI: stripe listen         │
│  BLOCKERS → None                                        │
└─────────────────────────────────────────────────────────┘
```

---

## Install

```bash
curl -sSL https://raw.githubusercontent.com/sreedhargs89/context-keeper/main/install.sh | bash
```

That's it. One command. No dependencies beyond Node.js (already required by Claude Code).

---

## Commands

| Command | What It Does |
|---------|-------------|
| `/ck:init` | Register current project — guided 4-question setup |
| `/ck:save` | Snapshot this session: goals, decisions, next steps, blockers, one-liner summary |
| `/ck:resume` | Brief me on this project — what was I doing? |
| `/ck:resume <name>` | Load **any** project's context from anywhere |
| `/ck:status` | Portfolio view of all projects with staleness indicators |
| `/ck:forget` | Remove a project's context |

---

## Workflow

### First time in a project
```
/ck:init
```
Claude asks 4 questions and sets everything up.

### End of every session
```
/ck:save
```
Claude analyzes the conversation and saves what matters.

### Start of next session
Context auto-loads via the SessionStart hook. Or run:
```
/ck:resume
```

### Switching between projects
```
/ck:status
```
See all projects at a glance from any terminal:

```
  PROJECT           LAST SEEN      STATUS    CURRENT GOAL               LAST SESSION
  ─────────────────────────────────────────────────────────────────────────────────────────────
  productivity   →  2 hours ago    ●         Build auth flow             Added Stripe webhooks  ← you are here
  saas-starter   →  3 days ago     ◐         Payment integration         Fixed checkout bug
  blog-redesign  →  8 days ago     ○         Redesign homepage           —
  api-client     →  Today          ●         Fix rate limits             Debugged timeout issue
```

Then jump in:
```
/ck:resume saas-starter
```

---

## How It Works

```
~/.claude/
├── skills/ck/
│   ├── SKILL.md                  ← Claude instructions for /ck:* commands
│   └── hooks/
│       └── session-start.mjs     ← Auto-injects context on session start
└── ck/
    ├── projects.json             ← Registry of all known projects
    └── contexts/
        └── <project-name>/
            ├── CONTEXT.md        ← Your living project context
            └── meta.json         ← Metadata (path, dates, session count)
```

**The SessionStart hook** fires every time you open Claude Code. If the current directory is a registered project, it silently injects your `CONTEXT.md` so Claude starts the session already knowing your project.

**The CONTEXT.md** is a structured, human-readable file that Claude reads and writes:

```markdown
# Project: my-saas-app
> Last Session: 2026-03-20 | Sessions: 12

## Current Goal
Launch payment flow with Stripe

## Where I Left Off
Debugging webhook signature verification in app/api/webhooks/stripe/route.ts

## Next Steps
1. Test with Stripe CLI: stripe listen --forward-to localhost:3000/api/webhooks/stripe
2. Handle subscription.updated event
3. Update user plan in database on successful payment

## Decisions Made
| Decision | Why | Date |
|----------|-----|------|
| Stripe over Paddle | Already in Vercel Marketplace | 2026-03-18 |
| Webhooks over polling | Real-time + Stripe recommends it | 2026-03-19 |

## Do Not Do
- Don't use Stripe.js for server-side operations
- Don't store raw card data (use Stripe's payment intents)
```

---

## Uninstall

```bash
curl -sSL https://raw.githubusercontent.com/sreedhargs89/context-keeper/main/uninstall.sh | bash
```

Your project contexts are preserved by default. The uninstaller asks before deleting them.

---

## Requirements

- [Claude Code](https://claude.ai/code) (any version with hook support)
- Node.js 18+ (comes with Claude Code)
- macOS or Linux

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). PRs welcome — especially for:
- Windows support
- `/ck:handoff` — generate shareable team briefings
- Smart compression — auto-summarize old decisions
- `/ck:relate` — cross-project pattern matching

---

## License

MIT — see [LICENSE](LICENSE)

---

Built to solve a real problem. If it helps you, share it.
