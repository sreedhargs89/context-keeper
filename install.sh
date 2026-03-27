#!/usr/bin/env bash
# ck — Context Keeper v2
# Installer: deploys command scripts, hook, and registers the SessionStart hook.

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
echo -e "${BOLD}${CYAN}ck — Context Keeper v2${RESET}"
echo -e "Never lose your place across Claude Code sessions."
echo ""

# ── Detect existing v1 install ───────────────────────────────────────────────
V1_DETECTED=false
if [ -f "$CK_SKILL_HOME/SKILL.md" ] && [ ! -d "$CK_SKILL_HOME/commands" ]; then
  V1_DETECTED=true
  echo -e "${YELLOW}→ Existing v1 install detected. Upgrading to v2...${RESET}"
fi

# ── 1. Create directories ────────────────────────────────────────────────────
echo "→ Creating directories..."
mkdir -p "$CK_SKILL_HOME/commands"
mkdir -p "$CK_SKILL_HOME/hooks"
mkdir -p "$CK_DATA_HOME/contexts"

# ── 2. Copy skill and command files ──────────────────────────────────────────
echo "→ Installing command scripts..."
cp "$SCRIPT_DIR/commands/"*.mjs "$CK_SKILL_HOME/commands/"
chmod +x "$CK_SKILL_HOME/commands/"*.mjs

echo "→ Installing hook..."
cp "$SCRIPT_DIR/hooks/session-start.mjs" "$CK_SKILL_HOME/hooks/session-start.mjs"
chmod +x "$CK_SKILL_HOME/hooks/session-start.mjs"

echo "→ Installing skill instructions..."
cp "$SCRIPT_DIR/SKILL.md" "$CK_SKILL_HOME/SKILL.md"

# ── 3. Initialize projects registry ─────────────────────────────────────────
if [ ! -f "$CK_DATA_HOME/projects.json" ]; then
  echo "→ Creating projects registry..."
  echo "{}" > "$CK_DATA_HOME/projects.json"
fi

# ── 4. Register SessionStart hook in settings.json ───────────────────────────
echo "→ Registering SessionStart hook..."

HOOK_REGISTER_SCRIPT=$(mktemp /tmp/ck-install-XXXXXX.mjs)
HOOK_CMD="node \"$CK_SKILL_HOME/hooks/session-start.mjs\""

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

node "$HOOK_REGISTER_SCRIPT" "$SETTINGS_FILE" "$HOOK_CMD"
rm -f "$HOOK_REGISTER_SCRIPT"

# ── 5. Offer migration for existing v1 data ──────────────────────────────────
if [ "$V1_DETECTED" = true ]; then
  echo ""
  echo -e "${YELLOW}→ You have v1 project data (CONTEXT.md + meta.json).${RESET}"
  echo -e "  Run ${CYAN}/ck:migrate${RESET} in Claude Code to convert it to v2 format."
  echo -e "  Your data is safe — migration backs up originals before converting."
fi

# ── 6. Done ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}✓ ck v2 installed successfully!${RESET}"
echo ""
echo -e "  ${BOLD}Get started:${RESET}"
echo -e "  1. Open Claude Code in any project folder"
echo -e "  2. Run ${CYAN}/ck:init${RESET} to register the project"
echo -e "  3. Run ${CYAN}/ck:save${RESET} at the end of each session"
echo -e "  4. Run ${CYAN}/ck:resume${RESET} next time to pick up where you left off"
echo -e "  5. Run ${CYAN}/ck:list${RESET} to see all your projects"
echo ""
echo -e "  ${BOLD}Upgrading from v1?${RESET} Run ${CYAN}/ck:migrate${RESET} to convert existing data."
echo -e "  ${BOLD}Docs:${RESET} https://github.com/sreedhargs89/context-keeper"
echo ""
