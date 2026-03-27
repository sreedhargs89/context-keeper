# ck — Context Keeper

> **Never lose your place across Claude Code sessions.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude-Code-blueviolet)](https://claude.ai/code)
[![Version](https://img.shields.io/badge/version-1.3.0-blue)](CHANGELOG.md)

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
│  → cd /Users/you/dev/my-saas-app  ✓                    │
├─────────────────────────────────────────────────────────┤
│  WHAT IT IS  → SaaS app with Stripe payments            │
│  STACK       → Next.js, Neon, Clerk, Stripe             │
│  PATH        → /Users/you/dev/my-saas-app               │
│  REPO        → https://github.com/you/my-saas-app.git  │
│  GOAL        → Launch payment flow with Stripe          │
├─────────────────────────────────────────────────────────┤
│  WHERE I LEFT OFF                                       │
│    • Debugging webhook signature verification           │
├─────────────────────────────────────────────────────────┤
│  NEXT STEPS                                             │
│    1. Test with Stripe CLI: stripe listen               │
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
| `/ck:init` | Register current project — auto-detects info, shows pre-filled draft to confirm |
| `/ck:save` | Snapshot this session: goals, decisions, next steps, blockers, one-liner summary |
| `/ck:resume` | Full briefing on this project — what was I doing? |
| `/ck:resume <name or #>` | Load **any** project's context by name or number from anywhere |
| `/ck:info` | Quick read-only context snapshot — no questions, just display |
| `/ck:info <name or #>` | Quick snapshot of any project by name or number |
| `/ck:list` | Portfolio view of all projects with numbered rows |
| `/ck:forget` | Remove a project's context |

---

## Workflow

### First time in a project
```
/ck:init
```
Claude auto-detects your project info (stack, goal, repo) from existing files and shows a pre-filled draft. Confirm or edit — done in seconds.

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

### Quick mid-session check
```
/ck:info
```
Read-only snapshot of where you are — no prompts, no questions. Also works from any directory:
```
/ck:info saas
```

### Switching between projects
```
/ck:list
```
See all projects at a glance with numbered rows:

```
  +---+------------------------+----------+-----------+-------------------------------------------------------+
  | # | Project                | Status   | Last Seen | Last Session                                          |
  +---+------------------------+----------+-----------+-------------------------------------------------------+
  | 1 | clipboard-rewriter-pro | ● Active | Today     | Created local/no-payments branch, stripped payments   |
  | 2 | context-keeper         | ● Active | Today     | Pushed all changes to GitHub, commit 287c720          |
  | 3 | productivity           | ◐ Warm   | 1 day ago | Built Context Keeper skill, needs publishing          |
  | 4 | my-saas-app        ←   | ◐ Warm   | 2 days ago| Debugging Stripe webhook signature verification       |
  +---+------------------------+----------+-----------+-------------------------------------------------------+
```

Reply with a number or name to jump straight in:
```
Resume which? (1 / 2 / 3 / 4 or name)
> 2
```
ck immediately runs the full `/ck:resume` briefing for that project.

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
            └── meta.json         ← Metadata (path, repo, dates, session count)
```

**The SessionStart hook** fires every time you open Claude Code. If the current directory is a registered project, it injects your `CONTEXT.md` so Claude starts the session already knowing your project. If you're in an unregistered directory, it shows your 3 most recent projects as a quick reference.

**The CONTEXT.md** is a structured, human-readable file that Claude reads and writes:

```markdown
# Project: my-saas-app
> Path: /Users/you/dev/my-saas-app
> Repo: https://github.com/you/my-saas-app.git
> Last Session: 2026-03-20 | Sessions: 12

## Current Goal
Launch payment flow with Stripe

## Where I Left Off
Debugging webhook signature verification in app/api/webhooks/stripe/route.ts

## Next Steps
1. Test with Stripe CLI: stripe listen --forward-to localhost:3000/api/webhooks/stripe
2. Handle subscription.updated event
3. Update user plan in database on successful payment

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
