# Changelog

All notable changes to ck — Context Keeper will be documented here.

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
