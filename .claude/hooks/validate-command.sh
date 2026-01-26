#!/bin/bash
# validate-command.sh
# Claude Code PreToolUse hook to block dangerous commands
#
# Environment variables available:
#   TOOL_NAME    - Name of the tool being called
#   TOOL_INPUT   - The input/command being executed
#
# Exit 0 to allow, exit non-zero to block.

# Get the command from environment or stdin
COMMAND="${TOOL_INPUT:-$(cat)}"

# Define blocked patterns
BLOCKED_PATTERNS=(
    "rm -rf /"
    "rm -rf ~"
    "rm -rf \$HOME"
    "sudo rm -rf"
    "chmod 777"
    "git push --force origin main"
    "git push --force origin master"
    "git reset --hard"
    "> /dev/sda"
    "mkfs"
    ":(){ :|:& };:"
)

# Check if command matches any blocked pattern
for pattern in "${BLOCKED_PATTERNS[@]}"; do
    if [[ "$COMMAND" == *"$pattern"* ]]; then
        echo "BLOCKED: Command matches dangerous pattern: $pattern" >&2
        exit 1
    fi
done

# Additional check: block commands that delete more than expected
if [[ "$COMMAND" =~ rm.*-rf.*\.\. ]]; then
    echo "BLOCKED: Cannot delete parent directories" >&2
    exit 1
fi

# Allow the command
exit 0
