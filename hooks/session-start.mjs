#!/usr/bin/env node
/**
 * ck — Context Keeper
 * SessionStart hook: auto-injects project context when Claude opens in a registered project folder.
 *
 * Output format: JSON with `additionalContext` key (Claude Code hook protocol).
 */

import { readFileSync, existsSync } from 'fs';
import { resolve } from 'path';
import { homedir } from 'os';

const CK_HOME = resolve(homedir(), '.claude', 'ck');
const PROJECTS_FILE = resolve(CK_HOME, 'projects.json');
const SKILL_FILE = resolve(homedir(), '.claude', 'skills', 'ck', 'SKILL.md');

function loadSkill() {
  if (existsSync(SKILL_FILE)) {
    return readFileSync(SKILL_FILE, 'utf8');
  }
  return '';
}

function loadProjects() {
  if (!existsSync(PROJECTS_FILE)) return {};
  try {
    return JSON.parse(readFileSync(PROJECTS_FILE, 'utf8'));
  } catch {
    return {};
  }
}

function loadContext(contextDir) {
  const contextFile = resolve(CK_HOME, 'contexts', contextDir, 'CONTEXT.md');
  const metaFile = resolve(CK_HOME, 'contexts', contextDir, 'meta.json');

  if (!existsSync(contextFile)) return null;

  const context = readFileSync(contextFile, 'utf8');
  let meta = {};
  if (existsSync(metaFile)) {
    try { meta = JSON.parse(readFileSync(metaFile, 'utf8')); } catch {}
  }

  return { context, meta };
}

function daysAgo(dateStr) {
  if (!dateStr) return null;
  const last = new Date(dateStr);
  const now = new Date();
  const diff = Math.floor((now - last) / (1000 * 60 * 60 * 24));
  if (diff === 0) return 'today';
  if (diff === 1) return '1 day ago';
  return `${diff} days ago`;
}

function main() {
  const cwd = process.env.PWD || process.cwd();
  const skill = loadSkill();
  const projects = loadProjects();
  const entry = projects[cwd];

  const parts = [];

  // Always inject skill instructions so Claude knows the /ck:* commands
  if (skill) {
    parts.push(skill);
  }

  // Inject project context if registered
  if (entry?.contextDir) {
    const result = loadContext(entry.contextDir);
    if (result) {
      const { context, meta } = result;
      const when = daysAgo(meta.lastUpdated);
      const sessions = meta.sessionCount ?? '?';

      parts.push([
        `---`,
        `## ck: Project Context Loaded — ${entry.name}`,
        `> Last session: ${when ?? 'unknown'} | Total sessions: ${sessions}`,
        `> Run \`/ck:resume\` for a full briefing or \`/ck:save\` to save this session.`,
        ``,
        context,
      ].join('\n'));
    }
  }

  if (parts.length > 0) {
    console.log(JSON.stringify({ additionalContext: parts.join('\n\n---\n\n') }));
  }
}

main();
