# Changelog

All notable changes to ck — Context Keeper will be documented here.

## [1.3.0] — 2026-03-27

### Fixed
- `SessionStart` hook no longer injects `SKILL.md` on every session start — eliminates ~12KB of unnecessary token cost per session on sessions where no `/ck:*` commands are used
- `buildMiniStatus` (shown in unregistered directories) now reads only `meta.json` per project instead of loading the full `CONTEXT.md` — eliminates O(n) file reads on session start
- Mini-status footer referenced `/ck:status` (removed in v1.2.0) — corrected to `/ck:list`

### Changed
- `meta.json` schema now includes a `goal` field — set on `/ck:init`, updated on `/ck:save` — so the `/ck:list` Bash command no longer needs to grep CONTEXT.md
- `/ck:list` Bash command simplified to read only `meta.json` per context dir (faster, cleaner)
- `Decisions Made` table removed from default CONTEXT.md template — now optional (add it only if you want to track decisions; SKILL.md still supports it when present)
- README: fixed `/ck:list` example showing broken ASCII approximations (`*`, `o`, `<-`) — now shows actual characters (`●`, `◐`, `←`)

## [1.2.0] — 2026-03-21

### Added
- `/ck:info` command — quick read-only context snapshot, no prompts, no follow-up questions
- `/ck:info <name or #>` — view any project's context by name or number from anywhere
- `/ck:list` command — replaces `/ck:status` with numbered ASCII-bordered table (`+`/`-`/`|`)
- Number-based project selection — `/ck:resume 2`, `/ck:info 3` pick by alphabetical row number
- `/ck:list` auto-chains into `/ck:resume` — reply with a number or name to jump straight in
- `/ck:resume` briefing now shows PATH (always) and REPO (if set) in the header block
- `meta.json` now stores optional `repo` field
- `CONTEXT.md` template now has optional `> Repo:` header line

### Changed
- `/ck:init` now auto-detects project info from `README.md`, `package.json`, `.git/config`, etc. and presents a pre-filled draft to confirm instead of asking questions one at a time
- `/ck:status` renamed to `/ck:list`
- `/ck:list` uses ASCII `+`/`-`/`|` borders instead of unicode box-drawing characters (universally supported)
- `/ck:resume`, `/ck:info`, `/ck:list` all use a single Bash call to collect all data (faster, fewer tool calls)
- SessionStart hook shows mini portfolio of 3 most recent projects when in an unregistered directory

## [1.1.0] — 2026-03-20

### Added
- `/ck:save` now generates a one-liner session summary — auto-generated with option to confirm or edit before saving
- `/ck:status` now shows a `LAST SESSION` column so you instantly see what happened last session

## [1.0.0] — 2026-03-20

### Added
- `/ck:init` — guided project registration with 4-question setup
- `/ck:save` — snapshot session state (goals, decisions, next steps, blockers)
- `/ck:resume` — project briefing on session start
- `/ck:resume <name>` — load any project's context from anywhere
- `/ck:status` — portfolio view of all projects with staleness indicators
- `/ck:forget` — remove a project's context cleanly
- `SessionStart` hook — auto-injects project context when Claude opens in a registered folder
- `CONTEXT.md` schema — structured, human-readable per-project context file
- `install.sh` — one-command installer with hook registration
- `uninstall.sh` — clean removal with optional data preservation
