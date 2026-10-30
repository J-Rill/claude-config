# Codex configuration for empirical research

This directory is the Codex-native mirror of the research workflows in the repository root. It preserves the substantive Claude Code configuration while using Codex's actual customization surfaces.

## Mapping

| Claude Code source | Codex mirror | Installed location |
|---|---|---|
| `AGENTS.md` plus standing rules | `AGENTS.md` | `~/.codex/AGENTS.md` |
| `skills/*` | `skills/*` | `~/.agents/skills/*` |
| `commands/check-merge.md` | `skills/check-merge/SKILL.md` | `~/.agents/skills/check-merge/` |
| `agents/*.md` | `agents/*.toml` | `~/.codex/agents/` |
| `references/*.md` | `references/*.md` | `~/.codex/references/` |
| `rules/*.md` | `rules/*.md` and key rules in `AGENTS.md` | `~/.codex/rules/` |

Claude-specific frontmatter and tool names are removed. Fresh-context `Task` calls become Codex subagent delegation, Claude model roles map to GPT-5.6 Sol or Terra, `$ARGUMENTS` becomes the user's request, and slash-command references become `$skill-name` invocations.

The Claude `skill-creator` is intentionally not mirrored because Codex ships a built-in `$skill-creator`; installing a second skill with the same name would create duplicate selectors. The reverse-direction `import-codex-skills` workflow is adapted as `import-claude-skills`.

## Install or update

Run:

```bash
bash codex/install.sh
```

The installer updates only the managed files and named skill directories in this mirror. It does not delete unrelated personal skills or agents.

See `INSTALL.md` for a new-machine setup.
