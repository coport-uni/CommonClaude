#!/bin/bash
# Remind to update claude_test/README.md when adding
# files to claude_test/. Per CLAUDE.md Section 2.
set -euo pipefail

input=$(cat)
file_path=$(
    echo "$input" \
        | jq -r '.tool_input.file_path // empty'
)

if [[ -z "$file_path" ]]; then
    exit 0
fi

# Check if writing to claude_test/ (not README itself)
if [[ "$file_path" == */claude_test/* ]] \
    || [[ "$file_path" == claude_test/* ]]; then
    basename=$(basename "$file_path")
    if [[ "$basename" != "README.md" ]]; then
        cat >&2 <<'MSG'
REMINDER: You added a file to claude_test/.
Per CLAUDE.md Section 2, update claude_test/README.md
with a row describing what this file does.
MSG
        exit 2
    fi
fi

exit 0
