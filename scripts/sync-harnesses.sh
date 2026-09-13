#!/bin/sh
# Check that every harness manifest still agrees about what this plugin is.
#
# It compares rather than regenerates. A manifest quietly rewritten under you is
# worse than one that stops the build and says which field drifted, because the
# rewrite is the thing you were trying to notice.
#
# POSIX shell and grep only. No jq: a packaging check that needs a package
# manager to run is one more thing to install before you can tell whether
# anything is wrong.

set -u

CANON=.claude-plugin/plugin.json

if [ ! -f "$CANON" ]; then
    echo "FAIL  $CANON is the source of truth and does not exist" >&2
    exit 1
fi

# First occurrence of a top-level string field.
field() {
    sed -n "s/.*\"$1\": *\"\\(.*\\)\".*/\\1/p" "$2" | head -1
}

name=$(field name "$CANON")
version=$(field version "$CANON")
description=$(field description "$CANON")

if [ -z "$name" ] || [ -z "$version" ] || [ -z "$description" ]; then
    echo "FAIL  $CANON is missing name, version or description" >&2
    exit 1
fi

echo "canonical: $name $version"

fail=0

# expect <file> <field> <value>
expect() {
    file=$1
    key=$2
    value=$3
    [ -f "$file" ] || { echo "FAIL  missing manifest: $file" >&2; fail=1; return; }
    if grep -Fq "\"$key\": \"$value\"" "$file"; then
        printf 'ok    %s %s\n' "$file" "$key"
    else
        printf 'FAIL  %s drifted\n' "$file" >&2
        printf '        expected  "%s": "%s"\n' "$key" "$value" >&2
        printf '        found     %s\n' "$(grep -F "\"$key\":" "$file" | head -1 | sed 's/^ *//')" >&2
        fail=1
    fi
}

for manifest in \
    .claude-plugin/marketplace.json \
    .codex-plugin/plugin.json \
    .kimi-plugin/plugin.json \
    .cursor-plugin/plugin.json
do
    expect "$manifest" name "$name"
    expect "$manifest" version "$version"
    expect "$manifest" description "$description"
done

# The cross-agent marketplace carries identity but no version or description.
expect .agents/plugins/marketplace.json name "$name"

echo
if [ "$fail" -eq 0 ]; then
    echo "every manifest agrees"
else
    echo "manifests have drifted"
fi
exit "$fail"
