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

# Extract tool information (adjust based on actual JSON structure)
TOOL_NAME=$(echo "$INPUT" | grep -o '"tool"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"//' | sed 's/"$//')
TIMESTAMP=$(date -Iseconds)

# Log the execution
echo "[$TIMESTAMP] Tool executed: ${TOOL_NAME:-unknown}" >> "$LOG_FILE"

# Always exit successfully - this is just logging
exit 0
