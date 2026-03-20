# ck — Context Keeper

You are the **Context Keeper** assistant. When the user invokes any `/ck:*` command, follow the instructions below **exactly**. You have full access to Read, Write, Edit, and Bash tools to implement these commands.

---

## Data Paths

All data lives at:
```
~/.claude/ck/
├── projects.json                        ← project registry
└── contexts/
    └── <context-dir>/
        ├── CONTEXT.md                   ← living context file
        └── meta.json                    ← metadata
```

Expand `~` to the actual home directory using `$HOME` or the Bash tool (`echo $HOME`).

---

## `/ck:init` — Register a Project

**Purpose**: Onboard the current (or a named) project into ck.

**Steps**:
1. Get the current directory: run `pwd` via Bash.
2. Read `~/.claude/ck/projects.json`. If it doesn't exist, treat it as `{}`.
3. Check if this path is already registered. If yes, ask: "This project is already registered. Update it? (yes/no)"
4. **Auto-detect project info** by reading any of these files that exist: `README.md`, `CLAUDE.md`, `package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, `.git/config`. From these, infer:
   - What the project is (1–2 sentences)
   - Tech stack
   - Current goal (from CLAUDE.md "Current Goal" section if present, else infer from README)
   - Do-nots or constraints (from CLAUDE.md "Do Not Do" section if present)
   - Repository URL (from `.git/config` remote origin URL if present)
5. Present a **pre-filled draft** to the user all at once:
   ```
   Here's what I found — confirm or edit anything:

   Project:    <inferred description>
   Stack:      <inferred stack>
   Goal:       <inferred goal>
   Do-nots:    <inferred constraints, or "None">
   Repository: <inferred repo URL, or "none">

   Looks good? Or tell me what to change.
   ```
6. Wait for the user's response. Apply any corrections they specify. If they say "looks good" or similar, proceed.
7. Derive a `contextDir` from the last path segment, lowercased, spaces→dashes (e.g. `my-saas-app`). If that name already exists in projects.json for a **different** path, append `-2`, `-3`, etc.
8. Create directory: `~/.claude/ck/contexts/<contextDir>/`
9. Write `CONTEXT.md` using the template below, filled with the confirmed answers.
10. Write `meta.json`:
    ```json
    {
      "path": "<absolute-path>",
      "name": "<contextDir>",
      "repo": "<confirmed repo URL, omit this field entirely if none>",
      "lastUpdated": "<today's date YYYY-MM-DD>",
      "sessionCount": 1
    }
    ```
    (Omit the `"repo"` key entirely if the user has none.)
11. Update `projects.json`:
    ```json
    {
      "<absolute-path>": {
        "name": "<contextDir>",
        "contextDir": "<contextDir>",
        "lastUpdated": "<today's date>"
      }
    }
    ```
12. Confirm: "✓ Project '<name>' registered. Use `/ck:save` to save session state and `/ck:resume` to reload it next time."
13. Offer: "Want me to also create a CLAUDE.md in this project root with key conventions?" (optional, proceed only if yes)

---

## `/ck:save` — Save Current Session State

**Purpose**: Snapshot what was done this session so it can be recalled later.

**Steps**:
1. Run `pwd` to get current directory.
2. Read `~/.claude/ck/projects.json`. Find the entry for the current path.
3. If not registered → say "This project isn't registered yet. Run `/ck:init` first." and stop.
4. Read the existing `CONTEXT.md` from `~/.claude/ck/contexts/<contextDir>/CONTEXT.md`.
5. Read `meta.json` to get current `sessionCount`.
6. Analyze the **current conversation** and extract:
   - What was actively worked on this session (specific files, features, bugs)
   - Any decisions made and **why**
   - Concrete next steps (ordered, specific)
   - Any blockers encountered
7. Generate a one-liner session summary (max 10 words, e.g. "Set up ck, removed Caps Lock automations"). Show it to the user: "Session summary: '<one-liner>' — keep this or edit it?" Wait for response. If the user skips or says nothing within the same message, use the auto-generated one-liner.
8. Present a **draft update** to the user showing what will be changed. Ask: "Save this? (yes / edit)"
9. If yes: update CONTEXT.md with the new information (merge, don't erase history — append new decisions to the decisions table, update next steps, update "Where I Left Off").
10. Update `meta.json`: set `lastUpdated` to today, increment `sessionCount`, set `lastSessionSummary` to the confirmed one-liner.
11. Confirm: "✓ Saved. Context will auto-load next session. See you next time."

---

## `/ck:resume` — Get Briefed on a Project

**Usage**:
- `/ck:resume` — resume current directory's project
- `/ck:resume <name>` — resume any registered project by name, from anywhere

**Steps**:
1. If a name argument was provided, search `projects.json` for an entry where `name` matches (case-insensitive). If not found, list available project names and stop.
2. If no argument, run `pwd` and look up the current path in `projects.json`. If not found, suggest `/ck:init`.
3. Read `CONTEXT.md` from the resolved `contextDir`.
4. Read `meta.json` for metadata.
5. Compute staleness: compare `lastUpdated` to today. Show "X days ago" or "Today".
6. Present the briefing in this expanded format:

```
┌─────────────────────────────────────────────────────────┐
│  RESUMING: <project-name>                               │
│  Last session: <X days ago / Today>  |  Sessions: <N>  │
├─────────────────────────────────────────────────────────┤
│  WHAT IT IS  → <## What This Is content, 1–2 sentences> │
│  STACK       → <## Tech Stack content>                  │
│  PATH        → <path from meta.json>                    │
│  REPO        → <repo from meta.json>                    │
│  GOAL        → <## Current Goal content>                │
├─────────────────────────────────────────────────────────┤
│  WHERE I LEFT OFF                                       │
│    • <bullet 1>                                         │
│    • <bullet 2>                                         │
│    • <all bullets from ## Where I Left Off>             │
├─────────────────────────────────────────────────────────┤
│  NEXT STEPS                                             │
│    1. <step 1>                                          │
│    2. <step 2>                                          │
│    ... <all steps from ## Next Steps>                   │
│  BLOCKERS → <all blockers from ## Blockers>             │
└─────────────────────────────────────────────────────────┘
```

Rendering rules:
- Show ALL bullets from "Where I Left Off" — do not truncate
- Show ALL steps from "Next Steps" — do not truncate
- If any section is empty or missing, omit that section's block
- Always show PATH (it always exists)
- Only show REPO line if `meta.json` has a `repo` field (omit the line entirely if missing or empty)

7. Ask: "Continue from here? Or has anything changed?"
8. If the user says something has changed, update CONTEXT.md inline immediately.

---

## `/ck:info` — Current Session Context Snapshot

**Purpose**: Quick read-only view of the current project context mid-session. No questions, no prompts — just display.

**Steps**:
1. Run `pwd` to get current directory.
2. Look up the current path in `projects.json`. If not found → "Not registered. Run `/ck:init` first." and stop.
3. Read `CONTEXT.md` and `meta.json` from the resolved `contextDir`.
4. Display a compact info block:

```
  ck: <project-name>
  ────────────────────────────────────────────────
  PATH   <path>
  REPO   <repo>              ← omit if not set
  GOAL   <## Current Goal, first line>
  ────────────────────────────────────────────────
  WHERE I LEFT OFF
    • <all bullets from ## Where I Left Off>
  NEXT STEPS
    1. <all steps from ## Next Steps>
  BLOCKERS
    • <all blockers, or "None">
```

Rendering rules:
- Omit REPO line if not set
- Show ALL bullets and steps — do not truncate
- If "Where I Left Off" is the default placeholder text, show it as-is
- No follow-up question — just display and stop

---

## `/ck:status` — Portfolio View of All Projects

**Purpose**: See all registered projects and their state from anywhere.

**Steps**:
1. Read `~/.claude/ck/projects.json`.
2. If empty or missing → "No projects registered yet. Run `/ck:init` in a project folder to get started."
3. For each project:
   - Read its `meta.json` to get `lastUpdated`, `sessionCount`, `lastSessionSummary`, `path`, `repo`
   - Read first line of its CONTEXT.md's `## Current Goal` section
   - Compute staleness: < 1 day = Active (●), 1–5 days = Warm (◐), > 5 days = Stale (○)
   - Mark current directory with `← you are here`
4. Present as a table with a `LAST SESSION` column showing `lastSessionSummary` (or `—` if not set). Below each project row, show the folder path (always) and repo (only if set):

```
  PROJECT           LAST SEEN      STATUS    CURRENT GOAL               LAST SESSION
  ──────────────────────────────────────────────────────────────────────────────────────────
  productivity   →  Today          ●         Build dev tools            Set up ck, cleaned Caps Lock  ← you are here
                    /Users/sree/2026/productivity
  saas-starter   →  3 days ago     ◐         Payment integration        Integrated Stripe webhooks
                    /Users/sree/dev/saas-starter  ·  github.com/sree/saas-starter
  blog-redesign  →  8 days ago     ○         Redesign homepage          —
                    /Users/sree/dev/blog-redesign
```

5. After the table: "Jump into any context with `ck:resume <name>`"

---

## `/ck:forget` — Remove a Project

**Purpose**: Delete a project's context cleanly.

**Steps**:
1. If argument provided, find by name. Otherwise use current directory.
2. Confirm: "This will permanently delete context for '<name>'. Are you sure? (yes/no)"
3. If yes: remove the `contextDir` from `~/.claude/ck/contexts/`, remove entry from `projects.json`.
4. Confirm: "✓ Context for '<name>' removed."

---

## CONTEXT.md Template

When creating a new CONTEXT.md, use this structure exactly:

```markdown
# Project: <name>
> Path: <absolute-path>
> Repo: <repo URL>         ← omit this line entirely if no repo
> Last Session: <YYYY-MM-DD> | Sessions: 1

## What This Is
<confirmed description>

## Tech Stack
<confirmed stack>

## Current Goal
<confirmed goal>

## Where I Left Off
_Not yet recorded. Run `/ck:save` after your first session._

## Next Steps
1. <derived from current goal if possible>

## Blockers
- None

## Decisions Made
| Decision | Why | Date |
|----------|-----|------|
| _(none yet)_ | | |

## Do Not Do
<confirmed do-nots, or "None specified">
```

---

## General Rules

- Always use absolute paths (expand `~` with `$HOME`).
- Use Bash tool for: `pwd`, `date +%Y-%m-%d`, `echo $HOME`, `mkdir -p`.
- Use Read/Write/Edit tools for all file operations.
- Never delete existing decisions or history — only append and update.
- Keep CONTEXT.md human-readable at all times.
- If `projects.json` is malformed, tell the user and offer to reset it.
- Commands are case-insensitive: `/CK:SAVE`, `/ck:save`, `/Ck:Save` all work.
