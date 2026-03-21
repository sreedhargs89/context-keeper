# Contributing to ck — Context Keeper

Thanks for wanting to make this better. ck is a community tool — your improvements help every Claude Code user.

## How to Contribute

### Bug Reports
Open an issue with:
- What you ran (`/ck:save`, `/ck:init`, etc.)
- What you expected to happen
- What actually happened
- Your OS + Node.js version

### Feature Ideas
Open an issue with the label `enhancement`. Describe the problem it solves, not just the feature.

### Pull Requests
1. Fork the repo
2. Create a branch: `git checkout -b feature/ck-handoff`
3. Make your changes
4. Test manually (see below)
5. Submit PR with a clear description

## Testing Manually

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/context-keeper
cd context-keeper

# Run the installer pointing to your local copy
bash install.sh

# Open Claude Code and test your changes
claude

# Then try the commands
/ck:init
/ck:save
/ck:resume
/ck:list
/ck:info
/ck:info <name or number>
```

## Areas That Need Help

| Area | Effort | Notes |
|------|--------|-------|
| Windows support | Medium | `install.sh` → `install.ps1`, path handling |
| `/ck:handoff` command | Low | Generate shareable team briefing from CONTEXT.md |
| Smart compression | Medium | Auto-summarize old decisions when CONTEXT.md gets long |
| `/ck:relate` | High | Cross-project pattern matching using embeddings |
| Test suite | Medium | Automated tests for hook output format |
| Homebrew formula | Low | `brew install ck` distribution |

## Code Style

- Keep it simple. This is a shell script + a Node.js hook + a Markdown file.
- No external npm dependencies in the hook — Node.js stdlib only.
- SKILL.md instructions must be clear enough for Claude to follow without ambiguity.
- Test on macOS and Linux before submitting.

## Questions?

Open an issue — happy to help.
