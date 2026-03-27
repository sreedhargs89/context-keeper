# ck — Context Keeper

> **Never lose your place across Claude Code sessions.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude-Code-blueviolet)](https://claude.ai/code)
[![Version](https://img.shields.io/badge/version-2.0.0-blue)](CHANGELOG.md)

---

## The Problem

You're deep in a project with Claude Code. You've made decisions, built context, found the right approach. Then you close the terminal. Next session — **blank slate**. You're re-explaining everything from scratch. Multiply this by every project you're juggling.

**ck fixes this.**

---

## What It Does

ck gives Claude Code **persistent, per-project memory** that survives across sessions. It automatically loads your project context when you open Claude — in any project, from any terminal.

```
ck: my-saas-app | 2 days ago | 12 sessions
Goal: Launch payment flow with Stripe
Left off: Debugging webhook signature verification in route.ts
Next: Test with Stripe CLI · Handle subscription.updated event
⚠  3 commits since last session
```

Context loads in ~100 tokens (not kilobytes). Fast, focused, always current.

---

## Install

```bash
curl -sSL https://raw.githubusercontent.com/sreedhargs89/context-keeper/main/install.sh | bash
```

One command. No dependencies beyond Node.js (already required by Claude Code).

**Upgrading from v1?** The installer detects your existing data and tells you to run `/ck:migrate` — your contexts are converted automatically, nothing is deleted.

---

## Commands

| Command | What It Does |
|---------|-------------|
| `/ck:init` | Register current project — auto-detects stack, goal, repo from your files |
| `/ck:save` | Snapshot this session: what you did, decisions, next steps, blockers |
| `/ck:resume` | Full briefing on this project — what was I doing? |
| `/ck:resume <name or #>` | Load **any** project's context by name or number |
| `/ck:info` | Quick read-only snapshot — no questions, just display |
| `/ck:info <name or #>` | Quick snapshot of any project from anywhere |
| `/ck:list` | Portfolio view of all projects |
| `/ck:forget` | Remove a project's context |
| `/ck:migrate` | Convert v1 data (CONTEXT.md + meta.json) to v2 (context.json) |

---

## Workflow

### First time in a project
```
/ck:init
```
Claude runs a script that auto-detects your project info (stack, goal, repo) from existing files and shows a pre-filled draft. Confirm or edit — done in seconds.

### End of every session
```
/ck:save
```
Claude analyzes the conversation and saves what matters: summary, what you left off, next steps, decisions, blockers. Git activity is captured automatically.

### Start of next session
Context auto-loads via the SessionStart hook. Or run:
```
/ck:resume
```

### Switching between projects
```
/ck:list
```
See all projects in a numbered table. Reply with a number or name to jump straight in.

---

## How It Works

### Architecture

```
~/.claude/
├── skills/ck/
│   ├── SKILL.md              ← Thin instructions: "run these scripts"
│   ├── commands/             ← Deterministic Node.js scripts
│   │   ├── init.mjs          ← Auto-detect project info → JSON
│   │   ├── save.mjs          ← Write session to context.json
│   │   ├── resume.mjs        ← Render full briefing box
│   │   ├── info.mjs          ← Render compact snapshot
│   │   ├── list.mjs          ← Render portfolio table
│   │   ├── forget.mjs        ← Remove project context
│   │   ├── migrate.mjs       ← Convert v1 → v2
│   │   └── shared.mjs        ← Shared utilities and renderers
│   └── hooks/
│       └── session-start.mjs ← Auto-injects context on session start
└── ck/
    ├── projects.json          ← Registry of all known projects
    └── contexts/
        └── <project-name>/
            ├── context.json   ← SOURCE OF TRUTH (structured JSON)
            └── CONTEXT.md     ← Generated view (human-readable)
```

### Key design decisions

**`context.json` is the source of truth.** CONTEXT.md is generated from it automatically — never hand-edited. This makes saves deterministic and enables session history, git tracking, and native memory integration.

**Commands are real scripts.** Every `/ck:*` command runs a Node.js script. Claude's only job is to pass the right data and display the output. Behavior is consistent across model versions.

**~100 token injection.** The SessionStart hook injects a compact 5-line summary — not the full context file. Claude loads what it needs when asked, not everything upfront.

**Session tracking.** Each save gets a unique session ID. The hook detects if your last session wasn't saved and warns you.

**Git activity.** Saves automatically capture how many commits happened since the last session.

**Native memory integration.** Each save writes a memory entry to `~/.claude/projects/*/memory/` — Claude Code's native memory system — so decisions surface across sessions even without explicitly running `/ck:resume`.

---

## Data Format

### context.json (source of truth)
```json
{
  "version": 2,
  "name": "my-saas-app",
  "path": "/Users/you/dev/my-saas-app",
  "description": "SaaS app with Stripe payments",
  "stack": ["Next.js", "Neon", "Clerk", "Stripe"],
  "goal": "Launch payment flow with Stripe",
  "constraints": ["Don't use Stripe.js server-side"],
  "repo": "https://github.com/you/my-saas-app.git",
  "createdAt": "2026-03-18",
  "sessions": [
    {
      "id": "a3f2b1c0",
      "date": "2026-03-25",
      "summary": "Debugged webhook signature verification",
      "leftOff": "Debugging webhook signature verification in route.ts",
      "nextSteps": ["Test with Stripe CLI", "Handle subscription.updated"],
      "decisions": [{"what": "Webhooks over polling", "why": "Real-time + Stripe recommends it"}],
      "blockers": [],
      "gitActivity": "3 commits, 5 files changed"
    }
  ]
}
```

### CONTEXT.md (generated — read-only)
The human-readable view, regenerated on every save. Useful for diffing in git or reading outside Claude.

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

## Upgrading from v1

The installer detects existing v1 data automatically. After upgrading:

```
/ck:migrate
```

This converts all your `CONTEXT.md` + `meta.json` files to `context.json` v2 format. Originals are backed up as `meta.json.v1-backup`. Run with `--dry-run` first to preview.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). PRs welcome.

---

## License

MIT — see [LICENSE](LICENSE)

---

Built to solve a real problem. If it helps you, share it.
