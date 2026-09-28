#!/bin/bash
# Block reads of credential files (.env, .key, .pem).
# Per CLAUDE.md umbrella issue #13 Task 7 (detail: #15).
set -euo pipefail

input=$(cat)
file_path=$(
    echo "$input" \
        | jq -r '.tool_input.file_path // empty'
)

# Claude Code on Windows passes backslash paths; the checks below
# expect forward slashes.
file_path="${file_path//\\//}"

if [[ -z "$file_path" ]]; then
    exit 0
fi

basename=$(basename "$file_path")

if [[ "$basename" == ".env" ]] \
    || [[ "$basename" == .env.* ]] \
    || [[ "$basename" == *.env ]] \
    || [[ "$basename" == *.key ]] \
    || [[ "$basename" == *.pem ]]; then
    cat >&2 <<ERRMSG
BLOCKED: Read of credential file is not permitted:
$file_path
These files typically hold secrets and must not enter
model context. Disable this hook intentionally rather
than bypassing it inline.
ERRMSG
    exit 2
fi

exit 0
