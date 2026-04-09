#!/bin/bash
# Block debug/exploratory scripts from being written to tests/.
# These must go in claude_test/ per CLAUDE.md Section 2.
set -euo pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [[ -z "$file_path" ]]; then
    exit 0
fi

# Check if writing to tests/ with debug-like names
if [[ "$file_path" == */tests/* ]] \
    || [[ "$file_path" == tests/* ]]; then
    basename=$(basename "$file_path")
    if [[ "$basename" == debug_* ]] \
        || [[ "$basename" == test_debug_* ]] \
        || [[ "$basename" == scratch_* ]] \
        || [[ "$basename" == tmp_* ]] \
        || [[ "$basename" == experiment_* ]]; then
        cat >&2 <<'ERRMSG'
BLOCKED: Debug/exploratory scripts must go in claude_test/, not tests/.
tests/ is reserved for production-quality CI/CD tests.
Please write this file to claude_test/ instead, and update claude_test/README.md.
ERRMSG
        exit 2
    fi
fi

exit 0
