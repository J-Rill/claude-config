---
name: import-codex-skills
description: >
  Import skills from Codex (~/.codex/skills/) into Claude Code (~/.claude/skills/).
  Use when user says "import codex skills", "sync codex skills", "bring in codex skills",
  "import from codex", or "add codex skills to claude". Supports importing all skills
  or a named subset. Skips skills that already exist unless --force is passed.
---

# Import Codex Skills

Copy skills from `~/.codex/skills/` into `~/.claude/skills/` so they are
globally available in every Claude Code session.

## Invocation forms

| Command | Behavior |
|---|---|
| `/import-codex-skills` | Import all Codex skills not already in Claude Code |
| `/import-codex-skills skill-name` | Import one named skill |
| `/import-codex-skills --force` | Import all, overwriting existing copies |
| `/import-codex-skills skill-name --force` | Import one skill, overwriting if present |

## Steps

1. **Discover** — list all directories in `~/.codex/skills/`. Each directory is one skill.

2. **Filter** — if a skill name argument was given, restrict to that skill only.
   If that skill does not exist in `~/.codex/skills/`, report an error and stop.

3. **Check for conflicts** — for each candidate skill, check whether
   `~/.claude/skills/<skill-name>/` already exists.
   - Without `--force`: skip existing skills and note them in the summary.
   - With `--force`: overwrite without prompting.

4. **Copy** — use `cp -r ~/.codex/skills/<skill-name> ~/.claude/skills/` for each
   skill being imported.

5. **Report** — print a summary table:

```
Imported:
  ✓ progress-tracker

Skipped (already exist — use --force to overwrite):
  - some-other-skill

Done. X skill(s) imported to ~/.claude/skills/.
Restart Claude Code (or open a new session) for new skills to appear.
```

## Notes

- Codex and Claude Code both use `SKILL.md` as the skill definition file, so
  no format conversion is needed.
- Skills imported this way become globally available across all projects.
- To later remove an imported skill: `rm -rf ~/.claude/skills/<skill-name>`
- The source at `~/.codex/skills/` is never modified.
