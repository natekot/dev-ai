#!/bin/bash
# validate-command.sh
# Copilot preToolUse hook to block dangerous commands
#
# This script receives tool context via stdin as JSON.
# Exit 0 to allow, exit 1 to block.

# Read the tool input from stdin
INPUT=$(cat)

# Extract the command being executed (adjust based on actual JSON structure)
COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"//' | sed 's/"$//')

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
