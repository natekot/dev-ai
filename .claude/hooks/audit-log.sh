#!/bin/bash
# audit-log.sh
# Claude Code PostToolUse hook for audit logging
#
# Environment variables available:
#   TOOL_NAME  - Name of the tool executed
#   TOOL_INPUT - The input provided to the tool
#
# Logs all tool executions with timestamp.

LOG_FILE=".claude/hooks/audit.log"
TIMESTAMP=$(date -Iseconds)

# Create log entry
TOOL="${TOOL_NAME:-unknown}"
echo "[$TIMESTAMP] Tool: $TOOL" >> "$LOG_FILE"

# Always succeed
exit 0
