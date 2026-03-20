#!/usr/bin/env bash
# ck — Context Keeper
# Uninstaller: removes skill files and hook registration. Data is preserved by default.

set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RESET="\033[0m"

CK_SKILL_HOME="$HOME/.claude/skills/ck"
CK_DATA_HOME="$HOME/.claude/ck"
SETTINGS_FILE="$HOME/.claude/settings.json"
HOOK_CMD="node \"$CK_SKILL_HOME/hooks/session-start.mjs\""

echo ""
echo -e "${BOLD}${CYAN}ck — Context Keeper Uninstaller${RESET}"
echo ""

# ── Ask about data ────────────────────────────────────────────────────────────
echo -e "${YELLOW}Your project contexts are stored at: $CK_DATA_HOME${RESET}"
read -p "Delete saved project contexts too? [y/N] " -n 1 -r DELETE_DATA
echo ""

# ── Remove skill files ────────────────────────────────────────────────────────
echo "→ Removing skill files..."
rm -rf "$CK_SKILL_HOME"

# ── Remove hook from settings.json ───────────────────────────────────────────
if [ -f "$SETTINGS_FILE" ]; then
  echo "→ Removing hook from settings.json..."
  node - <<EOF
const fs = require('fs');
const settingsPath = '$SETTINGS_FILE';
let settings = {};
try {
  settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
} catch { process.exit(0); }

if (settings.hooks?.SessionStart) {
  settings.hooks.SessionStart = settings.hooks.SessionStart.filter(entry =>
    !(Array.isArray(entry.hooks) && entry.hooks.some(h => h.command === '$HOOK_CMD'))
  );
  fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2));
}
EOF
fi

# ── Optionally delete data ────────────────────────────────────────────────────
if [[ "$DELETE_DATA" =~ ^[Yy]$ ]]; then
  echo "→ Deleting project contexts..."
  rm -rf "$CK_DATA_HOME"
  echo -e "${YELLOW}  All project contexts deleted.${RESET}"
else
  echo -e "  Project contexts preserved at: $CK_DATA_HOME"
fi

echo ""
echo -e "${GREEN}${BOLD}✓ ck uninstalled.${RESET}"
echo ""
