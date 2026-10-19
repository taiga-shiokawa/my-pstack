#!/usr/bin/env bash
# my-pstack installer for Claude Code.
# Upstream pstack is installed from the official Cursor marketplace inside Claude Code (see step 1 message).
# This script only adds the overlay skills and the Claude-only model rule.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
skills_dir="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
rules_file="$HOME/.claude/rules/pstack-models.md"

if find "$HOME/.claude/plugins" -path '*pstack*/skills/poteto-mode/SKILL.md' 2>/dev/null | grep -q .; then
  echo "[1/3] official pstack plugin found under ~/.claude/plugins"
else
  echo "[1/3] official pstack plugin not found. In Claude Code, run:"
  echo "        /plugin marketplace add cursor/plugins"
  echo "        /plugin install pstack@cursor-plugins"
  echo "      then re-run this script. (continuing anyway)"
fi

echo "[2/3] copying overlay skills (my-mode, spec-first, unslop-ja, requirements-interview) to $skills_dir"
mkdir -p "$skills_dir"
for s in my-mode spec-first unslop-ja requirements-interview; do
  rm -rf "$skills_dir/$s"
  cp -R "$here/skills/$s" "$skills_dir/$s"
done

if [ -f "$rules_file" ]; then
  echo "[3/3] $rules_file exists, left untouched. Compare with $here/config/pstack-models.md"
else
  echo "[3/3] writing Claude-only model rule to $rules_file"
  mkdir -p "$(dirname "$rules_file")"
  cp "$here/config/pstack-models.md" "$rules_file"
fi

cat <<MSG

done. next:
  1. open Claude Code in a TypeScript repo
  2. run /pstack:setup-pstack once to confirm the models your session can spawn
  3. try: /my-mode 仕様から始めて、CSV エクスポートに idempotency-key を足して
MSG
