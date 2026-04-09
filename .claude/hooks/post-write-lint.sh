#!/bin/bash
# Run ruff check and ruff format --check on Python files
# after every Write/Edit. Feeds errors back to Claude.
set -euo pipefail

input=$(cat)
file_path=$(
    echo "$input" \
        | jq -r '.tool_input.file_path // empty'
)

# Skip non-Python files
if [[ -z "$file_path" ]] \
    || [[ "$file_path" != *.py ]]; then
    exit 0
fi

# Skip if file was deleted
if [[ ! -f "$file_path" ]]; then
    exit 0
fi

# Graceful exit if ruff is not installed
if ! command -v ruff &>/dev/null; then
    echo "WARNING: ruff is not installed." >&2
    echo "Install with: pip install ruff" >&2
    exit 0
fi

errors=""

check_output=$(ruff check "$file_path" 2>&1) || {
    errors="ruff check errors:\n$check_output\n"
}

format_output=$(ruff format --check "$file_path" 2>&1) || {
    errors="${errors}ruff format errors:\n$format_output\n"
}

if [[ -n "$errors" ]]; then
    printf "Ruff violations in %s:\n%b\n" \
        "$file_path" "$errors" >&2
    echo "Fix these before committing." >&2
    exit 2
fi

exit 0
