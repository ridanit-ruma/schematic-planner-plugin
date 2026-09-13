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
if [ "$fail" -eq 0 ]; then
    echo "all checks passed"
else
    echo "checks failed"
fi
exit "$fail"
