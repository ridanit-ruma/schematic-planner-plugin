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

for s in \
    using-schematic-planner brainstorming-on-canvas writing-plans-on-canvas \
    executing-plans-on-canvas test-driven-development systematic-debugging \
    verification-before-completion requesting-code-review receiving-code-review \
    using-git-worktrees finishing-a-development-branch \
    subagent-driven-development dispatching-parallel-agents writing-skills
do
    need_file "skills/$s/SKILL.md"
    need_text "skills/$s/SKILL.md" "^name: $s\$" "$s declares its name"
    need_text "skills/$s/SKILL.md" '^description: .*[Uu]se ' "$s says when to use it"
done

for term in list_folders create_folder list_plans specs plans legacy; do
    need_text skills/using-schematic-planner/SKILL.md "$term" "entry skill routes project inventory with $term"
done
need_text skills/using-schematic-planner/SKILL.md '[Aa]mbigu' 'entry skill stops on ambiguous canvas selection'
need_text skills/using-schematic-planner/SKILL.md 'specification canvases only from `specs`' 'entry skill enforces Spec folder and content stage'
need_text skills/using-schematic-planner/SKILL.md 'executable Plans only from `plans`' 'entry skill enforces implementation folder and content stage'
need_text skills/brainstorming-on-canvas/SKILL.md 'folder.*specs' 'brainstorming files new specs in the specs folder'
need_text skills/brainstorming-on-canvas/SKILL.md '[Rr]euse' 'brainstorming reuses a matching spec before creation'
need_text skills/brainstorming-on-canvas/SKILL.md 'After `create_plan` returns' 'brainstorming verifies placement after Spec creation'
need_text skills/brainstorming-on-canvas/SKILL.md 'just-created' 'brainstorming limits folder correction to the new Spec'

for term in list_plans create_plan plans Source-Specs; do
    need_text skills/writing-plans-on-canvas/SKILL.md "$term" "planning skill creates folder-qualified plans with $term"
done
need_text skills/writing-plans-on-canvas/SKILL.md '[Nn]ever.*task.*Spec|do not.*task.*Spec' 'planning skill keeps executable tasks out of specs'
need_text skills/writing-plans-on-canvas/SKILL.md 'After `create_plan` returns' 'planning verifies placement after Plan creation'
need_text skills/writing-plans-on-canvas/SKILL.md 'just-created' 'planning limits folder correction to the new Plan'
need_text skills/writing-plans-on-canvas/SKILL.md 'use `trace`' 'planning uses trace before task authoring'
need_text skills/writing-plans-on-canvas/SKILL.md 'upstream and downstream' 'planning traces both directions of Spec impact'
need_text skills/writing-plans-on-canvas/SKILL.md 'Plan self-review' 'planning performs a self-review before approval'
for term in placeholder 'path and interface' 'task size'; do
    need_text skills/writing-plans-on-canvas/SKILL.md "$term" "planning self-review covers $term"
done
for term in list_plans plans Source-Specs; do
    need_text skills/executing-plans-on-canvas/SKILL.md "$term" "executor discovers implementation plans with $term"
done
need_text skills/executing-plans-on-canvas/SKILL.md 'persistent active Plan' 'executor keeps no persistent active plan pointer'
need_text skills/executing-plans-on-canvas/SKILL.md 'exactly one' 'executor runs exactly one ready task'
need_text skills/executing-plans-on-canvas/SKILL.md 'Refuse to execute' 'executor rejects tasks outside a valid implementation Plan'
need_text skills/executing-plans-on-canvas/SKILL.md 'Re-read every named source Spec' 'executor refreshes source Specs before task selection'
need_text skills/executing-plans-on-canvas/SKILL.md 'opaque revision' 'executor uses product revision metadata when available'
need_text skills/executing-plans-on-canvas/SKILL.md 'compatibility fallback' 'executor defines a pre-revision fallback'
need_text skills/executing-plans-on-canvas/SKILL.md 'material drift' 'executor stops stale task execution'
for term in test-driven-development systematic-debugging verification-before-completion; do
    need_text skills/executing-plans-on-canvas/SKILL.md "$term" "executor routes through $term"
    need_text README.md "$term" "README lists $term"
done
for term in requesting-code-review receiving-code-review using-git-worktrees finishing-a-development-branch; do
    need_text skills/executing-plans-on-canvas/SKILL.md "$term" "executor routes through $term"
    need_text README.md "$term" "README lists $term"
done
for term in subagent-driven-development dispatching-parallel-agents; do
    need_text skills/executing-plans-on-canvas/SKILL.md "$term" "executor routes through $term"
    need_text README.md "$term" "README lists $term"
done
need_text skills/executing-plans-on-canvas/SKILL.md 'Plan.*coordination ledger' 'executor uses the Plan as the coordination ledger'
need_text skills/executing-plans-on-canvas/SKILL.md 'conflict scan' 'executor requires a pre-dispatch conflict scan'
for term in dependency 'owned paths' interfaces configuration migrations; do
    need_text skills/dispatching-parallel-agents/SKILL.md "$term" "parallel conflict scan covers $term"
done
need_text skills/executing-plans-on-canvas/SKILL.md '[Rr]eturned.*Spec compliance.*before.*code quality' 'executor reviews returned work in stage order'
need_text skills/executing-plans-on-canvas/SKILL.md '[Rr]esume.*Plan state' 'executor resumes orchestration from canvas state'
need_text skills/executing-plans-on-canvas/SKILL.md '[Rr]eversible.*ruling' 'executor continues through reversible ambiguity with a ruling'
need_text skills/executing-plans-on-canvas/SKILL.md 'Spec-compliance review.*before.*code-quality review' 'executor orders Spec review before quality review'
for ledger in 'review-spec-<task-slug>' 'review-quality-<task-slug>' review-branch; do
    need_text skills/executing-plans-on-canvas/SKILL.md "$ledger" "executor records $ledger"
done
need_text skills/executing-plans-on-canvas/SKILL.md '[Ii]mplementation approval.*not.*Git.*authority' 'executor preserves explicit Git authority'
need_text skills/executing-plans-on-canvas/SKILL.md 'branch-wide review' 'executor requires final branch-wide review'
need_text skills/executing-plans-on-canvas/SKILL.md 'evidence-<task-slug>' 'executor records one idempotent evidence ledger entry'
need_text skills/executing-plans-on-canvas/SKILL.md 'ruling-<task-slug>' 'executor records safe reversible rulings'
need_text skills/executing-plans-on-canvas/SKILL.md 'destructive or irreversible' 'executor narrows blocking to high-risk or external conditions'
need_text README.md 'Spec never contains executable `task` nodes' 'README states the Spec content guard'
need_text README.md 'upstream and downstream' 'README explains Spec impact tracing'
need_text README.md 'Plan self-review' 'README explains pre-approval Plan review'
need_text README.md 'source Spec drift' 'README explains pre-execution drift protection'

need_file references/skill-evals.md
need_text README.md 'writing-skills' 'README lists writing-skills'
need_text skills/writing-skills/SKILL.md '[Bb]ehavior baseline' 'writing-skills requires a behavior baseline'
need_text skills/writing-skills/SKILL.md '[Ee]xisting.*skill' 'writing-skills extends an existing owner first'
need_text skills/writing-skills/SKILL.md 'quick_validate.py' 'writing-skills requires structural validation'
need_text skills/writing-skills/SKILL.md 'behavior scenarios' 'writing-skills requires conformance scenarios'
need_text skills/writing-skills/SKILL.md '[Aa]uthority' 'writing-skills preserves authority boundaries'
scenario_count=$(grep -Ec '^\| [1-7] \|' references/skill-evals.md 2>/dev/null || true)
if [ "$scenario_count" -eq 7 ]; then
    ok "skill eval reference defines seven core scenarios"
else
    err "skill eval reference must define seven core scenarios; found $scenario_count"
fi
if grep -Eq '\[(TODO|TBD):|(^|[^A-Za-z])(TODO|TBD)([^A-Za-z]|$)' skills/writing-skills/SKILL.md references/skill-evals.md; then
    err "skill authoring files contain unfinished placeholders"
else
    ok "skill authoring files contain no unfinished placeholders"
fi

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
