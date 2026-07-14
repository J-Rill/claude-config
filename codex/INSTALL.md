# Codex + Claude Code setup on a new machine

Reproduces the integration from this repo: Codex CLI as a cross-model second
reviewer inside Claude Code, via the official `codex@openai-codex` plugin.
Works on macOS and Linux (HPC login nodes) without sudo.

## Steps

```bash
# 1. This repo IS ~/.claude — clone it there first (skip if already done)
git clone https://github.com/J-Rill/claude-config.git ~/.claude

# 2. Install Claude Code if missing (goes to ~/.local/bin, no sudo)
curl -fsSL https://claude.ai/install.sh | bash

# 3. Run the installer (nvm + Node LTS + Codex CLI + AGENTS.md + plugin)
bash ~/.claude/codex/install.sh

# 4. Authenticate Codex — headless machines use device auth
codex login --device-auth        # ChatGPT account; usage counts against the plan

# 5. Verify end-to-end (from a NEW shell so PATH is fresh)
codex login status
codex exec --sandbox read-only --skip-git-repo-check "Reply with exactly: OK"
```

Then start `claude` and run `/codex:setup` once (decline the optional stop-time
review gate — we use on-demand + pipeline-triggered reviews instead).

## What each piece does

| Piece | Where | Purpose |
|---|---|---|
| `codex/install.sh` | this repo | Idempotent installer for all of the below |
| `codex/AGENTS.md` | → copied to `~/.codex/AGENTS.md` | Review standards Codex applies (merge cardinality, silent drops, loud failures, provenance) |
| `settings.json` | this repo | Declares the `openai-codex` marketplace and enables the plugin — Claude Code fetches it on first run |
| `CLAUDE.md` §"Code review after changes" | this repo | Tells Claude to get a Codex second opinion (`codex exec --sandbox read-only`) on substantive pipeline changes |

Plugin commands (user-invoked): `/codex:review`, `/codex:adversarial-review`,
`/codex:rescue`, `/codex:transfer`, `/codex:status`, `/codex:result`,
`/codex:cancel`, `/codex:setup`.

## HPC notes

- **No browser on login nodes** → `codex login --device-auth`, or copy
  `~/.codex/auth.json` from an authenticated machine and `chmod 600` it.
- **Old kernels**: Codex's read-only sandbox uses Landlock on Linux
  (kernel ≥ 5.13). On older RHEL/CentOS kernels sandboxed runs may fail —
  fall back to `codex exec --sandbox danger-full-access` (fine on a cluster
  where you trust the prompt and the repo) or set `sandbox_mode` in
  `~/.codex/config.toml`.
- **Compute nodes usually have no internet** — run Codex from the login node.
- nvm installs to `$HOME/.nvm`; if your `$HOME` is quota-limited, set
  `NVM_DIR` to a project/scratch path before running `install.sh`.
