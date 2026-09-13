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

echo "-- Task 1: the contract"

need_file references/mcp-surface.md
for tool in get_plan apply_ops create_plan list_plans layout export_plan; do
    need_text references/mcp-surface.md "$tool" "mcp-surface documents $tool"
done
need_text references/mcp-surface.md '[Aa]tomic' 'mcp-surface says apply_ops is atomic'
need_text references/mcp-surface.md 'via' 'mcp-surface warns about via on delete_edge'
need_text references/mcp-surface.md 'position' 'mcp-surface says agents set no coordinates'

need_file references/binding-file.md
for key in server workspace project plan; do
    need_text references/binding-file.md "\"$key\"" "binding-file documents \"$key\""
done

# The binding describes a consuming repository's link to its plan. A copy here,
# with empty values, would claim this plugin is bound to nothing.
if [ -f .schematic-planner.json ]; then
    err ".schematic-planner.json belongs in a consuming repository, not in this one"
else
    ok "no stray binding file in the plugin repository"
fi

echo
echo "-- Task 2: the package"

need_file .claude-plugin/plugin.json
need_text .claude-plugin/plugin.json '"name": "schematic-planner"' "plugin.json names the plugin"
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
echo "-- Task 3: the entry point"

need_file skills/using-schematic-planner/SKILL.md
need_text skills/using-schematic-planner/SKILL.md '^name: using-schematic-planner$' "entry skill declares its name"
need_text skills/using-schematic-planner/SKILL.md '^description: .*[Uu]se when' "entry skill description says when to use it"
need_text skills/using-schematic-planner/SKILL.md 'schematic-planner\.json' "entry skill reads the binding file"

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
