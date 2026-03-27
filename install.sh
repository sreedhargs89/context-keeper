#!/usr/bin/env bash
# ck — Context Keeper
# Installer: sets up skill files, data directories, and registers the SessionStart hook.

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RESET="\033[0m"

CK_SKILL_HOME="$HOME/.claude/skills/ck"
CK_DATA_HOME="$HOME/.claude/ck"
SETTINGS_FILE="$HOME/.claude/settings.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "${BOLD}${CYAN}ck — Context Keeper${RESET}"
echo -e "Never lose your place across Claude Code sessions."
echo ""

# ── 1. Create directories ────────────────────────────────────────────────────
echo "→ Creating directories..."
mkdir -p "$CK_SKILL_HOME/hooks"
mkdir -p "$CK_DATA_HOME/contexts"

# ── 2. Copy skill files ──────────────────────────────────────────────────────
echo "→ Installing skill files..."
cp "$SCRIPT_DIR/SKILL.md" "$CK_SKILL_HOME/SKILL.md"
cp "$SCRIPT_DIR/hooks/session-start.mjs" "$CK_SKILL_HOME/hooks/session-start.mjs"
cp "$SCRIPT_DIR/templates/CONTEXT.md.template" "$CK_DATA_HOME/CONTEXT.md.template"

# ── 3. Initialize projects registry ─────────────────────────────────────────
if [ ! -f "$CK_DATA_HOME/projects.json" ]; then
  echo "→ Creating projects registry..."
  echo "{}" > "$CK_DATA_HOME/projects.json"
fi

# ── 4. Register SessionStart hook in settings.json ───────────────────────────
echo "→ Registering SessionStart hook..."

# Write a temporary Node script to safely merge hook into settings.json
HOOK_REGISTER_SCRIPT=$(mktemp /tmp/ck-install-XXXXXX.mjs)

cat > "$HOOK_REGISTER_SCRIPT" << NODESCRIPT
import { readFileSync, writeFileSync, existsSync } from 'fs';

const settingsPath = process.argv[2];
const hookCmd = process.argv[3];

let settings = {};
if (existsSync(settingsPath)) {
  try {
    settings = JSON.parse(readFileSync(settingsPath, 'utf8'));
  } catch {
    console.log('  Warning: Could not parse existing settings.json — creating fresh.');
    settings = {};
  }
}

if (!settings.hooks) settings.hooks = {};
if (!settings.hooks.SessionStart) settings.hooks.SessionStart = [];

const alreadyRegistered = settings.hooks.SessionStart.some(entry =>
  Array.isArray(entry.hooks) && entry.hooks.some(h => h.command === hookCmd)
);

if (!alreadyRegistered) {
  settings.hooks.SessionStart.push({
    hooks: [{ type: 'command', command: hookCmd }]
  });
  writeFileSync(settingsPath, JSON.stringify(settings, null, 2));
  console.log('  Hook registered successfully.');
} else {
  console.log('  Hook already registered — skipping.');
}
NODESCRIPT

HOOK_CMD="node \"$CK_SKILL_HOME/hooks/session-start.mjs\""
node "$HOOK_REGISTER_SCRIPT" "$SETTINGS_FILE" "$HOOK_CMD"
rm -f "$HOOK_REGISTER_SCRIPT"

# ── 5. Done ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}✓ ck installed successfully!${RESET}"
echo ""
echo -e "  ${BOLD}Get started:${RESET}"
echo -e "  1. Open Claude Code in any project folder"
echo -e "  2. Run ${CYAN}/ck:init${RESET} to register the project"
echo -e "  3. Run ${CYAN}/ck:save${RESET} at the end of each session"
echo -e "  4. Run ${CYAN}/ck:resume${RESET} next time to pick up where you left off"
echo -e "  5. Run ${CYAN}/ck:list${RESET} from anywhere to see all your projects"
echo ""
echo -e "  ${BOLD}Docs:${RESET} https://github.com/sreedhargs89/context-keeper"
echo ""
