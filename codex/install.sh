#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_TARGET_HOME="${CODEX_HOME:-$HOME/.codex}"
AGENTS_TARGET_HOME="$HOME/.agents"

mkdir -p "$CODEX_TARGET_HOME/agents" "$CODEX_TARGET_HOME/references" "$CODEX_TARGET_HOME/rules" "$AGENTS_TARGET_HOME/skills"

install -m 0644 "$SCRIPT_DIR/AGENTS.md" "$CODEX_TARGET_HOME/AGENTS.md"

for source_file in "$SCRIPT_DIR"/agents/*.toml; do
  install -m 0644 "$source_file" "$CODEX_TARGET_HOME/agents/$(basename "$source_file")"
done

for source_file in "$SCRIPT_DIR"/references/*.md; do
  install -m 0644 "$source_file" "$CODEX_TARGET_HOME/references/$(basename "$source_file")"
done

for source_file in "$SCRIPT_DIR"/rules/*.md; do
  install -m 0644 "$source_file" "$CODEX_TARGET_HOME/rules/$(basename "$source_file")"
done

for source_skill in "$SCRIPT_DIR"/skills/*; do
  skill_name="$(basename "$source_skill")"
  destination_skill="$AGENTS_TARGET_HOME/skills/$skill_name"
  mkdir -p "$destination_skill"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$source_skill/" "$destination_skill/"
  else
    cp -R "$source_skill/." "$destination_skill/"
  fi
done

echo "Installed Codex guidance in $CODEX_TARGET_HOME"
echo "Installed $(find "$SCRIPT_DIR/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ') skills in $AGENTS_TARGET_HOME/skills"
echo "Start a new Codex session to reload AGENTS.md and custom agents."
