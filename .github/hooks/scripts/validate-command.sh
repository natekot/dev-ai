#!/bin/bash
# validate-command.sh
# Copilot preToolUse hook to block dangerous commands
#
# Input (stdin JSON): { "toolName": "bash", "toolArgs": "{\"command\":\"...\"}", ... }
# Exit 0 to allow, exit 1 to block.
# Stdout JSON with permissionDecision/permissionDecisionReason to deny.

# Read the tool input from stdin
INPUT=$(cat)

# Extract the command from toolArgs using jq or python3 fallback
if command -v jq >/dev/null 2>&1; then
    COMMAND=$(echo "$INPUT" | jq -r '.toolArgs | fromjson | .command // empty' 2>/dev/null)
elif command -v python3 >/dev/null 2>&1; then
    COMMAND=$(echo "$INPUT" | python3 -c '
import sys, json
d = json.load(sys.stdin)
args = json.loads(d.get("toolArgs", "{}"))
print(args.get("command", ""))
' 2>/dev/null)
else
    # No JSON parser available — allow rather than block everything
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
        echo "{\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"Blocked dangerous pattern: $pattern\"}"
        exit 0
    fi
done

# Allow the command
exit 0
