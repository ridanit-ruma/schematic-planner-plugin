#!/bin/sh
set -eu

require_file() {
  test -f "$1" || {
    echo "missing required file: $1" >&2
    exit 1
  }
}

require_file .schematic-planner.json
require_file references/mcp-surface.md
require_file .claude-plugin/plugin.json
require_file .codex-plugin/plugin.json
require_file .kimi-plugin/plugin.json
require_file .cursor/mcp.json.example
require_file .cursor/commands/using-schematic-planner.md
require_file .cursor/commands/brainstorming-on-canvas.md
require_file .cursor/commands/writing-plans-on-canvas.md
require_file .cursor/commands/executing-plans-on-canvas.md
require_file .opencode/plugins/schematic-planner.js
require_file .agents/plugins/marketplace.json
require_file hooks/hooks.json
require_file hooks/session-start
require_file skills/using-schematic-planner/SKILL.md
require_file skills/brainstorming-on-canvas/SKILL.md
require_file skills/writing-plans-on-canvas/SKILL.md
require_file skills/executing-plans-on-canvas/SKILL.md
require_file README.md
require_file LICENSE
require_file scripts/sync-harnesses.sh
require_file .github/workflows/check.yml

grep -q '"server"' .schematic-planner.json
grep -q 'apply_ops' references/mcp-surface.md
grep -q 'Apache-2.0' .claude-plugin/plugin.json
grep -q 'Apache-2.0' .codex-plugin/plugin.json
grep -q 'Apache-2.0' .kimi-plugin/plugin.json
grep -q 'schematic-planner' .cursor/commands/using-schematic-planner.md
grep -q 'using-schematic-planner' skills/using-schematic-planner/SKILL.md
grep -q 'brainstorming-on-canvas' skills/brainstorming-on-canvas/SKILL.md
grep -q 'writing-plans-on-canvas' skills/writing-plans-on-canvas/SKILL.md
grep -q 'executing-plans-on-canvas' skills/executing-plans-on-canvas/SKILL.md
grep -q 'Apache License' LICENSE
grep -q 'q-' README.md
grep -q 'gate-' README.md
grep -q '"type": "http"' .cursor/mcp.json.example

for skill in skills/*/SKILL.md; do
  grep -q '^---$' "$skill"
  grep -q '^name: ' "$skill"
  grep -q '^description: .*Use ' "$skill"
done

! rg -n 'Authorization: Bearer (?!\$\{SCHEMATIC_PLANNER_KEY\}|<key>)' \
  --pcre2 --glob '!references/mcp-surface.md' --glob '!scripts/check.sh' .

sh scripts/sync-harnesses.sh
node --input-type=module <<'NODE'
import { readFileSync } from 'node:fs'

for (const path of [
  '.schematic-planner.json',
  '.claude-plugin/plugin.json',
  '.codex-plugin/plugin.json',
  '.kimi-plugin/plugin.json',
  '.cursor/mcp.json.example',
  '.agents/plugins/marketplace.json',
  'hooks/hooks.json',
]) {
  JSON.parse(readFileSync(path, 'utf8'))
}
NODE
node --input-type=module --eval "import('./.opencode/plugins/schematic-planner.js').then(({ SchematicPlanner }) => SchematicPlanner({}).then((hooks) => { if (typeof hooks !== 'object') process.exit(1) }))"
