# Codex setup on a new machine

This installs the Codex-native mirror from the `claude-config` repository without changing the live Claude Code configuration.

```bash
# 1. Clone the configuration repository.
git clone https://github.com/J-Rill/claude-config.git ~/.claude

# 2. Install Codex CLI if needed (Node 18+ required).
npm install -g @openai/codex

# 3. Install the Codex guidance, agents, references, rules, and skills.
bash ~/.claude/codex/install.sh

# 4. Authenticate. Use device auth on headless machines.
codex login --device-auth

# 5. Start a new Codex session and verify discovery.
codex login status
codex --ask-for-approval never "Summarize the current instructions and list the research skills you can see."
```

## Locations

| Content | Location |
|---|---|
| Global working agreements | `~/.codex/AGENTS.md` |
| Custom subagents | `~/.codex/agents/*.toml` |
| Journal references | `~/.codex/references/*.md` |
| Research rules | `~/.codex/rules/*.md` |
| Personal skills | `~/.agents/skills/*` |

Codex normally detects skill changes automatically. Start a new session if an updated skill does not appear. `AGENTS.md` is loaded once per Codex run, so a new session is required after changing it.

## HPC notes

- On a login node without a browser, use `codex login --device-auth` or securely copy an authenticated `~/.codex/auth.json` and set mode `600`.
- Compute nodes often lack internet access; authenticate and run network-dependent research tasks from a node with access.
- Sandbox support varies with the operating system and kernel. Keep the default sandbox unless a concrete command fails and the requested task justifies broader access.
