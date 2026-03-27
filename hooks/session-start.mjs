#!/usr/bin/env node
/**
 * ck — Context Keeper
 * SessionStart hook: auto-injects project context + displays a welcome briefing.
 *
 * - In a registered project: shows a formatted welcome briefing as Claude's first message
 * - Outside a registered project: shows a mini summary of 3 most recent projects
 *
 * Output format: JSON with `additionalContext` key (Claude Code hook protocol).
 */

import { readFileSync, existsSync } from 'fs';
import { resolve } from 'path';
import { homedir } from 'os';

const CK_HOME = resolve(homedir(), '.claude', 'ck');
const PROJECTS_FILE = resolve(CK_HOME, 'projects.json');

function loadProjects() {
  if (!existsSync(PROJECTS_FILE)) return {};
  try { return JSON.parse(readFileSync(PROJECTS_FILE, 'utf8')); }
  catch { return {}; }
}

/** Read only meta.json — used by mini-status to avoid loading full CONTEXT.md per project */
function loadMeta(contextDir) {
  const metaFile = resolve(CK_HOME, 'contexts', contextDir, 'meta.json');
  if (!existsSync(metaFile)) return null;
  try { return JSON.parse(readFileSync(metaFile, 'utf8')); }
  catch { return null; }
}

/** Read both CONTEXT.md and meta.json — used only for the registered-project briefing */
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
  if (!dateStr) return 'unknown';
  const diff = Math.floor((Date.now() - new Date(dateStr)) / (1000 * 60 * 60 * 24));
  if (diff === 0) return 'today';
  if (diff === 1) return '1 day ago';
  return `${diff} days ago`;
}

function staleness(dateStr) {
  if (!dateStr) return '○';
  const diff = Math.floor((Date.now() - new Date(dateStr)) / (1000 * 60 * 60 * 24));
  if (diff < 1) return '●';
  if (diff <= 5) return '◐';
  return '○';
}

/** Extract a section value from CONTEXT.md */
function extractSection(context, heading) {
  const re = new RegExp(`## ${heading}\\n([\\s\\S]*?)(?=\\n## |$)`);
  const match = context.match(re);
  if (!match) return null;
  const lines = match[1].trim().split('\n').filter(l => l.trim() && !l.startsWith('_'));
  return lines[0]?.replace(/^[\d]+\.\s*/, '').trim() || null;
}

/** Build the welcome briefing box for a registered project */
function buildBriefing(name, context, meta) {
  const when = daysAgo(meta.lastUpdated);
  const sessions = meta.sessionCount ?? '?';
  const goal     = extractSection(context, 'Current Goal') ?? '—';
  const leftOff  = extractSection(context, 'Where I Left Off') ?? '—';
  const next     = extractSection(context, 'Next Steps') ?? '—';
  const blockers = extractSection(context, 'Blockers') ?? 'None';

  const W = 57;
  const pad = (str, w) => str.length > w ? str.slice(0, w - 1) + '…' : str.padEnd(w);
  const line = (label, value) => `│  ${label} → ${pad(value, W - label.length - 7)}│`;

  return [
    `┌${'─'.repeat(W)}┐`,
    `│  RESUMING: ${pad(name, W - 12)}│`,
    `│  Last session: ${pad(`${when}  |  Sessions: ${sessions}`, W - 16)}│`,
    `├${'─'.repeat(W)}┤`,
    line('GOAL    ', goal),
    line('LEFT OFF', leftOff),
    line('NEXT    ', next),
    line('BLOCKERS', blockers),
    `└${'─'.repeat(W)}┘`,
  ].join('\n');
}

/**
 * Build a mini summary for when NOT in a registered project.
 * Reads only meta.json per project — no CONTEXT.md loading.
 */
function buildMiniStatus(projects) {
  const entries = Object.entries(projects);
  if (entries.length === 0) return null;

  // Sort by lastUpdated desc, take top 3
  const sorted = entries
    .map(([path, info]) => {
      const meta = loadMeta(info.contextDir) ?? {};
      return {
        name: info.name,
        path,
        lastUpdated: meta.lastUpdated ?? '',
        lastSummary: meta.lastSessionSummary ?? '—',
      };
    })
    .sort((a, b) => (b.lastUpdated > a.lastUpdated ? 1 : -1))
    .slice(0, 3);

  const rows = sorted.map(p => {
    const s = staleness(p.lastUpdated);
    const when = daysAgo(p.lastUpdated);
    const name = p.name.padEnd(16).slice(0, 16);
    const whenStr = when.padEnd(12).slice(0, 12);
    const summary = (p.lastSummary ?? '—').slice(0, 30);
    return `  ${name}  ${s}  ${whenStr}  ${summary}`;
  });

  return [
    `ck — your recent projects:`,
    `  ${'PROJECT'.padEnd(16)}  S  ${'LAST SEEN'.padEnd(12)}  LAST SESSION`,
    `  ${'─'.repeat(70)}`,
    ...rows,
    ``,
    `Run /ck:list for full view · /ck:resume <name> to jump in · /ck:init to register this folder`,
  ].join('\n');
}

function main() {
  const cwd = process.env.PWD || process.cwd();
  const projects = loadProjects();
  const entry = projects[cwd];

  const parts = [];

  if (entry?.contextDir) {
    // ── REGISTERED PROJECT: inject CONTEXT.md + welcome briefing ──
    const result = loadContext(entry.contextDir);
    if (result) {
      const { context, meta } = result;
      const briefing = buildBriefing(entry.name, context, meta);

      parts.push([
        `---`,
        `## ck: Project Context Loaded — ${entry.name}`,
        ``,
        context,
      ].join('\n'));

      // Instruction to Claude: display the briefing as first message
      parts.push([
        `---`,
        `## ck: SESSION START INSTRUCTION`,
        ``,
        `IMPORTANT: Display the following welcome briefing as your VERY FIRST message, verbatim, before doing anything else. Do not add any text before it. After the briefing, add one short line: "Ready. What are we working on?"`,
        ``,
        '```',
        briefing,
        '```',
      ].join('\n'));
    }
  } else {
    // ── UNREGISTERED DIRECTORY: show mini summary of recent projects ──
    const miniStatus = buildMiniStatus(projects);
    if (miniStatus) {
      parts.push([
        `---`,
        `## ck: SESSION START INSTRUCTION`,
        ``,
        `IMPORTANT: Display the following as your VERY FIRST message, verbatim, before doing anything else:`,
        ``,
        '```',
        miniStatus,
        '```',
      ].join('\n'));
    }
  }

  if (parts.length > 0) {
    console.log(JSON.stringify({ additionalContext: parts.join('\n\n---\n\n') }));
  }
}

main();
