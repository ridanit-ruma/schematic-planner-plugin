#!/bin/sh
# Structural checks for the schematic-planner plugin.
#
# The plugin is Markdown and manifests, so there is nothing to unit test. What
# can go wrong is structural: a manifest that names the plugin something else, a
# reference that stops documenting a tool the skills call, a credential pasted
# into a file that gets published. These checks cover that, with nothing but a
# POSIX shell and grep.

set -u

fail=0

err() { printf 'FAIL  %s\n' "$1" >&2; fail=1; }
ok()  { printf 'ok    %s\n' "$1"; }

need_file() {
    if [ -f "$1" ]; then
        ok "$1"
    else
        err "missing file: $1"
    fi
}

# need_text <file> <extended-regex> <what it is for>
need_text() {
    if [ ! -f "$1" ]; then
        err "$3 — $1 does not exist"
    elif grep -Eq "$2" "$1"; then
        ok "$3"
    else
        err "$3 — $1 does not match /$2/"
    fi
}

echo "-- the contract"

need_file references/mcp-surface.md
for tool in \
    get_plan apply_ops create_plan list_plans layout export_plan \
    list_folders create_folder rename_folder delete_folder move_plan
do
    need_text references/mcp-surface.md "$tool" "mcp-surface documents $tool"
done
need_text references/mcp-surface.md 'create_plan.*folder' 'mcp-surface documents create_plan folder placement'
need_text references/mcp-surface.md '[Ff]olders do not nest' 'mcp-surface says folders do not nest'
need_text references/mcp-surface.md 'addressed by name' 'mcp-surface explains name-based folder lookup'
need_text references/mcp-surface.md '[Aa]tomic' 'mcp-surface says apply_ops is atomic'
need_text references/mcp-surface.md 'via' 'mcp-surface warns about via on delete_edge'
need_text references/mcp-surface.md 'position' 'mcp-surface says agents set no coordinates'

need_file references/binding-file.md
for key in server workspace project; do
    need_text references/binding-file.md "\"$key\"" "binding-file documents \"$key\""
done
need_text references/binding-file.md '`plan`' 'binding-file documents the legacy plan field'
need_text references/binding-file.md '[Pp]roject-scoped' 'binding-file makes the project the binding boundary'
need_text references/binding-file.md '[Oo]ptional legacy.*migration hint' 'binding-file treats plan as an optional migration hint'

# This repository dogfoods the project-scoped binding. A legacy consumer may
# still carry `plan` as migration input, but new bindings must not keep one.
if [ -f .schematic-planner.json ]; then
    for key in server workspace project; do
        need_text .schematic-planner.json "\"$key\"" "binding file names $key"
    done
    if grep -Eq '"plan"[[:space:]]*:' .schematic-planner.json; then
        err ".schematic-planner.json must bind the project, not one plan"
    else
        ok "binding file has no active plan pointer"
    fi
else
    ok "no binding file, and none needed yet"
fi

echo
echo "-- the package"

need_file .claude-plugin/plugin.json
need_text .claude-plugin/plugin.json '"name": "schematic-planner"' "plugin.json names the plugin"
for term in project specs plans; do
    need_text README.md "$term" "README explains project-scoped $term"
    need_text .claude-plugin/plugin.json "$term" "plugin.json describes project-scoped $term"
done
for f in \
    README.md \
    .claude-plugin/plugin.json \
    .claude-plugin/marketplace.json \
    .codex-plugin/plugin.json \
    .kimi-plugin/plugin.json \
    .cursor-plugin/plugin.json
do
    if grep -Eqi 'one graph' "$f"; then
        err "$f must not describe design and implementation as one graph"
    else
        ok "$f keeps Specs and Plans separate"
    fi
done
# skills/ is discovered automatically. None of the plugins shipped with Claude
# Code declares a skills path, and inventing one is at best ignored.
if [ -f .claude-plugin/plugin.json ] && grep -Eq '"skills"[[:space:]]*:' .claude-plugin/plugin.json; then
    err "plugin.json must not declare a skills path; skills/ is discovered"
else
    ok "plugin.json declares no skills path"
fi

need_file .claude-plugin/marketplace.json
need_text .claude-plugin/marketplace.json '"name": "schematic-planner"' "marketplace lists the plugin"
need_text .claude-plugin/marketplace.json '"source": "\./"' "marketplace sources the plugin from this repository"

need_file .mcp.json
need_text .mcp.json '"mcpServers"' "mcp.json uses the wrapped form"
need_text .mcp.json '"schematic-planner"' "mcp.json names the server"
need_text .mcp.json 'SCHEMATIC_PLANNER_KEY' "mcp.json takes its key from the environment"

need_file hooks/hooks.json
need_text hooks/hooks.json 'SessionStart' "hook runs at session start"
need_text hooks/hooks.json 'CLAUDE_PLUGIN_ROOT' "hook resolves its own plugin root"
need_file hooks/session-start
need_text hooks/session-start 'using-schematic-planner' "hook injects the entry skill"
need_file hooks/run-hook.cmd

need_file .codex-plugin/plugin.json
need_file .kimi-plugin/plugin.json
need_file .cursor-plugin/plugin.json
need_file .opencode/plugins/schematic-planner.js
need_file .agents/plugins/marketplace.json
need_file scripts/sync-harnesses.sh

# A .cursor/ directory applies when Cursor opens this repository. It is not
# distributed with the plugin, so it is not how Cursor gets these skills.
if [ -d .cursor ]; then
    err ".cursor/ is not distributed with a plugin; use .cursor-plugin/"
else
    ok "Cursor is served by .cursor-plugin/, not .cursor/"
fi

for f in scripts/check.sh scripts/sync-harnesses.sh hooks/session-start; do
    if [ -x "$f" ]; then
        ok "executable: $f"
    else
        err "not executable: $f"
    fi
done

echo
echo "-- the skills"

for s in using-schematic-planner brainstorming-on-canvas writing-plans-on-canvas executing-plans-on-canvas; do
    need_file "skills/$s/SKILL.md"
    need_text "skills/$s/SKILL.md" "^name: $s\$" "$s declares its name"
    need_text "skills/$s/SKILL.md" '^description: .*[Uu]se ' "$s says when to use it"
done

for term in list_folders create_folder list_plans specs plans legacy; do
    need_text skills/using-schematic-planner/SKILL.md "$term" "entry skill routes project inventory with $term"
done
need_text skills/using-schematic-planner/SKILL.md '[Aa]mbigu' 'entry skill stops on ambiguous canvas selection'
need_text skills/brainstorming-on-canvas/SKILL.md 'folder.*specs' 'brainstorming files new specs in the specs folder'
need_text skills/brainstorming-on-canvas/SKILL.md '[Rr]euse' 'brainstorming reuses a matching spec before creation'

for term in list_plans create_plan plans Source-Specs; do
    need_text skills/writing-plans-on-canvas/SKILL.md "$term" "planning skill creates folder-qualified plans with $term"
done
need_text skills/writing-plans-on-canvas/SKILL.md '[Nn]ever.*task.*Spec|do not.*task.*Spec' 'planning skill keeps executable tasks out of specs'
for term in list_plans plans Source-Specs; do
    need_text skills/executing-plans-on-canvas/SKILL.md "$term" "executor discovers implementation plans with $term"
done
need_text skills/executing-plans-on-canvas/SKILL.md 'persistent active Plan' 'executor keeps no persistent active plan pointer'
need_text skills/executing-plans-on-canvas/SKILL.md 'exactly one' 'executor runs exactly one ready task'

# A skill with no frontmatter is invisible to every harness that loads this.
for skill in skills/*/SKILL.md; do
    [ -e "$skill" ] || continue
    if head -1 "$skill" | grep -q '^---$'; then
        ok "frontmatter opens: $skill"
    else
        err "no frontmatter: $skill"
    fi
done

echo
echo "-- the setup references"

for h in claude-code codex cursor; do
    need_file "references/mcp-setup-$h.md"
done

echo
echo "-- no credentials anywhere"

# A key in a published file is the one mistake with no undo, so only the files
# that actually ship are scanned. After "Bearer" there may be a variable or an
# angle-bracket placeholder, and nothing else.
shipped=".claude-plugin .mcp.json hooks .codex-plugin .cursor-plugin .kimi-plugin .opencode .agents skills references README.md"
present=""
for p in $shipped; do
    [ -e "$p" ] && present="$present $p"
done
if [ -n "$present" ]; then
    # shellcheck disable=SC2086
    leaked=$(grep -REn "Bearer [^\$<]" $present 2>/dev/null || true)
    if [ -n "$leaked" ]; then
        err "a literal credential may be about to ship"
        printf "%s\n" "$leaked" >&2
    else
        ok "no literal credentials in shipped files"
    fi
else
    ok "nothing shipped to scan yet"
fi

echo
if [ "$fail" -eq 0 ]; then
    echo "all checks passed"
else
    echo "checks failed"
fi
exit "$fail"
