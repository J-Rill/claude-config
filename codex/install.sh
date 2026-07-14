#!/usr/bin/env bash
# Reproduce the Codex + Claude Code integration on a new machine (laptop or HPC).
# Idempotent: safe to re-run. No sudo required — everything lands in $HOME.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "== 1/5 Node via nvm =="
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
fi
. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'
nvm use default

echo "== 2/5 Codex CLI =="
if ! command -v codex >/dev/null 2>&1; then
  npm install -g @openai/codex
fi
codex --version

echo "== 3/5 ~/.codex/AGENTS.md =="
mkdir -p "$HOME/.codex"
if [ ! -f "$HOME/.codex/AGENTS.md" ]; then
  cp "$SCRIPT_DIR/AGENTS.md" "$HOME/.codex/AGENTS.md"
  echo "installed AGENTS.md"
elif ! cmp -s "$SCRIPT_DIR/AGENTS.md" "$HOME/.codex/AGENTS.md"; then
  echo "WARNING: ~/.codex/AGENTS.md differs from the repo copy — not overwriting."
  echo "  diff $SCRIPT_DIR/AGENTS.md ~/.codex/AGENTS.md"
else
  echo "AGENTS.md up to date"
fi

echo "== 4/5 Codex auth =="
if codex login status >/dev/null 2>&1; then
  codex login status
else
  echo "Not logged in. On a headless machine (HPC) run:"
  echo "  codex login --device-auth"
  echo "or copy ~/.codex/auth.json from an authenticated machine (then chmod 600 it)."
fi

echo "== 5/5 Claude Code plugin =="
if command -v claude >/dev/null 2>&1; then
  # settings.json (from the claude-config repo) already declares the marketplace
  # and enables codex@openai-codex; this just forces the fetch now. Errors from
  # a re-run are tolerated, but success is verified explicitly below.
  claude plugin marketplace add openai/codex-plugin-cc || true
  claude plugin install codex@openai-codex || true
  if claude plugin list 2>/dev/null | grep -q 'codex@openai-codex'; then
    claude plugin list | grep -A3 codex
  else
    echo "WARNING: codex plugin is NOT installed — check the errors above."
  fi
else
  echo "Claude Code not found. Install it first:"
  echo "  curl -fsSL https://claude.ai/install.sh | bash"
  echo "then re-run this script."
fi

echo "Done. Open a NEW shell so PATH picks up Node/codex, then verify with:"
echo "  codex exec --sandbox read-only --skip-git-repo-check 'Reply with exactly: OK'"
