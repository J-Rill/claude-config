---
name: import-claude-skills
description: Import or synchronize Claude Code skills and Markdown configuration into Codex-native guidance, skills, and custom agents. Use when the user asks to import Claude skills, sync claude-config to Codex, convert CLAUDE.md to AGENTS.md, or migrate Claude commands and subagents into Codex.
---

# Import Claude Code configuration into Codex

Convert the configuration rather than copying it blindly.

1. Identify the Claude source, normally `~/.claude` or a supplied GitHub checkout. If it is a Git repository and the user requested a sync, inspect local changes before pulling and preserve them.
2. Inventory `AGENTS.md`, `skills/`, `commands/`, `agents/`, `rules/`, and `references/`.
3. Map content to Codex surfaces:
   - `AGENTS.md` and durable rules → `~/.codex/AGENTS.md`.
   - reusable workflows and slash commands → `~/.agents/skills/<name>/SKILL.md`.
   - subagents → `~/.codex/agents/<name>.toml` with `name`, `description`, and `developer_instructions`.
   - supporting references → a stable referenced path such as `~/.codex/references/` or the importing skill's `references/` folder.
4. Keep only `name` and `description` in skill frontmatter. Convert `$ARGUMENTS` to the user's request, Claude slash-command references to `$skill-name`, and Claude tool names to capability-based Codex instructions.
5. Translate model roles deliberately: Opus-style demanding work → GPT-5.6 Sol with high or xhigh effort; Sonnet-style fast review → GPT-5.6 Terra with high effort; Haiku-style narrow high-volume work → GPT-5.6 Luna with medium effort. Preserve an explicit user model choice.
6. Convert fresh-context verification to Codex subagents with no inherited conversation turns when the current delegation surface supports that option. Pass source artifacts and questions, but withhold drafts or derivations when independence is part of the method.
7. Do not install a user skill whose name duplicates a built-in Codex skill. Explain the substitution and use the built-in skill.
8. Diff before overwriting. Back up or preserve unrelated existing Codex content, and never delete skills or agents outside the explicitly managed names.
9. Validate every imported skill with the built-in skill validator, parse every custom-agent TOML file, and scan for leftover Claude paths, model names, unsupported frontmatter, and tool-specific syntax.
10. Report the source revision, mappings, intentional exclusions, installed destinations, and verification results.
