#!/bin/bash
# validate-command.sh
# Copilot preToolUse hook to block dangerous commands
#
# This script receives tool context via stdin as JSON.
# Exit 0 to allow, exit 1 to block.

# Read the tool input from stdin
INPUT=$(cat)

# Extract the command being executed using jq or python3 fallback
if command -v jq >/dev/null 2>&1; then
    COMMAND=$(echo "$INPUT" | jq -r '.command // empty')
elif command -v python3 >/dev/null 2>&1; then
    COMMAND=$(echo "$INPUT" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("command",""))' 2>/dev/null)
else
    # Last resort: allow the command rather than block everything
    exit 0
fi

# Define blocked patterns
BLOCKED_PATTERNS=(
    "rm -rf /"
    "rm -rf ~"
    "sudo rm"
    "chmod 777"
    "git push --force"
    "git reset --hard"
    "> /dev/sda"
    "mkfs"
    "dd if="
)

# Check if command matches any blocked pattern
for pattern in "${BLOCKED_PATTERNS[@]}"; do
    if [[ "$COMMAND" == *"$pattern"* ]]; then
        echo "BLOCKED: Command matches dangerous pattern: $pattern" >&2
        exit 1
    fi
done

# Allow the command
exit 0
