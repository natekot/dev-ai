#!/bin/bash
# format-file.sh
# Claude Code PostToolUse hook to auto-format written files
#
# Environment variables available:
#   TOOL_NAME       - Name of the tool (Write)
#   TOOL_INPUT_PATH - Path of the file that was written
#
# This hook runs after a file is written and formats it based on extension.

FILE_PATH="${TOOL_INPUT_PATH:-}"

# Exit if no file path provided
if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"

# Format based on extension (silently fail if formatter not installed)
case "$EXT" in
    js|jsx|ts|tsx|json|css|scss|md|html)
        if command -v prettier &> /dev/null; then
            prettier --write "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
    py)
        if command -v black &> /dev/null; then
            black --quiet "$FILE_PATH" 2>/dev/null || true
        elif command -v autopep8 &> /dev/null; then
            autopep8 --in-place "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
    go)
        if command -v gofmt &> /dev/null; then
            gofmt -w "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
    rs)
        if command -v rustfmt &> /dev/null; then
            rustfmt "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
esac

# Always succeed - formatting is optional
exit 0
