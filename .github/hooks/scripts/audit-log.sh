#!/bin/bash
# audit-log.sh
# Copilot postToolUse hook for audit logging
#
# Logs tool executions with timestamp for compliance and debugging.

# Read the tool context from stdin
INPUT=$(cat)

# Create log directory if it doesn't exist
LOG_DIR=".github/hooks"
LOG_FILE="$LOG_DIR/audit.log"

# Extract tool information using jq or python3 fallback
if command -v jq >/dev/null 2>&1; then
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool // empty')
elif command -v python3 >/dev/null 2>&1; then
    TOOL_NAME=$(echo "$INPUT" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("tool",""))' 2>/dev/null)
else
    TOOL_NAME=""
fi

TIMESTAMP=$(date -Iseconds)

# Log the execution
echo "[$TIMESTAMP] Tool executed: ${TOOL_NAME:-unknown}" >> "$LOG_FILE"

# Always exit successfully - this is just logging
exit 0
